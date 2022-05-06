`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/31/2022 09:01:11 PM
// Design Name: 
// Module Name: front_detector
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


module front_detector(
    input  clk_i,
    input  async_strobe_i,
    output sync_strobe_o
);

reg [1:0] det_q;

always @(posedge clk_i)
    det_q <= {det_q[0], async_strobe_i};
    
assign sync_strobe_o = (det_q == 2'b01);

endmodule
