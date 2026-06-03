/* bspline_lut_tb.v
 * B样条查表模块仿真
 * 测试 x=-3,-2,-1,0,1,2,3 的基函数值
 * 参考值由 Python 精确计算
 */
`timescale 1ns/1ps

module bspline_lut_tb;

reg         clk, rst_n, valid_in;
reg  signed [15:0] x;
wire [15:0] bases_0, bases_1, bases_2, bases_3, bases_4, bases_5;
wire        valid_out;

bspline_lut dut (
    .clk(clk), .rst_n(rst_n), .valid_in(valid_in),
    .x(x),
    .bases_0(bases_0), .bases_1(bases_1), .bases_2(bases_2),
    .bases_3(bases_3), .bases_4(bases_4), .bases_5(bases_5),
    .valid_out(valid_out)
);

initial clk = 0;
always #5 clk = ~clk;

// 输出监控
always @(posedge clk) begin
    if (valid_out) begin
        $display("x_raw=%6d -> bases=[%5d,%5d,%5d,%5d,%5d,%5d]  (Q1.15, 32767=1.0)",
            $signed(x),
            bases_0, bases_1, bases_2, bases_3, bases_4, bases_5);
    end
end

task send_x;
    input signed [15:0] xval;
    begin
        x = xval; valid_in = 1;
        @(posedge clk); #1;
        valid_in = 0;
        @(posedge clk); #1;
        @(posedge clk); #1;
        @(posedge clk); #1;
    end
endtask

initial begin
    rst_n = 0; valid_in = 0; x = 0;
    repeat(3) @(posedge clk); #1;
    rst_n = 1;
    repeat(2) @(posedge clk); #1;

    $display("===== B-Spline LUT Testbench =====");
    $display("Q6.9: 512=1.0  Q1.15: 32767=1.0");
    $display("每组基函数值之和应≈32767（归一化）");
    $display("");

    // x = -3.0 = -1536
    send_x(-16'sd1536);
    // x = -1.5 = -768
    send_x(-16'sd768);
    // x =  0.0
    send_x(16'sd0);
    // x =  1.0 = 512
    send_x(16'sd512);
    // x =  1.5 = 768
    send_x(16'sd768);
    // x =  3.0 = 1536
    send_x(16'sd1536);

    repeat(5) @(posedge clk);
    $display("===== Done =====");
    $stop;
end

endmodule
