/* mac_tb.v
 * MAC 模块仿真 testbench
 * 用已知数值手算验证累加结果
 */
`timescale 1ns/1ps

module mac_tb;

reg        clk, rst_n;
reg        acc_clear, valid_in;
reg signed [15:0] sx;
reg signed [15:0] bases_0, bases_1, bases_2, bases_3, bases_4, bases_5;
reg signed [15:0] base_w;
reg signed [15:0] spline_w_0, spline_w_1, spline_w_2;
reg signed [15:0] spline_w_3, spline_w_4, spline_w_5;
reg signed [15:0] spline_sc;
wire signed [31:0] acc;
wire               valid_out;

mac dut (
    .clk(clk), .rst_n(rst_n),
    .acc_clear(acc_clear), .valid_in(valid_in),
    .sx(sx),
    .bases_0(bases_0), .bases_1(bases_1), .bases_2(bases_2),
    .bases_3(bases_3), .bases_4(bases_4), .bases_5(bases_5),
    .base_w(base_w),
    .spline_w_0(spline_w_0), .spline_w_1(spline_w_1), .spline_w_2(spline_w_2),
    .spline_w_3(spline_w_3), .spline_w_4(spline_w_4), .spline_w_5(spline_w_5),
    .spline_sc(spline_sc),
    .acc(acc), .valid_out(valid_out)
);

initial clk = 0;
always #5 clk = ~clk;

// 监控输出
always @(posedge clk) begin
    if (valid_out)
        $display("acc = %d (Q6.9 -> real = %f)", acc, $itor($signed(acc)) / 512.0);
end

initial begin
    rst_n = 0; valid_in = 0; acc_clear = 0;
    sx = 0; base_w = 0; spline_sc = 0;
    bases_0=0; bases_1=0; bases_2=0; bases_3=0; bases_4=0; bases_5=0;
    spline_w_0=0; spline_w_1=0; spline_w_2=0;
    spline_w_3=0; spline_w_4=0; spline_w_5=0;

    repeat(3) @(posedge clk); #1;
    rst_n = 1;
    repeat(2) @(posedge clk); #1;

    $display("===== MAC Testbench =====");
    $display("Test 1: sx=1.0, base_w=100, bases全0 -> base_contrib=1.0*100*1.0=100, acc应≈100(Q6.9=51200)");

    // 测试1：只有 base 分支
    // sx = 1.0 = 512(Q6.9), base_w = 100(int16), scale_bw = 1.0
    // base_contrib = (512*100/512)*1.0 = 100.0 -> Q6.9 = 51200
    sx = 16'sd512;    // 1.0
    base_w = 16'sd100;
    spline_sc = 16'sd0;
    acc_clear = 1; valid_in = 1;
    @(posedge clk); #1;
    acc_clear = 0; valid_in = 0;
    repeat(5) @(posedge clk); #1;

    $display("Test 2: 累加第2个输入，sx=0.5, base_w=50 -> 再加50, acc应≈150");
    sx = 16'sd256;    // 0.5 = 256(Q6.9)
    base_w = 16'sd100;
    acc_clear = 0; valid_in = 1;
    @(posedge clk); #1;
    valid_in = 0;
    repeat(5) @(posedge clk); #1;

    $display("Test 3: spline分支, bases_2=16384(0.5), spline_w_2=64, scale=1.0, spline_sc=512(1.0)");
    $display("        spline_contrib = 0.5*64*1.0*1.0*1.0 = 32 -> Q6.9=16384");
    sx = 16'sd0;
    base_w = 16'sd0;
    bases_2 = 16'sd16384;   // 0.5 in Q1.15
    spline_w_2 = 16'sd64;
    spline_sc = 16'sd512;   // 1.0 in Q6.9 (当作int16使用)
    acc_clear = 1; valid_in = 1;
    @(posedge clk); #1;
    acc_clear = 0; valid_in = 0;
    repeat(5) @(posedge clk); #1;

    $display("===== Done =====");
    $stop;
end

endmodule
