"""
权重衰减系数扫描实验：KAN [5,16,8,1] on NASA Airfoil
扫描范围：0, 1e-5, 1e-4, 5e-4, 1e-3, 3e-3, 5e-3
"""
import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'dataset'))

import time
import torch
import torch.nn as nn
import torch.optim as optim
import numpy as np
from efficient_kan import KAN
from data_loader import load_airfoil

# 超参数
EPOCHS = 2000
LR     = 5e-3
SEED   = 42
PATIENCE = 100
MIN_DELTA = 1e-4

DEVICE = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
torch.manual_seed(SEED)
np.random.seed(SEED)

dataset = load_airfoil()
x_train = dataset['train_input'].to(DEVICE)
y_train = dataset['train_label'].to(DEVICE)
x_test  = dataset['test_input'].to(DEVICE)
y_test  = dataset['test_label'].to(DEVICE)

# 权重衰减扫描列表
WD_LIST = [0, 1e-5, 1e-4, 5e-4, 1e-3, 3e-3, 5e-3]
configs = [
    {'layers': [5, 16, 8, 1], 'grid': 3, 'wd': wd, 'name': f'wd={wd}'}
    for wd in WD_LIST
]

results = []

for cfg in configs:
    print(f"\n{'='*70}")
    print(f"Training: {cfg['name']}")
    print(f"{'='*70}")

    model = KAN(cfg['layers'], grid_size=cfg['grid'], spline_order=3).to(DEVICE)
    optimizer = optim.AdamW(model.parameters(), lr=LR, weight_decay=cfg['wd'])
    scheduler = optim.lr_scheduler.ReduceLROnPlateau(
        optimizer, mode='min', factor=0.5, patience=50, min_lr=1e-6
    )
    criterion = nn.MSELoss()

    # Early stopping variables
    best_test_loss = float('inf')
    best_epoch = 0
    patience_counter = 0
    best_model_state = None

    train_losses = []
    test_losses = []

    t0 = time.time()
    for epoch in range(EPOCHS):
        # Training
        model.train()
        optimizer.zero_grad()
        train_pred = model(x_train)
        train_loss = criterion(train_pred, y_train)
        train_loss.backward()
        optimizer.step()

        # Validation
        model.eval()
        with torch.no_grad():
            test_pred = model(x_test)
            test_loss = criterion(test_pred, y_test).item()

        train_losses.append(train_loss.item())
        test_losses.append(test_loss)

        # Learning rate scheduling
        scheduler.step(test_loss)

        # Early stopping check
        if test_loss < best_test_loss - MIN_DELTA:
            best_test_loss = test_loss
            best_epoch = epoch
            patience_counter = 0
            best_model_state = model.state_dict().copy()
        else:
            patience_counter += 1

        # Print progress
        if (epoch + 1) % 100 == 0:
            print(f"  Epoch {epoch+1:4d} | train={train_loss.item():.4f} | "
                  f"test={test_loss:.4f} | best={best_test_loss:.4f} @ {best_epoch+1} | "
                  f"patience={patience_counter}/{PATIENCE}")

        # Early stopping
        if patience_counter >= PATIENCE:
            print(f"\n  Early stopping at epoch {epoch+1}")
            print(f"  Best test loss: {best_test_loss:.4f} at epoch {best_epoch+1}")
            break

    # Restore best model
    if best_model_state is not None:
        model.load_state_dict(best_model_state)

    elapsed = time.time() - t0

    # Final evaluation
    model.eval()
    with torch.no_grad():
        y_train_pred = model(x_train).cpu().numpy().ravel()
        y_test_pred = model(x_test).cpu().numpy().ravel()

    y_train_true = y_train.cpu().numpy().ravel()
    y_test_true = y_test.cpu().numpy().ravel()

    train_rmse = np.sqrt(np.mean((y_train_true - y_train_pred)**2))
    test_rmse = np.sqrt(np.mean((y_test_true - y_test_pred)**2))
    train_mae = np.mean(np.abs(y_train_true - y_train_pred))
    test_mae = np.mean(np.abs(y_test_true - y_test_pred))
    r2 = 1 - np.sum((y_test_true - y_test_pred)**2) / np.sum((y_test_true - y_test_true.mean())**2)

    params = sum(p.numel() for p in model.parameters())
    overfit_ratio = (test_rmse - train_rmse) / train_rmse * 100

    results.append({
        'name': cfg['name'],
        'layers': cfg['layers'],
        'weight_decay': cfg['wd'],
        'train_rmse': train_rmse,
        'test_rmse': test_rmse,
        'train_mae': train_mae,
        'test_mae': test_mae,
        'r2': r2,
        'params': params,
        'best_epoch': best_epoch + 1,
        'total_epochs': epoch + 1,
        'overfit_ratio': overfit_ratio,
        'time': elapsed,
        'model': model
    })

    print(f"  wd={cfg['wd']}: train_rmse={train_rmse:.4f} test_rmse={test_rmse:.4f} "
          f"overfit={overfit_ratio:.1f}% R2={r2:.4f} best_epoch={best_epoch+1}/{epoch+1} t={elapsed:.0f}s")

# 汇总表
print("\n" + "=" * 80)
print(f"{'weight_decay':<14} {'train_rmse':>11} {'test_rmse':>10} {'overfit%':>9} {'R2':>8} {'best_epoch':>12}")
print("-" * 80)
for r in results:
    print(f"{r['weight_decay']:<14} {r['train_rmse']:>11.4f} {r['test_rmse']:>10.4f} "
          f"{r['overfit_ratio']:>8.1f}% {r['r2']:>8.4f} {r['best_epoch']:>4d}/{r['total_epochs']:<4d}")
print("=" * 80)

best = min(results, key=lambda x: x['test_rmse'])
print(f"\nBest: weight_decay={best['weight_decay']}, test_rmse={best['test_rmse']:.4f}, R2={best['r2']:.4f}")
