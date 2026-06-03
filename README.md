# KAN FPGA 加速器

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.10](https://img.shields.io/badge/python-3.10-blue.svg)](https://www.python.org/)
[![Vivado 2025.2](https://img.shields.io/badge/Vivado-2025.2-green.svg)](https://www.xilinx.com/)
[![FPGA Zynq-7020](https://img.shields.io/badge/FPGA-Zynq--7020-orange.svg)](https://www.xilinx.com/products/silicon-devices/soc/zynq-7000.html)

基于 Xilinx Zynq-7020 FPGA 的 [Kolmogorov-Arnold Networks](https://arxiv.org/abs/2404.19756)（KAN）高能效硬件推理加速器，手工 RTL 实现，**120 MHz** 时序收敛，LUT 占用仅 **6.76%**，单次推理延迟 **3.45 μs**。

## 目录

- [概述](#概述)
- [关键指标](#关键指标)
- [项目结构](#项目结构)
- [环境配置](#环境配置)
- [实验流程](#实验流程)
  - [1. 算法训练](#1-算法训练)
  - [2. 量化分析](#2-量化分析)
  - [3. 硬件设计](#3-硬件设计)
  - [4. 仿真验证](#4-仿真验证)
- [设计决策](#设计决策)
- [致谢](#致谢)

## 概述

本项目实现了从 KAN 算法训练到 FPGA RTL 硬件推理的完整工程闭环：

```
算法训练 (PyTorch) → 定点量化 (Q6.9) → RTL 设计 (Verilog) → Vivado 综合实现 → RTL 仿真验证
```

KAN 将可学习的 B 样条函数放在网络连接边上，以替代 MLP 节点上的固定激活函数，在低维回归任务中具有更高的参数效率和符号可解释性。本项目以翼型自噪声预测为任务（NASA Airfoil 数据集，1503 样本，5→1 回归），在资源受限的 Zynq-7020 上实现了时分复用、深度流水线的 KAN[5,16,8,1] 推理引擎。

## 关键指标

| 指标 | 数值 |
|------|------|
| 网络结构 | KAN[5,16,8,1]，grid=3，k=3，216 条边，1728 参数 |
| 软件浮点 R² | 0.9756 |
| FPGA 芯片 | Xilinx Zynq-7020 (xc7z020clg400-2) |
| 工作频率 | **120 MHz** (WNS = 0.105 ns) |
| 推理延迟 | 414 周期 / **3.45 μs** |
| 吞吐量 | ~29 万次/秒 |
| LUT | 3595 / 53200 (6.76%) |
| DSP | 18 / 220 (8.18%) |
| BRAM | 6 / 140 (4.29%) |
| 硬件 R² | **0.9758**（301 样本 RTL 仿真） |

## 项目结构

```
├── README.md
├── experiment_report.md              # 完整实验数据（10 项实验）
├── .gitignore
│
├── dataset/
│   ├── data/airfoil_self_noise.dat   # NASA 翼型自噪声数据集 (UCI)
│   └── data_loader.py                # 数据加载与预处理
│
├── train/                            # 算法训练 (PyTorch)
│   ├── compare_kan_mlp.py            # KAN vs MLP 对比实验
│   ├── train_small_regularized.py    # 权重衰减扫描
│   ├── feature_function_analysis.py  # 符号回归分析
│   ├── pruning_experiment.py         # 剪枝实验
│   ├── logf_spl_plot.py              # log(f)-SPL 验证
│   ├── bpm_scaling_law_plot.py       # BPM 模型对比
│   └── *.json                        # 符号回归缓存
│
├── weights/                          # 模型权重与导出
│   ├── kan_16_8_full_data.pth        # 最优训练模型
│   ├── gen_weight_hex.py             # 权重 → .hex 生成
│   └── gen_bspline_hex.py            # B 样条 LUT → .hex 生成
│
├── verilog/                          # RTL 设计与验证
│   ├── silu_quadratic.v              # SiLU 近似模块（3 级流水线）
│   ├── bspline_lut.v                 # B 样条 LUT 模块（4 级流水线）
│   ├── mac.v                         # MAC 计算单元（5 级流水线）
│   ├── kan_top.v                     # 顶层 + FSM 控制器
│   ├── *_tb.v                        # 测试平台
│   ├── *.hex                         # 权重 / LUT 数据文件
│   ├── *.csv                         # 仿真输出结果
│   └── *.py                          # 精度评估脚本
│
├── scripts/                          # 图表生成
│   ├── gen_charts.py                 # 柱状图 / 堆叠图
│   ├── plot_bspline_basis.py         # B 样条基函数图
│   └── plot_silu.py                  # SiLU 近似曲线
│
├── figures/                          # 输出图表 (PNG)
│
└── vivado/
    └── timing.xdc                    # 时钟约束 (120 MHz)
```

## 环境配置

```bash
conda create -n pykan python=3.10
conda activate pykan

# 核心依赖
pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu
pip install "numpy<2"
pip install matplotlib scikit-learn pandas

# KAN 库
git clone https://github.com/KindXiaoming/pykan.git
pip install -e pykan/

git clone https://github.com/Blealtan/efficient-kan.git
# 将 efficient-kan/src 加入 PYTHONPATH
```

RTL 仿真需要 Xilinx Vivado 2025.2（或更高版本），安装时勾选 Zynq-7020 器件支持。

## 实验流程

完整实验数据见 [`experiment_report.md`](experiment_report.md)。

### 1. 算法训练

在 NASA Airfoil Self-Noise 数据集上训练 KAN[5,16,8,1]，与多种 MLP 变体对比。

```bash
# KAN vs MLP 对比实验
python train/compare_kan_mlp.py

# 权重衰减超参数扫描
python train/train_small_regularized.py

# 符号回归分析
python train/feature_function_analysis.py [5,16,8,1]

# 剪枝实验
python train/pruning_experiment.py
```

| 模型 | 参数量 | RMSE | R² |
|------|--------|------|-----|
| **KAN [5,16,8,1]** | 1728 | 0.1723 | **0.9722** |
| MLP [5,36,27,18,1] ReLU | 1738 | 0.2163 | 0.9562 |
| MLP [5,36,27,18,1] GELU | 1738 | 0.1830 | 0.9686 |
| MLP [5,36,27,18,1] SiLU | 1738 | 0.2084 | 0.9593 |

符号回归实验中，KAN 在对数空间中自动发现了 log(f) 与 SPL 之间的线性关系（r² = 0.998），与 Brooks-Pope-Marcolini（BPM）气动声学模型的理论预测一致，验证了 KAN 的符号回归能力。

### 2. 量化分析

对比三种 16 位定点格式，选定 Q6.9 方案：

| 格式 | 整数位 | 小数位 | 表示范围 | 量化 MAE | R² |
|------|--------|--------|---------|---------|-----|
| Q4.11 | 4 | 11 | [-16, 16] | 0.0009 | 0.9756 |
| Q5.10 | 5 | 10 | [-32, 32] | 0.0018 | 0.9756 |
| **Q6.9** | **6** | **9** | **[-64, 64]** | **0.0043** | **0.9756** |

选 Q6.9 的关键原因：[-64, 64] 的表示范围为三层 MAC 累加提供了足够溢出裕量。B 样条基函数值使用 Q1.15（值域 [0,1]，LSB ≈ 3×10⁻⁵）。

```bash
# 软件浮点 vs Q6.9 定点链对比
python verilog/compare_accuracy_full_testset.py

# 生成 .hex 文件供 RTL 仿真读入
python weights/gen_weight_hex.py
python weights/gen_bspline_hex.py
```

### 3. 硬件设计

系统采用**时分复用**架构：三层网络共享一套运算核心，由 11 状态有限状态机（FSM）统一调度。

| 模块 | 流水线级数 | 说明 |
|------|-----------|------|
| `silu_quadratic` | 3 | 8 段二次多项式 SiLU 近似，二分树段选择 |
| `bspline_lut` | 4 | 256 点 LUT + 线性插值，6 路基函数并行输出 |
| `mac` | 5 | Base + Spline 双路乘累加，舍入补偿 |

关键设计特点：
- **时分复用**：5→16→8→1 三层共享一套运算核心
- **Block RAM 存储**：1729 个 Q6.9 权重存入 6 块 BRAM；B 样条 LUT 占用 1 块 BRAM
- **11 状态 FSM**：S_IDLE → FEED → WAIT → MAC（×3 层）→ S_DONE
- **双缓冲**：buf_a / buf_b 实现层间数据无缝传递

### 4. 仿真验证

```bash
# RTL 精度评估
python verilog/eval_rtl_r2.py

# 误差来源分解
python verilog/analyze_quantization_error.py
```

| 指标 | 软件浮点 | RTL 硬件仿真 |
|------|---------|------------|
| R² | 0.9756 | **0.9758** |
| MAE（标准化空间） | 0.1187 | 0.1183 |
| RMSE（标准化空间） | 0.1615 | 0.1607 |
| 硬件 vs 浮点 MAE | — | **0.0093** |

推理延迟逐层分解：

| 层 | FEED | WAIT | MAC | 小计 |
|----|------|------|-----|------|
| L0 (5→16) | 6 | 4 | 16×(5+6) = 176 | 186 |
| L1 (16→8) | 17 | 4 | 8×(16+6) = 176 | 197 |
| L2 (8→1) | 9 | 4 | 1×(8+6) = 14 | 27 |
| FSM 开销 | — | — | — | 4 |
| **总计** | — | — | — | **414 @ 120 MHz = 3.45 μs** |

## 设计决策

四项关键设计决策使时序从 50MHz 收敛至 120MHz：

| # | 瓶颈 | 方案 | 效果 |
|---|------|------|------|
| 1 | MAC 7 路乘法 + 6 元素加法树同一拍完成 | 拆为 S1a（乘法）/ S1b（加法树）两拍 | 关键路径缩短约 40% |
| 2 | SiLU 8 级串行 if-else 比较器链 | 3 级二分决策树 | 比较深度 9 → 4 |
| 3 | B 样条 6 路组合插值 11.7 ns | 拆两拍 + ÷12 替换为 ×2731 >> 15 | 逻辑延迟 11.7 → 7.5 ns |
| 4 | 权重分布式 RAM 布线延迟 6.1 ns | Block RAM + MAC 输入寄存器 | 布线延迟 6.1 → 1.8 ns（↓70%） |

| 设计配置 | 100 MHz WNS |
|---------|------------|
| 未优化基线 | −9.69 ns |
| +MAC 拆分 +SiLU 二分树 | −9.69 ns |
| +B 样条流水线 + 除法替代 | **+0.49 ns** ✓ |
| +BRAM 权重存储（最终） | **+1.31 ns** → 120 MHz |

## 致谢

- [pykan](https://github.com/KindXiaoming/pykan) — KAN 官方实现 (Liu et al., 2024)
- [efficient-kan](https://github.com/Blealtan/efficient-kan) — 高效 KAN 实现，支持批量矩阵运算
- [NASA Airfoil Self-Noise Dataset](https://archive.ics.uci.edu/ml/datasets/Airfoil+Self-Noise) — UCI 机器学习数据库
- [Brooks, Pope & Marcolini (1989)](https://ntrs.nasa.gov/citations/19890016302) — BPM 气动声学模型
