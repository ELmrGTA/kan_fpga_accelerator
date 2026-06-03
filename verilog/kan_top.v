/* kan_top.v
 * KAN [5->16->8->1] inference top module
 * Time-multiplexed: three layers share one set of silu+bspline_lut+mac hardware
 * Data format: Q6.9 (signed 16bit)
 * Interface:
 *   - 5 Q6.9 inputs (parallel)
 *   - 1 Q6.9 output
 *   - start triggers inference, done signals completion
 *
 * Pipeline latency:
 *   - silu_quadratic: 3 cycles (binary-tree segment selection)
 *   - bspline_lut: 4 cycles (interpolation split: diff*frac -> sum)
 *   - mac: 5 cycles (input_reg + 1a=multiply + 1b=adder + align + accumulate)
 * Weight ROMs: Block RAM (ram_style=block) for fast, portable timing closure
 * Each layer: FEED -> WAIT -> MAC (with BRAM pre-fetch pipeline)
 * MAC drain: mac_out_cnt == 5 (accounts for BRAM output register)
 */
module kan_top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire signed [15:0] in_0, in_1, in_2, in_3, in_4,  // Q6.9
    output reg  signed [15:0] out_0,                           // Q6.9
    output reg         done
);

// Layer dimensions
localparam IN_DIM   = 5;
localparam HIDDEN1  = 16;
localparam HIDDEN2  = 8;
localparam OUT_DIM  = 1;
localparam COEFF    = 6;

// Weight ROMs (Block RAM)
(* ram_style = "block" *) reg signed [15:0] l0_bw  [0:79];    // 16*5
(* ram_style = "block" *) reg signed [15:0] l0_sw  [0:479];   // 16*5*6
(* ram_style = "block" *) reg signed [15:0] l0_sc  [0:79];    // 16*5

(* ram_style = "block" *) reg signed [15:0] l1_bw  [0:127];   // 8*16
(* ram_style = "block" *) reg signed [15:0] l1_sw  [0:767];   // 8*16*6
(* ram_style = "block" *) reg signed [15:0] l1_sc  [0:127];   // 8*16

(* ram_style = "block" *) reg signed [15:0] l2_bw  [0:7];     // 1*8
(* ram_style = "block" *) reg signed [15:0] l2_sw  [0:47];    // 1*8*6
(* ram_style = "block" *) reg signed [15:0] l2_sc  [0:7];     // 1*8

initial begin
    $readmemh("l0_base_weight.hex",   l0_bw);
    $readmemh("l0_spline_weight.hex", l0_sw);
    $readmemh("l0_spline_scaler.hex", l0_sc);
    $readmemh("l1_base_weight.hex",   l1_bw);
    $readmemh("l1_spline_weight.hex", l1_sw);
    $readmemh("l1_spline_scaler.hex", l1_sc);
    $readmemh("l2_base_weight.hex",   l2_bw);
    $readmemh("l2_spline_weight.hex", l2_sw);
    $readmemh("l2_spline_scaler.hex", l2_sc);
end

// Activation buffers (max 16 neurons)
reg signed [15:0] buf_a [0:15];  // current layer input
reg signed [15:0] buf_b [0:15];  // current layer output

// Submodule instances
reg        silu_valid_in;
reg signed [15:0] silu_x;
wire signed [15:0] silu_y;
wire       silu_valid_out;

silu_quadratic silu_inst (
    .clk(clk), .rst_n(rst_n),
    .valid_in(silu_valid_in), .x(silu_x),
    .y(silu_y), .valid_out(silu_valid_out)
);

reg        bsp_valid_in;
reg signed [15:0] bsp_x;
wire [15:0] bsp_b0, bsp_b1, bsp_b2, bsp_b3, bsp_b4, bsp_b5;
wire        bsp_valid_out;

bspline_lut bsp_inst (
    .clk(clk), .rst_n(rst_n),
    .valid_in(bsp_valid_in), .x(bsp_x),
    .bases_0(bsp_b0), .bases_1(bsp_b1), .bases_2(bsp_b2),
    .bases_3(bsp_b3), .bases_4(bsp_b4), .bases_5(bsp_b5),
    .valid_out(bsp_valid_out)
);

// MAC input pipeline: Stage 0 (BRAM read + data fetch) -> Stage 1 (feed to MAC)
reg        s0_mac_clear, s0_mac_valid;
reg signed [15:0] s0_mac_sx;
reg signed [15:0] s0_mac_b0,s0_mac_b1,s0_mac_b2,s0_mac_b3,s0_mac_b4,s0_mac_b5;
reg signed [15:0] s0_mac_bw,s0_mac_sw0,s0_mac_sw1,s0_mac_sw2,s0_mac_sw3,s0_mac_sw4,s0_mac_sw5,s0_mac_sc;

