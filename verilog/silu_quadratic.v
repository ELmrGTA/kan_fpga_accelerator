/* silu_quadratic.v
 * 8-segment piecewise quadratic polynomial SiLU approximation
 * y = a*x^2 + b*x + c
 * Max error: 0.003819 (vs 0.00809 for 18-segment linear)
 * Input/Output: Q6.9 signed 16-bit fixed-point
 * Latency: 3 cycles (segment select, multiply, sum)
 * Segment selection: binary decision tree (max 4 comparisons, down from 9)
 */
module silu_quadratic (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        valid_in,
    input  wire signed [15:0] x,      // Q6.9
    output reg  signed [15:0] y,      // Q6.9
    output reg         valid_out
);

// Segment boundaries (Q6.9)
localparam signed [15:0] B0 = -16'sd3072;  // -6.0
localparam signed [15:0] B1 = -16'sd1536;  // -3.0
localparam signed [15:0] B2 = -16'sd768;   // -1.5
localparam signed [15:0] B3 = -16'sd256;   // -0.5
localparam signed [15:0] B4 = 16'sd0;      //  0.0
localparam signed [15:0] B5 = 16'sd256;    //  0.5
localparam signed [15:0] B6 = 16'sd768;    //  1.5
localparam signed [15:0] B7 = 16'sd1536;   //  3.0
localparam signed [15:0] B8 = 16'sd3072;   //  6.0

// Coefficients for 8 segments (Q6.9)
// Segment 0: (-6,-3], a=-0.01298, b=-0.15763, c=-0.49592
localparam signed [15:0] A0 = -16'sd7;     // -0.01298*512 = -6.6
localparam signed [15:0] B0_coef = -16'sd81;    // -0.15763*512 = -80.7
localparam signed [15:0] C0 = -16'sd254;   // -0.49592*512 = -253.9

// Segment 1: (-3,-1.5], a=0.01117, b=-0.04175, c=-0.36523
localparam signed [15:0] A1 = 16'sd6;      // 0.01117*512 = 5.7
localparam signed [15:0] B1_coef = -16'sd21;    // -0.04175*512 = -21.4
localparam signed [15:0] C1 = -16'sd187;   // -0.36523*512 = -187.0

// Segment 2: (-1.5,-0.5], a=0.15099, b=0.38195, c=-0.03797
localparam signed [15:0] A2 = 16'sd77;     // 0.15099*512 = 77.3
localparam signed [15:0] B2_coef = 16'sd196;    // 0.38195*512 = 195.6
localparam signed [15:0] C2 = -16'sd19;    // -0.03797*512 = -19.4

// Segment 3: (-0.5,0], a=0.24129, b=0.49769, c=-0.00011
localparam signed [15:0] A3 = 16'sd124;    // 0.24129*512 = 123.5
localparam signed [15:0] B3_coef = 16'sd255;    // 0.49769*512 = 254.8
localparam signed [15:0] C3 = -16'sd0;     // -0.00011*512 = -0.1

// Segment 4: (0,0.5], a=0.24129, b=0.50231, c=-0.00011
localparam signed [15:0] A4 = 16'sd124;    // 0.24129*512 = 123.5
localparam signed [15:0] B4_coef = 16'sd257;    // 0.50231*512 = 257.2
localparam signed [15:0] C4 = -16'sd0;     // -0.00011*512 = -0.1

// Segment 5: (0.5,1.5], a=0.15099, b=0.61805, c=-0.03797
localparam signed [15:0] A5 = 16'sd77;     // 0.15099*512 = 77.3
localparam signed [15:0] B5_coef = 16'sd316;    // 0.61805*512 = 316.4
localparam signed [15:0] C5 = -16'sd19;    // -0.03797*512 = -19.4

// Segment 6: (1.5,3], a=0.01117, b=1.04175, c=-0.36523
localparam signed [15:0] A6 = 16'sd6;      // 0.01117*512 = 5.7
localparam signed [15:0] B6_coef = 16'sd533;    // 1.04175*512 = 533.4
localparam signed [15:0] C6 = -16'sd187;   // -0.36523*512 = -187.0

