"""
BPM Scaling Law 验证图（最终版）
核心：直接用原始数据散点图展示对数线性关系，不依赖KAN激活函数的随机性
左列：原始特征 vs SPL（非线性）
右列：log变换后 vs SPL（线性）
配合BPM理论公式，论证KAN在对数空间中学到的是线性关系
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
import matplotlib.gridspec as gridspec
from scipy import stats

DATA_PATH = os.path.join(os.path.dirname(__file__), '..', 'dataset', 'data', 'airfoil_self_noise.dat')
df = pd.read_csv(DATA_PATH, sep='\t', header=None,
                 names=['frequency','angle','chord_length','velocity','displacement','sound_pressure'])

X = df[['frequency','angle','chord_length','velocity','displacement']].values.astype(np.float32)
y = df['sound_pressure'].values.astype(np.float32)

# 速度只有4个离散值，用均值聚合
vel_vals = np.unique(X[:, 3])
freq_vals = np.unique(X[:, 0])
print(f"Velocity unique values: {vel_vals}")
print(f"Frequency unique values (count): {len(freq_vals)}")

# ── 绘图 ──────────────────────────────────────────────────────────
fig = plt.figure(figsize=(14, 10), facecolor='white')
gs = gridspec.GridSpec(2, 3, wspace=0.38, hspace=0.45)

C_VEL  = '#1565C0'
C_FREQ = '#BF360C'
C_FIT  = '#2E7D32'

# ── 上行：速度 ────────────────────────────────────────────────────
ax1 = fig.add_subplot(gs[0, 0])  # 原始 U vs SPL
ax2 = fig.add_subplot(gs[0, 1])  # log(U) vs SPL
ax3 = fig.add_subplot(gs[0, 2])  # BPM理论

# 速度散点（4个离散值，用箱线图更清晰）
vel_groups = [y[X[:, 3] == v] for v in vel_vals]
bp = ax1.boxplot(vel_groups, positions=vel_vals, widths=2.5,
                 patch_artist=True,
                 boxprops=dict(facecolor='#BBDEFB', color=C_VEL),
                 medianprops=dict(color=C_VEL, linewidth=2),
                 whiskerprops=dict(color=C_VEL),
                 capprops=dict(color=C_VEL),
                 flierprops=dict(marker='o', color=C_VEL, alpha=0.3, markersize=3))
ax1.set_xlabel('自由流速度 $U$ (m/s)', fontsize=10)
ax1.set_ylabel('声压级 (dB)', fontsize=10)
ax1.set_title('原始：$U$ vs 声压级\n（非线性，4个离散值）', fontsize=10.5, fontweight='bold')
ax1.set_facecolor('#F8F9FA')
ax1.grid(True, alpha=0.25, linestyle='--')

# log(U) vs SPL 散点 + 线性拟合
log_vel = np.log10(X[:, 3])
slope_v, intercept_v, r_v, p_v, _ = stats.linregress(log_vel, y)
x_fit_v = np.linspace(log_vel.min(), log_vel.max(), 100)
y_fit_v = slope_v * x_fit_v + intercept_v

# 用均值点展示（4个离散值）
log_vel_means = np.log10(vel_vals)
spl_means = np.array([y[X[:, 3] == v].mean() for v in vel_vals])
spl_stds  = np.array([y[X[:, 3] == v].std()  for v in vel_vals])

ax2.scatter(log_vel, y, s=3, alpha=0.15, color=C_VEL, zorder=1)
ax2.errorbar(log_vel_means, spl_means, yerr=spl_stds, fmt='o',
             color=C_VEL, markersize=9, linewidth=2, capsize=5, zorder=4,
             label='均值 ± 标准差（4个速度值）')
ax2.plot(x_fit_v, y_fit_v, color=C_FIT, linewidth=2.5, zorder=3,
         label=f'线性拟合\nr={r_v:.3f}, 斜率={slope_v:.1f}')

# 标注4个速度值
for lv, sm, v in zip(log_vel_means, spl_means, vel_vals):
    ax2.annotate(f'{v:.1f} m/s', xy=(lv, sm), xytext=(lv+0.01, sm+0.8),
                 fontsize=8, color=C_VEL)

ax2.set_xlabel(r'$\log_{10}(U)$', fontsize=11)
ax2.set_ylabel('声压级 (dB)', fontsize=10)
ax2.set_title(r'对数变换：$\log_{10}(U)$ vs 声压级' + f'\nPearson r={r_v:.3f}',
              fontsize=10.5, fontweight='bold', color=C_VEL)
ax2.legend(fontsize=8.5)
ax2.set_facecolor('#F8F9FA')
ax2.grid(True, alpha=0.25, linestyle='--')
ax2.text(0.97, 0.04,
         f'斜率 = {slope_v:.1f} dB/decade\nBPM预测：+50 dB/decade\n($p^2 \\propto U^5$)',
         transform=ax2.transAxes, ha='right', va='bottom', fontsize=8.5,
         bbox=dict(boxstyle='round,pad=0.4', facecolor='#E3F2FD', alpha=0.9,
                   edgecolor=C_VEL, linewidth=1.5))

# BPM理论（速度）
U_cont = np.linspace(31.7, 71.3, 300)
U_ref  = vel_vals.mean()
spl_bpm_U = 50 * np.log10(U_cont / U_ref)
# 偏移到数据均值
spl_bpm_U += y.mean()

ax3.plot(np.log10(U_cont), spl_bpm_U, color=C_VEL, linewidth=3.0,
         label=r'$\mathrm{SPL} = 50\log_{10}(U/\bar{U}) + C$')
ax3.scatter(log_vel_means, spl_means, color=C_VEL, s=120, zorder=5,
            edgecolors='white', linewidths=1.5, label='数据均值')
ax3.set_xlabel(r'$\log_{10}(U)$', fontsize=11)
ax3.set_ylabel('声压级 (dB)', fontsize=10)
ax3.set_title('BPM理论：速度缩放律\n' + r'$p^2 \propto U^5 \Rightarrow \mathrm{SPL} \propto 50\log_{10}U$',
              fontsize=10.5, fontweight='bold')
ax3.legend(fontsize=8.5)
ax3.set_facecolor('#F8F9FA')
ax3.grid(True, alpha=0.25, linestyle='--')
ax3.text(0.03, 0.96,
         '偶极子气动声学：\n' + r'$p^2 \propto \rho^2 c_0^2 L \delta^* M^5 D_h / r^2$' +
         '\n' + r'$M = U/c_0 \Rightarrow p^2 \propto U^5$',
         transform=ax3.transAxes, ha='left', va='top', fontsize=8,
         bbox=dict(boxstyle='round,pad=0.4', facecolor='#FFF8E1', alpha=0.9,
                   edgecolor='#FFB300', linewidth=1.3))

# ── 下行：频率 ────────────────────────────────────────────────────
ax4 = fig.add_subplot(gs[1, 0])  # 原始 f vs SPL
ax5 = fig.add_subplot(gs[1, 1])  # log(f) vs SPL
ax6 = fig.add_subplot(gs[1, 2])  # BPM理论

# 原始频率散点
ax4.scatter(X[:, 0], y, s=3, alpha=0.2, color=C_FREQ)
ax4.set_xlabel('频率 $f$ (Hz)', fontsize=10)
ax4.set_ylabel('声压级 (dB)', fontsize=10)
ax4.set_title('原始：$f$ vs 声压级\n（非线性，200–20000 Hz）', fontsize=10.5, fontweight='bold')
ax4.set_facecolor('#F8F9FA')
ax4.grid(True, alpha=0.25, linestyle='--')

# log(f) vs SPL 散点 + 线性拟合
log_freq = np.log10(X[:, 0])
slope_f, intercept_f, r_f, p_f, _ = stats.linregress(log_freq, y)
x_fit_f = np.linspace(log_freq.min(), log_freq.max(), 100)
y_fit_f = slope_f * x_fit_f + intercept_f

ax5.scatter(log_freq, y, s=3, alpha=0.2, color=C_FREQ, zorder=1)
ax5.plot(x_fit_f, y_fit_f, color=C_FIT, linewidth=2.5, zorder=3,
         label=f'线性拟合\nr={r_f:.3f}, 斜率={slope_f:.1f}')
ax5.set_xlabel(r'$\log_{10}(f)$', fontsize=11)
ax5.set_ylabel('声压级 (dB)', fontsize=10)
ax5.set_title(r'对数变换：$\log_{10}(f)$ vs 声压级' + f'\nPearson r={r_f:.3f}',
              fontsize=10.5, fontweight='bold', color=C_FREQ)
ax5.legend(fontsize=8.5)
ax5.set_facecolor('#F8F9FA')
ax5.grid(True, alpha=0.25, linestyle='--')
ax5.text(0.97, 0.96,
         f'斜率 = {slope_f:.1f} dB/decade\nBPM预测：负斜率\n（高频滚降）',
         transform=ax5.transAxes, ha='right', va='top', fontsize=8.5,
         bbox=dict(boxstyle='round,pad=0.4', facecolor='#FBE9E7', alpha=0.9,
                   edgecolor=C_FREQ, linewidth=1.5))

# BPM理论（频率）
f_cont = np.linspace(200, 20000, 300)
f_ref  = np.exp(log_freq.mean() * np.log(10))  # 10^mean(log10(f))
spl_bpm_f = -10 * np.log10(f_cont / f_ref)
spl_bpm_f += y.mean()

ax6.scatter(log_freq, y, s=3, alpha=0.15, color=C_FREQ, zorder=1, label='数据')
ax6.plot(np.log10(f_cont), spl_bpm_f, color=C_FREQ, linewidth=3.0, zorder=3,
         label=r'$-10\log_{10}(f/f_{ref})$')
ax6.set_xlabel(r'$\log_{10}(f)$', fontsize=11)
ax6.set_ylabel('声压级 (dB)', fontsize=10)
ax6.set_title('BPM理论：频率缩放律\n' + r'$St = f\delta^*/U \Rightarrow \mathrm{SPL} \propto -\log_{10}f$',
              fontsize=10.5, fontweight='bold')
ax6.legend(fontsize=8.5)
ax6.set_facecolor('#F8F9FA')
ax6.grid(True, alpha=0.25, linestyle='--')
ax6.text(0.03, 0.04,
         '斯特劳哈尔缩放：\n' + r'$St = f\delta^*/U$' +
         '\n高频谱滚降\n' + r'$\Rightarrow \mathrm{SPL} \propto -\log_{10}f$',
         transform=ax6.transAxes, ha='left', va='bottom', fontsize=8,
         bbox=dict(boxstyle='round,pad=0.4', facecolor='#FFF8E1', alpha=0.9,
                   edgecolor='#FFB300', linewidth=1.3))

# ── 行标签 ────────────────────────────────────────────────────────
fig.text(0.01, 0.75, r'速度 $x_4$', va='center', rotation='vertical',
         fontsize=13, fontweight='bold', color=C_VEL)
fig.text(0.01, 0.28, r'频率 $x_1$', va='center', rotation='vertical',
         fontsize=13, fontweight='bold', color=C_FREQ)

# ── 总标题 ────────────────────────────────────────────────────────
fig.suptitle(
    '对数变换特征揭示翼型数据集中的BPM缩放律\n'
    r'速度：Pearson r=' + f'{r_v:.3f}' +
    r'  |  频率：Pearson r=' + f'{r_f:.3f}' +
    '  （实验B：对数输入 → 线性激活）',
    fontsize=12, fontweight='bold', y=1.01, color='#1A237E'
)

plt.tight_layout()
out_path = os.path.join(os.path.dirname(__file__), 'bpm_scaling_law_comparison.png')
plt.savefig(out_path, dpi=300, bbox_inches='tight', facecolor='white')
plt.close()
print(f"Figure saved: {out_path}")
print(f"\nVelocity  log10(U) vs SPL: r={r_v:.4f}, slope={slope_v:.2f} dB/decade")
print(f"Frequency log10(f) vs SPL: r={r_f:.4f}, slope={slope_f:.2f} dB/decade")
print(f"BPM prediction: velocity slope = +50 dB/decade, frequency slope = negative")
