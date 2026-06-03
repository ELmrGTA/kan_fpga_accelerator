"""
Airfoil KAN 特征函数类型提取与可视化
用 suggest_symbolic 逐边分析第一层各边的函数类型
用法：python feature_function_analysis.py [5,16,8,1]
      python feature_function_analysis.py [5,16,8,1] --log   # 使用log变换特征
"""
import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'dataset'))
# pykan should be in PYTHONPATH or installed via pip

import ast
import json
import torch
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
matplotlib.rcParams['font.family'] = ['SimHei', 'Microsoft YaHei', 'DejaVu Sans']
matplotlib.rcParams['axes.unicode_minus'] = False
from collections import defaultdict
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from kan import KAN
from kan.utils import add_symbolic
from data_loader import load_airfoil

SEED = 42
torch.manual_seed(SEED)
np.random.seed(SEED)

# 从命令行读取网络结构和模式
USE_LOG = '--log' in sys.argv
USE_LOG_RAW = '--log-raw' in sys.argv  # log变换但不归一化
FORCE_RETRAIN = '--retrain' in sys.argv  # 强制重新训练
args = [a for a in sys.argv[1:] if not a.startswith('--')]
if args:
    WIDTH = ast.literal_eval(args[0])
else:
    WIDTH = [5, 16, 8, 1]

N_IN  = WIDTH[0]
N_HID = WIDTH[1]

TAG = '_'.join(map(str, WIDTH)) + ('_log_raw' if USE_LOG_RAW else '_log' if USE_LOG else '')

FEATURE_NAMES = ['频率\n($x_1$)', '攻角\n($x_2$)', '弦长\n($x_3$)', '速度\n($x_4$)', '厚度\n($x_5$)']
FEATURE_EN    = ['Frequency', 'Angle', 'Chord', 'Velocity', 'Thickness']
LOG_NAMES     = ['log(频率)\n($x_1$)', '攻角\n($x_2$)', 'log(弦长)\n($x_3$)', 'log(速度)\n($x_4$)', 'log(厚度)\n($x_5$)']
LOG_EN        = ['log(freq)', 'Angle', 'log(chord)', 'log(vel)', 'log(thick)']

add_symbolic('|x|^5', lambda x: torch.abs(x)**5 * torch.sign(x), c=4)
add_symbolic('|x|^3', lambda x: torch.abs(x)**3 * torch.sign(x), c=3)

LIB = ['x', 'x^2', 'x^3', 'x^4', 'x^5', '|x|^3', '|x|^5',
       'sqrt', 'exp', 'log', 'sin', 'cos', 'tanh', 'abs']

# ── 数据集准备 ────────────────────────────────────────────────────
if USE_LOG or USE_LOG_RAW:
    print(f"使用 log 变换特征{'（不归一化）' if USE_LOG_RAW else '（+StandardScaler）'}...")
    data_path = os.path.join(os.path.dirname(__file__), '..', 'dataset', 'data', 'airfoil_self_noise.dat')
    df = pd.read_csv(data_path, sep='\t', header=None,
                     names=['frequency','angle','chord','velocity','thickness','spl'])
    X_raw = df[['frequency','angle','chord','velocity','thickness']].values.astype(np.float32)
    y_raw = df['spl'].values.astype(np.float32)

    X_trans = X_raw.copy()
    X_trans[:, 0] = np.log(X_raw[:, 0])  # log(freq)
    X_trans[:, 2] = np.log(X_raw[:, 2])  # log(chord)
    X_trans[:, 3] = np.log(X_raw[:, 3])  # log(vel)
    X_trans[:, 4] = np.log(X_raw[:, 4])  # log(thick)

    x_tr, x_te, y_tr, y_te = train_test_split(X_trans, y_raw, test_size=0.2, random_state=SEED)

    if USE_LOG_RAW:
        x_tr = x_tr.astype(np.float32)
        x_te = x_te.astype(np.float32)
        y_tr = y_tr.astype(np.float32)
        y_te = y_te.astype(np.float32)
    else:
        scaler_x = StandardScaler()
        scaler_y = StandardScaler()
        x_tr = scaler_x.fit_transform(x_tr).astype(np.float32)
        x_te = scaler_x.transform(x_te).astype(np.float32)
        y_tr = scaler_y.fit_transform(y_tr.reshape(-1,1)).ravel().astype(np.float32)
        y_te = scaler_y.transform(y_te.reshape(-1,1)).ravel().astype(np.float32)

    dataset = {
        'train_input': torch.tensor(x_tr),
        'train_label': torch.tensor(y_tr).unsqueeze(1),
        'test_input':  torch.tensor(x_te),
        'test_label':  torch.tensor(y_te).unsqueeze(1),
    }
    y_true = y_te
    FEAT_NAMES_PLOT = LOG_NAMES
    FEAT_EN_PLOT    = LOG_EN
