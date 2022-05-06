`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2022 03:28:33 PM
// Design Name: 
// Module Name: channel_demux
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


module channel_demux #(
    parameter AdcRes = 14
)
(
    input clk_demux_i,
    input clk_en_i,
    input [AdcRes-1:0] adc_data_i,
    output valid_o,
    output [AdcRes-1:0] ch_A_o,
    output [AdcRes-1:0] ch_B_o
);

reg valid_q;
initial valid_q = 1'b0;

always @(posedge clk_demux_i) begin
    valid_q <= clk_en_i;
end

genvar g;
generate
    for (g = 0; g < AdcRes; g = g + 1) begin
        IDDR #(
            .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" 
                                    //    or "SAME_EDGE_PIPELINED" 
            .INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
            .INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
            .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
        ) IDDR_inst (
            .Q1(ch_A_o[g]), // 1-bit output for positive edge of clock
            .Q2(ch_B_o[g]), // 1-bit output for negative edge of clock
            .C(clk_demux_i),   // 1-bit clock input
            .CE(clk_en_i), // 1-bit clock enable input
            .D(adc_data_i[g]),   // 1-bit DDR data input
            .R(1'b0),   // 1-bit reset
            .S(1'b0)    // 1-bit set
        );
    end
endgenerate

assign valid_o = valid_q;

endmodule
