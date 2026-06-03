"""
gen_charts.py
生成4张替换三线表的图表，保存至 figures/ 目录。
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# 中文字体设置（Windows）
plt.rcParams['font.sans-serif'] = ['SimHei', 'Microsoft YaHei', 'DejaVu Sans']
plt.rcParams['axes.unicode_minus'] = False
plt.rcParams['font.size'] = 22

OUT = 'figures/'

# 图1：KAN vs MLP 对比（分组条形图）

def plot_kan_vs_mlp():
    models = ['MLP\nReLU', 'MLP\nGELU',
              'MLP\nSiLU', 'KAN']
    rmse  = [0.2163, 0.1830, 0.2084, 0.1723]
    r2    = [0.9562, 0.9686, 0.9593, 0.9722]
    params= [1738,   1738,   1738,   1728  ]

    x = np.arange(len(models))
    width = 0.28

    fig, ax1 = plt.subplots(figsize=(11, 7))
    ax2 = ax1.twinx()

    colors_rmse = ['#5B9BD5'] * 3 + ['#ED7D31']
    colors_r2   = ['#A9D18E'] * 3 + ['#FF0000']

    bars1 = ax1.bar(x - width/2, rmse, width, color=colors_rmse,
                    label='RMSE（左轴）', alpha=0.85, edgecolor='white')
    bars2 = ax2.bar(x + width/2, r2,   width, color=colors_r2,
                    label='R$^2$（右轴）',  alpha=0.85, edgecolor='white')

    # 数值标注
    for bar, v in zip(bars1, rmse):
        ax1.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.003,
                 f'{v:.4f}', ha='center', va='bottom', fontsize=22)
    for bar, v in zip(bars2, r2):
        ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.0005,
                 f'{v:.4f}', ha='center', va='bottom', fontsize=22)

    ax1.set_ylabel('RMSE', color='#5B9BD5', fontsize=22)
    ax2.set_ylabel('R$^2$', color='#2E7D32', fontsize=22)
    ax1.set_xticks(x)
    ax1.set_xticklabels(models, fontsize=24)
    ax1.set_ylim(0, 0.28)
    ax2.set_ylim(0.94, 0.990)
    ax1.tick_params(axis='y', labelcolor='#5B9BD5', labelsize=18)
    ax2.tick_params(axis='y', labelcolor='#2E7D32', labelsize=18)

    # 高亮 KAN 列背景
    ax1.axvspan(x[-1] - 0.5, x[-1] + 0.5, alpha=0.08, color='orange')

    patch1 = mpatches.Patch(color='#5B9BD5', label='RMSE（越低越好）')
    patch2 = mpatches.Patch(color='#A9D18E', label='R$^2$（越高越好）')
    patch3 = mpatches.Patch(color='#ED7D31', label='KAN RMSE')
    patch4 = mpatches.Patch(color='#FF0000', label='KAN R$^2$')
    ax1.legend(handles=[patch1, patch2, patch3, patch4],
               loc='upper right', fontsize=14, framealpha=0.8, handlelength=1.5)
    ax1.grid(axis='y', linestyle='--', alpha=0.4)
    plt.tight_layout()
    plt.savefig(OUT + 'chart_kan_vs_mlp.png', dpi=300, bbox_inches='tight')
    plt.close()
    print('saved chart_kan_vs_mlp.png')

# 图2：剪枝阈值 vs 精度（折线图，双轴）

def plot_pruning():
    edge_th   = [0, 0.01, 0.03, 0.05, 0.10, 0.20]
    labels    = ['基础\n模型', '0.01', '0.03', '0.05', '0.10', '0.20']
    r2        = [0.9664, 0.9581, 0.9627, 0.9618, 0.9732, 0.9629]
    remaining = [216,    215,    210,    197,    166,    108   ]
    prune_rate= [0,      0.5,    2.8,    8.8,    23.1,   50.0  ]

    x = np.arange(len(labels))
    fig, ax1 = plt.subplots(figsize=(8, 4.5))
    ax2 = ax1.twinx()

    line1, = ax1.plot(x, r2, 'o-', color='#ED7D31', linewidth=2,
                      markersize=7, label='微调后 R$^2$（左轴）')
    line2, = ax2.plot(x, remaining, 's--', color='#5B9BD5', linewidth=2,
                      markersize=7, label='剩余边数（右轴）')

    # 数值标注
    for i, (rv, ev) in enumerate(zip(r2, remaining)):
        ax1.annotate(f'{rv:.4f}', (x[i], rv),
                     textcoords='offset points', xytext=(0, 8),
                     ha='center', fontsize=8, color='#ED7D31')
        ax2.annotate(str(ev), (x[i], ev),
                     textcoords='offset points', xytext=(0, -14),
                     ha='center', fontsize=8, color='#5B9BD5')

    # 推荐配置标注
    ax1.axvline(x=4, color='gray', linestyle=':', alpha=0.7)
    ax1.text(4.05, 0.9590, '推荐\nedge_th=0.10', fontsize=8, color='gray')

    ax1.set_ylabel('微调后 R$^2$', color='#ED7D31')
    ax2.set_ylabel('剩余边数', color='#5B9BD5')
    ax1.set_xticks(x)
    ax1.set_xticklabels(labels)
    ax1.set_xlabel('edge_th（剪枝阈值）')
    ax1.set_ylim(0.950, 0.980)
    ax2.set_ylim(80, 240)
    ax1.tick_params(axis='y', labelcolor='#ED7D31')
    ax2.tick_params(axis='y', labelcolor='#5B9BD5')
    ax1.legend(handles=[line1, line2], loc='lower left', fontsize=9)
    ax1.set_title('图 3-x　不同剪枝阈值下的精度与结构变化', pad=10)
    ax1.grid(axis='y', linestyle='--', alpha=0.4)
    plt.tight_layout()
    plt.savefig(OUT + 'chart_pruning.png', dpi=150, bbox_inches='tight')
    plt.close()
    print('saved chart_pruning.png')

# 图3：推理延迟逐层分解（堆叠条形图）

def plot_latency():
    layers = ['L0\n(5→16)', 'L1\n(16→8)', 'L2\n(8→1)']
    feed   = [6,   17,  9 ]
    wait   = [4,   4,   4 ]
    mac    = [176, 176, 14]

    x = np.arange(len(layers))
    width = 0.45

    fig, ax = plt.subplots(figsize=(7, 4.5))

    b1 = ax.bar(x, feed, width, label='FEED（送入流水线）', color='#5B9BD5')
    b2 = ax.bar(x, wait, width, bottom=feed, label='WAIT（等待缓冲填满）', color='#FFC000')
    b3 = ax.bar(x, mac,  width, bottom=[f+w for f,w in zip(feed,wait)],
                label='MAC（累加计算）', color='#ED7D31')

    totals = [f+w+m for f,w,m in zip(feed,wait,mac)]
    for i, (f,w,m,t) in enumerate(zip(feed,wait,mac,totals)):
        ax.text(x[i], f/2,       str(f), ha='center', va='center', fontsize=13, color='white', fontweight='bold')
        ax.text(x[i], f+w/2,     str(w), ha='center', va='center', fontsize=13, color='white', fontweight='bold')
        ax.text(x[i], f+w+m/2,   str(m), ha='center', va='center', fontsize=13, color='white', fontweight='bold')
        ax.text(x[i], t+3, f'{t}周期', ha='center', va='bottom', fontsize=12)

    ax.annotate('+ FSM开销 4周期\n总计 414周期\n= 3.45 μs @120 MHz',
                xy=(2, totals[2]), xytext=(0.7, 230),
                arrowprops=dict(arrowstyle='->', color='gray'),
                fontsize=10, color='gray',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))

    ax.set_ylabel('时钟周期数 (@120 MHz)', fontsize=13)
    ax.set_xticks(x)
    ax.set_xticklabels(layers, fontsize=13)
    ax.set_ylim(0, 260)
    ax.legend(loc='upper right', fontsize=11, framealpha=0.8)
    ax.grid(axis='y', linestyle='--', alpha=0.4)
    ax.tick_params(axis='y', labelsize=11)
    plt.tight_layout()
    plt.savefig(OUT + 'chart_latency.png', dpi=300, bbox_inches='tight')
    plt.close()
    print('saved chart_latency.png')

# 图4：FPGA 资源利用率（水平条形图）

def plot_resources():
    resources = ['LUT\n(查找表)', 'FF\n(触发器)', 'BRAM\n(块RAM)', 'DSP48E1']
    used      = [3595, 3171, 6,   18 ]
    total     = [53200,106400,140, 220]
    util      = [6.76, 2.98, 4.29, 8.18]

    y = np.arange(len(resources))
    fig, ax = plt.subplots(figsize=(8, 4))

    # 背景（总量）
    ax.barh(y, [100]*4, 0.5, color='#E0E0E0', label='剩余容量')
    # 已用
    colors = ['#ED7D31', '#5B9BD5', '#70AD47', '#FFC000']
    bars = ax.barh(y, util, 0.5, color=colors, label='已使用', alpha=0.9)

    # 数值标注
    for i, (bar, u, us, tot) in enumerate(zip(bars, util, used, total)):
        ax.text(u + 0.5, bar.get_y() + bar.get_height()/2,
                f'{u:.2f}%  ({us}/{tot})',
                va='center', fontsize=10)

    ax.set_xlim(0, 16)
    ax.set_xlabel('资源利用率 (%)', fontsize=12)
    ax.set_yticks(y)
    ax.set_yticklabels(resources, fontsize=11)
    ax.tick_params(axis='x', labelsize=9)
    ax.axvline(x=10, color='red', linestyle='--', alpha=0.5, linewidth=1)
    ax.grid(axis='x', linestyle='--', alpha=0.4)

    used_patch = mpatches.Patch(color='#ED7D31', label='已使用（各资源颜色不同）')
    free_patch = mpatches.Patch(color='#E0E0E0', label='剩余容量')
    ax.legend(handles=[used_patch, free_patch], loc='lower right', fontsize=9)

    plt.tight_layout()
    plt.savefig(OUT + 'chart_resources.png', dpi=150, bbox_inches='tight')
    plt.close()
    print('saved chart_resources.png')

if __name__ == '__main__':
    plot_kan_vs_mlp()
    plot_pruning()
    plot_latency()
    plot_resources()
    print('全部图表已生成至 figures/ 目录。')
