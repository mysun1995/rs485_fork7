`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/22 17:47:09
// Design Name: 
// Module Name: Top
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


module Screen_Top(
    input clk_29491200Hz,
    input clk_5MHz,
    input  clk_100m,
    output uart_tx,
    input  uart_rx,
    output con,
    output rs485_run,
    output rs485_stop,
    output rs485_reset,
    input [31:0] i_in,
    input [31:0] v_in,
    output write06_flash,
    output [31:0] write06_rs485,
    input [15:0] state_data,
    //input state_screen_busy

    //新增测试部分
    input [63:0] IP,
    input [63:0] netmask,
    input [63:0] gateway,
    input [15:0] type,
    //电源全状态
    input [31:0]  PLC1_status,    
    input [223:0] PLC2_status,
    input [255:0] PLC3_status,
    input [255:0] PLC4_status,
    input [255:0] PLC5_status,
    input [255:0] PLC6_status,
    input [255:0] PLC7_status,
    input [255:0] PLC8_status,
    //读必选参数
    input [31:0] read100,
    input [31:0] read101,
    input [31:0] read102,

    //读可选
    input [15:0] write00,    
    input [15:0] write01, 
    input [15:0] write02,
    input [15:0] write03, 
    input [15:0] write04, 
    input [15:0] write05, 
    input [15:0] write07, 
    input [15:0] write08, 
    input [15:0] write09, 
    input [15:0] write06,
    
    input [31:0] avg_i_1,
    input [31:0] avg_i_2,  
    input [31:0] avg_i_3,
    input [31:0] avg_i_4,
    input [31:0] avg_i_5,
    input [31:0] avg_i_6

    );
    
    //reg [31:0] state_data_use;
    
   // always @ (posedge clk_100m)
   // begin
   //     if (!state_screen_busy)
   //         state_data_use <= {16'b0,state_data[14],7'b0,state_data[6],state_data[4],1'b0,state_data[7],2'b0,!state_data[15],!state_data[0]};
   //     else
   //         state_data_use <= state_data_use;
   // end
    
  //  wire clk_100m;
    wire [7:0] data_in,data_out;
    wire data_tx_flash,data_rx_flash;
    wire tx_finish;
   // wire clk_1843200Hz;
    
    
        wire [7:0] data_reg_o;
    wire [11:0] check_num_o;
    wire [1:0] bps_en_reg_o;
    wire [1:0] uart_rx_reg_o;
    wire [7:0] rx_dly_o;
    
    wire [3:0] rx_reg_o;
    
    wire [3:0] cnt_rx_o;
    
    wire [15:0] cnt_rx_check_o;
    
    wire [11:0] rx_reg_ob_o;
    
//    clk_wiz_0 instance_name
//   (
//    // Clock out ports
//    .clk_out1(clk_100m),     // output clk_out1
//   // Clock in ports
//    .clk_in1(clk_in));      // input clk_in1


// vio_0 your_instance_name (
//  .clk(clk_100m),                // input wire clk
//  .probe_out0(data_in),  // output wire [7 : 0] probe_out0
//  .probe_out1(data_tx_flash)  // output wire [0 : 0] probe_out1
//);
    

    //新增测试部分
   //wire    [63:0]  IP      ;
   //wire    [63:0]  netmask ;
   //wire    [63:0]  gateway ;
   //wire    [15:0]  type    ;

   ////电源全状态
   //wire [31:0] PLC1_status ;    
   //wire [223:0] PLC2_status;
   //wire [255:0] PLC3_status;
   //wire [255:0] PLC4_status;
   //wire [255:0] PLC5_status;
   //wire [255:0] PLC6_status;
   //wire [255:0] PLC7_status;
   //wire [255:0] PLC8_status;

   ////必选参数
   //wire [31:0] read100;    
   //wire [31:0] read101;    
   //wire [31:0] read102;    


    Uart_for_Screen u_Uart_Top(
    .clk_29491200Hz (clk_29491200Hz),
    .clk            (clk_100m),//100m
    .clk_5MHz       (clk_5MHz),
    .uart_rx        (uart_rx),
    .uart_tx        (uart_tx),
    .con            (con),
    .data_in        (data_in),
    .data_tx_flash  (data_tx_flash),
    .data_out       (data_out),
    .data_rx_flash  (data_rx_flash),
    .tx_finish      (tx_finish),
    .bautate        (4'd5),
    
    
        
    .data_reg_o (data_reg_o),
    .check_num_o (check_num_o),
    .bps_en_reg_o (bps_en_reg_o),
    .uart_rx_reg_o (uart_rx_reg_o),
    .rx_dly_o (rx_dly_o),
    
    .rx_reg_o(rx_reg_o),
    
    .cnt_rx_o(cnt_rx_o),
    
    .cnt_rx_check_o(cnt_rx_check_o),
    
    .rx_reg_ob_o(rx_reg_ob_o)
    );
    
    
    wire [31:0] kp_rs485,ki_rs485;

    wire kp_flash,ki_flash;
    
    Screen_Analysis  u_Rs485_Analysis (
    .clk                     ( clk_100m                   ),
    .rst                     ( 1'b1                   ),
    .data_rx                 ( data_out          ),
    .data_rx_flash           ( data_rx_flash         ),
    .tx_finish               ( tx_finish             ),
    .i_in                    ( i_in            ),
    .v_in                    ( v_in            ),
    .state_data              ( state_data      ),

    .data_tx                 ( data_in          ),
    .data_tx_flash           ( data_tx_flash         ),
    .rs485_run               ( rs485_run             ),
    .rs485_stop              ( rs485_stop            ),
    .rs485_reset             ( rs485_reset           ),
    .write06_rs485           ( write06_rs485   ),
    .kp_rs485                ( kp_rs485        ),
    .ki_rs485                ( ki_rs485        ),
    .write06_flash           ( write06_flash         ),
    .kp_flash                ( kp_flash              ),
    .ki_flash                ( ki_flash              ),
    
    
        
    .data_reg_o (data_reg_o),
    .check_num_o (check_num_o),
    .bps_en_reg_o (bps_en_reg_o),
    .uart_rx_reg_o (uart_rx_reg_o),
    .rx_dly_o (rx_dly_o),
    
    .rx_reg_o(rx_reg_o),
    
    .cnt_rx_o(cnt_rx_o),
    
    .cnt_rx_check_o(cnt_rx_check_o),
    
    .rx_reg_ob_o(rx_reg_ob_o),
    
     .uart_rx        (uart_rx),


     //新增测试部分

    .IP             (IP             ),
    .netmask        (netmask        ),
    .gateway        (gateway        ),
    .type           (type           ),
    .PLC1_status    (PLC1_status    ),
    .PLC2_status    (PLC2_status    ),
    .PLC3_status    (PLC3_status    ),
    .PLC4_status    (PLC4_status    ),
    .PLC5_status    (PLC5_status    ),
    .PLC6_status    (PLC6_status    ),
    .PLC7_status    (PLC7_status    ),
    .PLC8_status    (PLC8_status    ),
    .read100        (read100        ),
    .read101        (read101        ),
    .read102        (read102        ),
    //读可选
    .write00        (write00        ),//float
    .write01        (write01        ),//float
    .write02        (write02        ),//float
    .write03        (write03        ),//float
    .write04        (write04        ),//float
    .write05        (write05        ),//int
    .write06        (write06        ),//int
    .write07        (write07        ),//int
    .write08        (write08        ),//int
    .write09        (write09        ), //int

    .avg_i_1        (avg_i_1   ),// float  
    .avg_i_2        (avg_i_2   ),// float
    .avg_i_3        (avg_i_3   ),// float
    .avg_i_4        (avg_i_4   ),// float
    .avg_i_5        (avg_i_5   ),// float
    .avg_i_6        (avg_i_6   ) // float
   
    );   
    
    
endmodule
