/* silu_quadratic_tb.v
 * Testbench for 8-segment piecewise quadratic SiLU
 */
`timescale 1ns/1ps

module silu_quadratic_tb;

reg clk, rst_n, valid_in;
reg signed [15:0] x;
wire signed [15:0] y;
wire valid_out;

silu_quadratic dut (
    .clk(clk),
    .rst_n(rst_n),
    .valid_in(valid_in),
    .x(x),
    .y(y),
    .valid_out(valid_out)
);

initial clk = 0;
always #5 clk = ~clk;

real x_real, y_real, expected, error, abs_error;
real max_error, sum_error;
integer num_tests;

// Exact SiLU function
function real silu_exact;
    input real x_val;
    real exp_neg_x;
    begin
        if (x_val < -10.0) begin
            silu_exact = 0.0;
        end else if (x_val > 10.0) begin
            silu_exact = x_val;
        end else begin
            exp_neg_x = $exp(-x_val);
            silu_exact = x_val / (1.0 + exp_neg_x);
        end
    end
endfunction

initial begin
    rst_n = 0;
    x = 0;
    max_error = 0.0;
    sum_error = 0.0;
    num_tests = 0;

    repeat(5) @(posedge clk); #1;
    rst_n = 1;
    repeat(2) @(posedge clk); #1;

    $display("===== SiLU Quadratic Approximation Test =====");
    $display("Testing 8-segment piecewise quadratic polynomial");
    $display("");

    // Test range: -6 to 6 with step 0.1
    for (x_real = -6.0; x_real <= 6.0; x_real = x_real + 0.1) begin
        x = $rtoi(x_real * 512.0);
        repeat(4) @(posedge clk); #1;  // Wait for 3-stage pipeline

        y_real = $itor($signed(y)) / 512.0;
        expected = silu_exact(x_real);
        error = y_real - expected;
        abs_error = (error >= 0) ? error : -error;

        sum_error = sum_error + abs_error;
        num_tests = num_tests + 1;

        if (abs_error > max_error) begin
            max_error = abs_error;
            $display("New max error at x=%f: expected=%f, actual=%f, error=%f",
                     x_real, expected, y_real, abs_error);
        end

        // Show some sample points
        if ((x_real >= -6.0 && x_real <= -5.5) ||
            (x_real >= -3.0 && x_real <= -2.5) ||
            (x_real >= -1.5 && x_real <= -1.0) ||
            (x_real >= -0.5 && x_real <= 0.5) ||
            (x_real >= 1.0 && x_real <= 1.5) ||
            (x_real >= 2.5 && x_real <= 3.0) ||
            (x_real >= 5.5 && x_real <= 6.0)) begin
            $display("x=%+6.2f: expected=%+8.5f, actual=%+8.5f, error=%+8.5f",
                     x_real, expected, y_real, error);
        end
    end

    $display("");
    $display("===== Summary =====");
    $display("Total tests:      %0d", num_tests);
    $display("Max abs error:    %f", max_error);
    $display("Mean abs error:   %f", sum_error / num_tests);
    $display("Target max error: 0.003824");

    if (max_error < 0.005) begin
        $display("PASS: Max error < 0.005");
    end else begin
        $display("FAIL: Max error >= 0.005");
    end
    $display("===================");

    $stop;
end

endmodule
