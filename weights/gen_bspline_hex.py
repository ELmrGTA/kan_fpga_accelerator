"""
生成 bspline_lut.hex 供 Verilog $readmemh 使用
格式：每行 6 个 int16 值（Q1.15，32767=1.0），hex 格式
LUT范围 [-3.0, 3.0]，256点，等步长 Q6.9=12（对应 0.02344）
采样点与 Verilog 索引完全对齐：x_q9[i] = -1536 + i*12
"""
import sys
import os

import numpy as np
from efficient_kan import KAN
import torch

RESULTS_DIR = os.path.join(os.path.dirname(__file__))
VER_DIR     = os.path.join(os.path.dirname(__file__), '..', 'verilog')

model = KAN([5, 16, 8, 1], grid_size=3, spline_order=3)
model.load_state_dict(torch.load(os.path.join(RESULTS_DIR, 'kan_16_8_full_data.pth'),
                                  map_location='cpu'))
model.eval()

GRID_SIZE    = 3
SPLINE_ORDER = 3
COEFF_SIZE   = GRID_SIZE + SPLINE_ORDER  # 6
N_LUT        = 256
X_MIN, X_MAX = -3.0, 3.0

grid_1d = model.layers[0].grid.data.numpy()[0]  # shape [10]

def b_splines_numpy(x_val, grid, spline_order=3):
    coeff_size = len(grid) - spline_order - 1
    b = np.array([(x_val >= grid[i]) and (x_val < grid[i+1])
                  for i in range(len(grid)-1)], dtype=np.float32)
    for k in range(1, spline_order + 1):
        new_b = np.zeros(len(b) - 1, dtype=np.float32)
        for i in range(len(new_b)):
            d1 = grid[i+k]   - grid[i]
            d2 = grid[i+k+1] - grid[i+1]
            t1 = (x_val - grid[i])      / d1 * b[i]   if d1 != 0 else 0.0
            t2 = (grid[i+k+1] - x_val) / d2 * b[i+1] if d2 != 0 else 0.0
            new_b[i] = t1 + t2
        b = new_b
    return b[:coeff_size]

# 采样点：与 Verilog 完全对齐，x_q9[i] = -1536 + i*12，转回浮点
LUT_STEP_Q9 = 12
x_q9_arr  = np.arange(N_LUT) * LUT_STEP_Q9 - 1536  # Q6.9 整数
x_samples = x_q9_arr / 512.0                         # 浮点
lut = np.zeros((N_LUT, COEFF_SIZE), dtype=np.float32)
for idx, xv in enumerate(x_samples):
    xv_c = float(np.clip(xv, X_MIN, X_MAX - 1e-6))
    lut[idx] = b_splines_numpy(xv_c, grid_1d, SPLINE_ORDER)

# Q1.15 量化：32767=1.0
lut_q15 = np.clip(np.round(lut * 32767), 0, 32767).astype(np.int16)

# 写 hex 文件（$readmemh 格式，每行一个地址，6个值拼接）
# 每行格式：每个值4位hex（16bit），空格分隔，Verilog会按 [0][0],[0][1]...顺序读
# 因为是 2D array，$readmemh 按展平顺序写
lines = []
for i in range(N_LUT):
    for k in range(COEFF_SIZE):
        val = lut_q15[i][k] & 0xFFFF
        lines.append(f"{val:04X}")

hex_path = os.path.join(VER_DIR, 'bspline_lut.hex')
with open(hex_path, 'w') as f:
    f.write('\n'.join(lines))

print(f"已写入: {hex_path}")
print(f"共 {N_LUT * COEFF_SIZE} 行（{N_LUT} 点 × {COEFF_SIZE} 基函数）")
print(f"前5点示例：")
for i in range(5):
    print(f"  x={x_samples[i]:.3f}: {[int(v) for v in lut_q15[i]]}")