else:
    data = load_airfoil()
    dataset = {
        'train_input': data['train_input'],
        'train_label': data['train_label'],
        'test_input':  data['test_input'],
        'test_label':  data['test_label'],
    }
    y_true = data['test_label'].numpy().ravel()
    FEAT_NAMES_PLOT = FEATURE_NAMES
    FEAT_EN_PLOT    = FEATURE_EN

# ── 训练 ──────────────────────────────────────────────────────────
CACHE_FILE = os.path.join(os.path.dirname(__file__), f'feature_function_cache_{TAG}.json')

if not FORCE_RETRAIN and os.path.exists(CACHE_FILE):
    print(f"加载缓存结果: {CACHE_FILE}")
    with open(CACHE_FILE, 'r', encoding='utf-8') as f:
        cache = json.load(f)
    best_func = {(int(k.split(',')[0]), int(k.split(',')[1])): v for k, v in cache['best_func'].items()}
    best_r2   = {(int(k.split(',')[0]), int(k.split(',')[1])): v for k, v in cache['best_r2'].items()}
    n_in, n_hid = cache['n_in'], cache['n_hid']
else:
    print(f"训练 KAN {WIDTH} ...")
    model = KAN(width=WIDTH, grid=3, k=3, seed=SEED)
    model.fit(dataset, opt='Adam',  lr=1e-2, steps=500, log=500, lamb=1e-4, lamb_entropy=2)
    model.fit(dataset, opt='LBFGS', lr=1.0,  steps=200, log=200, lamb=1e-5, lamb_entropy=0.5)

    model.eval()
    with torch.no_grad():
        y_pred = model(dataset['test_input']).numpy().ravel()
    rmse = np.sqrt(np.mean((y_true - y_pred)**2))
    r2   = 1 - np.sum((y_true - y_pred)**2) / np.sum((y_true - y_true.mean())**2)
    print(f"训练完成: RMSE={rmse:.4f}  R2={r2:.4f}\n")

    # ── 逐边提取函数类型 ──────────────────────────────────────────────
    n_in, n_hid = N_IN, N_HID
    print(">>> 逐边分析函数类型 ...")

    best_func = {}
    best_r2   = {}

    for i in range(n_in):
        for j in range(n_hid):
            name, _, r2v, _ = model.suggest_symbolic(0, i, j, lib=LIB, verbose=False)
            best_func[(i,j)] = name
            best_r2[(i,j)]   = r2v

    # 保存缓存
    cache = {
        'n_in': n_in, 'n_hid': n_hid,
        'best_func': {f'{k[0]},{k[1]}': v for k, v in best_func.items()},
        'best_r2':   {f'{k[0]},{k[1]}': v for k, v in best_r2.items()},
    }
    with open(CACHE_FILE, 'w', encoding='utf-8') as f:
        json.dump(cache, f, ensure_ascii=False, indent=2)
    print(f"结果已缓存: {CACHE_FILE}")

# ── 汇总打印 ──────────────────────────────────────────────────────
print(f"\n{'特征':<20} {'函数分布':<40} {'平均r2':>8}")
print("-"*70)
for i, fname in enumerate(FEAT_EN_PLOT):
    funcs = [best_func[(i,j)] for j in range(n_hid)]
    r2s   = [best_r2[(i,j)]   for j in range(n_hid)]
    cnt   = defaultdict(int)
    for f in funcs: cnt[f] += 1
    dist  = ', '.join(f"{f}×{c}" for f, c in sorted(cnt.items(), key=lambda x: -x[1]))
    print(f"{fname:<20} {dist:<40} {np.mean(r2s):>8.4f}")

print("\n详细（第一层每条边）：")
for i, fname in enumerate(FEAT_EN_PLOT):
    row = '  '.join(f"h{j+1}:{best_func[(i,j)]}({best_r2[(i,j)]:.2f})" for j in range(n_hid))
    print(f"  {fname}: {row}")

# ── 可视化 ────────────────────────────────────────────────────────
FUNC_COLOR = {
    'sin':'#E53935', 'cos':'#E53935',
    'exp':'#1565C0', 'log':'#1E88E5',
    'x^5':'#FF6F00', 'x^4':'#FFA000', 'x^3':'#FFB300', '|x|^5':'#FF6F00', '|x|^3':'#FFB300',
    'x^2':'#FDD835', 'x':'#78909C',
    'tanh':'#7B1FA2', 'abs':'#AB47BC',
    'sqrt':'#2E7D32', '0':'#BDBDBD',
}

out_dir = os.path.dirname(__file__)
fig, axes = plt.subplots(1, 2, figsize=(13, 5), facecolor='white')

# 左图：r² 热力图，格子内标函数名
r2_mat = np.array([[best_r2[(i,j)] for j in range(n_hid)] for i in range(n_in)])
im = axes[0].imshow(r2_mat, cmap='RdYlGn', vmin=0, vmax=1, aspect='auto')
axes[0].set_xticks(range(n_hid))
axes[0].set_xticklabels([f'h{j+1}' for j in range(n_hid)], fontsize=9)
axes[0].set_yticks(range(n_in))
axes[0].set_yticklabels(FEAT_NAMES_PLOT, fontsize=10)
axes[0].set_title('各边符号拟合质量（$r^2$）', fontsize=11)
plt.colorbar(im, ax=axes[0], fraction=0.046)
for i in range(n_in):
    for j in range(n_hid):
        txt_color = 'white' if r2_mat[i,j] > 0.55 else 'black'
        axes[0].text(j, i, best_func[(i,j)], ha='center', va='center',
                     fontsize=7.5, color=txt_color, fontweight='bold')

