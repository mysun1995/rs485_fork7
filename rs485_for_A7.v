`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/18 20:29:38
// Design Name: 
// Module Name: rs485_for_A7
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


module rs485_for_A7(
    input       i_clk                       ,
    input       i_uart_rx                   ,
    output      o_con                       ,
    input       rst_n                       ,
    output      o_uart_tx               

    );              

    wire        clk_100MHz                  ;
    wire        clk_29_491_200Hz            ;
    wire        clk_5MHz                    ;
   


   clk_wiz_0 instance_name
   (
   
    .clk_out1(clk_100MHz),     // output clk_out1    
    .clk_in1(i_clk)
  
    );      
    clk_wiz_1 u1_clk_wiz
   (
    .clk_out1(clk_29_491_200Hz),     
    .clk_in1(clk_100MHz)
    );      



    Screen_Top u_Screen_Top(
    .clk_29491200Hz    (clk_29_491_200Hz    ),
    .clk_100m          (clk_100MHz          ),
    .clk_5MHz          (clk_5MHz            ),
    .uart_tx           (o_uart_tx           ),
    .uart_rx           (i_uart_rx           ),
    .con               (o_con               ),
    .rs485_run         (                    ),
    .rs485_stop        (                    ),
    .rs485_reset       (                    ),
    .i_in              (32'h4120_0000       ),
    .v_in              (32'h4013_3333       ),
    .write06_flash     (                    ),
    .write06_rs485     (                    ),
    .state_data        (16'h0001           ),
    //.state_screen_busy (state_screen_busy )

    //以下为新增测试部分
    //IP
    .IP                 (64'h0000_0000_0000_0001),
    .netmask            (64'h0000_0000_0000_0010),
    .gateway            (64'h0000_0000_0000_0011),
    .type               (16'h0001),
    //电源全状态
    .PLC1_status        (32'h1234_5678),
    .PLC2_status        (224'h0000_0001_0002_0003_0004_0008_0006_0007_0008_0009_000a_000b_000c_000d),
    .PLC3_status        (256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000),
    .PLC4_status        (256'h000f_000e_000d_000c_000b_000a_0009_0008_0007_0006_0005_0004_0003_0002_0001_0000),
    .PLC5_status        (256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000),
    .PLC6_status        (256'h0000_0001_0002_0003_0004_0005_0006_0007_0008_0009_000a_000b_000c_000d_000e_000f),
    .PLC7_status        (256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000),
    .PLC8_status        (256'h0000_0001_0002_0003_0004_0005_0006_0007_0008_0009_000a_000b_000c_000d_000e_000f),

    //读必选参数
    .read100            (32'h0000_0123),
    .read101            (32'h0000_0123),
    .read102            (32'h0000_0123),
    .write00            (16'h00_aa    ),//float
    .write01            (16'h00_0b    ),//float
    .write02            (16'h00_0c    ),//float
    .write03            (16'h00_0d    ),//float
    .write04            (16'h00_0e    ),//float
    .write05            (16'h00_0f    ),//int
    .write06            (16'h00_00    ),//int
    .write07            (16'h00_01    ),//int
    .write08            (16'h00_02    ),//int
    .write09            (16'h00_03    ), //int

    .avg_i_1            (32'h4120_0000    ),// float  
    .avg_i_2            (32'h4013_3333    ),// float
    .avg_i_3            (32'h4120_0000    ),// float
    .avg_i_4            (32'h4013_3333    ),// float
    .avg_i_5            (32'h4120_0000    ),// float
    .avg_i_6            (32'h4013_3333    ) // float 
);

   
endmodule
