`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2022 08:49:04 PM
// Design Name: 
// Module Name: config_unit
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


module config_unit #(
    parameter TxRegWidth = 24,
    parameter RxRegWidth = 8,
    parameter RcvBits = 16,
    parameter Cpol = 0,
    parameter Cpha = 0  
)
(
    input clk_i,
    input rst_clk_i,
    /*from module above */
    input [TxRegWidth-1:0] tx_reg_i,
    input transfer_start_i,
    input config_done_i,
    input ac_dc_coupling_i,
    /* To module above */
    output [RxRegWidth-1:0] rx_reg_o,
    output transfer_done_o,
    output iddr_clk_en_o,
    input  miso_i,
    output cs_o,
    output sck_o,
    output mosi_o,
    output [$clog2(TxRegWidth)-1:0] shift_strobe_cnt_o,
    /* Relay config signals */
    output com_sc_h_t_o,
    output com_sc_l_t_o,
    output sc1_ac_h_t_o,
    output sc1_ac_l_t_o,
    output sc2_ac_h_t_o,
    output sc2_ac_l_t_o,
    output sc1_gain_h_t_o,
    output sc1_gain_l_t_o,
    output sc2_gain_h_t_o,
    output sc2_gain_l_t_o,
    input sweep_complete_i,
    input [31:0] sweep_num_i
);

wire [TxRegWidth-1:0] tx_reg_d;
wire [RxRegWidth-1:0] rx_reg_d;
wire transfer_start_d;
wire transfer_done_d;

spi_adapter #(
    .DataBits(TxRegWidth),
    .Cpol(Cpol),
    .Cpha(Cpha)    
) spi_adapter_inst (
    .clk_i(clk_i),
    .rst_clk_i(rst_clk_i),
    .start_transfer_i(transfer_start_d),
    /* Data to transmit */
    .tx_data_i(tx_reg_d),
    .miso_i(miso_i),
    /* Received data */
    .rx_data_o(rx_reg_d),
    .cs_o(cs_o),
    .sck_o(sck_o),
    .mosi_o(mosi_o),
    .shift_strobe_cnt_o(shift_strobe_cnt_o),
    .transfer_done_o(transfer_done_d)
);

control_fsm #(
    .TxRegWidth(TxRegWidth),
    .RxRegWidth(RxRegWidth)
) control_fsm_inst (
    .clk_i(clk_i),
    .rst_clk_i(rst_clk_i),
    /* from module above */
    .tx_reg_i(tx_reg_i),
    .transfer_start_i(transfer_start_i),
    /* to spi controller */
    .tx_reg_o(tx_reg_d),
    .transfer_start_o(transfer_start_d),
    /*
    *from module above
    *indicate that we done ADC config when transition from 0 to 1 occured
    *indicate that proccessign finished when transition from 1 to 0 occured
    */
    .config_done_i(config_done_i),
    .ac_dc_coupling_i(ac_dc_coupling_i),
    /* To module above */
    .rx_reg_o(rx_reg_o),
    .transfer_done_o(transfer_done_o),
    /* From spi controller */
    .rx_reg_i(rx_reg_d),
    .transfer_done_i(transfer_done_d),
    /* Signals that control CDC fifo */
    .iddr_clk_en_o(iddr_clk_en_o),
    .com_sc_h_t_o(com_sc_h_t_o),
    .com_sc_l_t_o(com_sc_l_t_o),
    .sc1_ac_h_t_o(sc1_ac_h_t_o),
    .sc1_ac_l_t_o(sc1_ac_l_t_o),
    .sc2_ac_h_t_o(sc2_ac_h_t_o),
    .sc2_ac_l_t_o(sc2_ac_l_t_o),
    .sc1_gain_h_t_o(sc1_gain_h_t_o),
    .sc1_gain_l_t_o(sc1_gain_l_t_o),
    .sc2_gain_h_t_o(sc2_gain_h_t_o),
    .sc2_gain_l_t_o(sc2_gain_l_t_o),
    .sweep_complete_i(sweep_complete_i),
    .sweep_num_i(sweep_num_i)
);

endmodule