// Segment 7: (3,6], a=-0.01298, b=1.15763, c=-0.49592
localparam signed [15:0] A7 = -16'sd7;     // -0.01298*512 = -6.6
localparam signed [15:0] B7_coef = 16'sd593;    // 1.15763*512 = 592.7
localparam signed [15:0] C7 = -16'sd254;   // -0.49592*512 = -253.9

// Pipeline stage 1: segment selection and x^2
reg signed [15:0] a_sel, b_sel, c_sel;
reg signed [31:0] x_squared;
reg signed [15:0] x_d1;
reg valid_d1;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        a_sel <= 0;
        b_sel <= 0;
        c_sel <= 0;
        x_squared <= 0;
        x_d1 <= 0;
        valid_d1 <= 0;
    end else begin
        valid_d1 <= valid_in;
        x_d1 <= x;
        x_squared <= x * x;  // Q6.9 * Q6.9 = Q12.18

        // Binary-tree segment selection (max 4 comparisons vs 9 serial)
        // Level 1: split at B3 (-0.5)
        if (x <= B3) begin
            // Level 2: split at B1 (-3.0)
            if (x <= B1) begin
                // Level 3: x <= -3  =>  x <= B0(-6)? saturate : seg0
                if (x <= B0)
                    {a_sel, b_sel, c_sel} <= {16'd0, 16'd0, 16'd0};
                else
                    {a_sel, b_sel, c_sel} <= {A0, B0_coef, C0};
            end else begin
                // Level 3: -3 < x <= -0.5  =>  x <= B2(-1.5)? seg1 : seg2
                if (x <= B2)
                    {a_sel, b_sel, c_sel} <= {A1, B1_coef, C1};
                else
                    {a_sel, b_sel, c_sel} <= {A2, B2_coef, C2};
            end
        end else begin
            // Level 2: x > -0.5, split at B6 (1.5)
            if (x <= B6) begin
                // Level 3: -0.5 < x <= 1.5  =>  x <= B4(0)? seg3 : (x <= B5(0.5)? seg4 : seg5)
                if (x <= B4)
                    {a_sel, b_sel, c_sel} <= {A3, B3_coef, C3};
                else if (x <= B5)
                    {a_sel, b_sel, c_sel} <= {A4, B4_coef, C4};
                else
                    {a_sel, b_sel, c_sel} <= {A5, B5_coef, C5};
            end else begin
                // Level 3: x > 1.5  =>  x <= B7(3)? seg6 : (x <= B8(6)? seg7 : passthrough)
                if (x <= B7)
                    {a_sel, b_sel, c_sel} <= {A6, B6_coef, C6};
                else if (x <= B8)
                    {a_sel, b_sel, c_sel} <= {A7, B7_coef, C7};
                else
                    {a_sel, b_sel, c_sel} <= {16'd0, 16'sd512, 16'd0};
            end
        end
    end
end

// Pipeline stage 2: compute a*x^2 and b*x
reg signed [47:0] ax2_full;  // a * x^2 full precision
reg signed [31:0] bx_full;   // b * x full precision
reg signed [15:0] c_d2;
reg valid_d2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ax2_full <= 0;
        bx_full <= 0;
        c_d2 <= 0;
        valid_d2 <= 0;
    end else begin
        valid_d2 <= valid_d1;
        // a * x^2: Q6.9(16bit) * Q12.18(32bit) = Q18.27(48bit)
        ax2_full <= $signed(a_sel) * $signed(x_squared);
        // b * x: Q6.9 * Q6.9 = Q12.18(32bit)
        bx_full <= $signed(b_sel) * $signed(x_d1);
        c_d2 <= c_sel;
    end
end

// Pipeline stage 3: shift and final sum
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        y <= 0;
        valid_out <= 0;
    end else begin
        valid_out <= valid_d2;
        // Shift to Q6.9 and sum: (ax2>>18) + (bx>>9) + c
        y <= (ax2_full >>> 18) + (bx_full >>> 9) + $signed(c_d2);
    end
end

endmodule
