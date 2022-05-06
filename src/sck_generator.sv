`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/26/2022 01:56:36 PM
// Design Name: 
// Module Name: sck_generator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sck_generator #(
    parameter DataBits = 8,
    parameter Cpol = 0,
    parameter Cpha = 0
)
(
    input logic clk_i,
    input logic rst_clk_i,
    input logic start_gen_i,
    output logic stop_gen_o,
    output logic sck_o
);

typedef enum logic [1:0] {
    IDLE,
    FIRST_HALF_PERIOD,
    SECOND_HALF_PERIOD,
    STOP
} states_q;

logic [1:0] pulse_cnt_q, pulse_cnt_d;
logic [$clog2(DataBits)-1:0] bit_cnt_q, bit_cnt_d;
states_q state_q, next_state_d;

always_ff @(posedge clk_i) begin
    if (rst_clk_i) begin
        state_q <= IDLE;
        pulse_cnt_q <= 0;
        bit_cnt_q <= 0;
    end else begin
        state_q <= next_state_d;
        pulse_cnt_q <= pulse_cnt_d;
        bit_cnt_q <= bit_cnt_d;
    end
end

/* Next state logic */
always_comb begin
    next_state_d = state_q;
    pulse_cnt_d = pulse_cnt_q;
    bit_cnt_d = bit_cnt_q;
    case (state_q)
        IDLE: begin
            if (start_gen_i) begin
                pulse_cnt_d = 0;
                next_state_d = FIRST_HALF_PERIOD;
            end
        end

        FIRST_HALF_PERIOD: begin
            if (pulse_cnt_q == 3) begin
                pulse_cnt_d = 0;
                next_state_d = SECOND_HALF_PERIOD;
            end else
                pulse_cnt_d = pulse_cnt_q + 1'b1;
        end

        SECOND_HALF_PERIOD: begin
            if (pulse_cnt_q == 3) begin
                pulse_cnt_d = 0;
                if (bit_cnt_q == DataBits-1) begin
                    bit_cnt_d = 0;
                    next_state_d = STOP;
                end else begin
                    bit_cnt_d = bit_cnt_q + 1'b1;
                    next_state_d = FIRST_HALF_PERIOD;
                end
            end else
                pulse_cnt_d = pulse_cnt_q + 1'b1;
        end

        STOP: begin
            if (pulse_cnt_q == 3)
                next_state_d = IDLE;
            else
                pulse_cnt_d = pulse_cnt_q + 1'b1;
        end
    endcase
end

/* Output logic */
always_comb begin
    sck_o = Cpol;
    stop_gen_o = 1'b0;
    case (state_q)
        IDLE: begin
            sck_o = Cpol;
        end

        FIRST_HALF_PERIOD: begin
            sck_o = Cpol;
        end

        SECOND_HALF_PERIOD: begin
            sck_o = ~Cpol;
        end

        STOP: begin
            sck_o = Cpol;
            if (state_q == STOP && pulse_cnt_q == 3)
                stop_gen_o = 1'b1;
        end
    endcase
end

endmodule
