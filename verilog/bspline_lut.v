/* bspline_lut.v
 * B-spline basis function lookup table (4-stage pipeline, 4-cycle latency)
 * Input:  Q6.9 fixed-point x (range [-3,3])
 * Output: 6 basis values, Q1.15 format (32767=1.0)
 * LUT:    256 points, step=12 (Q6.9), linear interpolation
 * Optimized: interpolation split into diff+frac_mul -> sum, for 100MHz+
 */
module bspline_lut (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        valid_in,
    input  wire signed [15:0] x,
    output reg  [15:0] bases_0,
    output reg  [15:0] bases_1,
    output reg  [15:0] bases_2,
    output reg  [15:0] bases_3,
    output reg  [15:0] bases_4,
    output reg  [15:0] bases_5,
    output reg         valid_out
);

// LUT parameters (Q6.9): X_MIN=-1536(-3.0), STEP=12, N=256
localparam signed [15:0] LUT_X_MIN = -16'sd1536;
localparam        [15:0] LUT_STEP  = 16'd12;
localparam               N_LUT     = 256;

// Flattened LUT: 256*6=1536 entries
reg [15:0] lut_flat [0:1535];
initial $readmemh("bspline_lut.hex", lut_flat);

// Stage 1: clamp + compute index
reg [7:0]  s1_idx0;
reg [15:0] s1_frac;
reg        s1_valid;

wire signed [15:0] x_clamped;
assign x_clamped = ($signed(x) < $signed(LUT_X_MIN)) ? LUT_X_MIN :
                   ($signed(x) > 16'sd1536)           ? 16'sd1536 : x;

wire [15:0] pos_num;
assign pos_num = $unsigned($signed(x_clamped) - $signed(LUT_X_MIN));

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        s1_idx0 <= 8'd0; s1_frac <= 16'd0; s1_valid <= 1'b0;
    end else begin
        s1_valid <= valid_in;
        s1_frac  <= pos_num % LUT_STEP;
        if ((pos_num / LUT_STEP) >= (N_LUT - 1))
            s1_idx0 <= N_LUT - 2;
        else
            s1_idx0 <= pos_num / LUT_STEP;
    end
end

// Stage 2: table lookup (BRAM read)
reg [15:0] s2_v0 [0:5];
reg [15:0] s2_v1 [0:5];
reg [15:0] s2_frac;
reg        s2_valid;

wire [7:0] idx1 = s1_idx0 + 8'd1;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        s2_valid <= 1'b0; s2_frac <= 16'd0;
    end else begin
        s2_valid <= s1_valid;
        s2_frac  <= s1_frac;
        s2_v0[0] <= lut_flat[s1_idx0 * 6 + 0];
        s2_v0[1] <= lut_flat[s1_idx0 * 6 + 1];
        s2_v0[2] <= lut_flat[s1_idx0 * 6 + 2];
        s2_v0[3] <= lut_flat[s1_idx0 * 6 + 3];
        s2_v0[4] <= lut_flat[s1_idx0 * 6 + 4];
        s2_v0[5] <= lut_flat[s1_idx0 * 6 + 5];
        s2_v1[0] <= lut_flat[idx1 * 6 + 0];
        s2_v1[1] <= lut_flat[idx1 * 6 + 1];
        s2_v1[2] <= lut_flat[idx1 * 6 + 2];
        s2_v1[3] <= lut_flat[idx1 * 6 + 3];
        s2_v1[4] <= lut_flat[idx1 * 6 + 4];
        s2_v1[5] <= lut_flat[idx1 * 6 + 5];
    end
end

// Stage 3a: product = frac * (v1 - v0)  (DSP multiply, registered)
// 1/STEP = 1/12 ≈ 2731/32768 (Q1.15, error < 0.01%)
localparam signed [31:0] INV_STEP = 32'sd2731;  // 1/12 in Q1.15

reg signed [31:0] s3_prod [0:5];
reg signed [16:0] s3_v0_ext [0:5];
reg               s3_valid;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        s3_valid <= 1'b0;
    end else begin
        s3_valid <= s2_valid;
        s3_prod[0] <= $signed(s2_frac) * $signed(s2_v1[0] - s2_v0[0]);
        s3_prod[1] <= $signed(s2_frac) * $signed(s2_v1[1] - s2_v0[1]);
        s3_prod[2] <= $signed(s2_frac) * $signed(s2_v1[2] - s2_v0[2]);
        s3_prod[3] <= $signed(s2_frac) * $signed(s2_v1[3] - s2_v0[3]);
        s3_prod[4] <= $signed(s2_frac) * $signed(s2_v1[4] - s2_v0[4]);
        s3_prod[5] <= $signed(s2_frac) * $signed(s2_v1[5] - s2_v0[5]);
        s3_v0_ext[0] <= {1'b0, s2_v0[0]};
        s3_v0_ext[1] <= {1'b0, s2_v0[1]};
        s3_v0_ext[2] <= {1'b0, s2_v0[2]};
        s3_v0_ext[3] <= {1'b0, s2_v0[3]};
        s3_v0_ext[4] <= {1'b0, s2_v0[4]};
        s3_v0_ext[5] <= {1'b0, s2_v0[5]};
    end
end

// Stage 3b: result = v0 + prod * (1/STEP) >> 15  (registered output)
// prod/12 ≈ (prod * 2731 + 16384) >> 15 (with rounding)
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        valid_out <= 1'b0;
        bases_0 <= 16'd0; bases_1 <= 16'd0; bases_2 <= 16'd0;
        bases_3 <= 16'd0; bases_4 <= 16'd0; bases_5 <= 16'd0;
    end else begin
        valid_out <= s3_valid;
        bases_0 <= $signed(s3_v0_ext[0]) + ((s3_prod[0] * INV_STEP + 32'sd16384) >>> 15);
        bases_1 <= $signed(s3_v0_ext[1]) + ((s3_prod[1] * INV_STEP + 32'sd16384) >>> 15);
        bases_2 <= $signed(s3_v0_ext[2]) + ((s3_prod[2] * INV_STEP + 32'sd16384) >>> 15);
        bases_3 <= $signed(s3_v0_ext[3]) + ((s3_prod[3] * INV_STEP + 32'sd16384) >>> 15);
        bases_4 <= $signed(s3_v0_ext[4]) + ((s3_prod[4] * INV_STEP + 32'sd16384) >>> 15);
        bases_5 <= $signed(s3_v0_ext[5]) + ((s3_prod[5] * INV_STEP + 32'sd16384) >>> 15);
    end
end

endmodule
