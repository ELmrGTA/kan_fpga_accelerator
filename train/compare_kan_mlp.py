"""
KAN vs MLP 对比实验
相同参数量，在 NASA Airfoil 数据集上对比 RMSE / MAE / R²
输出：控制台表格 + 训练曲线图
"""
import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'dataset'))

import time
import torch
import torch.nn as nn
import torch.optim as optim
import numpy as np
import matplotlib.pyplot as plt
import matplotlib
matplotlib.rcParams['font.family'] = ['SimHei', 'Microsoft YaHei', 'DejaVu Sans']
matplotlib.rcParams['axes.unicode_minus'] = False
from efficient_kan import KAN
from data_loader import load_airfoil

EPOCHS = 1000
LR     = 5e-3
SEED   = 42
DEVICE = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
torch.manual_seed(SEED)

dataset = load_airfoil()
x_train = dataset['train_input'].to(DEVICE)
y_train = dataset['train_label'].to(DEVICE)
x_test  = dataset['test_input'].to(DEVICE)
y_test  = dataset['test_label'].to(DEVICE)


class MLP(nn.Module):
    def __init__(self, layers, act='relu'):
        super().__init__()
        act_map = {'relu': nn.ReLU, 'gelu': nn.GELU, 'silu': nn.SiLU}
        act_fn = act_map[act]
        blocks = []
        for i in range(len(layers) - 1):
            blocks.append(nn.Linear(layers[i], layers[i+1]))
            if i < len(layers) - 2:
                blocks.append(act_fn())
        self.net = nn.Sequential(*blocks)

    def forward(self, x):
        return self.net(x)


def count_params(model):
    return sum(p.numel() for p in model.parameters())


def train_model(model, name):
    optimizer = optim.AdamW(model.parameters(), lr=LR, weight_decay=1e-4)
    scheduler = optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=EPOCHS, eta_min=1e-5)
    criterion = nn.MSELoss()

    train_losses, test_losses = [], []
    t0 = time.time()

    for epoch in range(EPOCHS):
        model.train()
        optimizer.zero_grad()
        loss = criterion(model(x_train), y_train)
        loss.backward()
        optimizer.step()
        scheduler.step()

        if (epoch + 1) % 10 == 0:
            model.eval()
            with torch.no_grad():
                tl = criterion(model(x_test), y_test).item()
            train_losses.append(loss.item())
            test_losses.append(tl)

        if (epoch + 1) % 200 == 0:
            print(f"  [{name}] Epoch {epoch+1:4d} | train={loss.item():.4f} | test={tl:.4f}")

    model.eval()
    with torch.no_grad():
        y_pred = model(x_test).cpu().numpy().ravel()
    y_true = y_test.cpu().numpy().ravel()

    rmse = np.sqrt(np.mean((y_true - y_pred) ** 2))
    mae  = np.mean(np.abs(y_true - y_pred))
    r2   = 1 - np.sum((y_true - y_pred) ** 2) / np.sum((y_true - y_true.mean()) ** 2)
    elapsed = time.time() - t0

    return rmse, mae, r2, elapsed, train_losses, test_losses


results = []
all_curves = {}

# ── KAN [5,16,8,1] ──────────────────────────────────────────────
print("\n>>> Training KAN [5,16,8,1]")
kan = KAN([5, 16, 8, 1], grid_size=3, spline_order=3).to(DEVICE)
kan_params = count_params(kan)
rmse, mae, r2, t, tr, te = train_model(kan, 'KAN')
results.append(('KAN  [5,16,8,1]', 'B-Spline', kan_params, rmse, mae, r2, t))
all_curves['KAN [5,16,8,1]'] = (tr, te)
print(f"  => params={kan_params}  RMSE={rmse:.4f}  MAE={mae:.4f}  R2={r2:.4f}  time={t:.1f}s\n")

# ── MLP ReLU ──────────────────────────────────────────────────────
for act in ['relu', 'gelu', 'silu']:
    for layers, tag in [([5,45,25,1], '2h'), ([5,36,27,18,1], '3h')]:
        name = f'MLP-{act.upper()} [{",".join(map(str,layers))}]'
        print(f">>> Training {name}")
        model = MLP(layers, act=act).to(DEVICE)
        params = count_params(model)
        rmse, mae, r2, t, tr, te = train_model(model, name)
        results.append((name, act.upper(), params, rmse, mae, r2, t))
        all_curves[name] = (tr, te)
        print(f"  => params={params}  RMSE={rmse:.4f}  MAE={mae:.4f}  R2={r2:.4f}  time={t:.1f}s\n")

# ── 打印汇总表 ────────────────────────────────────────────────────
print("\n" + "=" * 80)
print(f"{'Model':<35} {'Act':>8} {'Params':>6} {'RMSE':>8} {'MAE':>8} {'R2':>8}")
print("-" * 80)
for name, act, params, rmse, mae, r2, t in results:
    print(f"{name:<35} {act:>8} {params:>6} {rmse:>8.4f} {mae:>8.4f} {r2:>8.4f}")
print("=" * 80)

# ── 绘制训练曲线（只画测试集，避免图太乱）────────────────────────
epochs_axis = np.arange(10, EPOCHS + 1, 10)
colors = ['#2196F3',
          '#FF5722', '#FF8A65',
          '#4CAF50', '#81C784',
          '#9C27B0', '#CE93D8']
fig, ax = plt.subplots(figsize=(10, 5))
for i, (label, (tr, te)) in enumerate(all_curves.items()):
    lw = 2.5 if 'KAN' in label else 1.2
    ls = '-' if 'KAN' in label else ('--' if '2h' in label or '45' in label else ':')
    ax.plot(epochs_axis, te, label=label, color=colors[i % len(colors)], linewidth=lw, linestyle=ls)
ax.set_xlabel('训练轮次')
ax.set_ylabel('测试集 MSE 损失')
ax.set_title('KAN 与 MLP 测试集损失对比（ReLU / GELU / SiLU）')
ax.legend(fontsize=8, ncol=2)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)
plt.tight_layout()
out_path = os.path.join(os.path.dirname(__file__), 'compare_kan_mlp.png')
plt.savefig(out_path, dpi=300, bbox_inches='tight')
plt.close("all")
print(f"\nSaved: {out_path}")
