/* kan_top_tb_full.v
 * KAN top-level testbench - 301 test samples (full test set)
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
integer fout;

always @(posedge clk) begin
    if (start) cycle_cnt <= 0;
    else       cycle_cnt <= cycle_cnt + 1;
end

always @(posedge clk) begin
    if (done) begin
        actual = $itor($signed(out_0)) / 512.0;
        error = actual - expected;
        abs_error = (error >= 0) ? error : -error;
        sum_abs_error = sum_abs_error + abs_error;
        if (abs_error > max_abs_error) max_abs_error = abs_error;
        $fdisplay(fout, "%0d,%f,%f", sample_id, expected, actual);
    end
end

initial begin
    rst_n = 0; start = 0; cycle_cnt = 0;
    in_0 = 0; in_1 = 0; in_2 = 0; in_3 = 0; in_4 = 0;
    sum_abs_error = 0.0; max_abs_error = 0.0; num_samples = 301;
    fout = $fopen("rtl_outputs.csv", "w");
    $fdisplay(fout, "sample_id,sw_pred,rtl_out");

    repeat(5) @(posedge clk); #1;
    rst_n = 1;
    repeat(2) @(posedge clk); #1;

    $display("===== KAN Top Testbench - 301 Test Samples =====");
    $display("");

    // Sample 0: sw_pred=0.042356
    sample_id = 0;
    in_0 = -16'sd397; in_1 = -16'sd594; in_2 = 16'sd917; in_3 = -16'sd645; in_4 = -16'sd305;
    expected = 0.042356; expected_q9 = 22;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 1: sw_pred=-1.040606
    sample_id = 1;
    in_0 = -16'sd260; in_1 = 16'sd486; in_2 = -16'sd197; in_3 = -16'sd645; in_4 = 16'sd1211;
    expected = -1.040606; expected_q9 = -533;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 2: sw_pred=-0.757561
    sample_id = 2;
    in_0 = -16'sd60; in_1 = -16'sd243; in_2 = 16'sd917; in_3 = -16'sd385; in_4 = -16'sd208;
    expected = -0.757561; expected_q9 = -388;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 3: sw_pred=1.683195
    sample_id = 3;
    in_0 = 16'sd181; in_1 = -16'sd594; in_2 = -16'sd615; in_3 = -16'sd645; in_4 = -16'sd418;
    expected = 1.683195; expected_q9 = 862;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 4: sw_pred=1.442127
    sample_id = 4;
    in_0 = 16'sd341; in_1 = -16'sd594; in_2 = -16'sd476; in_3 = 16'sd138; in_4 = -16'sd406;
    expected = 1.442127; expected_q9 = 738;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 5: sw_pred=-0.560631
    sample_id = 5;
    in_0 = -16'sd332; in_1 = -16'sd173; in_2 = -16'sd615; in_3 = -16'sd385; in_4 = -16'sd400;
    expected = -0.560631; expected_q9 = -287;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 6: sw_pred=-0.113472
    sample_id = 6;
    in_0 = -16'sd300; in_1 = 16'sd758; in_2 = -16'sd476; in_3 = -16'sd645; in_4 = 16'sd704;
    expected = -0.113472; expected_q9 = -58;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 7: sw_pred=1.861207
    sample_id = 7;
    in_0 = -16'sd380; in_1 = 16'sd47; in_2 = 16'sd499; in_3 = 16'sd657; in_4 = -16'sd25;
    expected = 1.861207; expected_q9 = 953;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 8: sw_pred=0.965489
    sample_id = 8;
    in_0 = -16'sd397; in_1 = 16'sd38; in_2 = 16'sd81; in_3 = 16'sd657; in_4 = -16'sd140;
    expected = 0.965489; expected_q9 = 494;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 9: sw_pred=0.218723
    sample_id = 9;
    in_0 = -16'sd260; in_1 = -16'sd120; in_2 = 16'sd81; in_3 = -16'sd645; in_4 = -16'sd229;
    expected = 0.218723; expected_q9 = 112;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 10: sw_pred=0.408263
    sample_id = 10;
    in_0 = -16'sd300; in_1 = -16'sd594; in_2 = -16'sd476; in_3 = -16'sd645; in_4 = -16'sd404;
    expected = 0.408263; expected_q9 = 209;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 11: sw_pred=-2.109378
    sample_id = 11;
    in_0 = 16'sd822; in_1 = -16'sd331; in_2 = 16'sd917; in_3 = -16'sd385; in_4 = -16'sd241;
    expected = -2.109378; expected_q9 = -1080;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 12: sw_pred=1.267019
    sample_id = 12;
    in_0 = -16'sd204; in_1 = 16'sd521; in_2 = -16'sd615; in_3 = 16'sd657; in_4 = 16'sd43;
    expected = 1.267019; expected_q9 = 649;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 13: sw_pred=1.252246
    sample_id = 13;
    in_0 = -16'sd204; in_1 = 16'sd240; in_2 = -16'sd615; in_3 = 16'sd657; in_4 = -16'sd270;
    expected = 1.252246; expected_q9 = 641;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 14: sw_pred=-0.231905
    sample_id = 14;
    in_0 = -16'sd204; in_1 = 16'sd47; in_2 = 16'sd499; in_3 = 16'sd138; in_4 = 16'sd4;
    expected = -0.231905; expected_q9 = -119;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 15: sw_pred=-2.199554
    sample_id = 15;
    in_0 = 16'sd550; in_1 = 16'sd486; in_2 = -16'sd197; in_3 = -16'sd385; in_4 = 16'sd1170;
    expected = -2.199554; expected_q9 = -1126;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 16: sw_pred=0.631497
    sample_id = 16;
    in_0 = -16'sd300; in_1 = -16'sd129; in_2 = 16'sd499; in_3 = -16'sd385; in_4 = -16'sd194;
    expected = 0.631497; expected_q9 = 323;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 17: sw_pred=0.713528
    sample_id = 17;
    in_0 = -16'sd410; in_1 = 16'sd38; in_2 = 16'sd81; in_3 = -16'sd385; in_4 = -16'sd78;
    expected = 0.713528; expected_q9 = 365;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 18: sw_pred=0.548240
    sample_id = 18;
    in_0 = -16'sd300; in_1 = -16'sd418; in_2 = 16'sd499; in_3 = 16'sd657; in_4 = -16'sd320;
    expected = 0.548240; expected_q9 = 281;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 19: sw_pred=-0.713961
    sample_id = 19;
    in_0 = -16'sd397; in_1 = 16'sd143; in_2 = -16'sd476; in_3 = 16'sd138; in_4 = -16'sd221;
    expected = -0.713961; expected_q9 = -366;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 20: sw_pred=-0.052634
    sample_id = 20;
    in_0 = 16'sd181; in_1 = -16'sd594; in_2 = 16'sd81; in_3 = -16'sd385; in_4 = -16'sd360;
    expected = -0.052634; expected_q9 = -27;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 21: sw_pred=0.637487
    sample_id = 21;
    in_0 = 16'sd1143; in_1 = -16'sd594; in_2 = -16'sd476; in_3 = 16'sd657; in_4 = -16'sd407;
    expected = 0.637487; expected_q9 = 326;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 22: sw_pred=-2.278830
    sample_id = 22;
    in_0 = 16'sd341; in_1 = 16'sd275; in_2 = 16'sd81; in_3 = -16'sd645; in_4 = 16'sd558;
    expected = -2.278830; expected_q9 = -1167;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 23: sw_pred=0.232342
    sample_id = 23;
    in_0 = -16'sd380; in_1 = -16'sd418; in_2 = 16'sd499; in_3 = 16'sd657; in_4 = -16'sd320;
    expected = 0.232342; expected_q9 = 119;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 24: sw_pred=-0.101469
    sample_id = 24;
    in_0 = -16'sd410; in_1 = 16'sd758; in_2 = -16'sd476; in_3 = -16'sd385; in_4 = 16'sd676;
    expected = -0.101469; expected_q9 = -52;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 25: sw_pred=-0.039229
    sample_id = 25;
    in_0 = 16'sd550; in_1 = -16'sd594; in_2 = -16'sd197; in_3 = -16'sd385; in_4 = -16'sd378;
    expected = -0.039229; expected_q9 = -20;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 26: sw_pred=0.162757
    sample_id = 26;
    in_0 = -16'sd300; in_1 = -16'sd225; in_2 = -16'sd476; in_3 = -16'sd385; in_4 = -16'sd376;
    expected = 0.162757; expected_q9 = 83;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 27: sw_pred=0.906323
    sample_id = 27;
    in_0 = -16'sd332; in_1 = -16'sd129; in_2 = 16'sd499; in_3 = -16'sd385; in_4 = -16'sd194;
    expected = 0.906323; expected_q9 = 464;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 28: sw_pred=-2.123647
    sample_id = 28;
    in_0 = 16'sd341; in_1 = 16'sd486; in_2 = -16'sd197; in_3 = -16'sd385; in_4 = 16'sd1170;
    expected = -2.123647; expected_q9 = -1087;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 29: sw_pred=0.650343
    sample_id = 29;
    in_0 = -16'sd429; in_1 = 16'sd775; in_2 = -16'sd197; in_3 = 16'sd657; in_4 = 16'sd1284;
    expected = 0.650343; expected_q9 = 333;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 30: sw_pred=1.662330
    sample_id = 30;
    in_0 = -16'sd300; in_1 = 16'sd933; in_2 = -16'sd615; in_3 = -16'sd385; in_4 = 16'sd242;
    expected = 1.662330; expected_q9 = 851;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 31: sw_pred=-0.257566
    sample_id = 31;
    in_0 = 16'sd822; in_1 = -16'sd594; in_2 = 16'sd81; in_3 = 16'sd657; in_4 = -16'sd373;
    expected = -0.257566; expected_q9 = -132;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 32: sw_pred=0.002146
    sample_id = 32;
    in_0 = -16'sd260; in_1 = 16'sd38; in_2 = 16'sd81; in_3 = -16'sd385; in_4 = -16'sd78;
    expected = 0.002146; expected_q9 = 1;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 33: sw_pred=-0.570359
    sample_id = 33;
    in_0 = 16'sd822; in_1 = 16'sd521; in_2 = -16'sd615; in_3 = -16'sd385; in_4 = 16'sd77;
    expected = -0.570359; expected_q9 = -292;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 34: sw_pred=-0.749560
    sample_id = 34;
    in_0 = 16'sd181; in_1 = -16'sd243; in_2 = 16'sd917; in_3 = 16'sd657; in_4 = -16'sd240;
    expected = -0.749560; expected_q9 = -384;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 35: sw_pred=1.065510
    sample_id = 35;
    in_0 = -16'sd429; in_1 = 16'sd187; in_2 = -16'sd197; in_3 = 16'sd657; in_4 = -16'sd30;
    expected = 1.065510; expected_q9 = 546;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 36: sw_pred=1.411442
    sample_id = 36;
    in_0 = -16'sd60; in_1 = -16'sd594; in_2 = -16'sd476; in_3 = -16'sd385; in_4 = -16'sd405;
    expected = 1.411442; expected_q9 = 723;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 37: sw_pred=0.720403
    sample_id = 37;
    in_0 = -16'sd380; in_1 = -16'sd129; in_2 = 16'sd499; in_3 = 16'sd657; in_4 = -16'sd231;
    expected = 0.720403; expected_q9 = 369;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 38: sw_pred=-0.465172
    sample_id = 38;
    in_0 = 16'sd181; in_1 = 16'sd933; in_2 = -16'sd615; in_3 = -16'sd385; in_4 = 16'sd242;
    expected = -0.465172; expected_q9 = -238;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 39: sw_pred=-2.325072
    sample_id = 39;
    in_0 = -16'sd60; in_1 = 16'sd486; in_2 = -16'sd197; in_3 = -16'sd645; in_4 = 16'sd1211;
    expected = -2.325072; expected_q9 = -1190;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 40: sw_pred=0.081012
    sample_id = 40;
    in_0 = -16'sd60; in_1 = -16'sd243; in_2 = 16'sd499; in_3 = 16'sd657; in_4 = -16'sd278;
    expected = 0.081012; expected_q9 = 41;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 41: sw_pred=1.546254
    sample_id = 41;
    in_0 = 16'sd341; in_1 = -16'sd173; in_2 = -16'sd615; in_3 = 16'sd138; in_4 = -16'sd401;
    expected = 1.546254; expected_q9 = 792;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 42: sw_pred=0.042873
    sample_id = 42;
    in_0 = -16'sd300; in_1 = 16'sd275; in_2 = 16'sd81; in_3 = 16'sd657; in_4 = 16'sd323;
    expected = 0.042873; expected_q9 = 22;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 43: sw_pred=-0.528314
    sample_id = 43;
    in_0 = -16'sd429; in_1 = 16'sd758; in_2 = -16'sd476; in_3 = -16'sd645; in_4 = 16'sd704;
    expected = -0.528314; expected_q9 = -270;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 44: sw_pred=0.176389
    sample_id = 44;
    in_0 = -16'sd410; in_1 = -16'sd243; in_2 = 16'sd917; in_3 = -16'sd385; in_4 = -16'sd208;
    expected = 0.176389; expected_q9 = 90;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 45: sw_pred=1.402140
    sample_id = 45;
    in_0 = 16'sd181; in_1 = -16'sd173; in_2 = -16'sd615; in_3 = 16'sd138; in_4 = -16'sd401;
    expected = 1.402140; expected_q9 = 718;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 46: sw_pred=0.904245
    sample_id = 46;
    in_0 = -16'sd300; in_1 = 16'sd758; in_2 = -16'sd476; in_3 = 16'sd138; in_4 = 16'sd634;
    expected = 0.904245; expected_q9 = 463;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 47: sw_pred=-1.102229
    sample_id = 47;
    in_0 = 16'sd341; in_1 = 16'sd758; in_2 = -16'sd476; in_3 = 16'sd138; in_4 = 16'sd634;
    expected = -1.102229; expected_q9 = -564;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 48: sw_pred=-0.170185
    sample_id = 48;
    in_0 = 16'sd1143; in_1 = -16'sd594; in_2 = -16'sd197; in_3 = 16'sd657; in_4 = -16'sd388;
    expected = -0.170185; expected_q9 = -87;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 49: sw_pred=1.284469
    sample_id = 49;
    in_0 = 16'sd45; in_1 = -16'sd173; in_2 = -16'sd615; in_3 = 16'sd657; in_4 = -16'sd402;
    expected = 1.284469; expected_q9 = 658;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 50: sw_pred=0.828803
    sample_id = 50;
    in_0 = -16'sd60; in_1 = -16'sd594; in_2 = -16'sd197; in_3 = -16'sd645; in_4 = -16'sd377;
    expected = 0.828803; expected_q9 = 424;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 51: sw_pred=-1.259530
    sample_id = 51;
    in_0 = 16'sd822; in_1 = -16'sd462; in_2 = 16'sd917; in_3 = 16'sd657; in_4 = -16'sd303;
    expected = -1.259530; expected_q9 = -645;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 52: sw_pred=0.628815
    sample_id = 52;
    in_0 = 16'sd822; in_1 = -16'sd173; in_2 = -16'sd615; in_3 = -16'sd385; in_4 = -16'sd400;
    expected = 0.628815; expected_q9 = 322;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 53: sw_pred=0.730189
    sample_id = 53;
    in_0 = -16'sd429; in_1 = 16'sd275; in_2 = 16'sd81; in_3 = -16'sd645; in_4 = 16'sd558;
    expected = 0.730189; expected_q9 = 374;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 54: sw_pred=0.167231
    sample_id = 54;
    in_0 = -16'sd300; in_1 = -16'sd462; in_2 = 16'sd917; in_3 = 16'sd657; in_4 = -16'sd303;
    expected = 0.167231; expected_q9 = 86;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 55: sw_pred=-0.602861
    sample_id = 55;
    in_0 = 16'sd181; in_1 = 16'sd933; in_2 = -16'sd615; in_3 = -16'sd645; in_4 = 16'sd259;
    expected = -0.602861; expected_q9 = -309;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 56: sw_pred=-0.181743
    sample_id = 56;
    in_0 = 16'sd45; in_1 = -16'sd594; in_2 = 16'sd499; in_3 = -16'sd645; in_4 = -16'sd329;
    expected = -0.181743; expected_q9 = -93;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 57: sw_pred=0.718986
    sample_id = 57;
    in_0 = -16'sd332; in_1 = -16'sd357; in_2 = 16'sd81; in_3 = -16'sd385; in_4 = -16'sd320;
    expected = 0.718986; expected_q9 = 368;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 58: sw_pred=-0.738338
    sample_id = 58;
    in_0 = -16'sd421; in_1 = -16'sd594; in_2 = 16'sd917; in_3 = -16'sd645; in_4 = -16'sd305;
    expected = -0.738338; expected_q9 = -378;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 59: sw_pred=-0.615502
    sample_id = 59;
    in_0 = 16'sd341; in_1 = -16'sd243; in_2 = 16'sd499; in_3 = 16'sd657; in_4 = -16'sd278;
    expected = -0.615502; expected_q9 = -315;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 60: sw_pred=0.167520
    sample_id = 60;
    in_0 = -16'sd140; in_1 = -16'sd462; in_2 = 16'sd917; in_3 = 16'sd657; in_4 = -16'sd303;
    expected = 0.167520; expected_q9 = 86;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 61: sw_pred=1.584127
    sample_id = 61;
    in_0 = 16'sd181; in_1 = -16'sd594; in_2 = -16'sd476; in_3 = 16'sd138; in_4 = -16'sd406;
    expected = 1.584127; expected_q9 = 811;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 62: sw_pred=0.918260
    sample_id = 62;
    in_0 = -16'sd360; in_1 = -16'sd120; in_2 = 16'sd81; in_3 = -16'sd645; in_4 = -16'sd229;
    expected = 0.918260; expected_q9 = 470;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 63: sw_pred=1.602663
    sample_id = 63;
    in_0 = -16'sd140; in_1 = 16'sd143; in_2 = -16'sd476; in_3 = 16'sd657; in_4 = -16'sd227;
    expected = 1.602663; expected_q9 = 821;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 64: sw_pred=-0.941572
    sample_id = 64;
    in_0 = 16'sd341; in_1 = -16'sd418; in_2 = 16'sd499; in_3 = -16'sd645; in_4 = -16'sd289;
    expected = -0.941572; expected_q9 = -482;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 65: sw_pred=0.224479
    sample_id = 65;
    in_0 = -16'sd140; in_1 = 16'sd933; in_2 = -16'sd615; in_3 = -16'sd645; in_4 = 16'sd259;
    expected = 0.224479; expected_q9 = 115;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 66: sw_pred=0.423692
    sample_id = 66;
    in_0 = 16'sd550; in_1 = 16'sd240; in_2 = -16'sd615; in_3 = 16'sd657; in_4 = -16'sd270;
    expected = 0.423692; expected_q9 = 217;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 67: sw_pred=-0.699269
    sample_id = 67;
    in_0 = -16'sd140; in_1 = 16'sd1135; in_2 = -16'sd476; in_3 = 16'sd657; in_4 = 16'sd906;
    expected = -0.699269; expected_q9 = -358;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 68: sw_pred=-0.119531
    sample_id = 68;
    in_0 = -16'sd360; in_1 = -16'sd594; in_2 = 16'sd81; in_3 = -16'sd385; in_4 = -16'sd360;
    expected = -0.119531; expected_q9 = -61;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 69: sw_pred=0.639760
    sample_id = 69;
    in_0 = -16'sd300; in_1 = -16'sd594; in_2 = 16'sd499; in_3 = -16'sd385; in_4 = -16'sd336;
    expected = 0.639760; expected_q9 = 328;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 70: sw_pred=0.580592
    sample_id = 70;
    in_0 = -16'sd332; in_1 = -16'sd594; in_2 = 16'sd81; in_3 = -16'sd645; in_4 = -16'sd353;
    expected = 0.580592; expected_q9 = 297;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 71: sw_pred=0.970857
    sample_id = 71;
    in_0 = -16'sd204; in_1 = -16'sd594; in_2 = -16'sd476; in_3 = -16'sd645; in_4 = -16'sd404;
    expected = 0.970857; expected_q9 = 497;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 72: sw_pred=0.577224
    sample_id = 72;
    in_0 = -16'sd360; in_1 = -16'sd418; in_2 = 16'sd499; in_3 = -16'sd385; in_4 = -16'sd299;
    expected = 0.577224; expected_q9 = 296;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 73: sw_pred=-1.351370
    sample_id = 73;
    in_0 = 16'sd181; in_1 = 16'sd758; in_2 = -16'sd476; in_3 = -16'sd645; in_4 = 16'sd704;
    expected = -1.351370; expected_q9 = -692;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 74: sw_pred=0.744433
    sample_id = 74;
    in_0 = -16'sd204; in_1 = -16'sd594; in_2 = -16'sd476; in_3 = -16'sd385; in_4 = -16'sd405;
    expected = 0.744433; expected_q9 = 381;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 75: sw_pred=0.847707
    sample_id = 75;
    in_0 = 16'sd181; in_1 = 16'sd521; in_2 = -16'sd615; in_3 = 16'sd657; in_4 = 16'sd43;
    expected = 0.847707; expected_q9 = 434;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 76: sw_pred=1.127402
    sample_id = 76;
    in_0 = -16'sd421; in_1 = 16'sd47; in_2 = 16'sd499; in_3 = -16'sd385; in_4 = 16'sd50;
    expected = 1.127402; expected_q9 = 577;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 77: sw_pred=1.193534
    sample_id = 77;
    in_0 = -16'sd204; in_1 = -16'sd304; in_2 = -16'sd197; in_3 = -16'sd385; in_4 = -16'sd339;
    expected = 1.193534; expected_q9 = 611;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 78: sw_pred=1.290251
    sample_id = 78;
    in_0 = 16'sd45; in_1 = -16'sd594; in_2 = -16'sd615; in_3 = -16'sd385; in_4 = -16'sd419;
    expected = 1.290251; expected_q9 = 661;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 79: sw_pred=1.746347
    sample_id = 79;
    in_0 = 16'sd822; in_1 = -16'sd594; in_2 = -16'sd615; in_3 = -16'sd385; in_4 = -16'sd419;
    expected = 1.746347; expected_q9 = 894;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 80: sw_pred=0.007638
    sample_id = 80;
    in_0 = -16'sd332; in_1 = 16'sd758; in_2 = -16'sd476; in_3 = -16'sd645; in_4 = 16'sd704;
    expected = 0.007638; expected_q9 = 4;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 81: sw_pred=-0.864793
    sample_id = 81;
    in_0 = 16'sd341; in_1 = 16'sd933; in_2 = -16'sd615; in_3 = -16'sd645; in_4 = 16'sd259;
    expected = -0.864793; expected_q9 = -443;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 82: sw_pred=-0.876443
    sample_id = 82;
    in_0 = -16'sd429; in_1 = -16'sd594; in_2 = 16'sd917; in_3 = -16'sd385; in_4 = -16'sd314;
    expected = -0.876443; expected_q9 = -449;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 83: sw_pred=-0.096467
    sample_id = 83;
    in_0 = -16'sd60; in_1 = 16'sd933; in_2 = -16'sd615; in_3 = 16'sd138; in_4 = 16'sd216;
    expected = -0.096467; expected_q9 = -49;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 84: sw_pred=-0.901164
    sample_id = 84;
    in_0 = 16'sd550; in_1 = 16'sd240; in_2 = -16'sd615; in_3 = -16'sd645; in_4 = -16'sd254;
    expected = -0.901164; expected_q9 = -461;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 85: sw_pred=-0.617874
    sample_id = 85;
    in_0 = -16'sd300; in_1 = 16'sd775; in_2 = -16'sd197; in_3 = -16'sd385; in_4 = 16'sd1643;
    expected = -0.617874; expected_q9 = -316;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 86: sw_pred=-2.426759
    sample_id = 86;
    in_0 = 16'sd1143; in_1 = -16'sd594; in_2 = 16'sd917; in_3 = -16'sd645; in_4 = -16'sd305;
    expected = -2.426759; expected_q9 = -1243;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 87: sw_pred=0.792178
    sample_id = 87;
    in_0 = -16'sd300; in_1 = 16'sd240; in_2 = -16'sd615; in_3 = -16'sd385; in_4 = -16'sd259;
    expected = 0.792178; expected_q9 = 406;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 88: sw_pred=-1.722849
    sample_id = 88;
    in_0 = 16'sd550; in_1 = 16'sd47; in_2 = 16'sd499; in_3 = 16'sd657; in_4 = -16'sd25;
    expected = -1.722849; expected_q9 = -882;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 89: sw_pred=-0.728520
    sample_id = 89;
    in_0 = 16'sd822; in_1 = -16'sd304; in_2 = -16'sd197; in_3 = 16'sd138; in_4 = -16'sd349;
    expected = -0.728520; expected_q9 = -373;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 90: sw_pred=-1.128612
    sample_id = 90;
    in_0 = 16'sd341; in_1 = -16'sd331; in_2 = 16'sd917; in_3 = 16'sd138; in_4 = -16'sd258;
    expected = -1.128612; expected_q9 = -578;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 91: sw_pred=-1.866620
    sample_id = 91;
    in_0 = -16'sd410; in_1 = 16'sd933; in_2 = -16'sd615; in_3 = 16'sd138; in_4 = 16'sd216;
    expected = -1.866620; expected_q9 = -956;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 92: sw_pred=-0.279623
    sample_id = 92;
    in_0 = -16'sd397; in_1 = 16'sd758; in_2 = -16'sd476; in_3 = -16'sd645; in_4 = 16'sd704;
    expected = -0.279623; expected_q9 = -143;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 93: sw_pred=1.304050
    sample_id = 93;
    in_0 = -16'sd260; in_1 = 16'sd187; in_2 = -16'sd197; in_3 = 16'sd657; in_4 = -16'sd30;
    expected = 1.304050; expected_q9 = 668;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 94: sw_pred=-1.437535
    sample_id = 94;
    in_0 = 16'sd550; in_1 = -16'sd331; in_2 = 16'sd917; in_3 = 16'sd138; in_4 = -16'sd258;
    expected = -1.437535; expected_q9 = -736;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 95: sw_pred=-1.072500
    sample_id = 95;
    in_0 = 16'sd550; in_1 = -16'sd120; in_2 = 16'sd81; in_3 = 16'sd138; in_4 = -16'sd265;
    expected = -1.072500; expected_q9 = -549;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 96: sw_pred=-1.413308
    sample_id = 96;
    in_0 = 16'sd1544; in_1 = -16'sd594; in_2 = 16'sd81; in_3 = 16'sd138; in_4 = -16'sd368;
    expected = -1.413308; expected_q9 = -724;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 97: sw_pred=-1.578553
    sample_id = 97;
    in_0 = 16'sd341; in_1 = 16'sd758; in_2 = -16'sd476; in_3 = -16'sd385; in_4 = 16'sd676;
    expected = -1.578553; expected_q9 = -808;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 98: sw_pred=1.039859
    sample_id = 98;
    in_0 = -16'sd260; in_1 = -16'sd594; in_2 = -16'sd197; in_3 = -16'sd385; in_4 = -16'sd378;
    expected = 1.039859; expected_q9 = 532;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 99: sw_pred=0.032919
    sample_id = 99;
    in_0 = 16'sd341; in_1 = -16'sd594; in_2 = 16'sd81; in_3 = 16'sd138; in_4 = -16'sd368;
    expected = 0.032919; expected_q9 = 17;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 100: sw_pred=0.723598
    sample_id = 100;
    in_0 = -16'sd140; in_1 = -16'sd594; in_2 = 16'sd81; in_3 = -16'sd385; in_4 = -16'sd360;
    expected = 0.723598; expected_q9 = 370;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 101: sw_pred=-2.561536
    sample_id = 101;
    in_0 = 16'sd341; in_1 = 16'sd486; in_2 = -16'sd197; in_3 = -16'sd645; in_4 = 16'sd1211;
    expected = -2.561536; expected_q9 = -1312;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 102: sw_pred=1.438872
    sample_id = 102;
    in_0 = -16'sd360; in_1 = 16'sd486; in_2 = -16'sd197; in_3 = 16'sd657; in_4 = 16'sd893;
    expected = 1.438872; expected_q9 = 737;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 103: sw_pred=-0.961567
    sample_id = 103;
    in_0 = -16'sd204; in_1 = 16'sd275; in_2 = 16'sd81; in_3 = -16'sd385; in_4 = 16'sd482;
    expected = -0.961567; expected_q9 = -492;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 104: sw_pred=0.268749
    sample_id = 104;
    in_0 = -16'sd360; in_1 = 16'sd1135; in_2 = -16'sd476; in_3 = 16'sd657; in_4 = 16'sd906;
    expected = 0.268749; expected_q9 = 138;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 105: sw_pred=0.599352
    sample_id = 105;
    in_0 = -16'sd410; in_1 = 16'sd486; in_2 = -16'sd197; in_3 = -16'sd385; in_4 = 16'sd1170;
    expected = 0.599352; expected_q9 = 307;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 106: sw_pred=-1.298541
    sample_id = 106;
    in_0 = 16'sd550; in_1 = -16'sd594; in_2 = 16'sd917; in_3 = -16'sd385; in_4 = -16'sd314;
    expected = -1.298541; expected_q9 = -665;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 107: sw_pred=-0.590075
    sample_id = 107;
    in_0 = -16'sd60; in_1 = -16'sd594; in_2 = 16'sd917; in_3 = -16'sd645; in_4 = -16'sd305;
    expected = -0.590075; expected_q9 = -302;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 108: sw_pred=0.848712
    sample_id = 108;
    in_0 = -16'sd380; in_1 = -16'sd6; in_2 = -16'sd197; in_3 = -16'sd645; in_4 = -16'sd203;
    expected = 0.848712; expected_q9 = 435;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 109: sw_pred=-0.752059
    sample_id = 109;
    in_0 = -16'sd410; in_1 = 16'sd1354; in_2 = -16'sd615; in_3 = 16'sd657; in_4 = 16'sd407;
    expected = -0.752059; expected_q9 = -385;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 110: sw_pred=-0.539907
    sample_id = 110;
    in_0 = 16'sd181; in_1 = -16'sd594; in_2 = 16'sd917; in_3 = 16'sd138; in_4 = -16'sd324;
    expected = -0.539907; expected_q9 = -276;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 111: sw_pred=1.254461
    sample_id = 111;
    in_0 = -16'sd140; in_1 = 16'sd240; in_2 = -16'sd615; in_3 = 16'sd138; in_4 = -16'sd265;
    expected = 1.254461; expected_q9 = 642;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 112: sw_pred=0.434527
    sample_id = 112;
    in_0 = 16'sd822; in_1 = -16'sd594; in_2 = -16'sd476; in_3 = -16'sd645; in_4 = -16'sd404;
    expected = 0.434527; expected_q9 = 222;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 113: sw_pred=1.317636
    sample_id = 113;
    in_0 = 16'sd181; in_1 = 16'sd240; in_2 = -16'sd615; in_3 = 16'sd657; in_4 = -16'sd270;
    expected = 1.317636; expected_q9 = 675;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 114: sw_pred=-0.890800
    sample_id = 114;
    in_0 = -16'sd410; in_1 = 16'sd1354; in_2 = -16'sd615; in_3 = -16'sd385; in_4 = 16'sd465;
    expected = -0.890800; expected_q9 = -456;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 115: sw_pred=1.106019
    sample_id = 115;
    in_0 = 16'sd341; in_1 = -16'sd594; in_2 = -16'sd476; in_3 = -16'sd645; in_4 = -16'sd404;
    expected = 1.106019; expected_q9 = 566;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 116: sw_pred=-1.290929
    sample_id = 116;
    in_0 = -16'sd60; in_1 = 16'sd47; in_2 = 16'sd499; in_3 = -16'sd385; in_4 = 16'sd50;
    expected = -1.290929; expected_q9 = -661;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 117: sw_pred=-1.886829
    sample_id = 117;
    in_0 = 16'sd822; in_1 = -16'sd243; in_2 = 16'sd499; in_3 = -16'sd385; in_4 = -16'sd249;
    expected = -1.886829; expected_q9 = -966;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 118: sw_pred=0.591482
    sample_id = 118;
    in_0 = -16'sd204; in_1 = 16'sd521; in_2 = -16'sd615; in_3 = -16'sd385; in_4 = 16'sd77;
    expected = 0.591482; expected_q9 = 303;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 119: sw_pred=-1.449277
    sample_id = 119;
    in_0 = -16'sd140; in_1 = 16'sd486; in_2 = -16'sd197; in_3 = -16'sd385; in_4 = 16'sd1170;
    expected = -1.449277; expected_q9 = -742;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 120: sw_pred=0.762531
    sample_id = 120;
    in_0 = -16'sd332; in_1 = -16'sd331; in_2 = 16'sd917; in_3 = 16'sd138; in_4 = -16'sd258;
    expected = 0.762531; expected_q9 = 390;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 121: sw_pred=0.958960
    sample_id = 121;
    in_0 = -16'sd204; in_1 = 16'sd240; in_2 = -16'sd615; in_3 = -16'sd385; in_4 = -16'sd259;
    expected = 0.958960; expected_q9 = 491;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 122: sw_pred=0.429877
    sample_id = 122;
    in_0 = -16'sd300; in_1 = -16'sd594; in_2 = 16'sd81; in_3 = 16'sd138; in_4 = -16'sd368;
    expected = 0.429877; expected_q9 = 220;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 123: sw_pred=0.857153
    sample_id = 123;
    in_0 = -16'sd332; in_1 = -16'sd418; in_2 = 16'sd499; in_3 = -16'sd645; in_4 = -16'sd289;
    expected = 0.857153; expected_q9 = 439;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 124: sw_pred=-2.149254
    sample_id = 124;
    in_0 = 16'sd181; in_1 = 16'sd512; in_2 = 16'sd81; in_3 = 16'sd657; in_4 = 16'sd1464;
    expected = -2.149254; expected_q9 = -1100;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 125: sw_pred=-0.589262
    sample_id = 125;
    in_0 = -16'sd204; in_1 = 16'sd38; in_2 = 16'sd81; in_3 = -16'sd385; in_4 = -16'sd78;
    expected = -0.589262; expected_q9 = -302;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 126: sw_pred=0.080660
    sample_id = 126;
    in_0 = -16'sd332; in_1 = 16'sd47; in_2 = 16'sd499; in_3 = -16'sd385; in_4 = 16'sd50;
    expected = 0.080660; expected_q9 = 41;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 127: sw_pred=-1.330820
    sample_id = 127;
    in_0 = 16'sd45; in_1 = 16'sd1135; in_2 = -16'sd476; in_3 = 16'sd657; in_4 = 16'sd906;
    expected = -1.330820; expected_q9 = -681;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 128: sw_pred=1.068871
    sample_id = 128;
    in_0 = 16'sd181; in_1 = -16'sd225; in_2 = -16'sd476; in_3 = -16'sd385; in_4 = -16'sd376;
    expected = 1.068871; expected_q9 = 547;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 129: sw_pred=-2.742640
    sample_id = 129;
    in_0 = 16'sd45; in_1 = 16'sd512; in_2 = 16'sd81; in_3 = -16'sd385; in_4 = 16'sd1861;
    expected = -2.742640; expected_q9 = -1404;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 130: sw_pred=0.605698
    sample_id = 130;
    in_0 = 16'sd45; in_1 = -16'sd594; in_2 = -16'sd197; in_3 = -16'sd645; in_4 = -16'sd377;
    expected = 0.605698; expected_q9 = 310;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 131: sw_pred=-0.032092
    sample_id = 131;
    in_0 = -16'sd380; in_1 = -16'sd418; in_2 = 16'sd499; in_3 = 16'sd138; in_4 = -16'sd312;
    expected = -0.032092; expected_q9 = -16;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 132: sw_pred=-2.259885
    sample_id = 132;
    in_0 = 16'sd1544; in_1 = -16'sd462; in_2 = 16'sd917; in_3 = 16'sd657; in_4 = -16'sd303;
    expected = -2.259885; expected_q9 = -1157;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 133: sw_pred=-0.135255
    sample_id = 133;
    in_0 = 16'sd341; in_1 = 16'sd1354; in_2 = -16'sd615; in_3 = 16'sd657; in_4 = 16'sd407;
    expected = -0.135255; expected_q9 = -69;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 134: sw_pred=1.436288
    sample_id = 134;
    in_0 = -16'sd410; in_1 = 16'sd275; in_2 = 16'sd81; in_3 = 16'sd657; in_4 = 16'sd323;
    expected = 1.436288; expected_q9 = 735;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 135: sw_pred=0.714985
    sample_id = 135;
    in_0 = -16'sd421; in_1 = 16'sd47; in_2 = 16'sd499; in_3 = -16'sd645; in_4 = 16'sd86;
    expected = 0.714985; expected_q9 = 366;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 136: sw_pred=0.334065
    sample_id = 136;
    in_0 = -16'sd360; in_1 = -16'sd594; in_2 = 16'sd917; in_3 = 16'sd138; in_4 = -16'sd324;
    expected = 0.334065; expected_q9 = 171;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 137: sw_pred=-1.351845
    sample_id = 137;
    in_0 = 16'sd1143; in_1 = -16'sd594; in_2 = 16'sd81; in_3 = -16'sd385; in_4 = -16'sd360;
    expected = -1.351845; expected_q9 = -692;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 138: sw_pred=0.691319
    sample_id = 138;
    in_0 = -16'sd300; in_1 = -16'sd243; in_2 = 16'sd499; in_3 = -16'sd645; in_4 = -16'sd236;
    expected = 0.691319; expected_q9 = 354;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 139: sw_pred=0.041306
    sample_id = 139;
    in_0 = -16'sd429; in_1 = 16'sd389; in_2 = -16'sd476; in_3 = -16'sd385; in_4 = 16'sd156;
    expected = 0.041306; expected_q9 = 21;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 140: sw_pred=-0.080992
    sample_id = 140;
    in_0 = -16'sd380; in_1 = -16'sd594; in_2 = 16'sd499; in_3 = 16'sd138; in_4 = -16'sd346;
    expected = -0.080992; expected_q9 = -41;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 141: sw_pred=0.931571
    sample_id = 141;
    in_0 = -16'sd260; in_1 = -16'sd243; in_2 = 16'sd499; in_3 = 16'sd657; in_4 = -16'sd278;
    expected = 0.931571; expected_q9 = 477;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 142: sw_pred=0.709605
    sample_id = 142;
    in_0 = -16'sd429; in_1 = 16'sd512; in_2 = 16'sd81; in_3 = 16'sd657; in_4 = 16'sd1464;
    expected = 0.709605; expected_q9 = 363;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 143: sw_pred=-0.406906
    sample_id = 143;
    in_0 = -16'sd380; in_1 = -16'sd357; in_2 = 16'sd81; in_3 = -16'sd385; in_4 = -16'sd320;
    expected = -0.406906; expected_q9 = -208;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 144: sw_pred=0.316817
    sample_id = 144;
    in_0 = -16'sd260; in_1 = 16'sd933; in_2 = -16'sd615; in_3 = 16'sd138; in_4 = 16'sd216;
    expected = 0.316817; expected_q9 = 162;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 145: sw_pred=0.446508
    sample_id = 145;
    in_0 = 16'sd181; in_1 = 16'sd240; in_2 = -16'sd615; in_3 = -16'sd385; in_4 = -16'sd259;
    expected = 0.446508; expected_q9 = 229;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 146: sw_pred=-0.224729
    sample_id = 146;
    in_0 = -16'sd410; in_1 = 16'sd521; in_2 = -16'sd615; in_3 = -16'sd385; in_4 = 16'sd77;
    expected = -0.224729; expected_q9 = -115;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 147: sw_pred=0.421330
    sample_id = 147;
    in_0 = -16'sd332; in_1 = -16'sd594; in_2 = 16'sd81; in_3 = -16'sd385; in_4 = -16'sd360;
    expected = 0.421330; expected_q9 = 216;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 148: sw_pred=0.511853
    sample_id = 148;
    in_0 = -16'sd332; in_1 = 16'sd143; in_2 = -16'sd476; in_3 = 16'sd138; in_4 = -16'sd221;
    expected = 0.511853; expected_q9 = 262;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 149: sw_pred=0.815674
    sample_id = 149;
    in_0 = -16'sd332; in_1 = -16'sd418; in_2 = 16'sd499; in_3 = -16'sd385; in_4 = -16'sd299;
    expected = 0.815674; expected_q9 = 418;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 150: sw_pred=-0.102510
    sample_id = 150;
    in_0 = -16'sd204; in_1 = -16'sd120; in_2 = 16'sd81; in_3 = -16'sd645; in_4 = -16'sd229;
    expected = -0.102510; expected_q9 = -52;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 151: sw_pred=2.068861
    sample_id = 151;
    in_0 = -16'sd360; in_1 = 16'sd187; in_2 = -16'sd197; in_3 = 16'sd657; in_4 = -16'sd30;
    expected = 2.068861; expected_q9 = 1059;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 152: sw_pred=-1.991830
    sample_id = 152;
    in_0 = 16'sd822; in_1 = 16'sd758; in_2 = -16'sd476; in_3 = 16'sd657; in_4 = 16'sd604;
    expected = -1.991830; expected_q9 = -1020;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 153: sw_pred=1.542653
    sample_id = 153;
    in_0 = 16'sd550; in_1 = -16'sd173; in_2 = -16'sd615; in_3 = 16'sd138; in_4 = -16'sd401;
    expected = 1.542653; expected_q9 = 790;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 154: sw_pred=-0.304156
    sample_id = 154;
    in_0 = 16'sd181; in_1 = -16'sd594; in_2 = 16'sd499; in_3 = -16'sd645; in_4 = -16'sd329;
    expected = -0.304156; expected_q9 = -156;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 155: sw_pred=0.537169
    sample_id = 155;
    in_0 = -16'sd300; in_1 = -16'sd357; in_2 = 16'sd81; in_3 = 16'sd657; in_4 = -16'sd340;
    expected = 0.537169; expected_q9 = 275;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 156: sw_pred=0.761385
    sample_id = 156;
    in_0 = -16'sd380; in_1 = 16'sd275; in_2 = 16'sd81; in_3 = 16'sd138; in_4 = 16'sd384;
    expected = 0.761385; expected_q9 = 390;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 157: sw_pred=-0.095006
    sample_id = 157;
    in_0 = -16'sd397; in_1 = -16'sd243; in_2 = 16'sd499; in_3 = 16'sd138; in_4 = -16'sd267;
    expected = -0.095006; expected_q9 = -49;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 158: sw_pred=1.197268
    sample_id = 158;
    in_0 = 16'sd550; in_1 = -16'sd594; in_2 = -16'sd615; in_3 = 16'sd657; in_4 = -16'sd420;
    expected = 1.197268; expected_q9 = 613;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 159: sw_pred=-0.391393
    sample_id = 159;
    in_0 = -16'sd60; in_1 = -16'sd243; in_2 = 16'sd499; in_3 = 16'sd138; in_4 = -16'sd267;
    expected = -0.391393; expected_q9 = -200;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 160: sw_pred=0.208194
    sample_id = 160;
    in_0 = -16'sd140; in_1 = -16'sd129; in_2 = 16'sd499; in_3 = 16'sd657; in_4 = -16'sd231;
    expected = 0.208194; expected_q9 = 107;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 161: sw_pred=-1.094648
    sample_id = 161;
    in_0 = 16'sd341; in_1 = -16'sd594; in_2 = 16'sd917; in_3 = -16'sd385; in_4 = -16'sd314;
    expected = -1.094648; expected_q9 = -560;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 162: sw_pred=-0.360633
    sample_id = 162;
    in_0 = 16'sd341; in_1 = -16'sd304; in_2 = -16'sd197; in_3 = -16'sd645; in_4 = -16'sd337;
    expected = -0.360633; expected_q9 = -185;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 163: sw_pred=-0.495352
    sample_id = 163;
    in_0 = -16'sd140; in_1 = 16'sd47; in_2 = 16'sd499; in_3 = 16'sd138; in_4 = 16'sd4;
    expected = -0.495352; expected_q9 = -254;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 164: sw_pred=-0.974312
    sample_id = 164;
    in_0 = -16'sd204; in_1 = 16'sd486; in_2 = -16'sd197; in_3 = -16'sd385; in_4 = 16'sd1170;
    expected = -0.974312; expected_q9 = -499;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 165: sw_pred=1.118446
    sample_id = 165;
    in_0 = -16'sd429; in_1 = 16'sd47; in_2 = 16'sd499; in_3 = -16'sd385; in_4 = 16'sd50;
    expected = 1.118446; expected_q9 = 573;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 166: sw_pred=0.573861
    sample_id = 166;
    in_0 = -16'sd300; in_1 = -16'sd331; in_2 = 16'sd917; in_3 = 16'sd657; in_4 = -16'sd268;
    expected = 0.573861; expected_q9 = 294;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 167: sw_pred=-0.691571
    sample_id = 167;
    in_0 = 16'sd181; in_1 = -16'sd331; in_2 = 16'sd917; in_3 = 16'sd657; in_4 = -16'sd268;
    expected = -0.691571; expected_q9 = -354;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 168: sw_pred=-0.531549
    sample_id = 168;
    in_0 = 16'sd822; in_1 = -16'sd225; in_2 = -16'sd476; in_3 = -16'sd385; in_4 = -16'sd376;
    expected = -0.531549; expected_q9 = -272;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 169: sw_pred=1.448641
    sample_id = 169;
    in_0 = 16'sd341; in_1 = -16'sd173; in_2 = -16'sd615; in_3 = -16'sd645; in_4 = -16'sd399;
    expected = 1.448641; expected_q9 = 742;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 170: sw_pred=-0.826737
    sample_id = 170;
    in_0 = 16'sd181; in_1 = 16'sd143; in_2 = -16'sd476; in_3 = -16'sd385; in_4 = -16'sd213;
    expected = -0.826737; expected_q9 = -423;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 171: sw_pred=0.296445
    sample_id = 171;
    in_0 = -16'sd260; in_1 = -16'sd129; in_2 = 16'sd499; in_3 = -16'sd385; in_4 = -16'sd194;
    expected = 0.296445; expected_q9 = 152;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 172: sw_pred=0.231779
    sample_id = 172;
    in_0 = -16'sd204; in_1 = -16'sd243; in_2 = 16'sd499; in_3 = 16'sd138; in_4 = -16'sd267;
    expected = 0.231779; expected_q9 = 119;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 173: sw_pred=0.930875
    sample_id = 173;
    in_0 = -16'sd397; in_1 = 16'sd38; in_2 = 16'sd81; in_3 = -16'sd385; in_4 = -16'sd78;
    expected = 0.930875; expected_q9 = 477;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 174: sw_pred=-1.188647
    sample_id = 174;
    in_0 = 16'sd1143; in_1 = -16'sd304; in_2 = -16'sd197; in_3 = 16'sd657; in_4 = -16'sd356;
    expected = -1.188647; expected_q9 = -609;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 175: sw_pred=-1.500187
    sample_id = 175;
    in_0 = -16'sd60; in_1 = 16'sd512; in_2 = 16'sd81; in_3 = 16'sd657; in_4 = 16'sd1464;
    expected = -1.500187; expected_q9 = -768;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 176: sw_pred=0.086845
    sample_id = 176;
    in_0 = -16'sd397; in_1 = -16'sd331; in_2 = 16'sd917; in_3 = -16'sd385; in_4 = -16'sd241;
    expected = 0.086845; expected_q9 = 44;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 177: sw_pred=-0.386008
    sample_id = 177;
    in_0 = -16'sd140; in_1 = 16'sd1354; in_2 = -16'sd615; in_3 = -16'sd385; in_4 = 16'sd465;
    expected = -0.386008; expected_q9 = -198;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 178: sw_pred=0.508730
    sample_id = 178;
    in_0 = -16'sd300; in_1 = 16'sd758; in_2 = -16'sd476; in_3 = -16'sd385; in_4 = 16'sd676;
    expected = 0.508730; expected_q9 = 260;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 179: sw_pred=-1.177567
    sample_id = 179;
    in_0 = -16'sd360; in_1 = 16'sd486; in_2 = -16'sd197; in_3 = -16'sd645; in_4 = 16'sd1211;
    expected = -1.177567; expected_q9 = -603;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 180: sw_pred=0.827050
    sample_id = 180;
    in_0 = -16'sd140; in_1 = -16'sd173; in_2 = -16'sd615; in_3 = -16'sd645; in_4 = -16'sd399;
    expected = 0.827050; expected_q9 = 423;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 181: sw_pred=-1.371523
    sample_id = 181;
    in_0 = -16'sd421; in_1 = 16'sd512; in_2 = 16'sd81; in_3 = -16'sd385; in_4 = 16'sd1861;
    expected = -1.371523; expected_q9 = -702;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 182: sw_pred=-2.326119
    sample_id = 182;
    in_0 = 16'sd550; in_1 = 16'sd758; in_2 = -16'sd476; in_3 = -16'sd645; in_4 = 16'sd704;
    expected = -2.326119; expected_q9 = -1191;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 183: sw_pred=0.964400
    sample_id = 183;
    in_0 = -16'sd260; in_1 = -16'sd129; in_2 = 16'sd499; in_3 = 16'sd657; in_4 = -16'sd231;
    expected = 0.964400; expected_q9 = 494;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 184: sw_pred=-0.869821
    sample_id = 184;
    in_0 = -16'sd140; in_1 = 16'sd486; in_2 = -16'sd197; in_3 = 16'sd138; in_4 = 16'sd1012;
    expected = -0.869821; expected_q9 = -445;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 185: sw_pred=0.067977
    sample_id = 185;
    in_0 = -16'sd397; in_1 = -16'sd594; in_2 = 16'sd917; in_3 = -16'sd385; in_4 = -16'sd314;
    expected = 0.067977; expected_q9 = 35;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 186: sw_pred=-2.504181
    sample_id = 186;
    in_0 = 16'sd181; in_1 = 16'sd486; in_2 = -16'sd197; in_3 = -16'sd645; in_4 = 16'sd1211;
    expected = -2.504181; expected_q9 = -1282;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 187: sw_pred=1.155098
    sample_id = 187;
    in_0 = -16'sd260; in_1 = -16'sd594; in_2 = -16'sd197; in_3 = -16'sd645; in_4 = -16'sd377;
    expected = 1.155098; expected_q9 = 591;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 188: sw_pred=-1.970471
    sample_id = 188;
    in_0 = 16'sd1143; in_1 = -16'sd129; in_2 = 16'sd499; in_3 = 16'sd657; in_4 = -16'sd231;
    expected = -1.970471; expected_q9 = -1009;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 189: sw_pred=1.048614
    sample_id = 189;
    in_0 = 16'sd1143; in_1 = -16'sd594; in_2 = -16'sd615; in_3 = -16'sd645; in_4 = -16'sd418;
    expected = 1.048614; expected_q9 = 537;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 190: sw_pred=-0.278772
    sample_id = 190;
    in_0 = 16'sd550; in_1 = -16'sd304; in_2 = -16'sd197; in_3 = 16'sd138; in_4 = -16'sd349;
    expected = -0.278772; expected_q9 = -143;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 191: sw_pred=-1.253091
    sample_id = 191;
    in_0 = 16'sd341; in_1 = -16'sd243; in_2 = 16'sd499; in_3 = -16'sd645; in_4 = -16'sd236;
    expected = -1.253091; expected_q9 = -642;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 192: sw_pred=-0.606815
    sample_id = 192;
    in_0 = -16'sd332; in_1 = 16'sd775; in_2 = -16'sd197; in_3 = -16'sd385; in_4 = 16'sd1643;
    expected = -0.606815; expected_q9 = -311;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 193: sw_pred=0.093841
    sample_id = 193;
    in_0 = -16'sd204; in_1 = -16'sd243; in_2 = 16'sd499; in_3 = -16'sd645; in_4 = -16'sd236;
    expected = 0.093841; expected_q9 = 48;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 194: sw_pred=0.837184
    sample_id = 194;
    in_0 = 16'sd181; in_1 = 16'sd240; in_2 = -16'sd615; in_3 = 16'sd138; in_4 = -16'sd265;
    expected = 0.837184; expected_q9 = 429;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 195: sw_pred=1.321639
    sample_id = 195;
    in_0 = -16'sd204; in_1 = -16'sd594; in_2 = -16'sd197; in_3 = -16'sd645; in_4 = -16'sd377;
    expected = 1.321639; expected_q9 = 677;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 196: sw_pred=-0.649815
    sample_id = 196;
    in_0 = -16'sd60; in_1 = -16'sd243; in_2 = 16'sd499; in_3 = -16'sd385; in_4 = -16'sd249;
    expected = -0.649815; expected_q9 = -333;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 197: sw_pred=0.626499
    sample_id = 197;
    in_0 = -16'sd260; in_1 = -16'sd243; in_2 = 16'sd917; in_3 = 16'sd657; in_4 = -16'sd240;
    expected = 0.626499; expected_q9 = 321;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 198: sw_pred=0.618013
    sample_id = 198;
    in_0 = -16'sd332; in_1 = -16'sd418; in_2 = 16'sd499; in_3 = 16'sd138; in_4 = -16'sd312;
    expected = 0.618013; expected_q9 = 316;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 199: sw_pred=-1.065094
    sample_id = 199;
    in_0 = 16'sd550; in_1 = -16'sd243; in_2 = 16'sd499; in_3 = 16'sd657; in_4 = -16'sd278;
    expected = -1.065094; expected_q9 = -545;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 200: sw_pred=-0.620851
    sample_id = 200;
    in_0 = -16'sd260; in_1 = 16'sd47; in_2 = 16'sd499; in_3 = -16'sd385; in_4 = 16'sd50;
    expected = -0.620851; expected_q9 = -318;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 201: sw_pred=-0.198061
    sample_id = 201;
    in_0 = -16'sd380; in_1 = 16'sd758; in_2 = -16'sd476; in_3 = -16'sd645; in_4 = 16'sd704;
    expected = -0.198061; expected_q9 = -101;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 202: sw_pred=-1.409433
    sample_id = 202;
    in_0 = -16'sd397; in_1 = 16'sd933; in_2 = -16'sd615; in_3 = 16'sd138; in_4 = 16'sd216;
    expected = -1.409433; expected_q9 = -722;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 203: sw_pred=0.767673
    sample_id = 203;
    in_0 = -16'sd380; in_1 = -16'sd120; in_2 = 16'sd81; in_3 = -16'sd645; in_4 = -16'sd229;
    expected = 0.767673; expected_q9 = 393;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 204: sw_pred=0.004961
    sample_id = 204;
    in_0 = 16'sd1143; in_1 = -16'sd594; in_2 = -16'sd476; in_3 = -16'sd385; in_4 = -16'sd405;
    expected = 0.004961; expected_q9 = 3;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 205: sw_pred=0.264306
    sample_id = 205;
    in_0 = -16'sd332; in_1 = 16'sd275; in_2 = 16'sd81; in_3 = 16'sd138; in_4 = 16'sd384;
    expected = 0.264306; expected_q9 = 135;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 206: sw_pred=-0.037213
    sample_id = 206;
    in_0 = -16'sd140; in_1 = 16'sd933; in_2 = -16'sd615; in_3 = -16'sd385; in_4 = 16'sd242;
    expected = -0.037213; expected_q9 = -19;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 207: sw_pred=1.094708
    sample_id = 207;
    in_0 = 16'sd45; in_1 = -16'sd594; in_2 = -16'sd197; in_3 = 16'sd657; in_4 = -16'sd388;
    expected = 1.094708; expected_q9 = 560;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 208: sw_pred=0.307061
    sample_id = 208;
    in_0 = 16'sd45; in_1 = -16'sd594; in_2 = 16'sd499; in_3 = 16'sd657; in_4 = -16'sd351;
    expected = 0.307061; expected_q9 = 157;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 209: sw_pred=0.666211
    sample_id = 209;
    in_0 = -16'sd421; in_1 = 16'sd275; in_2 = 16'sd81; in_3 = -16'sd645; in_4 = 16'sd558;
    expected = 0.666211; expected_q9 = 341;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 210: sw_pred=-1.029206
    sample_id = 210;
    in_0 = -16'sd410; in_1 = 16'sd933; in_2 = -16'sd615; in_3 = -16'sd645; in_4 = 16'sd259;
    expected = -1.029206; expected_q9 = -527;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 211: sw_pred=1.302832
    sample_id = 211;
    in_0 = -16'sd204; in_1 = -16'sd304; in_2 = -16'sd197; in_3 = 16'sd138; in_4 = -16'sd349;
    expected = 1.302832; expected_q9 = 667;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 212: sw_pred=-1.644215
    sample_id = 212;
    in_0 = 16'sd550; in_1 = -16'sd594; in_2 = 16'sd917; in_3 = -16'sd645; in_4 = -16'sd305;
    expected = -1.644215; expected_q9 = -842;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 213: sw_pred=1.662358
    sample_id = 213;
    in_0 = -16'sd60; in_1 = 16'sd240; in_2 = -16'sd615; in_3 = 16'sd657; in_4 = -16'sd270;
    expected = 1.662358; expected_q9 = 851;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 214: sw_pred=-0.111895
    sample_id = 214;
    in_0 = -16'sd140; in_1 = -16'sd594; in_2 = 16'sd499; in_3 = -16'sd645; in_4 = -16'sd329;
    expected = -0.111895; expected_q9 = -57;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 215: sw_pred=0.153304
    sample_id = 215;
    in_0 = 16'sd181; in_1 = 16'sd933; in_2 = -16'sd615; in_3 = 16'sd657; in_4 = 16'sd198;
    expected = 0.153304; expected_q9 = 78;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 216: sw_pred=0.251820
    sample_id = 216;
    in_0 = -16'sd380; in_1 = -16'sd594; in_2 = 16'sd499; in_3 = -16'sd645; in_4 = -16'sd329;
    expected = 0.251820; expected_q9 = 129;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 217: sw_pred=-0.667445
    sample_id = 217;
    in_0 = -16'sd397; in_1 = 16'sd240; in_2 = -16'sd615; in_3 = 16'sd138; in_4 = -16'sd265;
    expected = -0.667445; expected_q9 = -342;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 218: sw_pred=0.983081
    sample_id = 218;
    in_0 = -16'sd300; in_1 = -16'sd357; in_2 = 16'sd81; in_3 = -16'sd385; in_4 = -16'sd320;
    expected = 0.983081; expected_q9 = 503;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 219: sw_pred=-2.459404
    sample_id = 219;
    in_0 = 16'sd45; in_1 = 16'sd486; in_2 = -16'sd197; in_3 = -16'sd645; in_4 = 16'sd1211;
    expected = -2.459404; expected_q9 = -1259;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 220: sw_pred=1.139277
    sample_id = 220;
    in_0 = -16'sd60; in_1 = -16'sd594; in_2 = -16'sd476; in_3 = 16'sd657; in_4 = -16'sd407;
    expected = 1.139277; expected_q9 = 583;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 221: sw_pred=-1.289496
    sample_id = 221;
    in_0 = 16'sd1544; in_1 = -16'sd594; in_2 = 16'sd499; in_3 = 16'sd657; in_4 = -16'sd351;
    expected = -1.289496; expected_q9 = -660;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 222: sw_pred=0.553601
    sample_id = 222;
    in_0 = -16'sd260; in_1 = -16'sd418; in_2 = 16'sd499; in_3 = -16'sd385; in_4 = -16'sd299;
    expected = 0.553601; expected_q9 = 283;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 223: sw_pred=1.033084
    sample_id = 223;
    in_0 = -16'sd300; in_1 = 16'sd389; in_2 = -16'sd476; in_3 = -16'sd385; in_4 = 16'sd156;
    expected = 1.033084; expected_q9 = 529;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 224: sw_pred=-0.289499
    sample_id = 224;
    in_0 = -16'sd260; in_1 = 16'sd775; in_2 = -16'sd197; in_3 = 16'sd657; in_4 = 16'sd1284;
    expected = -0.289499; expected_q9 = -148;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 225: sw_pred=0.420215
    sample_id = 225;
    in_0 = -16'sd140; in_1 = -16'sd120; in_2 = 16'sd81; in_3 = 16'sd138; in_4 = -16'sd265;
    expected = 0.420215; expected_q9 = 215;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 226: sw_pred=0.513356
    sample_id = 226;
    in_0 = -16'sd360; in_1 = -16'sd594; in_2 = 16'sd499; in_3 = -16'sd385; in_4 = -16'sd336;
    expected = 0.513356; expected_q9 = 263;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 227: sw_pred=1.140326
    sample_id = 227;
    in_0 = 16'sd341; in_1 = -16'sd225; in_2 = -16'sd476; in_3 = 16'sd657; in_4 = -16'sd380;
    expected = 1.140326; expected_q9 = 584;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 228: sw_pred=-0.638253
    sample_id = 228;
    in_0 = -16'sd421; in_1 = -16'sd594; in_2 = 16'sd917; in_3 = -16'sd385; in_4 = -16'sd314;
    expected = -0.638253; expected_q9 = -327;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 229: sw_pred=0.014700
    sample_id = 229;
    in_0 = -16'sd260; in_1 = -16'sd594; in_2 = 16'sd917; in_3 = -16'sd645; in_4 = -16'sd305;
    expected = 0.014700; expected_q9 = 8;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 230: sw_pred=-1.000948
    sample_id = 230;
    in_0 = -16'sd360; in_1 = 16'sd1354; in_2 = -16'sd615; in_3 = 16'sd657; in_4 = 16'sd407;
    expected = -1.000948; expected_q9 = -512;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 231: sw_pred=1.196491
    sample_id = 231;
    in_0 = -16'sd60; in_1 = -16'sd594; in_2 = -16'sd615; in_3 = -16'sd645; in_4 = -16'sd418;
    expected = 1.196491; expected_q9 = 613;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 232: sw_pred=0.741758
    sample_id = 232;
    in_0 = -16'sd410; in_1 = 16'sd1135; in_2 = -16'sd476; in_3 = -16'sd385; in_4 = 16'sd999;
    expected = 0.741758; expected_q9 = 380;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 233: sw_pred=-1.021264
    sample_id = 233;
    in_0 = -16'sd140; in_1 = 16'sd47; in_2 = 16'sd499; in_3 = -16'sd385; in_4 = 16'sd50;
    expected = -1.021264; expected_q9 = -523;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 234: sw_pred=-0.411094
    sample_id = 234;
    in_0 = -16'sd260; in_1 = 16'sd512; in_2 = 16'sd81; in_3 = 16'sd657; in_4 = 16'sd1464;
    expected = -0.411094; expected_q9 = -210;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 235: sw_pred=0.501926
    sample_id = 235;
    in_0 = -16'sd397; in_1 = -16'sd120; in_2 = 16'sd81; in_3 = -16'sd645; in_4 = -16'sd229;
    expected = 0.501926; expected_q9 = 257;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 236: sw_pred=1.532076
    sample_id = 236;
    in_0 = 16'sd181; in_1 = -16'sd173; in_2 = -16'sd615; in_3 = 16'sd657; in_4 = -16'sd402;
    expected = 1.532076; expected_q9 = 784;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 237: sw_pred=1.164605
    sample_id = 237;
    in_0 = -16'sd140; in_1 = -16'sd594; in_2 = -16'sd197; in_3 = -16'sd645; in_4 = -16'sd377;
    expected = 1.164605; expected_q9 = 596;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 238: sw_pred=0.205880
    sample_id = 238;
    in_0 = -16'sd204; in_1 = 16'sd933; in_2 = -16'sd615; in_3 = 16'sd138; in_4 = 16'sd216;
    expected = 0.205880; expected_q9 = 105;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 239: sw_pred=-1.071598
    sample_id = 239;
    in_0 = 16'sd341; in_1 = 16'sd1354; in_2 = -16'sd615; in_3 = -16'sd385; in_4 = 16'sd465;
    expected = -1.071598; expected_q9 = -549;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 240: sw_pred=-2.350412
    sample_id = 240;
    in_0 = 16'sd550; in_1 = 16'sd47; in_2 = 16'sd499; in_3 = -16'sd645; in_4 = 16'sd86;
    expected = -2.350412; expected_q9 = -1203;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 241: sw_pred=-0.365657
    sample_id = 241;
    in_0 = -16'sd410; in_1 = 16'sd521; in_2 = -16'sd615; in_3 = 16'sd657; in_4 = 16'sd43;
    expected = -0.365657; expected_q9 = -187;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 242: sw_pred=-1.849360
    sample_id = 242;
    in_0 = 16'sd45; in_1 = 16'sd512; in_2 = 16'sd81; in_3 = 16'sd657; in_4 = 16'sd1464;
    expected = -1.849360; expected_q9 = -947;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 243: sw_pred=-0.901482
    sample_id = 243;
    in_0 = 16'sd341; in_1 = -16'sd129; in_2 = 16'sd499; in_3 = 16'sd657; in_4 = -16'sd231;
    expected = -0.901482; expected_q9 = -462;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 244: sw_pred=0.486171
    sample_id = 244;
    in_0 = -16'sd410; in_1 = 16'sd389; in_2 = -16'sd476; in_3 = 16'sd657; in_4 = 16'sd118;
    expected = 0.486171; expected_q9 = 249;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 245: sw_pred=0.709009
    sample_id = 245;
    in_0 = -16'sd360; in_1 = -16'sd331; in_2 = 16'sd917; in_3 = 16'sd657; in_4 = -16'sd268;
    expected = 0.709009; expected_q9 = 363;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 246: sw_pred=-0.046361
    sample_id = 246;
    in_0 = 16'sd45; in_1 = -16'sd357; in_2 = 16'sd81; in_3 = -16'sd385; in_4 = -16'sd320;
    expected = -0.046361; expected_q9 = -24;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 247: sw_pred=1.018884
    sample_id = 247;
    in_0 = -16'sd397; in_1 = 16'sd47; in_2 = 16'sd499; in_3 = -16'sd385; in_4 = 16'sd50;
    expected = 1.018884; expected_q9 = 522;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 248: sw_pred=-0.973583
    sample_id = 248;
    in_0 = 16'sd550; in_1 = -16'sd418; in_2 = 16'sd499; in_3 = 16'sd138; in_4 = -16'sd312;
    expected = -0.973583; expected_q9 = -498;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 249: sw_pred=1.663651
    sample_id = 249;
    in_0 = -16'sd429; in_1 = 16'sd275; in_2 = 16'sd81; in_3 = 16'sd657; in_4 = 16'sd323;
    expected = 1.663651; expected_q9 = 852;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 250: sw_pred=-1.901571
    sample_id = 250;
    in_0 = 16'sd341; in_1 = 16'sd758; in_2 = -16'sd476; in_3 = -16'sd645; in_4 = 16'sd704;
    expected = -1.901571; expected_q9 = -974;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 251: sw_pred=-2.889517
    sample_id = 251;
    in_0 = 16'sd181; in_1 = 16'sd512; in_2 = 16'sd81; in_3 = -16'sd385; in_4 = 16'sd1861;
    expected = -2.889517; expected_q9 = -1479;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 252: sw_pred=-1.278998
    sample_id = 252;
    in_0 = 16'sd2747; in_1 = -16'sd173; in_2 = -16'sd615; in_3 = 16'sd138; in_4 = -16'sd401;
    expected = -1.278998; expected_q9 = -655;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 253: sw_pred=-0.830824
    sample_id = 253;
    in_0 = -16'sd410; in_1 = -16'sd418; in_2 = 16'sd499; in_3 = -16'sd385; in_4 = -16'sd299;
    expected = -0.830824; expected_q9 = -425;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 254: sw_pred=1.396469
    sample_id = 254;
    in_0 = 16'sd45; in_1 = -16'sd594; in_2 = -16'sd476; in_3 = 16'sd138; in_4 = -16'sd406;
    expected = 1.396469; expected_q9 = 715;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 255: sw_pred=0.021729
    sample_id = 255;
    in_0 = 16'sd181; in_1 = -16'sd304; in_2 = -16'sd197; in_3 = -16'sd385; in_4 = -16'sd339;
    expected = 0.021729; expected_q9 = 11;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 256: sw_pred=0.867968
    sample_id = 256;
    in_0 = -16'sd380; in_1 = 16'sd47; in_2 = 16'sd499; in_3 = -16'sd385; in_4 = 16'sd50;
    expected = 0.867968; expected_q9 = 444;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 257: sw_pred=-1.091400
    sample_id = 257;
    in_0 = -16'sd360; in_1 = 16'sd512; in_2 = 16'sd81; in_3 = -16'sd385; in_4 = 16'sd1861;
    expected = -1.091400; expected_q9 = -559;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 258: sw_pred=-0.709457
    sample_id = 258;
    in_0 = -16'sd60; in_1 = -16'sd120; in_2 = 16'sd81; in_3 = -16'sd645; in_4 = -16'sd229;
    expected = -0.709457; expected_q9 = -363;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 259: sw_pred=-0.750765
    sample_id = 259;
    in_0 = 16'sd822; in_1 = -16'sd304; in_2 = -16'sd197; in_3 = -16'sd385; in_4 = -16'sd339;
    expected = -0.750765; expected_q9 = -384;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 260: sw_pred=-0.807169
    sample_id = 260;
    in_0 = -16'sd380; in_1 = 16'sd933; in_2 = -16'sd615; in_3 = 16'sd138; in_4 = 16'sd216;
    expected = -0.807169; expected_q9 = -413;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 261: sw_pred=-0.021970
    sample_id = 261;
    in_0 = -16'sd60; in_1 = 16'sd143; in_2 = -16'sd476; in_3 = -16'sd645; in_4 = -16'sd207;
    expected = -0.021970; expected_q9 = -11;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 262: sw_pred=0.037508
    sample_id = 262;
    in_0 = -16'sd204; in_1 = -16'sd594; in_2 = 16'sd499; in_3 = -16'sd645; in_4 = -16'sd329;
    expected = 0.037508; expected_q9 = 19;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 263: sw_pred=1.539720
    sample_id = 263;
    in_0 = -16'sd360; in_1 = 16'sd38; in_2 = 16'sd81; in_3 = 16'sd657; in_4 = -16'sd140;
    expected = 1.539720; expected_q9 = 788;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 264: sw_pred=0.998807
    sample_id = 264;
    in_0 = 16'sd822; in_1 = -16'sd594; in_2 = -16'sd615; in_3 = 16'sd657; in_4 = -16'sd420;
    expected = 0.998807; expected_q9 = 511;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 265: sw_pred=-0.247207
    sample_id = 265;
    in_0 = -16'sd300; in_1 = 16'sd486; in_2 = -16'sd197; in_3 = -16'sd385; in_4 = 16'sd1170;
    expected = -0.247207; expected_q9 = -127;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 266: sw_pred=0.969792
    sample_id = 266;
    in_0 = -16'sd300; in_1 = 16'sd521; in_2 = -16'sd615; in_3 = 16'sd657; in_4 = 16'sd43;
    expected = 0.969792; expected_q9 = 497;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 267: sw_pred=0.222668
    sample_id = 267;
    in_0 = 16'sd341; in_1 = -16'sd594; in_2 = -16'sd197; in_3 = -16'sd385; in_4 = -16'sd378;
    expected = 0.222668; expected_q9 = 114;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 268: sw_pred=0.487959
    sample_id = 268;
    in_0 = -16'sd204; in_1 = -16'sd594; in_2 = 16'sd499; in_3 = 16'sd138; in_4 = -16'sd346;
    expected = 0.487959; expected_q9 = 250;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 269: sw_pred=-0.111011
    sample_id = 269;
    in_0 = 16'sd550; in_1 = 16'sd240; in_2 = -16'sd615; in_3 = 16'sd138; in_4 = -16'sd265;
    expected = -0.111011; expected_q9 = -57;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 270: sw_pred=1.299171
    sample_id = 270;
    in_0 = 16'sd341; in_1 = -16'sd594; in_2 = -16'sd476; in_3 = -16'sd385; in_4 = -16'sd405;
    expected = 1.299171; expected_q9 = 665;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 271: sw_pred=-0.381537
    sample_id = 271;
    in_0 = -16'sd140; in_1 = -16'sd243; in_2 = 16'sd499; in_3 = -16'sd645; in_4 = -16'sd236;
    expected = -0.381537; expected_q9 = -195;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 272: sw_pred=-0.467071
    sample_id = 272;
    in_0 = -16'sd140; in_1 = -16'sd594; in_2 = 16'sd917; in_3 = -16'sd645; in_4 = -16'sd305;
    expected = -0.467071; expected_q9 = -239;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 273: sw_pred=0.920034
    sample_id = 273;
    in_0 = -16'sd332; in_1 = -16'sd120; in_2 = 16'sd81; in_3 = 16'sd657; in_4 = -16'sd278;
    expected = 0.920034; expected_q9 = 471;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 274: sw_pred=0.857748
    sample_id = 274;
    in_0 = -16'sd332; in_1 = -16'sd243; in_2 = 16'sd499; in_3 = -16'sd645; in_4 = -16'sd236;
    expected = 0.857748; expected_q9 = 439;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 275: sw_pred=-0.355564
    sample_id = 275;
    in_0 = -16'sd332; in_1 = -16'sd173; in_2 = -16'sd615; in_3 = -16'sd645; in_4 = -16'sd399;
    expected = -0.355564; expected_q9 = -182;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 276: sw_pred=0.651972
    sample_id = 276;
    in_0 = -16'sd60; in_1 = -16'sd594; in_2 = -16'sd615; in_3 = 16'sd138; in_4 = -16'sd420;
    expected = 0.651972; expected_q9 = 334;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 277: sw_pred=0.145533
    sample_id = 277;
    in_0 = -16'sd360; in_1 = 16'sd933; in_2 = -16'sd615; in_3 = -16'sd385; in_4 = 16'sd242;
    expected = 0.145533; expected_q9 = 75;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 278: sw_pred=-1.158497
    sample_id = 278;
    in_0 = -16'sd380; in_1 = 16'sd1354; in_2 = -16'sd615; in_3 = 16'sd657; in_4 = 16'sd407;
    expected = -1.158497; expected_q9 = -593;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 279: sw_pred=-0.513209
    sample_id = 279;
    in_0 = -16'sd60; in_1 = 16'sd1354; in_2 = -16'sd615; in_3 = -16'sd385; in_4 = 16'sd465;
    expected = -0.513209; expected_q9 = -263;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 280: sw_pred=0.026789
    sample_id = 280;
    in_0 = -16'sd410; in_1 = 16'sd758; in_2 = -16'sd476; in_3 = 16'sd138; in_4 = 16'sd634;
    expected = 0.026789; expected_q9 = 14;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 281: sw_pred=-0.228559
    sample_id = 281;
    in_0 = 16'sd550; in_1 = -16'sd594; in_2 = 16'sd81; in_3 = 16'sd138; in_4 = -16'sd368;
    expected = -0.228559; expected_q9 = -117;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 282: sw_pred=0.223077
    sample_id = 282;
    in_0 = -16'sd140; in_1 = 16'sd933; in_2 = -16'sd615; in_3 = 16'sd657; in_4 = 16'sd198;
    expected = 0.223077; expected_q9 = 114;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 283: sw_pred=-1.091687
    sample_id = 283;
    in_0 = 16'sd341; in_1 = 16'sd143; in_2 = -16'sd476; in_3 = 16'sd138; in_4 = -16'sd221;
    expected = -1.091687; expected_q9 = -559;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 284: sw_pred=0.136730
    sample_id = 284;
    in_0 = -16'sd140; in_1 = -16'sd173; in_2 = -16'sd615; in_3 = 16'sd657; in_4 = -16'sd402;
    expected = 0.136730; expected_q9 = 70;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 285: sw_pred=0.834427
    sample_id = 285;
    in_0 = -16'sd332; in_1 = -16'sd594; in_2 = 16'sd499; in_3 = -16'sd645; in_4 = -16'sd329;
    expected = 0.834427; expected_q9 = 427;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 286: sw_pred=0.476078
    sample_id = 286;
    in_0 = 16'sd181; in_1 = -16'sd594; in_2 = 16'sd81; in_3 = 16'sd657; in_4 = -16'sd373;
    expected = 0.476078; expected_q9 = 244;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 287: sw_pred=-0.844252
    sample_id = 287;
    in_0 = 16'sd822; in_1 = -16'sd594; in_2 = 16'sd499; in_3 = 16'sd657; in_4 = -16'sd351;
    expected = -0.844252; expected_q9 = -432;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 288: sw_pred=0.884782
    sample_id = 288;
    in_0 = 16'sd181; in_1 = -16'sd594; in_2 = -16'sd197; in_3 = 16'sd138; in_4 = -16'sd384;
    expected = 0.884782; expected_q9 = 453;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 289: sw_pred=-0.098723
    sample_id = 289;
    in_0 = -16'sd397; in_1 = -16'sd462; in_2 = 16'sd917; in_3 = -16'sd385; in_4 = -16'sd282;
    expected = -0.098723; expected_q9 = -51;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 290: sw_pred=-1.590214
    sample_id = 290;
    in_0 = 16'sd341; in_1 = 16'sd187; in_2 = -16'sd197; in_3 = -16'sd385; in_4 = 16'sd54;
    expected = -1.590214; expected_q9 = -814;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 291: sw_pred=-0.183818
    sample_id = 291;
    in_0 = -16'sd204; in_1 = -16'sd173; in_2 = -16'sd615; in_3 = 16'sd138; in_4 = -16'sd401;
    expected = -0.183818; expected_q9 = -94;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 292: sw_pred=0.326939
    sample_id = 292;
    in_0 = 16'sd45; in_1 = 16'sd933; in_2 = -16'sd615; in_3 = 16'sd657; in_4 = 16'sd198;
    expected = 0.326939; expected_q9 = 167;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 293: sw_pred=-1.854925
    sample_id = 293;
    in_0 = 16'sd1143; in_1 = -16'sd331; in_2 = 16'sd917; in_3 = 16'sd657; in_4 = -16'sd268;
    expected = -1.854925; expected_q9 = -950;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 294: sw_pred=-0.302868
    sample_id = 294;
    in_0 = 16'sd822; in_1 = -16'sd594; in_2 = -16'sd197; in_3 = -16'sd385; in_4 = -16'sd378;
    expected = -0.302868; expected_q9 = -155;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 295: sw_pred=0.103008
    sample_id = 295;
    in_0 = -16'sd332; in_1 = 16'sd933; in_2 = -16'sd615; in_3 = 16'sd138; in_4 = 16'sd216;
    expected = 0.103008; expected_q9 = 53;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 296: sw_pred=1.662313
    sample_id = 296;
    in_0 = 16'sd341; in_1 = -16'sd594; in_2 = -16'sd615; in_3 = -16'sd385; in_4 = -16'sd419;
    expected = 1.662313; expected_q9 = 851;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 297: sw_pred=-1.048223
    sample_id = 297;
    in_0 = 16'sd822; in_1 = -16'sd357; in_2 = 16'sd81; in_3 = -16'sd385; in_4 = -16'sd320;
    expected = -1.048223; expected_q9 = -537;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 298: sw_pred=0.183936
    sample_id = 298;
    in_0 = -16'sd360; in_1 = -16'sd594; in_2 = -16'sd197; in_3 = -16'sd385; in_4 = -16'sd378;
    expected = 0.183936; expected_q9 = 94;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 299: sw_pred=0.225036
    sample_id = 299;
    in_0 = 16'sd2106; in_1 = -16'sd594; in_2 = -16'sd615; in_3 = 16'sd657; in_4 = -16'sd420;
    expected = 0.225036; expected_q9 = 115;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    // Sample 300: sw_pred=0.700052
    sample_id = 300;
    in_0 = -16'sd410; in_1 = 16'sd38; in_2 = 16'sd81; in_3 = 16'sd657; in_4 = -16'sd140;
    expected = 0.700052; expected_q9 = 358;
    start = 1; @(posedge clk); #1; start = 0;
    wait(done); repeat(5) @(posedge clk); #1;

    $fclose(fout);
    $display("===== Summary =====");
    $display("Total samples:    %0d", num_samples);
    $display("Mean abs error:   %f", sum_abs_error / num_samples);
    $display("Max abs error:    %f", max_abs_error);
    $display("==================");
    $display("RTL outputs saved to: rtl_outputs.csv");

    $stop;
end

endmodule