`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/22 17:42:19
// Design Name: 
// Module Name: Uart_Top
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


module Uart_for_Screen(
input clk_29491200Hz,
    input  clk,//100m
    input  clk_5MHz,
    input  uart_rx,
    output uart_tx,
    output con,
    input  [7:0] data_in,
    input  data_tx_flash,
    output [7:0] data_out,
    output data_rx_flash,
    input [3:0] bautate,
    output tx_finish,
    
        
    output [7:0] data_reg_o,
    output [11:0] check_num_o,
    output [1:0] bps_en_reg_o,
    output [1:0] uart_rx_reg_o,
    output [7:0] rx_dly_o,
    
    output [3:0] rx_reg_o,
    
    output [3:0] cnt_rx_o,
    
    output [15:0] cnt_rx_check_o,
    
    output [11:0] rx_reg_ob_o
    );
    
    wire bps_en;
    wire [15:0] bps_num;
    
   Screen_Tx u_Uart_Tx(
    .clk       (clk),//100M
    .bps_en    (bps_en),
    .data_in   (data_in),
    .data_flash(data_tx_flash),
    .uart_tx   (uart_tx),
    .tx_finish (tx_finish),
    .con       (con)
    );
    
//    Uart_Rx u_Uart_Rx(
//    .clk        (clk),//100M
//    .bps_en     (bps_en),
//    .data_out   (data_out),
//    .data_flash (data_rx_flash),
//    .uart_rx    (uart_rx),
//    .bps_num    (bps_num),
    
    
//    .data_reg_o (data_reg_o),
//    .check_num_o (check_num_o),
//    .bps_en_reg_o (bps_en_reg_o),
//    .uart_rx_reg_o (uart_rx_reg_o),
//    .rx_dly_o (rx_dly_o),
    
//    .rx_reg_o(rx_reg_o),
    
//    .cnt_rx_o(cnt_rx_o),
    
//    .cnt_rx_check_o(cnt_rx_check_o),
    
//    .rx_reg_ob_o(rx_reg_ob_o)
//    );


Screen_Rx Uart_Rx
	(
	clk_29491200Hz,
	uart_rx,
	data_out,
	data_rx_flash
	);
    
    Bps_Gen u_Bps_Gen(
    .clk     (clk),
    .bautate (bautate),
    .bps_num (bps_num),
    .bps_en  (bps_en),
    .clk_5MHz(clk_5MHz)
    );



//    ila_test your_instance_name (
//	.clk(clk), // input wire clk
//	.probe0(uart_tx), // input wire [0:0]  probe0  
//	.probe1(data_tx_flash), // input wire [0:0]  probe1 
//	.probe2(data_in), // input wire [7:0]  probe2
//    .probe3(tx_finish)
//);
endmodule
