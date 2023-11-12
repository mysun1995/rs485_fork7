`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: cui
// 
// Create Date: 2020/05/24 17:04:30
// Design Name: 
// Module Name: CRC16_modbus 
// Width:8
// Poly:0x8005
// Init:0xFFFF;
// Refin:True;
// Refout:True;
// Xorout:0x0000;
// 
//////////////////////////////////////////////////////////////////////////////////


module CRC16_modbus(
    input sys_clk,
    input rst_n,
    input[7:0] data_l,
    input vld,
    output [15:0] crc_reg

    );
reg[15:0] crc;
wire [15:0] newcrc;
reg[15:0] nextCRC16_D8;
reg [15:0] c;


wire [15:0] crc_n;
parameter xor_a=16'd0;
wire[7:0] data_n;

assign data_n[7]=data_l[0];
assign data_n[6]=data_l[1];
assign data_n[5]=data_l[2];
assign data_n[4]=data_l[3];
assign data_n[3]=data_l[4];
assign data_n[2]=data_l[5];
assign data_n[1]=data_l[6];
assign data_n[0]=data_l[7];

 assign crc_reg = crc_n^xor_a ;
 assign crc_n={newcrc[0],newcrc[1],newcrc[2],newcrc[3],newcrc[4],newcrc[5],newcrc[6],newcrc[7],newcrc[8],newcrc[9],newcrc[10],newcrc[11],newcrc[12],newcrc[13],newcrc[14],newcrc[15]};
//assign c=newcrc;

assign newcrc[0] = data_n[7] ^ data_n[6] ^ data_n[5] ^ data_n[4] ^ data_n[3] ^ data_n[2] ^ data_n[1] ^ data_n[0] ^ c[8] ^ c[9] ^ c[10] ^ c[11] ^ c[12] ^ c[13] ^ c[14] ^ c[15];
  assign   newcrc[1] = data_n[7] ^ data_n[6] ^ data_n[5] ^ data_n[4] ^ data_n[3] ^ data_n[2] ^ data_n[1] ^ c[9] ^ c[10] ^ c[11] ^ c[12] ^ c[13] ^ c[14] ^ c[15];
 assign   newcrc[2] = data_n[1] ^ data_n[0] ^ c[8] ^ c[9];
  assign  newcrc[3] = data_n[2] ^ data_n[1] ^ c[9] ^ c[10];
 assign   newcrc[4] = data_n[3] ^ data_n[2] ^ c[10] ^ c[11];
 assign   newcrc[5] = data_n[4] ^ data_n[3] ^ c[11] ^ c[12];
 assign   newcrc[6] = data_n[5] ^ data_n[4] ^ c[12] ^ c[13];
  assign  newcrc[7] = data_n[6] ^ data_n[5] ^ c[13] ^ c[14];
assign    newcrc[8] = data_n[7] ^ data_n[6] ^ c[0] ^ c[14] ^ c[15];
assign    newcrc[9] = data_n[7] ^ c[1] ^ c[15];
 assign   newcrc[10] = c[2];
 assign   newcrc[11] = c[3];
 assign   newcrc[12] = c[4];
assign    newcrc[13] = c[5];
 assign   newcrc[14] = c[6];
 assign   newcrc[15] = data_n[7] ^ data_n[6] ^ data_n[5] ^ data_n[4] ^ data_n[3] ^ data_n[2] ^ data_n[1] ^ data_n[0] ^ c[7] ^ c[8] ^ c[9] ^ c[10] ^ c[11] ^ c[12] ^ c[13] ^ c[14] ^ c[15];


always @(posedge sys_clk or negedge rst_n) begin
	if(~rst_n) begin
		 c<= 16'hFFFF;
	end
    else if(vld) 
    begin
	   c <= newcrc;
	   
   end
    else 
	   c<= 16'hFFFF;
end



endmodule
