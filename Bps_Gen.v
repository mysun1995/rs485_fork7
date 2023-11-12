`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/22 17:35:29
// Design Name: 
// Module Name: Bps_Gen
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


module Bps_Gen(
    input clk,
    input clk_5MHz,
    input [3:0] bautate,
    output reg bps_en,
    input bps_cnt_clr,
    output reg [15:0] bps_num
    );
    
    reg [15:0] cnt = 16'h1;
    
    
    
    always @ (posedge clk)
    begin
        case (bautate)
        4'd1:    bps_num <= 16'd10417;    //9600bps
        4'd2:    bps_num <= 16'd5209;    // 19200bps
        4'd3:    bps_num <= 16'd2605;    // 38400bps 
        4'd4:    bps_num <= 16'd1737;    // 57600bps
        4'd5:    bps_num <= 16'd867;     // 115200bps 
        default: bps_num <= 16'd867;
        endcase
    end
    
    
    always @ (posedge clk)
    begin
        if (bps_cnt_clr)
        begin
            cnt <= 16'd1;
        end
        else if (cnt == bps_num)
        begin
            cnt <= 16'd1;
        end
        else
        begin
            cnt <= cnt + 1'b1;
        end
    end
    
    
    always @ (posedge clk)
    begin
        if (cnt == bps_num)
        begin
            bps_en <= 1'b1;
        end
        else
        begin
            bps_en <= 1'b0;
        end
    end
    
endmodule
