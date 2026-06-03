"""
RTL仿真精度评估：计算RTL硬件输出的R²、MAE、RMSE
输入：
  - rtl_outputs.csv（由修改后的kan_top_tb_full.v生成）
  - 数据集真实标签（通过data_loader获取，含inverse_transform）
"""
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'dataset'))
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

import numpy as np
import csv
import torch
from data_loader import load_airfoil

RTL_CSV = os.path.join(os.path.dirname(__file__), 'rtl_outputs.csv')

def r2_score(y_true, y_pred):
    ss_res = np.sum((y_true - y_pred) ** 2)
    ss_tot = np.sum((y_true - y_true.mean()) ** 2)
    return 1 - ss_res / ss_tot

def main():
    # 1. 读取RTL仿真输出（标准化空间）
    rtl_data = {}
    with open(RTL_CSV, encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            sid = int(row['sample_id'])
            rtl_data[sid] = {
                'sw_pred': float(row['sw_pred']),
                'rtl_out': float(row['rtl_out']),
            }

    n = len(rtl_data)
    print(f"读取RTL输出：{n} 个样本")

    # 2. 加载数据集（标准化空间的真实标签 + scaler）
    dataset = load_airfoil()
    y_test_std = dataset['test_label'].numpy().ravel()   # 标准化空间

    # 3. 获取scaler做inverse_transform（还原到dB空间）
    # data_loader里用了StandardScaler，需要拿到scaler
    # 如果load_airfoil没有返回scaler，就在标准化空间做评估
    has_scaler = 'scaler_y' in dataset

    # 按sample_id排序
    ids = sorted(rtl_data.keys())
    sw_std  = np.array([rtl_data[i]['sw_pred'] for i in ids])
    rtl_std = np.array([rtl_data[i]['rtl_out'] for i in ids])
    gt_std  = np.array([y_test_std[i] for i in ids])

    print("\n=== 标准化空间评估 ===")
    print(f"{'指标':<20} {'软件浮点':>12} {'RTL硬件':>12}")
    print("-" * 46)
    print(f"{'R²':<20} {r2_score(gt_std, sw_std):>12.4f} {r2_score(gt_std, rtl_std):>12.4f}")
    print(f"{'MAE':<20} {np.mean(np.abs(gt_std - sw_std)):>12.4f} {np.mean(np.abs(gt_std - rtl_std)):>12.4f}")
    print(f"{'RMSE':<20} {np.sqrt(np.mean((gt_std-sw_std)**2)):>12.4f} {np.sqrt(np.mean((gt_std-rtl_std)**2)):>12.4f}")
    print(f"{'RTL vs SW MAE':<20} {'—':>12} {np.mean(np.abs(rtl_std - sw_std)):>12.4f}")
    print(f"{'RTL vs SW MaxErr':<20} {'—':>12} {np.max(np.abs(rtl_std - sw_std)):>12.4f}")

    if has_scaler:
        scaler_y = dataset['scaler_y']
        gt_db   = scaler_y.inverse_transform(gt_std.reshape(-1,1)).ravel()
        sw_db   = scaler_y.inverse_transform(sw_std.reshape(-1,1)).ravel()
        rtl_db  = scaler_y.inverse_transform(rtl_std.reshape(-1,1)).ravel()

        print("\n=== 原始dB空间评估 ===")
        print(f"{'指标':<20} {'软件浮点':>12} {'RTL硬件':>12}")
        print("-" * 46)
        print(f"{'R²':<20} {r2_score(gt_db, sw_db):>12.4f} {r2_score(gt_db, rtl_db):>12.4f}")
        print(f"{'MAE (dB)':<20} {np.mean(np.abs(gt_db - sw_db)):>12.4f} {np.mean(np.abs(gt_db - rtl_db)):>12.4f}")
        print(f"{'RMSE (dB)':<20} {np.sqrt(np.mean((gt_db-sw_db)**2)):>12.4f} {np.sqrt(np.mean((gt_db-rtl_db)**2)):>12.4f}")
    else:
        print("\n注意：data_loader未返回scaler_y，无法还原到dB空间")
        print("如需dB空间评估，请在data_loader.py中返回 scaler_y")

if __name__ == '__main__':
    main()
