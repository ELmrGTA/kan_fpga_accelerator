/* kan_top_tb.v
 * KAN top-level testbench with multiple test samples
 * Tests 5 diverse samples from the test dataset
 */
`timescale 1ns/1ps

module kan_top_tb;

reg         clk, rst_n, start;
reg  signed [15:0] in_0, in_1, in_2, in_3, in_4;
wire signed [15:0] out_0;
wire               done;

kan_top dut (
    .clk(clk), .rst_n(rst_n), .start(start),
    .in_0(in_0), .in_1(in_1), .in_2(in_2), .in_3(in_3), .in_4(in_4),
    .out_0(out_0), .done(done)
);

initial clk = 0;
always #5 clk = ~clk;  // 100MHz

integer cycle_cnt;
integer sample_id;
real expected, actual, error, abs_error;
integer expected_q9;
real sum_abs_error, max_abs_error;
integer num_samples;

always @(posedge clk) begin
    if (start) cycle_cnt <= 0;
    else       cycle_cnt <= cycle_cnt + 1;
end

always @(posedge clk) begin
    if (done) begin
        actual = $itor($signed(out_0)) / 512.0;
        error = actual - expected;
        abs_error = (error >= 0) ? error : -error;

        $display("Sample %0d:", sample_id);
        $display("  Expected: %f (Q6.9=%0d)", expected, expected_q9);
        $display("  Actual:   %f (Q6.9=%0d)", actual, $signed(out_0));
        $display("  Error:    %f", error);
        $display("  Cycles:   %0d", cycle_cnt);
        $display("");

        sum_abs_error = sum_abs_error + abs_error;
        if (abs_error > max_abs_error) max_abs_error = abs_error;
    end
end

initial begin
    rst_n = 0; start = 0; cycle_cnt = 0;
    in_0 = 0; in_1 = 0; in_2 = 0; in_3 = 0; in_4 = 0;
    sum_abs_error = 0.0; max_abs_error = 0.0; num_samples = 20;

    repeat(5) @(posedge clk); #1;
    rst_n = 1;
    repeat(2) @(posedge clk); #1;

    $display("===== KAN Top Testbench - 20 Test Samples =====");
    $display("");

    // Sample 0: idx=5, ground_truth=-0.6002
    sample_id = 0;
    in_0 = -16'sd332; in_1 = -16'sd173; in_2 = -16'sd615; in_3 = -16'sd385; in_4 = -16'sd400;
    expected = -0.560631; expected_q9 = -287;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 1: idx=9, ground_truth=-0.1293
    sample_id = 1;
    in_0 = -16'sd260; in_1 = -16'sd120; in_2 = 16'sd81; in_3 = -16'sd645; in_4 = -16'sd229;
    expected = 0.218723; expected_q9 = 112;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 2: idx=33, ground_truth=-0.6234
    sample_id = 2;
    in_0 = 16'sd822; in_1 = 16'sd521; in_2 = -16'sd615; in_3 = -16'sd385; in_4 = 16'sd77;
    expected = -0.570358; expected_q9 = -292;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 3: idx=45, ground_truth=1.3208
    sample_id = 3;
    in_0 = 16'sd181; in_1 = -16'sd173; in_2 = -16'sd615; in_3 = 16'sd138; in_4 = -16'sd401;
    expected = 1.402140; expected_q9 = 718;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 4: idx=46, ground_truth=0.8063
    sample_id = 4;
    in_0 = -16'sd300; in_1 = 16'sd758; in_2 = -16'sd476; in_3 = 16'sd138; in_4 = 16'sd634;
    expected = 0.904244; expected_q9 = 463;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 5: idx=60, ground_truth=0.2577
    sample_id = 5;
    in_0 = -16'sd140; in_1 = -16'sd462; in_2 = 16'sd917; in_3 = 16'sd657; in_4 = -16'sd303;
    expected = 0.167519; expected_q9 = 86;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 6: idx=97, ground_truth=-1.5219
    sample_id = 6;
    in_0 = 16'sd341; in_1 = 16'sd758; in_2 = -16'sd476; in_3 = -16'sd385; in_4 = 16'sd676;
    expected = -1.578553; expected_q9 = -808;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 7: idx=101, ground_truth=-2.5885
    sample_id = 7;
    in_0 = 16'sd341; in_1 = 16'sd486; in_2 = -16'sd197; in_3 = -16'sd645; in_4 = 16'sd1211;
    expected = -2.561536; expected_q9 = -1312;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 8: idx=116, ground_truth=-1.2144
    sample_id = 8;
    in_0 = -16'sd60; in_1 = 16'sd47; in_2 = 16'sd499; in_3 = -16'sd385; in_4 = 16'sd50;
    expected = -1.290929; expected_q9 = -661;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 9: idx=118, ground_truth=0.7446
    sample_id = 9;
    in_0 = -16'sd204; in_1 = 16'sd521; in_2 = -16'sd615; in_3 = -16'sd385; in_4 = 16'sd77;
    expected = 0.591482; expected_q9 = 303;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 10: idx=124, ground_truth=-2.4590
    sample_id = 10;
    in_0 = 16'sd181; in_1 = 16'sd512; in_2 = 16'sd81; in_3 = 16'sd657; in_4 = 16'sd1464;
    expected = -2.149254; expected_q9 = -1100;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 11: idx=154, ground_truth=-0.4149
    sample_id = 11;
    in_0 = 16'sd181; in_1 = -16'sd594; in_2 = 16'sd499; in_3 = -16'sd645; in_4 = -16'sd329;
    expected = -0.304156; expected_q9 = -156;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 12: idx=158, ground_truth=1.4760
    sample_id = 12;
    in_0 = 16'sd550; in_1 = -16'sd594; in_2 = -16'sd615; in_3 = 16'sd657; in_4 = -16'sd420;
    expected = 1.197268; expected_q9 = 613;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 13: idx=164, ground_truth=-1.0223
    sample_id = 13;
    in_0 = -16'sd204; in_1 = 16'sd486; in_2 = -16'sd197; in_3 = -16'sd385; in_4 = 16'sd1170;
    expected = -0.974311; expected_q9 = -499;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 14: idx=173, ground_truth=1.0572
    sample_id = 14;
    in_0 = -16'sd397; in_1 = 16'sd38; in_2 = 16'sd81; in_3 = -16'sd385; in_4 = -16'sd78;
    expected = 0.930875; expected_q9 = 477;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 15: idx=177, ground_truth=-0.5286
    sample_id = 15;
    in_0 = -16'sd140; in_1 = 16'sd1354; in_2 = -16'sd615; in_3 = -16'sd385; in_4 = 16'sd465;
    expected = -0.386008; expected_q9 = -198;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 16: idx=198, ground_truth=0.5278
    sample_id = 16;
    in_0 = -16'sd332; in_1 = -16'sd418; in_2 = 16'sd499; in_3 = 16'sd138; in_4 = -16'sd312;
    expected = 0.618013; expected_q9 = 316;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 17: idx=228, ground_truth=-0.8114
    sample_id = 17;
    in_0 = -16'sd421; in_1 = -16'sd594; in_2 = 16'sd917; in_3 = -16'sd385; in_4 = -16'sd314;
    expected = -0.638253; expected_q9 = -327;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 18: idx=230, ground_truth=-0.6161
    sample_id = 18;
    in_0 = -16'sd360; in_1 = 16'sd1354; in_2 = -16'sd615; in_3 = 16'sd657; in_4 = 16'sd407;
    expected = -1.000947; expected_q9 = -512;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 19: idx=289, ground_truth=-0.1279
    sample_id = 19;
    in_0 = -16'sd397; in_1 = -16'sd462; in_2 = 16'sd917; in_3 = -16'sd385; in_4 = -16'sd282;
    expected = -0.098724; expected_q9 = -51;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    $display("===== Summary =====");
    $display("Total samples:    %0d", num_samples);
    $display("Mean abs error:   %f", sum_abs_error / num_samples);
    $display("Max abs error:    %f", max_abs_error);
    $display("==================");

    $stop;
end

endmodule