"""
生成 KAN 权重的 hex 文件供 Verilog $readmemh 使用
策略：把 scale 预先吸收进权重，直接存 Q6.9 定点数
  实际值 = int16权重 * float_scale
  Q6.9值 = round(实际值 * 512)，截断到 [-32767, 32767]
输出文件：
  l0_base_weight.hex, l0_spline_weight.hex, l0_spline_scaler.hex
  l1_base_weight.hex, l1_spline_weight.hex, l1_spline_scaler.hex
  l2_base_weight.hex, l2_spline_weight.hex, l2_spline_scaler.hex
"""
import sys, os
import torch
import numpy as np
from efficient_kan import KAN

RESULTS_DIR = os.path.join(os.path.dirname(__file__))
VER_DIR     = os.path.join(os.path.dirname(__file__), '..', 'verilog')

model = KAN([5, 16, 8, 1], grid_size=3, spline_order=3)
model.load_state_dict(torch.load(os.path.join(RESULTS_DIR, 'kan_16_8_full_data.pth'), map_location='cpu'))
model.eval()

INT16_MAX = 32767
Q9_SCALE = 512.0  # Q6.9: 1.0 = 512

def float_to_q9_hex(t, path):
    """float32 权重直接转 Q6.9 定点，存 hex"""
    arr = t.detach().numpy().flatten()
    q9 = np.clip(np.round(arr * Q9_SCALE), -32767, 32767).astype(np.int16)
    with open(path, 'w') as f:
        for v in q9:
            f.write(f"{int(v) & 0xFFFF:04X}\n")
    real_max = np.abs(arr).max()
    return q9, real_max

for i, layer in enumerate(model.layers):
    for wname in ['base_weight', 'spline_weight', 'spline_scaler']:
        w = getattr(layer, wname).data
        fname = f"l{i}_{wname}.hex"
        q9, real_max = float_to_q9_hex(w, os.path.join(VER_DIR, fname))
        print(f"  {fname}: shape={list(w.shape)}, max={real_max:.4f}, "
              f"Q9_max={int(np.abs(q9).max())}")

print(f"\n已写入 {VER_DIR}")
print("注：scale 已预先吸收进权重，Verilog 中直接用 Q6.9 乘法，无需额外 scale")
