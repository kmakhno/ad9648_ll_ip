`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2022 05:02:05 PM
// Design Name: 
// Module Name: data_path
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


module data_path #(
    parameter AdcRes = 14
)
(
    input clk_sys_i,
    input clk_demux_i,
    input clk_en_i,
    input rd_en_i,
    output empty_o,
    input [AdcRes-1:0] adc_data_i,
    output [31:0] ch_AB_o,
    /*for test*/
    output full_o
);

wire valid_d;
wire [AdcRes-1:0] ch_A_d;
wire [AdcRes-1:0] ch_B_d;

reg [31:0] ch_AB_q;
reg        ch_valid_q;

initial ch_AB_q = 0;
initial ch_valid_q = 1'b0;

channel_demux #(
    .AdcRes(AdcRes)
) channel_demux_inst (
    .clk_demux_i(clk_demux_i),
    .clk_en_i(clk_en_i),
    .adc_data_i(adc_data_i),
    .valid_o(valid_d),
    .ch_A_o(ch_A_d),
    .ch_B_o(ch_B_d)
);

/* Multiplex channels */
always @(posedge clk_demux_i) begin
    ch_AB_q <= {{{2{ch_B_d[13]}}, ch_B_d}, {{2{ch_A_d[13]}}, ch_A_d}};
    ch_valid_q <= valid_d;
end

fifo_generator_0 fifo_generator_0_inst0 (
    .wr_clk(clk_demux_i),
    .rd_clk(clk_sys_i),
    .din(ch_AB_q),
    .wr_en(ch_valid_q),
    .rd_en(rd_en_i),
    .dout(ch_AB_o),
    .full(full_o),
    .empty(empty_o)
);

endmodule
