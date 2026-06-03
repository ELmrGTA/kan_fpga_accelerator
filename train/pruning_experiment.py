"""
KAN [5,16,8,1] 剪枝实验
测试不同 edge_th 下的剪枝效果：边数、节点数、精度变化
流程：训练 → 剪枝 → 微调 → 评估
"""
import sys, os, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'dataset'))
# pykan should be in PYTHONPATH or installed via pip

import torch
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from kan import KAN
from data_loader import load_airfoil

SEED = 42
torch.manual_seed(SEED); np.random.seed(SEED)

data = load_airfoil()
dataset = {
    'train_input': data['train_input'],
    'train_label': data['train_label'],
    'test_input':  data['test_input'],
    'test_label':  data['test_label'],
}
y_true = data['test_label'].numpy().ravel()

def eval_r2(model):
    model.eval()
    with torch.no_grad():
        y_pred = model(data['test_input']).numpy().ravel()
    return 1 - np.sum((y_true-y_pred)**2)/np.sum((y_true-y_true.mean())**2)

def count_active_edges(model):
    """统计激活幅度 > 0 的边数"""
    total = 0
    try:
        for acts in model.acts_scale:
            total += int((acts > 1e-6).sum().item())
    except:
        pass
    return total

def count_edges_from_mask(model):
    """通过 mask 统计剩余边数"""
    total = 0
    try:
        for layer in model.act_fun:
            if hasattr(layer, 'mask'):
                total += int(layer.mask.sum().item())
    except:
        pass
    return total

# ── 训练基础模型 ──────────────────────────────────────────────────
print("=" * 60)
print("训练基础模型 KAN [5,16,8,1] ...")
print("=" * 60)
base_model = KAN(width=[5,16,8,1], grid=3, k=3, seed=SEED)
base_model.fit(dataset, opt='Adam',  lr=1e-2, steps=500, log=500, lamb=1e-4, lamb_entropy=2)
base_model.fit(dataset, opt='LBFGS', lr=1.0,  steps=200, log=200, lamb=1e-5, lamb_entropy=0.5)

r2_base = eval_r2(base_model)
# 总边数：5*16 + 16*8 + 8*1 = 216
total_edges = 5*16 + 16*8 + 8*1
print(f"\n基础模型: R2={r2_base:.4f}, 总边数={total_edges}")

# ── 剪枝实验 ──────────────────────────────────────────────────────
EDGE_TH_LIST  = [0.01, 0.03, 0.05, 0.10, 0.20]
FINETUNE_STEPS = 100

results = []
print(f"\n{'edge_th':<10} {'剩余边':>8} {'剪枝率':>8} {'剪枝后R2':>10} {'微调后R2':>10}")
print("-" * 55)

for eth in EDGE_TH_LIST:
    torch.manual_seed(SEED)
    # 重新加载基础模型权重（深拷贝）
    model = KAN(width=[5,16,8,1], grid=3, k=3, seed=SEED)
    model.load_state_dict(base_model.state_dict())

    # 先 forward 一次让 acts_scale 有值
    model.eval()
    with torch.no_grad():
        _ = model(data['train_input'])

    # 剪枝
    model = model.prune(node_th=0.01, edge_th=eth)

    # 剪枝后精度
    r2_pruned = eval_r2(model)

    # 统计剩余边数
    remaining = count_edges_from_mask(model)
    if remaining == 0:
        remaining = count_active_edges(model)

    prune_rate = (1 - remaining / total_edges) * 100

    # 微调
    model.fit(dataset, opt='LBFGS', lr=0.5, steps=FINETUNE_STEPS, log=FINETUNE_STEPS+1,
              lamb=1e-5, lamb_entropy=0.1)
    r2_finetuned = eval_r2(model)

    results.append({
        'edge_th': eth,
        'remaining': remaining,
        'prune_rate': prune_rate,
        'r2_pruned': r2_pruned,
        'r2_finetuned': r2_finetuned,
        'r2_drop': r2_base - r2_finetuned,
    })
    print(f"{eth:<10} {remaining:>8} {prune_rate:>7.1f}% {r2_pruned:>10.4f} {r2_finetuned:>10.4f}")

# ── 汇总表 ────────────────────────────────────────────────────────
print("\n" + "=" * 70)
print(f"基础模型: R2={r2_base:.4f}, 总边数={total_edges}")
print("=" * 70)
print(f"{'edge_th':<10} {'剩余边':>6} {'剪枝率':>8} {'剪枝后R2':>10} {'微调后R2':>10} {'R2损失':>8}")
print("-" * 70)
for r in results:
    print(f"{r['edge_th']:<10} {r['remaining']:>6} {r['prune_rate']:>7.1f}% "
          f"{r['r2_pruned']:>10.4f} {r['r2_finetuned']:>10.4f} {r['r2_drop']:>+8.4f}")
print("=" * 70)

# ── 可视化 ────────────────────────────────────────────────────────
fig, axes = plt.subplots(1, 2, figsize=(11, 4), facecolor='white')

eth_vals    = [r['edge_th']    for r in results]
remaining   = [r['remaining']  for r in results]
r2_pruned   = [r['r2_pruned']  for r in results]
r2_finetuned= [r['r2_finetuned'] for r in results]

# 左图：剩余边数 vs edge_th
ax = axes[0]
ax.plot(eth_vals, remaining, 'o-', color='#1E88E5', linewidth=2, markersize=7, label='Remaining edges')
ax.axhline(total_edges, color='#BDBDBD', linestyle='--', linewidth=1.5, label=f'Original ({total_edges})')
ax.set_xlabel('edge_th (pruning threshold)', fontsize=10)
ax.set_ylabel('Remaining edge count', fontsize=10)
ax.set_title('Pruning Rate vs Threshold', fontsize=11)
ax.legend(fontsize=9); ax.grid(True, alpha=0.3); ax.set_facecolor('white')
for x, y in zip(eth_vals, remaining):
    ax.annotate(f'{y}', (x, y), textcoords='offset points', xytext=(0, 8),
                ha='center', fontsize=9)

# 右图：R2 vs edge_th
ax = axes[1]
ax.axhline(r2_base, color='#BDBDBD', linestyle='--', linewidth=1.5, label=f'Baseline R²={r2_base:.4f}')
ax.plot(eth_vals, r2_pruned,    's--', color='#FF5722', linewidth=1.5, markersize=7, label='After pruning')
ax.plot(eth_vals, r2_finetuned, 'o-',  color='#4CAF50', linewidth=2,   markersize=7, label='After fine-tuning')
ax.set_xlabel('edge_th (pruning threshold)', fontsize=10)
ax.set_ylabel('R²', fontsize=10)
ax.set_title('R² vs Pruning Threshold', fontsize=11)
ax.legend(fontsize=9); ax.grid(True, alpha=0.3); ax.set_facecolor('white')
ax.set_ylim(max(0, min(r2_pruned)-0.05), 1.0)

plt.tight_layout()
out_path = os.path.join(os.path.dirname(__file__), 'pruning_results.png')
plt.savefig(out_path, dpi=150, bbox_inches='tight', facecolor='white')
plt.close()
print(f"\n图已保存: pruning_results.png")
