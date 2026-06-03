/* mac.v
 * Multiply-Accumulate unit (scale pre-absorbed into weights, full fixed-point)
 * Data format:
 *   sx:       Q6.9 (signed 16bit), SiLU output
 *   bases:    Q1.15 (signed 16bit), B-spline basis values
 *   base_w:   Q6.9 (signed 16bit), base weight
 *   spline_w: Q6.9 (signed 16bit), spline weight
 *   spline_sc:Q6.9 (signed 16bit), spline scaler
 *   acc:      signed 32bit accumulator
 * Pipeline latency: 4 cycles (optimized for 100MHz+)
 *
 * Computation:
 *   base_contrib   = sx(Q6.9) * base_w(Q6.9) >> 9  -> Q6.9
 *   spline_coeff   = sum_k bases[k](Q1.15) * spline_w[k](Q6.9) >> 15 -> Q6.9
 *   spline_contrib = spline_coeff(Q6.9) * spline_sc(Q6.9) >> 9 -> Q6.9
 *   acc           += base_contrib + spline_contrib
 */
module mac (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        acc_clear,
    input  wire        valid_in,

    input  wire signed [15:0] sx,
    input  wire signed [15:0] bases_0,
    input  wire signed [15:0] bases_1,
    input  wire signed [15:0] bases_2,
    input  wire signed [15:0] bases_3,
    input  wire signed [15:0] bases_4,
    input  wire signed [15:0] bases_5,
    input  wire signed [15:0] base_w,
    input  wire signed [15:0] spline_w_0,
    input  wire signed [15:0] spline_w_1,
    input  wire signed [15:0] spline_w_2,
    input  wire signed [15:0] spline_w_3,
    input  wire signed [15:0] spline_w_4,
    input  wire signed [15:0] spline_w_5,
    input  wire signed [15:0] spline_sc,

    output reg  signed [31:0] acc,
    output reg         valid_out
);

// Stage 1a: integer multiply (7 parallel multiplies, register results)
(* use_dsp = "yes" *) reg signed [31:0] s1a_base_raw;      // sx(Q6.9) * base_w(Q6.9) -> Q12.18
(* use_dsp = "yes" *) reg signed [31:0] s1a_sp_0;          // bases[0](Q1.15) * spline_w[0](Q6.9) -> Q7.24
(* use_dsp = "yes" *) reg signed [31:0] s1a_sp_1;
(* use_dsp = "yes" *) reg signed [31:0] s1a_sp_2;
(* use_dsp = "yes" *) reg signed [31:0] s1a_sp_3;
(* use_dsp = "yes" *) reg signed [31:0] s1a_sp_4;
(* use_dsp = "yes" *) reg signed [31:0] s1a_sp_5;
reg signed [15:0] s1a_spline_sc;
reg               s1a_valid, s1a_clear;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        s1a_valid <= 0; s1a_clear <= 0;
        s1a_base_raw <= 0;
        s1a_sp_0 <= 0; s1a_sp_1 <= 0; s1a_sp_2 <= 0;
        s1a_sp_3 <= 0; s1a_sp_4 <= 0; s1a_sp_5 <= 0;
        s1a_spline_sc <= 0;
    end else begin
        s1a_valid     <= valid_in;
        s1a_clear     <= acc_clear;
        s1a_spline_sc <= spline_sc;
        s1a_base_raw  <= $signed(sx) * $signed(base_w);
        s1a_sp_0      <= $signed(bases_0) * $signed(spline_w_0);
        s1a_sp_1      <= $signed(bases_1) * $signed(spline_w_1);
        s1a_sp_2      <= $signed(bases_2) * $signed(spline_w_2);
        s1a_sp_3      <= $signed(bases_3) * $signed(spline_w_3);
        s1a_sp_4      <= $signed(bases_4) * $signed(spline_w_4);
        s1a_sp_5      <= $signed(bases_5) * $signed(spline_w_5);
    end
end

// Stage 1b: 6-way adder tree, register the sum
reg signed [47:0] s1b_spline_coeff;  // sum of 6 Q7.24 values -> Q7.24 + 3 guard bits = Q10.24 (fits in 48)
reg signed [31:0] s1b_base_raw;
reg signed [15:0] s1b_spline_sc;
reg               s1b_valid, s1b_clear;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        s1b_valid <= 0; s1b_clear <= 0;
        s1b_spline_coeff <= 0;
        s1b_base_raw <= 0;
        s1b_spline_sc <= 0;
    end else begin
        s1b_valid         <= s1a_valid;
        s1b_clear         <= s1a_clear;
        s1b_base_raw      <= s1a_base_raw;
        s1b_spline_sc     <= s1a_spline_sc;
        // 6-way adder tree: (s0+s1)+(s2+s3)+(s4+s5)
        s1b_spline_coeff  <= {16'd0, s1a_sp_0} + {16'd0, s1a_sp_1}
                           + {16'd0, s1a_sp_2} + {16'd0, s1a_sp_3}
                           + {16'd0, s1a_sp_4} + {16'd0, s1a_sp_5};
    end
end

// Stage 2: shift align + spline_sc multiply
// base_contrib   = s1b_base_raw >> 9 (with rounding)       -> Q6.9
// spline_mid     = s1b_spline_coeff[30:15] (with rounding) -> Q6.9
// spline_contrib = spline_mid * spline_sc >> 9 (with rounding) -> Q6.9
reg signed [31:0] s2_base_contrib;
reg signed [31:0] s2_spline_mid_x_sc;
reg               s2_valid, s2_clear;

// Round spline_coeff: add bit[14] for rounding before extracting [30:15]
wire signed [47:0] spline_coeff_rounded = s1b_spline_coeff + 48'sd16384;  // add 2^14
wire signed [15:0] spline_mid = spline_coeff_rounded[30:15];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        s2_valid <= 0; s2_clear <= 0;
        s2_base_contrib <= 0; s2_spline_mid_x_sc <= 0;
    end else begin
        s2_valid          <= s1b_valid;
        s2_clear          <= s1b_clear;
        // Round base_raw: add bit[8] for rounding before shift
        s2_base_contrib   <= (s1b_base_raw + 32'sd256) >>> 9;
        s2_spline_mid_x_sc <= $signed(spline_mid) * $signed(s1b_spline_sc);
    end
end

// Stage 3: accumulate
// Round spline_contrib: add bit[8] for rounding before shift
wire signed [31:0] spline_contrib = (s2_spline_mid_x_sc + 32'sd256) >>> 9;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        acc <= 0; valid_out <= 0;
    end else begin
        valid_out <= s2_valid;
        if (s2_clear)
            acc <= s2_base_contrib + spline_contrib;
        else if (s2_valid)
            acc <= acc + s2_base_contrib + spline_contrib;
    end
end

endmodule
