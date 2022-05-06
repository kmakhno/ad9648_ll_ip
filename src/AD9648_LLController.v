`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2022 07:11:40 PM
// Design Name: 
// Module Name: AD9648_LLController
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


module AD9648_LLController #(
    parameter AdcRes = 14,
    parameter TxRegWidth = 24,
    parameter RxRegWidth = 8,
    parameter RcvBits = 16,
    parameter Cpol = 0,
    parameter Cpha = 0
)
(
    /* from clock generator */
    input adc_clk_gen_i,
    output adc_clk_no,
    output adc_clk_po,
    input adc_sync_clk_i,
    output adc_sync_clk_o,
    input adc_dco_clk_i,
    /* System clock */
    input clk_sys_i,
    input rst_sys_clk_i,

    /* SPI interface */
    input  start_transfer_i,
    input  [TxRegWidth-1:0] tx_data_i,
    output transfer_done_o,
    output [RxRegWidth-1:0] rx_data_o,
    output cs_o,
    output sck_o,
    inout  sdio_io,

    input config_done_i,
    input ac_dc_coupling_i,

    /* Relay interface */
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

    /* Data path interface */
    input [AdcRes-1:0] adc_data_i,
    input rd_en_i,
    output empty_o,
    output [31:0] ch_AB_o,
    output full_o
);

/****************************** ADC's clock section ************************/
OBUFDS #(
    .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
    .SLEW("SLOW")           // Specify the output slew rate
) OBUFDS_inst (
    .O (adc_clk_po),     // Diff_p output (connect directly to top-level port)
    .OB(adc_clk_no),   // Diff_n output (connect directly to top-level port)
    .I (adc_clk_gen_i)      // Buffer input
);

BUFG BUFG_inst0 (
    .O(adc_sync_clk_o), // 1-bit output: Clock output
    .I(adc_sync_clk_i)  // 1-bit input: Clock input
);

wire adc_dco_clk_d;

BUFG BUFG_inst1 (
    .O(adc_dco_clk_d), // 1-bit output: Clock output
    .I(adc_dco_clk_i)  // 1-bit input: Clock input
);

/****************************** Config section ********************************/
wire [$clog2(TxRegWidth)-1:0] shift_strobe_cnt_d;
wire oe_d;
wire mosi_d, miso_d;
wire iddr_clk_en_d;

config_unit #(
    .TxRegWidth        (TxRegWidth),
    .RxRegWidth        (RxRegWidth),
    .RcvBits           (RcvBits),
    .Cpol              (Cpol),
    .Cpha              (Cpha)  
) config_unit_inst (
    .clk_i             (clk_sys_i),
    .rst_clk_i         (rst_sys_clk_i),
    /*from module above */
    .tx_reg_i          (tx_data_i),
    .transfer_start_i  (start_transfer_i),
    .config_done_i     (config_done_i),
    .ac_dc_coupling_i  (ac_dc_coupling_i),
    /* To module above */
    .rx_reg_o          (rx_data_o),
    .transfer_done_o   (transfer_done_o),
    .iddr_clk_en_o     (iddr_clk_en_d),
    .miso_i            (miso_d),
    .cs_o              (cs_o),
    .sck_o             (sck_o),
    .mosi_o            (mosi_d),
    .shift_strobe_cnt_o(shift_strobe_cnt_d),
    /* Relay config signals */
    .com_sc_h_t_o      (com_sc_h_t_o),
    .com_sc_l_t_o      (com_sc_l_t_o),
    .sc1_ac_h_t_o      (sc1_ac_h_t_o),
    .sc1_ac_l_t_o      (sc1_ac_l_t_o),
    .sc2_ac_h_t_o      (sc2_ac_h_t_o),
    .sc2_ac_l_t_o      (sc2_ac_l_t_o),
    .sc1_gain_h_t_o    (sc1_gain_h_t_o),
    .sc1_gain_l_t_o    (sc1_gain_l_t_o),
    .sc2_gain_h_t_o    (sc2_gain_h_t_o),
    .sc2_gain_l_t_o    (sc2_gain_l_t_o)
);

IOBUF IOBUF_inst (
  .O (miso_d),     // Buffer output
  .IO(sdio_io),   // Buffer inout port (connect directly to top-level port)
  .I (mosi_d),     // Buffer input
  .T (oe_d)      // 3-state enable input, high=input, low=output
);

assign oe_d = (shift_strobe_cnt_d < RcvBits) ? 1'b0 : tx_data_i[TxRegWidth-1];

/************************ Data path section *********************************/
data_path #(
    .AdcRes(AdcRes)
) data_path_inst (
    .clk_sys_i(clk_sys_i),
    .clk_demux_i(adc_dco_clk_d),
    .clk_en_i(iddr_clk_en_d),
    .rd_en_i(rd_en_i),
    .empty_o(empty_o),
    .adc_data_i(adc_data_i),
    .ch_AB_o(ch_AB_o),
    /*for test*/
    .full_o(full_o)
);


endmodule