reg        mac_clear, mac_valid;
reg signed [15:0] mac_sx;
reg signed [15:0] mac_b0,mac_b1,mac_b2,mac_b3,mac_b4,mac_b5;
reg signed [15:0] mac_bw, mac_sw0,mac_sw1,mac_sw2,mac_sw3,mac_sw4,mac_sw5, mac_sc;
wire signed [31:0] mac_acc;
wire               mac_valid_out;

mac mac_inst (
    .clk(clk), .rst_n(rst_n),
    .acc_clear(mac_clear), .valid_in(mac_valid),
    .sx(mac_sx),
    .bases_0(mac_b0),.bases_1(mac_b1),.bases_2(mac_b2),
    .bases_3(mac_b3),.bases_4(mac_b4),.bases_5(mac_b5),
    .base_w(mac_bw),
    .spline_w_0(mac_sw0),.spline_w_1(mac_sw1),.spline_w_2(mac_sw2),
    .spline_w_3(mac_sw3),.spline_w_4(mac_sw4),.spline_w_5(mac_sw5),
    .spline_sc(mac_sc),
    .acc(mac_acc), .valid_out(mac_valid_out)
);

// MAC input pipeline register (BRAM output register + 1 fabric register)
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mac_clear <= 0; mac_valid <= 0;
        mac_sx <= 0;
        mac_b0 <= 0; mac_b1 <= 0; mac_b2 <= 0;
        mac_b3 <= 0; mac_b4 <= 0; mac_b5 <= 0;
        mac_bw <= 0; mac_sc <= 0;
        mac_sw0 <= 0; mac_sw1 <= 0; mac_sw2 <= 0;
        mac_sw3 <= 0; mac_sw4 <= 0; mac_sw5 <= 0;
    end else begin
        mac_clear <= s0_mac_clear;
        mac_valid <= s0_mac_valid;
        mac_sx    <= s0_mac_sx;
        mac_b0 <= s0_mac_b0; mac_b1 <= s0_mac_b1; mac_b2 <= s0_mac_b2;
        mac_b3 <= s0_mac_b3; mac_b4 <= s0_mac_b4; mac_b5 <= s0_mac_b5;
        mac_bw <= s0_mac_bw; mac_sc <= s0_mac_sc;
        mac_sw0 <= s0_mac_sw0; mac_sw1 <= s0_mac_sw1; mac_sw2 <= s0_mac_sw2;
        mac_sw3 <= s0_mac_sw3; mac_sw4 <= s0_mac_sw4; mac_sw5 <= s0_mac_sw5;
    end
end

// FSM states
localparam S_IDLE     = 4'd0;
localparam S_L0_FEED  = 4'd1;
localparam S_L0_WAIT  = 4'd2;
localparam S_L0_MAC   = 4'd3;
localparam S_L1_FEED  = 4'd4;
localparam S_L1_WAIT  = 4'd5;
localparam S_L1_MAC   = 4'd6;
localparam S_L2_FEED  = 4'd7;
localparam S_L2_WAIT  = 4'd8;
localparam S_L2_MAC   = 4'd9;
localparam S_DONE     = 4'd10;

reg [3:0]  state;
reg [4:0]  feed_cnt;
reg [4:0]  in_cnt, out_cnt;
reg [4:0]  mac_out_cnt;   // drain: count mac_valid_out pulses, threshold = 5

// SiLU/BSpline result buffers (max 16)
reg signed [15:0] sx_buf [0:15];
reg [15:0] b0_buf[0:15], b1_buf[0:15], b2_buf[0:15];
reg [15:0] b3_buf[0:15], b4_buf[0:15], b5_buf[0:15];

reg [4:0] silu_res_cnt;
reg [4:0] bsp_res_cnt;

