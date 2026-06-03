"""
数据集统一加载接口
支持：NASA Airfoil Self-Noise、Feynman物理方程
"""
import os
import torch
import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split

DATA_DIR = os.path.join(os.path.dirname(__file__), 'data')
os.makedirs(DATA_DIR, exist_ok=True)


def load_airfoil(test_size=0.2, seed=42, normalize=True):
    """
    NASA Airfoil Self-Noise 数据集
    来源：UCI Machine Learning Repository
    特征（5个）：
      x1 - 频率 (Hz)
      x2 - 攻角 (degrees)
      x3 - 弦长 (m)
      x4 - 自由流速度 (m/s)
      x5 - 吸力侧位移厚度 (m)
    目标：声压级 (dB)
    """
    filepath = os.path.join(DATA_DIR, 'airfoil_self_noise.dat')

    if not os.path.exists(filepath):
        print("请下载数据集：")
        print("https://archive.ics.uci.edu/ml/machine-learning-databases/00291/airfoil_self_noise.dat")
        print(f"保存到：{filepath}")
        return None

    df = pd.read_csv(filepath, sep='\t', header=None,
                     names=['frequency', 'angle', 'chord_length',
                            'velocity', 'displacement', 'sound_pressure'])

    X = df.iloc[:, :-1].values.astype(np.float32)
    y = df.iloc[:, -1].values.astype(np.float32)

    x_train, x_test, y_train, y_test = train_test_split(
        X, y, test_size=test_size, random_state=seed)

    if normalize:
        scaler_x = StandardScaler()
        scaler_y = StandardScaler()
        x_train = scaler_x.fit_transform(x_train)
        x_test = scaler_x.transform(x_test)
        y_train = scaler_y.fit_transform(y_train.reshape(-1, 1)).ravel()
        y_test = scaler_y.transform(y_test.reshape(-1, 1)).ravel()

    dataset = {
        'train_input': torch.tensor(x_train),
        'train_label': torch.tensor(y_train).unsqueeze(1),
        'test_input': torch.tensor(x_test),
        'test_label': torch.tensor(y_test).unsqueeze(1),
        'feature_names': ['frequency', 'angle', 'chord_length', 'velocity', 'displacement'],
        'target_name': 'sound_pressure',
        'n_var': 5,
        'task': 'regression',
        'scaler_y': scaler_y if normalize else None,
    }
    print(f"Airfoil 数据集加载成功")
    print(f"  训练集: {x_train.shape[0]} 样本，测试集: {x_test.shape[0]} 样本")
    return dataset


def load_feynman(name, n_samples=1000, test_size=0.2, seed=42):
    """
    Feynman物理方程数据集（pykan内置）
    name: 方程编号，如 'I.34.8'（多普勒效应）或数字索引
    推荐航空相关：
      'I.34.8'  (34) - 多普勒效应：ω = ω0 / (1 - v/c)
      'I.50.26' (54) - 谐振：x = x1*(cos(ω0*t) + α*cos(ω0*t)²)
      'I.10.7'  (6)  - 相对论质量：m = m0/sqrt(1-v²/c²)
    """
    from kan.feynman import get_feynman_dataset
    from kan.utils import create_dataset

    torch.manual_seed(seed)
    f, ranges, expr = None, None, None

    result = get_feynman_dataset(name)
    symbol, expr, f, ranges = result

    # 生成数据
    n_var = len(ranges) if isinstance(ranges[0], list) else 1
    if isinstance(ranges[0], list):
        x = torch.cat([
            torch.rand(n_samples, 1) * (r[1] - r[0]) + r[0]
            for r in ranges
        ], dim=1)
    else:
        x = torch.rand(n_samples, 1) * (ranges[1] - ranges[0]) + ranges[0]

    y = f(x)

    # 划分训练/测试集
    n_train = int(n_samples * (1 - test_size))
    dataset = {
        'train_input': x[:n_train],
        'train_label': y[:n_train],
        'test_input': x[n_train:],
        'test_label': y[n_train:],
        'formula': expr,
        'n_var': x.shape[1],
        'task': 'regression',
    }
    print(f"Feynman '{name}' 数据集加载成功")
    print(f"  真实公式: {expr}")
    print(f"  输入维度: {x.shape[1]}，样本数: {n_samples}")
    return dataset
