`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/26/2022 05:14:01 PM
// Design Name: 
// Module Name: spi_adapter
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


module spi_adapter #(
    parameter DataBits = 16,
    parameter Cpol = 0,
    parameter Cpha = 0    
)
(
    input  logic clk_i,
    input  logic rst_clk_i,
    input  logic start_transfer_i,
    /* Data to transmit */
    input  logic [DataBits-1:0] tx_data_i,
    input  logic miso_i,
    /* Received data */
    output logic [DataBits-1:0] rx_data_o,
    output logic cs_o,
    output logic sck_o,
    output logic mosi_o,
    output logic [$clog2(DataBits)-1:0] shift_strobe_cnt_o,
    output logic transfer_done_o
);

logic start_gen_d, stop_gen_d;

cs_generator cs_generator_inst (
    .clk_i           (clk_i),
    .rst_clk_i       (rst_clk_i),
    .start_transfer_i(start_transfer_i),
    .cs_o            (cs_o),
    .start_gen_o     (start_gen_d),
    .stop_gen_i      (stop_gen_d)
);

sck_generator #(
    .DataBits       (DataBits),
    .Cpol           (Cpol),
    .Cpha           (Cpha)
) sck_gen_tb (
    .clk_i          (clk_i),
    .rst_clk_i      (rst_clk_i),
    .start_gen_i    (start_gen_d),
    .stop_gen_o     (stop_gen_d),
    .sck_o          (sck_o)
);

logic [1:0] front_det_q;
logic [DataBits:0] tx_buff_q;
logic [DataBits-1:0] rx_buff_q;
logic shift_strobe_d;
logic capture_strobe_d;

always_ff @(posedge clk_i) begin
    if (rst_clk_i) begin
        tx_buff_q <= 0;
    end else if (start_transfer_i)
        tx_buff_q <= {1'b0, tx_data_i};
    else if (shift_strobe_d)
        tx_buff_q <= {tx_buff_q[DataBits-1:0], 1'b0}; //MSB first
end

always_ff @(posedge clk_i) begin
    if (rst_clk_i) begin
        rx_buff_q <= 0;
        rx_data_o <= 0;
    end else if (capture_strobe_d)
        rx_buff_q <= {rx_buff_q[DataBits-2:0], miso_i};
    else if (stop_gen_d) begin
        rx_data_o <= rx_buff_q;
        rx_buff_q <= 0;
    end
end

always_ff @(posedge clk_i) begin
    front_det_q <= {front_det_q[0], sck_o};
end

/* Shift strobe and capture strobe */
always_comb begin
    if ((~Cpol & Cpha) | (Cpol & ~Cpha)) begin
        shift_strobe_d = (front_det_q == 2'b01);
        capture_strobe_d = (front_det_q == 2'b10);
    end else if ((~Cpol & ~Cpha) | (Cpol & Cpha)) begin
        shift_strobe_d = (front_det_q == 2'b10);
        capture_strobe_d = (front_det_q == 2'b01);
    end
end

logic [$clog2(DataBits)-1:0] shift_strobe_cnt_q, shift_strobe_cnt_d;

always_ff @(posedge clk_i) begin
    if (rst_clk_i)
        shift_strobe_cnt_q <= 0;
    else if (!cs_o)
        shift_strobe_cnt_q <= shift_strobe_cnt_d;
    else
        shift_strobe_cnt_q <= 0;
end

logic transfer_done_q;
initial transfer_done_q = 1'b0;

always_ff @(posedge clk_i) begin
    transfer_done_q <= stop_gen_d;
end

assign shift_strobe_cnt_d = shift_strobe_cnt_q + shift_strobe_d;

assign mosi_o = (Cpha) ? tx_buff_q[DataBits] : tx_buff_q[DataBits-1];
assign shift_strobe_cnt_o = shift_strobe_cnt_q;
assign transfer_done_o = transfer_done_q;

endmodule
