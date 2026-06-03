"""
全测试集：软件浮点 vs 定点链（权重量化 Q6.9 + 输入 Q6.9）输出对比表

说明：
- software_float：PyTorch 浮点模型、浮点输入（与训练一致）。
- fixed_point_chain：权重按 gen_weight_hex 思路 round(w*512)/512 代入模型，输入 round(x*512)/512，
  仍在 PyTorch 中做浮点前向（激活与样条仍为浮点实现），用于全样本覆盖的「定点数据通路」近似。
  与 RTL 门级输出在个别样本上会有差异（RTL 含 SiLU 分段近似、B 样条 LUT 等）。
- 若需与仿真波形逐样本对照，请使用 simulate.log 或 accuracy_rtl_subset.csv（20 个 TB 样本）。

输出：verilog/accuracy_full_testset_sw_fp.csv
"""
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "dataset"))
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

import numpy as np
import torch
from data_loader import load_airfoil
from efficient_kan import KAN

Q9_SCALE = 512.0
WEIGHTS = os.path.join(os.path.dirname(__file__), "..", "weights", "kan_16_8_full_data.pth")
OUT_CSV = os.path.join(os.path.dirname(__file__), "accuracy_full_testset_sw_fp.csv")


def quantize_model_weights_inplace(model: torch.nn.Module) -> None:
    with torch.no_grad():
        for p in model.parameters():
            q = torch.round(p.data * Q9_SCALE).clamp(-32767, 32767)
            p.data.copy_(q / Q9_SCALE)


def main():
    dataset = load_airfoil()
    x_test = dataset["test_input"].float()
    y_test = dataset["test_label"].float().numpy().ravel()
    n = x_test.shape[0]

    model_fp = KAN([5, 16, 8, 1], grid_size=3, spline_order=3)
    model_fp.load_state_dict(torch.load(WEIGHTS, map_location="cpu"))
    model_fp.eval()

    with torch.no_grad():
        y_sw = model_fp(x_test).numpy().ravel()

    model_q = KAN([5, 16, 8, 1], grid_size=3, spline_order=3)
    model_q.load_state_dict(torch.load(WEIGHTS, map_location="cpu"))
    quantize_model_weights_inplace(model_q)
    model_q.eval()

    x_q = torch.round(x_test * Q9_SCALE) / Q9_SCALE
    with torch.no_grad():
        y_fpchain = model_q(x_q).numpy().ravel()

    err = y_fpchain - y_sw

    with open(OUT_CSV, "w", encoding="utf-8") as f:
        f.write(
            "test_idx,ground_truth,software_float,fixed_point_chain,error_fp_minus_sw\n"
        )
        for i in range(n):
            f.write(
                f"{i},{y_test[i]:.8f},{y_sw[i]:.8f},{y_fpchain[i]:.8f},{err[i]:.8f}\n"
            )

    print(f"样本数: {n}")
    print(f"已写入: {OUT_CSV}")
    print(f"|error| mean: {np.mean(np.abs(err)):.6f}  max: {np.max(np.abs(err)):.6f}")


if __name__ == "__main__":
    main()
