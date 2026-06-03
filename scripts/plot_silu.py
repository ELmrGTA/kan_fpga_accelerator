"""
SiLU 激活函数可视化
展示：SiLU精确值、8段二次多项式近似、误差曲线
"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib
matplotlib.rcParams['font.family'] = ['SimHei', 'Microsoft YaHei', 'DejaVu Sans']
matplotlib.rcParams['axes.unicode_minus'] = False

x = np.linspace(-3, 3, 4000)

# ── 精确 SiLU ─────────────────────────────────────────────────────
def silu(x):
    return x / (1 + np.exp(-x))

y_exact = silu(x)

# ── 8段二次多项式近似（与硬件实现完全一致） ───────────────────────
# 边界（浮点）
B = [-6, -3, -1.5, -0.5, 0, 0.5, 1.5, 3, 6]
# 各段系数 [a, b, c]，y = a*x^2 + b*x + c
SEGS = [
    [-0.01298, -0.15763, -0.49592],   # (-6,  -3]
    [ 0.01117, -0.04175, -0.36523],   # (-3,  -1.5]
    [ 0.15099,  0.38195, -0.03797],   # (-1.5,-0.5]
    [ 0.24129,  0.49769, -0.00011],   # (-0.5, 0]
    [ 0.24129,  0.50231, -0.00011],   # (0,    0.5]
    [ 0.15099,  0.61805, -0.03797],   # (0.5,  1.5]
    [ 0.01117,  1.04175, -0.36523],   # (1.5,  3]
    [-0.01298,  1.15763, -0.49592],   # (3,    6]
]

def silu_approx(xv):
    if xv <= -6:
        return 0.0
    elif xv > 6:
        return xv
    for k in range(8):
        if xv <= B[k+1]:
            a, b, c = SEGS[k]
            return a*xv*xv + b*xv + c
    return xv

y_approx = np.array([silu_approx(xv) for xv in x])
y_error  = np.abs(y_exact - y_approx)

# ── 绘图 ──────────────────────────────────────────────────────────
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(8, 7),
                                gridspec_kw={'height_ratios': [3, 1], 'hspace': 0.08})
fig.patch.set_facecolor('white')

# 上图：SiLU 精确 vs 近似
ax1.set_facecolor('white')
ax1.plot(x, y_exact,  color='#1E88E5', linewidth=2.2, label='SiLU  $x\\cdot\\sigma(x)$', zorder=3)
ax1.plot(x, y_approx, color='#E53935', linewidth=1.6, linestyle='--',
         label='8段二次多项式近似', zorder=2)

# 标注分段边界
for bv in [-1.5, -0.5, 0, 0.5, 1.5]:
    ax1.axvline(bv, color='#AAAAAA', linewidth=0.8, linestyle=':', zorder=1)

ax1.axhline(0, color='black', linewidth=0.8)
ax1.axvline(0, color='black', linewidth=0.8)
ax1.set_xlim(-3, 3)
ax1.set_ylim(-1.0, 6.2)
ax1.set_ylabel('$y$', fontsize=12)
ax1.legend(fontsize=11, loc='upper left', framealpha=0.9, edgecolor='#cccccc')
ax1.grid(True, alpha=0.2, linestyle=':')
ax1.spines['top'].set_visible(False)
ax1.spines['right'].set_visible(False)
ax1.tick_params(labelbottom=False)

# 最大误差标注
max_err = y_error.max()
max_x   = x[np.argmax(y_error)]
ax1.annotate(f'最大误差 = {max_err:.4f}',
             xy=(max_x, silu_approx(max_x)),
             xytext=(max_x + 1.2, silu_approx(max_x) - 0.4),
             fontsize=9, color='#E53935',
             arrowprops=dict(arrowstyle='->', color='#E53935', lw=1.2))

# 下图：误差曲线
ax2.set_facecolor('white')
ax2.fill_between(x, y_error, color='#E53935', alpha=0.25)
ax2.plot(x, y_error, color='#E53935', linewidth=1.4)
ax2.axhline(max_err, color='#E53935', linewidth=0.8, linestyle='--', alpha=0.6)
ax2.text(3.5, max_err + 0.0003, f'{max_err:.4f}', fontsize=8.5, color='#E53935')

for bv in [-1.5, -0.5, 0, 0.5, 1.5]:
    ax2.axvline(bv, color='#AAAAAA', linewidth=0.8, linestyle=':', zorder=1)

ax2.set_xlim(-3, 3)
ax2.set_ylim(0, max_err * 2.2)
ax2.set_xlabel('$x$', fontsize=12)
ax2.set_ylabel('|误差|', fontsize=10)
ax2.grid(True, alpha=0.2, linestyle=':')
ax2.spines['top'].set_visible(False)
ax2.spines['right'].set_visible(False)

# x轴刻度
ax2.set_xticks([-3, -1.5, -0.5, 0, 0.5, 1.5, 3])
ax2.set_xticklabels(['-3', '-1.5', '-0.5', '0', '0.5', '1.5', '3'], fontsize=9)

out_path = os.path.join(os.path.dirname(__file__), '..', 'figures', 'silu_approximation.png')
plt.savefig(out_path, dpi=300, bbox_inches='tight', facecolor='white')
plt.close()
print(f"saved: {out_path}")
