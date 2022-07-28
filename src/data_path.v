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
    parameter AdcRes = 14,
    parameter AdcNchannels = 1,
    parameter AdcChannelName = "CHA"
)
(
    input clk_sys_i,
    input clk_demux_i,
    input clk_en_i,
    input rd_en_i,
    output adc_valid_o,
    input [AdcRes-1:0] adc_data_i,
    output [31:0] ch_AB_o,
    /*for test*/
    output full_o
);

wire valid_d;
wire [AdcRes-1:0] ch_A_d;
wire [AdcRes-1:0] ch_B_d;

wire [31:0] fifo_dout_d;
wire fifo_empty_d;
wire fifo_rd_en_d;

reg [31:0] ch_AB_q;
reg        ch_valid_q;

genvar g;

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
    .rd_en(fifo_rd_en_d),
    .dout(fifo_dout_d),
    .full(full_o),
    .empty(fifo_empty_d)
);

generate
    if (AdcNchannels == 1) begin
        reg [1:0] sync_chain_q = 2'b00;
        wire aresetn_d;
        wire [15:0] data_d;
        
        if (AdcChannelName == "CHA")
            assign data_d = fifo_dout_d[15:0];
        else if (AdcChannelName == "CHB")
            assign data_d = fifo_dout_d[31:16];
        
        always @(posedge clk_sys_i) begin
            sync_chain_q <= {sync_chain_q[0], clk_en_i};
        end
        
        assign aresetn_d = sync_chain_q[1];
        
        axis_dwidth_converter_0 axis_dwidth_converter_0_inst (
          .aclk(clk_sys_i),
          .aresetn(aresetn_d),
          .s_axis_tvalid(~fifo_empty_d),
          .s_axis_tready(fifo_rd_en_d),
          .s_axis_tdata(data_d),
          .m_axis_tvalid(adc_valid_o),
          .m_axis_tready(rd_en_i),
          .m_axis_tdata(ch_AB_o)
        );
    end else if (AdcNchannels == 2) begin
        assign fifo_rd_en_d = rd_en_i;
        assign ch_AB_o = fifo_dout_d;
        assign adc_valid_o = ~fifo_empty_d;
    end
endgenerate

ila_0 ila_0_inst(
    .clk(clk_demux_i),
    .probe0(ch_A_d),
    .probe1(ch_B_d),
    .probe2(valid_d),
    .probe3(adc_data_i)
);

endmodule
