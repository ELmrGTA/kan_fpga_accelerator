"""
三阶B-样条6个基函数图
与实际模型完全一致：
  - 节点向量：[-3, -7/3, -5/3, -1, -1/3, 1/3, 1, 5/3, 7/3, 3]（10个节点）
  - 阶数 k=3（三阶/cubic）
  - 基函数数量：10 - 3 - 1 = 6
  - 绘制范围：[-3, 3]
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
matplotlib.rcParams['font.family'] = ['SimHei', 'Microsoft YaHei', 'DejaVu Sans']
matplotlib.rcParams['axes.unicode_minus'] = False
import matplotlib.pyplot as plt

# ── 实际节点向量 ──────────────────────────────────────────────────
t = np.array([-3.0, -7/3, -5/3, -1.0, -1/3, 1/3, 1.0, 5/3, 7/3, 3.0])
k = 3   # spline order (degree)
n_basis = len(t) - k - 1  # = 6

# ── Cox-de Boor 递推 ──────────────────────────────────────────────
def B(x, i, p, knots):
    """B_{i,p}(x) via Cox-de Boor recursion"""
    if p == 0:
        # 最后一个区间右端点闭合处理
        if i == len(knots) - 2:
            return 1.0 if knots[i] <= x <= knots[i+1] else 0.0
        return 1.0 if knots[i] <= x < knots[i+1] else 0.0
    d1 = knots[i+p] - knots[i]
    d2 = knots[i+p+1] - knots[i+1]
    left  = ((x - knots[i])       / d1 * B(x, i,   p-1, knots)) if d1 != 0 else 0.0
    right = ((knots[i+p+1] - x)   / d2 * B(x, i+1, p-1, knots)) if d2 != 0 else 0.0
    return left + right

# ── 计算6个基函数 ─────────────────────────────────────────────────
x = np.linspace(-3.0, 3.0, 3000)

basis_vals = []
for i in range(n_basis):
    y = np.array([B(xv, i, k, t) for xv in x])
    basis_vals.append(y)

# 验证：各点基函数之和应为1（在有效域内）
total = sum(basis_vals)

# ── 颜色方案（6色区分） ───────────────────────────────────────────
COLORS = ['#E53935', '#FB8C00', '#FDD835', '#43A047', '#1E88E5', '#8E24AA']
LABELS = [f'$B_{{0,3}}$', f'$B_{{1,3}}$', f'$B_{{2,3}}$',
          f'$B_{{3,3}}$', f'$B_{{4,3}}$', f'$B_{{5,3}}$']

# ── 绘图 ──────────────────────────────────────────────────────────
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(9, 7),
                                gridspec_kw={'height_ratios': [4, 1], 'hspace': 0.08})
fig.patch.set_facecolor('white')

# 上图：6个基函数
ax1.set_facecolor('white')
for i in range(n_basis):
    ax1.plot(x, basis_vals[i], color=COLORS[i], linewidth=2.2,
             label=LABELS[i], zorder=3)

# 节点位置竖线
for tv in t:
    ax1.axvline(tv, color='#CCCCCC', linewidth=0.9, linestyle='--', zorder=1)

ax1.axhline(0, color='black', linewidth=0.8)
ax1.set_xlim(-3, 3)
ax1.set_ylim(-0.05, 1.15)
ax1.set_ylabel('基函数值', fontsize=11)
ax1.legend(fontsize=10, loc='upper right', ncol=3,
           framealpha=0.9, edgecolor='#cccccc')
ax1.grid(True, alpha=0.15, linestyle=':')
ax1.spines['top'].set_visible(False)
ax1.spines['right'].set_visible(False)
ax1.tick_params(labelbottom=False)

# 节点位置标注（x轴上方）
knot_labels = ['-3', r'$-\frac{7}{3}$', r'$-\frac{5}{3}$', '-1',
               r'$-\frac{1}{3}$', r'$\frac{1}{3}$', '1',
               r'$\frac{5}{3}$', r'$\frac{7}{3}$', '3']
for tv, lbl in zip(t, knot_labels):
    ax1.text(tv, 1.08, lbl, ha='center', va='bottom', fontsize=7.5,
             color='#666666')

ax1.text(-2.85, 1.10, '节点：', fontsize=8, color='#666666', va='bottom')

# 下图：基函数之和（验证partition of unity）
ax2.set_facecolor('white')
ax2.plot(x, total, color='#333333', linewidth=1.8, label='$\\sum B_{i,3}(x)$')
ax2.axhline(1.0, color='#E53935', linewidth=1.0, linestyle='--', alpha=0.7)
ax2.set_xlim(-3, 3)
ax2.set_ylim(0, 1.3)
ax2.set_ylabel('求和', fontsize=10)
ax2.set_xlabel('$x$', fontsize=11)
ax2.legend(fontsize=9, loc='lower right', framealpha=0.9)
ax2.grid(True, alpha=0.15, linestyle=':')
ax2.spines['top'].set_visible(False)
ax2.spines['right'].set_visible(False)

# x轴刻度
ax2.set_xticks([-3, -2, -1, 0, 1, 2, 3])

plt.suptitle('三次B样条基函数  ($k=3$，6个基函数，grid\_size=3)',
             fontsize=12, fontweight='bold', y=1.01)

out_path = os.path.join(os.path.dirname(__file__), '..', 'figures', 'bspline_basis_orders.png')
plt.savefig(out_path, dpi=300, bbox_inches='tight', facecolor='white')
plt.close()
print(f"saved: {out_path}")

# 打印验证信息
print(f"节点向量: {t}")
print(f"基函数数量: {n_basis}")
print(f"各基函数最大值: {[f'{max(b):.4f}' for b in basis_vals]}")
print(f"partition of unity误差(最大): {abs(total - 1.0).max():.6f}")
