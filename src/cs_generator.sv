`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/26/2022 05:16:49 PM
// Design Name: 
// Module Name: cs_generator
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


module cs_generator
(
    input  logic clk_i,
    input  logic rst_clk_i,
    input  logic start_transfer_i,
    output logic cs_o,
    output logic start_gen_o,
    input  logic stop_gen_i
);


always_ff @( posedge clk_i ) begin
    if (rst_clk_i) begin
        cs_o <= 1'b1;
    end else if (start_transfer_i) begin
        cs_o <= 1'b0;
    end else if (stop_gen_i)
        cs_o <= 1'b1;
end

assign start_gen_o = start_transfer_i;

endmodule