# 右图：每个特征的函数类型堆叠条形图
all_funcs = sorted(set(best_func.values()))
bottom = np.zeros(n_in)
for func in all_funcs:
    counts = np.array([sum(best_func[(i,j)] == func for j in range(n_hid)) for i in range(n_in)], dtype=float)
    if counts.sum() == 0:
        continue
    color = FUNC_COLOR.get(func, '#BDBDBD')
    bars = axes[1].barh(range(n_in), counts, left=bottom, color=color,
                        label=func, height=0.55, edgecolor='white', linewidth=0.5)
    # 在条形内标注函数名（仅当宽度足够时）
    for idx, (cnt, bot) in enumerate(zip(counts, bottom)):
        if cnt >= 1:
            axes[1].text(bot + cnt/2, idx, func, ha='center', va='center',
                         fontsize=8, color='white', fontweight='bold')
    bottom += counts

axes[1].set_yticks(range(n_in))
axes[1].set_yticklabels(FEAT_NAMES_PLOT, fontsize=10)
axes[1].set_xlabel('边数', fontsize=10)
axes[1].set_title('各特征函数类型分布', fontsize=11)
axes[1].set_xlim(0, n_hid)
axes[1].set_facecolor('white')
axes[1].invert_yaxis()  # 与左图热力图方向一致（x1在顶部）
axes[1].legend(loc='lower right', fontsize=8, ncol=2, framealpha=0.8)

plt.tight_layout()
out_path = os.path.join(out_dir, f'feature_function_types_{TAG}.png')
plt.savefig(out_path, dpi=300, bbox_inches='tight', facecolor='white')
plt.close()
print(f"\n图已保存: feature_function_types_{TAG}.png")

# ── 可视化2：每个特征的样条曲线（仅训练模式可用，缓存模式跳过）──────
if 'model' not in dir():
    print("缓存模式：跳过样条曲线图（需要 --retrain 才能生成）")
    sys.exit(0)

fig, axes = plt.subplots(1, n_in, figsize=(15, 3.5), facecolor='white')
x_sweep = torch.linspace(-2.5, 2.5, 300)

for i, fname in enumerate(FEAT_NAMES_PLOT):
    ax = axes[i]
    x_in = torch.zeros(300, 5)
    x_in[:, i] = x_sweep

    model.eval()
    with torch.no_grad():
        _ = model(x_in)
        if hasattr(model, 'spline_postacts') and len(model.spline_postacts) > 0:
            edge_vals = model.spline_postacts[0].numpy()
            # shape可能是[N, n_in, actual_hid]，用实际维度
            actual_hid = edge_vals.shape[2]
            for j in range(min(n_hid, actual_hid)):
                y_vals = edge_vals[:, i, j]
                func   = best_func[(i,j)]
                r2v    = best_r2[(i,j)]
                color  = FUNC_COLOR.get(func, '#BDBDBD')
                alpha  = 0.35 + 0.65 * min(r2v, 1.0)
                lw     = 1.0 + r2v
                ax.plot(x_sweep.numpy(), y_vals, color=color, alpha=alpha,
                        linewidth=lw, label=f'{func}({r2v:.2f})')
        else:
            ax.text(0.5, 0.5, 'N/A', transform=ax.transAxes, ha='center', va='center')

    ax.axhline(0, color='#CCCCCC', linewidth=0.8)
    ax.axvline(0, color='#CCCCCC', linewidth=0.8)
    ax.set_title(fname, fontsize=10)
    ax.set_xlabel('归一化输入值', fontsize=8)
    ax.set_facecolor('white')
    # 图例只显示 top-3 r²
    handles, labels = ax.get_legend_handles_labels()
    if handles:
        r2_vals = [best_r2[(i,j)] for j in range(n_hid)]
        top3_idx = [k for k in np.argsort(r2_vals)[-3:][::-1] if k < len(handles)]
        if top3_idx:
            ax.legend([handles[k] for k in top3_idx], [labels[k] for k in top3_idx],
                      fontsize=7, loc='best', framealpha=0.7)

plt.suptitle('KAN 第一层各边激活函数（颜色=函数类型，透明度=$r^2$）',
             fontsize=11, y=1.01)
plt.tight_layout()
out_path2 = os.path.join(out_dir, f'feature_activations_{TAG}.png')
plt.savefig(out_path2, dpi=300, bbox_inches='tight', facecolor='white')
plt.close()
print(f"图已保存: feature_activations_{TAG}.png")
print(f"图已保存: feature_activations.png")
