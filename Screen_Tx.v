`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/22 16:58:34
// Design Name: 
// Module Name: Uart_Tx
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


module Screen_Tx(
    input clk,//100M
    input bps_en,
    input [7:0] data_in,
    input data_flash,
    output uart_tx,
    output reg tx_finish,
    output reg con
    );
    
    reg uart_tx_reg = 1'b1;
    assign uart_tx = uart_tx_reg;
    
    
    reg [1:0] data_flash_reg = 2'b0;
    reg [1:0] bps_en_reg = 2'b0;
    
    
    reg [3:0] cnt_tx = 4'd15;
    
   
    
    
    always @ (posedge clk)
    begin
        if (cnt_tx > 4'd10)
        begin
            tx_finish <= 1'b1;
        end
        else
        begin
            tx_finish <= 1'b0;
        end
    end
    
    always @ (posedge clk)
    begin
        if (cnt_tx < 4'd11)
        begin
            con <= 1'b1;
        end
        else
        begin
            con <= 1'b0;
        end
    end
    
    always @ (posedge clk)
    begin
        data_flash_reg[0] <= data_flash;
        data_flash_reg[1] <= data_flash_reg[0];
    end
    
    always @ (posedge clk)
    begin
        bps_en_reg[0] <= bps_en;
        bps_en_reg[1] <= bps_en_reg[0];
    end
    
    
    
    always @ (posedge clk)
    begin
        if (data_flash_reg == 2'b01)//begin to send
        begin
            cnt_tx <= 4'd0;
        end
        else if (bps_en_reg == 2'b01)//base on bps to cal cnt_tx
        begin
            if (cnt_tx == 4'd15)
            begin
                cnt_tx <= cnt_tx;
            end
            else
            begin
                cnt_tx <= cnt_tx + 1'b1;
            end
        end
        else
        begin
            cnt_tx <= cnt_tx;
        end
    end
    
    
    always @ (posedge clk)
    begin
        case (cnt_tx)
            4'd1:  uart_tx_reg <= 1'b0;
            4'd2:  uart_tx_reg <= data_in[0];
            4'd3:  uart_tx_reg <= data_in[1];
            4'd4:  uart_tx_reg <= data_in[2];
            4'd5:  uart_tx_reg <= data_in[3];
            4'd6:  uart_tx_reg <= data_in[4];
            4'd7:  uart_tx_reg <= data_in[5];
            4'd8:  uart_tx_reg <= data_in[6];
            4'd9:  uart_tx_reg <= data_in[7];
            4'd10: uart_tx_reg <= 1'b1;
            default: uart_tx_reg <= uart_tx_reg;
        endcase
    end
    
    
endmodule