integer k;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= S_IDLE; done <= 0;
        silu_valid_in <= 0; bsp_valid_in <= 0;
        s0_mac_valid <= 0; s0_mac_clear <= 0;
        feed_cnt <= 0;
        in_cnt <= 0; out_cnt <= 0; mac_out_cnt <= 0;
        silu_res_cnt <= 0; bsp_res_cnt <= 0;
    end else begin
        silu_valid_in <= 0;
        bsp_valid_in  <= 0;
        s0_mac_valid  <= 0;
        s0_mac_clear  <= 0;
        done          <= 0;

        // Always capture pipeline results
        if (silu_valid_out) begin
            sx_buf[silu_res_cnt] <= silu_y;
            silu_res_cnt <= silu_res_cnt + 1;
        end
        if (bsp_valid_out) begin
            b0_buf[bsp_res_cnt] <= bsp_b0;
            b1_buf[bsp_res_cnt] <= bsp_b1;
            b2_buf[bsp_res_cnt] <= bsp_b2;
            b3_buf[bsp_res_cnt] <= bsp_b3;
            b4_buf[bsp_res_cnt] <= bsp_b4;
            b5_buf[bsp_res_cnt] <= bsp_b5;
            bsp_res_cnt <= bsp_res_cnt + 1;
        end

        case (state)
        S_IDLE: begin
            if (start) begin
                buf_a[0] <= in_0; buf_a[1] <= in_1; buf_a[2] <= in_2;
                buf_a[3] <= in_3; buf_a[4] <= in_4;
                feed_cnt     <= 0;
                silu_res_cnt <= 0;
                bsp_res_cnt  <= 0;
                state        <= S_L0_FEED;
            end
        end

        // Layer 0
        S_L0_FEED: begin
            if (feed_cnt < IN_DIM) begin
                silu_x <= buf_a[feed_cnt]; silu_valid_in <= 1;
                bsp_x  <= buf_a[feed_cnt]; bsp_valid_in  <= 1;
                feed_cnt <= feed_cnt + 1;
            end else begin
                state <= S_L0_WAIT;
            end
        end

        S_L0_WAIT: begin
            if (bsp_res_cnt == IN_DIM) begin
                out_cnt <= 0; in_cnt <= 0; state <= S_L0_MAC;
            end
        end

        S_L0_MAC: begin
            if (out_cnt < HIDDEN1) begin
                if (in_cnt < IN_DIM) begin
                    // Stage 0: fetch data + read BRAM weights (result ready next cycle)
                    s0_mac_sx  <= sx_buf[in_cnt];
                    s0_mac_b0  <= b0_buf[in_cnt]; s0_mac_b1 <= b1_buf[in_cnt];
                    s0_mac_b2  <= b2_buf[in_cnt]; s0_mac_b3 <= b3_buf[in_cnt];
                    s0_mac_b4  <= b4_buf[in_cnt]; s0_mac_b5 <= b5_buf[in_cnt];
                    s0_mac_bw  <= l0_bw[out_cnt * IN_DIM + in_cnt];
                    s0_mac_sc  <= l0_sc[out_cnt * IN_DIM + in_cnt];
                    s0_mac_sw0 <= l0_sw[(out_cnt * IN_DIM + in_cnt) * COEFF + 0];
                    s0_mac_sw1 <= l0_sw[(out_cnt * IN_DIM + in_cnt) * COEFF + 1];
                    s0_mac_sw2 <= l0_sw[(out_cnt * IN_DIM + in_cnt) * COEFF + 2];
                    s0_mac_sw3 <= l0_sw[(out_cnt * IN_DIM + in_cnt) * COEFF + 3];
                    s0_mac_sw4 <= l0_sw[(out_cnt * IN_DIM + in_cnt) * COEFF + 4];
                    s0_mac_sw5 <= l0_sw[(out_cnt * IN_DIM + in_cnt) * COEFF + 5];
                    s0_mac_clear <= (in_cnt == 0);
                    s0_mac_valid <= 1;
                    in_cnt <= in_cnt + 1;
                    mac_out_cnt <= 0;
                end else begin
                    if (mac_valid_out)
                        mac_out_cnt <= mac_out_cnt + 1;
                    if (mac_out_cnt == 5) begin
                        buf_b[out_cnt] <= mac_acc[15:0];
                        out_cnt <= out_cnt + 1;
                        in_cnt  <= 0; mac_out_cnt <= 0;
                    end
                end
            end else begin
                silu_res_cnt <= 0; bsp_res_cnt <= 0; feed_cnt <= 0;
                for (k = 0; k < HIDDEN1; k = k + 1) buf_a[k] <= buf_b[k];
                state <= S_L1_FEED;
            end
        end

        // Layer 1
        S_L1_FEED: begin
            if (feed_cnt < HIDDEN1) begin
                silu_x <= buf_a[feed_cnt]; silu_valid_in <= 1;
                bsp_x  <= buf_a[feed_cnt]; bsp_valid_in  <= 1;
                feed_cnt <= feed_cnt + 1;
            end else begin
                state <= S_L1_WAIT;
            end
        end

        S_L1_WAIT: begin
            if (bsp_res_cnt == HIDDEN1) begin
                out_cnt <= 0; in_cnt <= 0; state <= S_L1_MAC;
            end
        end

        S_L1_MAC: begin
            if (out_cnt < HIDDEN2) begin
                if (in_cnt < HIDDEN1) begin
                    s0_mac_sx  <= sx_buf[in_cnt];
                    s0_mac_b0  <= b0_buf[in_cnt]; s0_mac_b1 <= b1_buf[in_cnt];
                    s0_mac_b2  <= b2_buf[in_cnt]; s0_mac_b3 <= b3_buf[in_cnt];
                    s0_mac_b4  <= b4_buf[in_cnt]; s0_mac_b5 <= b5_buf[in_cnt];
                    s0_mac_bw  <= l1_bw[out_cnt * HIDDEN1 + in_cnt];
                    s0_mac_sc  <= l1_sc[out_cnt * HIDDEN1 + in_cnt];
                    s0_mac_sw0 <= l1_sw[(out_cnt * HIDDEN1 + in_cnt) * COEFF + 0];
                    s0_mac_sw1 <= l1_sw[(out_cnt * HIDDEN1 + in_cnt) * COEFF + 1];
                    s0_mac_sw2 <= l1_sw[(out_cnt * HIDDEN1 + in_cnt) * COEFF + 2];
                    s0_mac_sw3 <= l1_sw[(out_cnt * HIDDEN1 + in_cnt) * COEFF + 3];
                    s0_mac_sw4 <= l1_sw[(out_cnt * HIDDEN1 + in_cnt) * COEFF + 4];
                    s0_mac_sw5 <= l1_sw[(out_cnt * HIDDEN1 + in_cnt) * COEFF + 5];
                    s0_mac_clear <= (in_cnt == 0);
                    s0_mac_valid <= 1;
                    in_cnt <= in_cnt + 1;
                    mac_out_cnt <= 0;
                end else begin
                    if (mac_valid_out)
                        mac_out_cnt <= mac_out_cnt + 1;
                    if (mac_out_cnt == 5) begin
                        buf_b[out_cnt] <= mac_acc[15:0];
                        out_cnt <= out_cnt + 1;
                        in_cnt  <= 0; mac_out_cnt <= 0;
                    end
                end
            end else begin
                silu_res_cnt <= 0; bsp_res_cnt <= 0; feed_cnt <= 0;
                for (k = 0; k < HIDDEN2; k = k + 1) buf_a[k] <= buf_b[k];
                state <= S_L2_FEED;
            end
        end

        // Layer 2
        S_L2_FEED: begin
            if (feed_cnt < HIDDEN2) begin
                silu_x <= buf_a[feed_cnt]; silu_valid_in <= 1;
                bsp_x  <= buf_a[feed_cnt]; bsp_valid_in  <= 1;
                feed_cnt <= feed_cnt + 1;
            end else begin
                state <= S_L2_WAIT;
            end
        end

        S_L2_WAIT: begin
            if (bsp_res_cnt == HIDDEN2) begin
                out_cnt <= 0; in_cnt <= 0; state <= S_L2_MAC;
            end
        end

        S_L2_MAC: begin
            if (out_cnt < OUT_DIM) begin
                if (in_cnt < HIDDEN2) begin
                    s0_mac_sx  <= sx_buf[in_cnt];
                    s0_mac_b0  <= b0_buf[in_cnt]; s0_mac_b1 <= b1_buf[in_cnt];
                    s0_mac_b2  <= b2_buf[in_cnt]; s0_mac_b3 <= b3_buf[in_cnt];
                    s0_mac_b4  <= b4_buf[in_cnt]; s0_mac_b5 <= b5_buf[in_cnt];
                    s0_mac_bw  <= l2_bw[out_cnt * HIDDEN2 + in_cnt];
                    s0_mac_sc  <= l2_sc[out_cnt * HIDDEN2 + in_cnt];
                    s0_mac_sw0 <= l2_sw[(out_cnt * HIDDEN2 + in_cnt) * COEFF + 0];
                    s0_mac_sw1 <= l2_sw[(out_cnt * HIDDEN2 + in_cnt) * COEFF + 1];
                    s0_mac_sw2 <= l2_sw[(out_cnt * HIDDEN2 + in_cnt) * COEFF + 2];
                    s0_mac_sw3 <= l2_sw[(out_cnt * HIDDEN2 + in_cnt) * COEFF + 3];
                    s0_mac_sw4 <= l2_sw[(out_cnt * HIDDEN2 + in_cnt) * COEFF + 4];
                    s0_mac_sw5 <= l2_sw[(out_cnt * HIDDEN2 + in_cnt) * COEFF + 5];
                    s0_mac_clear <= (in_cnt == 0);
                    s0_mac_valid <= 1;
                    in_cnt <= in_cnt + 1;
                    mac_out_cnt <= 0;
                end else begin
                    if (mac_valid_out)
                        mac_out_cnt <= mac_out_cnt + 1;
                    if (mac_out_cnt == 5) begin
                        out_0   <= mac_acc[15:0];
                        out_cnt <= out_cnt + 1;
                        state   <= S_DONE;
                    end
                end
            end
        end

        S_DONE: begin
            done  <= 1;
            state <= S_IDLE;
        end

        endcase
    end
end

endmodule
