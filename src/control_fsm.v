`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2022 11:18:01 PM
// Design Name: 
// Module Name: control_fsm
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


module control_fsm #(
    parameter TxRegWidth = 24,
    parameter RxRegWidth = 8
)
(
    input clk_i,
    input rst_clk_i,
    /* from module above */
    input [TxRegWidth-1:0] tx_reg_i,
    input transfer_start_i,
    /* to spi controller */
    output [TxRegWidth-1:0] tx_reg_o,
    output transfer_start_o,
    /*
    *from module above
    *indicate that we done ADC config when transition from 0 to 1 occured
    *indicate that proccessign finished when transition from 1 to 0 occured
    */
    input config_done_i,
    input ac_dc_coupling_i,
    /* To module above */
    output [RxRegWidth-1:0] rx_reg_o,
    output transfer_done_o,
    /* From spi controller */
    input [RxRegWidth-1:0] rx_reg_i,
    input transfer_done_i,
    /* Signals that control CDC fifo */
    output iddr_clk_en_o,
    /* Relay config signals */
    output reg com_sc_h_t_o,
    output reg com_sc_l_t_o,
    output reg sc1_ac_h_t_o,
    output reg sc1_ac_l_t_o,
    output reg sc2_ac_h_t_o,
    output reg sc2_ac_l_t_o,
    output reg sc1_gain_h_t_o,
    output reg sc1_gain_l_t_o,
    output reg sc2_gain_h_t_o,
    output reg sc2_gain_l_t_o
);

localparam [1:0] IDLE    = 2'b00,
                 CONFIG  = 2'b01,
                 PROCESS = 2'b10;

wire transfer_start_d;
wire config_done_d;
wire process_finished_d;

reg [1:0] state_q;
reg [TxRegWidth-1:0] tx_reg_q;
reg transfer_start_q;
reg [1:0] front_det;
reg iddr_clk_en_q;

initial iddr_clk_en_q = 1'b0;

always @(posedge clk_i)
    front_det <= {front_det[0], config_done_i};

front_detector front_detector_inst0 (
    .clk_i(clk_i),
    .async_strobe_i(transfer_start_i),
    .sync_strobe_o(transfer_start_d)
);

front_detector front_detector_inst1 (
    .clk_i(clk_i),
    .async_strobe_i(config_done_i),
    .sync_strobe_o(config_done_d)
);

always @(posedge clk_i) begin
    if (rst_clk_i) begin
        state_q <= IDLE;
        tx_reg_q <= 0;
        transfer_start_q <= 1'b0;
    end else begin
        transfer_start_q <= 1'b0;
        iddr_clk_en_q <= 1'b0;
        case (state_q)
            IDLE: begin
                if (config_done_d)
                    state_q <= PROCESS;
                else if (transfer_start_d)
                    state_q <= CONFIG;
                else
                    state_q <= IDLE;
            end

            CONFIG: begin
                transfer_start_q <= 1'b1;
                tx_reg_q <= tx_reg_i;
                state_q <= IDLE;
            end

            PROCESS: begin
                if (process_finished_d) begin
                    state_q <= IDLE;
                    iddr_clk_en_q <= 1'b0;
                end else begin
                    state_q <= PROCESS;
                    iddr_clk_en_q <= 1'b1;
                end
            end
        endcase
    end
end

always @(*) begin
    if (state_q == PROCESS && ac_dc_coupling_i) begin //ac coupling
        com_sc_h_t_o = 1'b1;
        com_sc_l_t_o = 1'b0;
        sc1_ac_h_t_o = 1'b0;
        sc1_ac_l_t_o = 1'b1;
        sc2_ac_h_t_o = 1'b0;
        sc2_ac_l_t_o = 1'b1;
        sc1_gain_h_t_o = 1'b0;
        sc1_gain_l_t_o = 1'b1;
        sc2_gain_h_t_o = 1'b0;
        sc2_gain_l_t_o = 1'b1;
    end else if (state_q == PROCESS && !ac_dc_coupling_i) begin //dc coupling
        com_sc_h_t_o = 1'b0;
        com_sc_l_t_o = 1'b1;
        sc1_ac_h_t_o = 1'b1;
        sc1_ac_l_t_o = 1'b0;
        sc2_ac_h_t_o = 1'b1;
        sc2_ac_l_t_o = 1'b0;
        sc1_gain_h_t_o = 1'b1;
        sc1_gain_l_t_o = 1'b0;
        sc2_gain_h_t_o = 1'b1;
        sc2_gain_l_t_o = 1'b0;
    end else begin
        com_sc_h_t_o = 1'b1;
        com_sc_l_t_o = 1'b1;
        sc1_ac_h_t_o = 1'b1;
        sc1_ac_l_t_o = 1'b1;
        sc2_ac_h_t_o = 1'b1;
        sc2_ac_l_t_o = 1'b1;
        sc1_gain_h_t_o = 1'b1;
        sc1_gain_l_t_o = 1'b1;
        sc2_gain_h_t_o = 1'b1;
        sc2_gain_l_t_o = 1'b1;
    end
end

assign transfer_start_o = transfer_start_q;
assign tx_reg_o = tx_reg_q;
assign rx_reg_o = rx_reg_i;
assign transfer_done_o = transfer_done_i;
assign process_finished_d = (front_det == 2'b10);
assign iddr_clk_en_o = iddr_clk_en_q;

endmodule
