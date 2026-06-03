"""
log(f) vs SPL 线性关系图
固定 vel=71.3 m/s, chord=0.3048 m 子集（61样本）
展示 BPM 频率缩放律的数据证据
"""
import sys, os, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
matplotlib.rcParams['font.family'] = ['SimHei', 'Microsoft YaHei', 'DejaVu Sans']
matplotlib.rcParams['axes.unicode_minus'] = False
from scipy import stats

DATA_PATH = os.path.join(os.path.dirname(__file__), '..', 'dataset', 'data', 'airfoil_self_noise.dat')
df = pd.read_csv(DATA_PATH, sep='\t', header=None,
                 names=['frequency','angle','chord_length','velocity','displacement','sound_pressure'])
X = df.values.astype(np.float32)

# 子集：vel=71.3, chord=0.3048
mask = (X[:,3] == 71.3) & (X[:,2] == 0.3048)
sub  = X[mask]
print(f"Subset: {mask.sum()} samples (vel=71.3 m/s, chord=0.3048 m)")
print(f"Angle values: {np.unique(sub[:,1])}")
print(f"Freq values:  {np.unique(sub[:,0])}")

freq = sub[:, 0]
spl  = sub[:, 5]
logf = np.log10(freq)

slope, intercept, r, p, se = stats.linregress(logf, spl)
print(f"\nLinear fit: SPL = {slope:.2f} * log10(f) + {intercept:.2f}")
print(f"Pearson r = {r:.4f},  p = {p:.2e}")

x_fit = np.linspace(logf.min(), logf.max(), 200)
y_fit = slope * x_fit + intercept

# ── 图：左原始，右对数 ────────────────────────────────────────────
fig, axes = plt.subplots(1, 2, figsize=(11, 5), facecolor='white')

C = '#BF360C'
C_FIT = '#1B5E20'

# 左：原始 f vs SPL
ax = axes[0]
angle_vals = np.unique(sub[:,1])
cmap = plt.cm.Blues
for i, a in enumerate(angle_vals):
    m = sub[:,1] == a
    ax.scatter(sub[m,0], sub[m,5], s=40, alpha=0.85,
               color=cmap(0.4 + 0.5*i/max(len(angle_vals)-1,1)),
               label=f'攻角={a}°', zorder=3)
ax.set_xlabel('频率 $f$ (Hz)', fontsize=11)
ax.set_ylabel('声压级 (dB)', fontsize=11)
ax.set_title('原始：$f$ vs 声压级\n（非线性，高频压缩）', fontsize=11, fontweight='bold')
ax.legend(fontsize=8.5, title='攻角', title_fontsize=8)
ax.set_facecolor('#F8F9FA')
ax.grid(True, alpha=0.25, linestyle='--')
ax.set_xticks([250, 500, 1000, 2000, 4000, 8000, 16000])
ax.set_xticklabels(['250','500','1k','2k','4k','8k','16k'], fontsize=9)

# 右：log10(f) vs SPL + 线性拟合
ax = axes[1]
for i, a in enumerate(angle_vals):
    m = sub[:,1] == a
    ax.scatter(np.log10(sub[m,0]), sub[m,5], s=40, alpha=0.85,
               color=cmap(0.4 + 0.5*i/max(len(angle_vals)-1,1)),
               label=f'攻角={a}°', zorder=3)

ax.plot(x_fit, y_fit, color=C_FIT, linewidth=2.5, zorder=2,
        label=f'线性拟合  r={r:.3f}')

# 标注斜率
mid = len(x_fit)//2
ax.annotate(f'斜率 = {slope:.1f} dB/decade',
            xy=(x_fit[mid], y_fit[mid]),
            xytext=(x_fit[mid]-0.35, y_fit[mid]+3.5),
            fontsize=9.5, color=C_FIT, fontweight='bold',
            arrowprops=dict(arrowstyle='->', color=C_FIT, lw=1.3))

ax.set_xlabel(r'$\log_{10}(f)$（刻度单位：Hz）', fontsize=11)
ax.set_ylabel('声压级 (dB)', fontsize=11)
ax.set_title(r'对数变换：$\log_{10}(f)$ vs 声压级' + f'\nPearson r = {r:.3f}  (p < 0.001)',
             fontsize=11, fontweight='bold', color=C)
ax.legend(fontsize=8.5, title='攻角', title_fontsize=8)
ax.set_facecolor('#F8F9FA')
ax.grid(True, alpha=0.25, linestyle='--')

# x轴加物理刻度
xticks_log = np.log10([250, 500, 1000, 2000, 4000, 8000, 16000])
ax.set_xticks(xticks_log)
ax.set_xticklabels(['250','500','1k','2k','4k','8k','16k'], fontsize=9)

fig.suptitle(
    r'频率缩放律：$\mathrm{SPL} \propto -\log_{10}(f)$' + '\n'
    '受控子集（vel=71.3 m/s，chord=0.3048 m，n=61）— 与BPM斯特劳哈尔缩放一致',
    fontsize=11.5, fontweight='bold', y=1.02, color='#1A237E'
)

plt.tight_layout()
out = os.path.join(os.path.dirname(__file__), 'logf_spl_comparison.png')
plt.savefig(out, dpi=300, bbox_inches='tight', facecolor='white')
plt.close()
print(f"\nFigure saved: {out}")
