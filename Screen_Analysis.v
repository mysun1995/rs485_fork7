`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/24 21:53:23
// Design Name: 
// Module Name: Rs485_Analysis
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
// 目的：在原有版本上升级数据读取功能
// 修改部分：1.状态机rb_data_03状态跳转条件
//////////////////////////////////////////////////////////////////////////////////


module Screen_Analysis(
    input clk, //clk_100m
    input rst,
    input [7:0] data_rx,
    input data_rx_flash,
    output reg [7:0] data_tx,
    output reg data_tx_flash,
    input tx_finish,
    input [31:0] set_value,
    input [31:0] kp,
    input [31:0] ki,
    input [31:0] i_in,
    input [31:0] v_in,
    input [31:0] state_data,  //Module fault_bus use fifo  {1'b0,fault_11-fault_0,i_over,pwm_fault,poweron_fin}
    output reg rs485_run,
    output reg rs485_stop,
    output reg rs485_reset,
    output reg [31:0] write06_rs485,
    output reg [31:0] kp_rs485,
    output reg [31:0] ki_rs485,
    output reg write06_flash,
    output reg kp_flash,
    output reg ki_flash,
    
        
    input [7:0] data_reg_o,
    input [11:0] check_num_o,
    input [1:0] bps_en_reg_o,
    input [1:0] uart_rx_reg_o,
    input [7:0] rx_dly_o,
    
    input [3:0] rx_reg_o,
    
    input [3:0] cnt_rx_o,
    
    input [15:0] cnt_rx_check_o,
    
    input [11:0] rx_reg_ob_o,
    
    input uart_rx,




    //新增测试部分
    input [63:0] IP,
    input [63:0] netmask,
    input [63:0] gateway,
    input [15:0] type,

    //电源全状态
    input [31:0] PLC1_status ,    
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
    
    
    
    
//    localparam idle = 16'd0;   
//    localparam ins_choose = 16'd1;
//    localparam para_rb = 16'd2;
//    localparam para_wr = 16'd4;
//    localparam crc_check = 16'd8;
//    localparam rb_data_03 = 16'd16;
//    localparam rb_data_10 = 16'd32;
    
    
    localparam idle = 16'd0;   
    localparam ins_choose = 16'd1;
    localparam para_rb = 16'd2;
    localparam para_wr = 16'd3;
    localparam cal_lenth = 16'd4;
    localparam crc_check = 16'd8;
    localparam rb_data_03 = 16'd16;
    localparam rb_data_10 = 16'd32;
    
    
     
    
    
    reg [15:0] crc_reg;
    reg vld;
    wire [15:0] crc_calcu;
    reg [7:0] data_crc;
    
    CRC16_modbus u_CRC16(
    .sys_clk(clk),
    .rst_n(rst),
    .data_l(data_crc),//one clock finish one byte
    .vld(vld),
    .crc_reg(crc_calcu)

    );
    
    reg [15:0] current_state,next_state;
    
    
    
    always @ (posedge clk or negedge rst)
    begin
        if (!rst)
        begin
            current_state <= idle;
        end
        else
        begin
            current_state <= next_state;
        end
    end   
    
    reg [1:0] data_rx_flash_reg = 2'b0;
    reg [1:0] tx_finish_reg = 2'b0;
    reg [1:0] data_flash_reg = 2'b0;
    
    reg [7:0] cnt_rx = 4'd0;
    reg [7:0] cnt_rx_dly;
    reg [7:0] cnt_rx_dly1;
    reg [7:0] cnt_rx_dly2;
    reg [7:0] cnt_tx = 4'd0;
    reg [8:0] cnt_crc = 8'd32;
//    reg [3:0] cnt_tx_dly;
reg [31:0] i_in_reg;
reg [31:0] v_in_reg;
reg [31:0] state_data_reg;

//新增内容2023.08.08
reg [63:0] IP_reg;
reg [63:0] netmask_reg;
reg [63:0] gateway_reg;  
reg [15:0] type_reg;

//电源全状态
reg [31:0]  PLC1_status_reg ;   
reg [223:0] PLC2_status_reg ;
reg [255:0] PLC3_status_reg ;
reg [255:0] PLC4_status_reg ;
reg [255:0] PLC5_status_reg ;
reg [255:0] PLC6_status_reg ;
reg [255:0] PLC7_status_reg ;
reg [255:0] PLC8_status_reg ;

//必选参数
reg [31:0] read100_reg ;
reg [31:0] read101_reg ;
reg [31:0] read102_reg ;

//读可选
reg [15:0] write00_reg;    
reg [15:0] write01_reg; 
reg [15:0] write02_reg;
reg [15:0] write03_reg; 
reg [15:0] write04_reg; 
reg [15:0] write05_reg; 
reg [15:0] write07_reg; 
reg [15:0] write08_reg; 
reg [15:0] write09_reg; 
reg [15:0] write06_reg;

reg [31:0] avg_i_1_reg    ;
reg [31:0] avg_i_2_reg    ;
reg [31:0] avg_i_3_reg    ;
reg [31:0] avg_i_4_reg    ;
reg [31:0] avg_i_5_reg    ;
reg [31:0] avg_i_6_reg    ;
 

reg [15:0] flt_num;
reg [15:0] int_num;

reg [31:0] para_rb_reg = 32'd0;
    
    reg [7:0] data_rx_reg[255:0];//the most lenth in this protocol is 256.
    wire [7:0] lenth_para;
    wire [7:0] temp;
    assign temp = data_rx_reg[6];
//    assign lenth_para = temp[7]*2*2*2*2*2*2*2*2 + temp[6]*2*2*2*2*2*2*2 + temp[5]*2*2*2*2*2*2 + temp[5]*2*2*2*2*2 + temp[4]*2*2*2*2
//    + temp[3]*2*2*2 + temp[2]*2*2 + temp[1]*2 + temp[0];
    assign lenth_para = {temp[7],temp[6],temp[5],temp[4],temp[3],temp[2],temp[1],temp[0]};
    reg error_flag = 0;
    
    //    output [7:0] data_reg_o,
//    output [11:0] check_num_o,
//    output [1:0] bps_en_reg_o,
//    output [1:0] uart_rx_reg_o,
//    output [7:0] rx_dly_o,    
//    output [3:0] rx_reg_o,    
//    output [3:0] cnt_rx_o,    
//    output [15:0] cnt_rx_check_o,    
//    output [11:0] rx_reg_ob_o
    
//    ila_1 ila1_inst (
//	.clk(clk), // input wire clk
//	.probe0(error_flag),
//	.probe1(data_reg_o),
//	.probe2(check_num_o),
//	.probe3(data_rx_flash_reg),
//	.probe4(uart_rx_reg_o),
//	.probe5(rx_dly_o),
//	.probe6(rx_reg_o),
//	.probe7(cnt_rx_o),
//	.probe8(cnt_rx_check_o),
//	.probe9(rx_reg_ob_o),
//	.probe10( data_rx), // input wire [3:0]  probe1
//	.probe11(uart_rx),
//	.probe12(data_rx_flash)
	
	
//);

//    ila_0 your_instance_name (
//	.clk(clk), // input wire clk


//	.probe0(current_state), // input wire [15:0]  probe0  
//	.probe1(cnt_tx), // input wire [3:0]  probe1
//	.probe2( data_rx_reg[0]), // input wire [3:0]  probe1
//	.probe3( data_rx_reg[1]), // input wire [3:0]  probe1
//	.probe4( data_rx_reg[2]), // input wire [3:0]  probe1
//	.probe5( data_rx_reg[3]), // input wire [3:0]  probe1
//	.probe6( data_rx_reg[4]), // input wire [3:0]  probe1
//	.probe7( data_rx_reg[5]), // input wire [3:0]  probe1
//	.probe8( data_rx_reg[6]), // input wire [3:0]  probe1
//	.probe9( data_rx_reg[7]), // input wire [3:0]  probe1
//	.probe10( data_rx_reg[8]), // input wire [3:0]  probe1
//	.probe11( data_rx_reg[9]), // input wire [3:0]  probe1
//	.probe12( data_rx_reg[10]), // input wire [3:0]  probe1
//	.probe13( data_rx_reg[11]), // input wire [3:0]  probe1
//	.probe14( data_rx_reg[12]), // input wire [3:0]  probe1
//	.probe15( data_rx_reg[13]), // input wire [3:0]  probe1
//	.probe16( data_rx_reg[14]), // input wire [3:0]  probe1
//	.probe17( data_rx_reg[15]), // input wire [3:0]  probe1
//	.probe18( data_rx_reg[16]), // input wire [3:0]  probe1
//	.probe19( data_rx_reg[17]), // input wire [3:0]  probe1
//	.probe20( data_rx_reg[18]), // input wire [3:0]  probe1
//	.probe21( data_rx_reg[19]), // input wire [3:0]  probe1
//	.probe22( data_rx_reg[20]), // input wire [3:0]  probe1
//	.probe23( data_rx_reg[21]), // input wire [3:0]  probe1
//	.probe24( data_rx_reg[22]), // input wire [3:0]  probe1
//	.probe25( data_rx_reg[23]), // input wire [3:0]  probe1
//	.probe26( data_rx_reg[24]), // input wire [3:0]  probe1
//	.probe27( data_rx_reg[25]), // input wire [3:0]  probe1
//	.probe28( data_rx_reg[26]), // input wire [3:0]  probe1
//	.probe29( data_rx_reg[27]), // input wire [3:0]  probe1
//	.probe30( data_rx_reg[28]), // input wire [3:0]  probe1	
//	.probe31( data_rx_reg[29]), // input wire [3:0]  probe1
//	.probe32( data_rx_reg[30]), // input wire [3:0]  probe1
//	.probe33( data_rx_reg[31]), // input wire [3:0]  probe1
//	.probe34( data_rx_reg[32]), // input wire [3:0]  probe1	
//	.probe35( data_rx_reg[33]), // input wire [3:0]  probe1	
//	.probe36( data_rx_reg[34]), // input wire [3:0]  probe1	
//	.probe37( data_rx_reg[35]), // input wire [3:0]  probe1	
//	.probe38( data_rx_reg[36]), // input wire [3:0]  probe1	
//	.probe39( data_rx_reg[37]), // input wire [3:0]  probe1	
//	.probe40( data_rx_reg[38]), // input wire [3:0]  probe1	
//	.probe41( data_rx_reg[40]), // input wire [3:0]  probe1	
//	.probe42( data_rx_reg[41]), // input wire [3:0]  probe1	
//	.probe43( data_rx_reg[42]), // input wire [3:0]  probe1	
//	.probe44( data_rx_reg[43]), // input wire [3:0]  probe1	
//	.probe45( data_rx_reg[44]), // input wire [3:0]  probe1	
//	.probe46( data_rx_reg[45]), // input wire [3:0]  probe1	
//	.probe47( data_rx_reg[46]), // input wire [3:0]  probe1	
//	.probe48( data_rx_reg[47]), // input wire [3:0]  probe1	
//	.probe49( data_rx_reg[48]), // input wire [3:0]  probe1	
//	.probe50( data_rx_reg[49]), // input wire [3:0]  probe1	
//	.probe51( data_rx_reg[50]), // input wire [3:0]  probe1	
//	.probe52( data_rx_reg[51]), // input wire [3:0]  probe1	
//	.probe53( data_rx_reg[52]), // input wire [3:0]  probe1	
//	.probe54( cnt_rx), // input wire [3:0]  probe1
//	.probe55( cnt_rx_dly2 ), // input wire [3:0]  probe1
//	.probe56( data_rx), // input wire [3:0]  probe1
//	.probe57( data_crc), // input wire [3:0]  probe1
//	.probe58( vld), // input wire [3:0]  probe1
//	.probe59( crc_calcu), // input wire [3:0]  probe1
//	.probe60(error_flag)
//);


//test 测试收到指令次数

//ila_0 your_instance_name (
//	.clk(clk), // input wire clk
//
//
//	.probe0(r_cnt_test), // input wire [2:0]  probe0  
//	.probe1(data_tx_flash), // input wire [0:0]  probe1 
//	.probe2(data_tx) // input wire [7:0]  probe2
//);
        

    
    
    always @ (posedge clk)
    begin
        if((	data_rx_reg	[	1	]	!=	8'h10	)	||
(	data_rx_reg	[	2	]	!=	8'h00	)	||
(	data_rx_reg	[	3	]	!=	8'h15	)	||
(	data_rx_reg	[	4	]	!=	8'h00	)	||
(	data_rx_reg	[	5	]	!=	8'h16	)	||
(	data_rx_reg	[	6	]	!=	8'h2C	)	||
(	data_rx_reg	[	7	]	!=	8'h01	)	||
(	data_rx_reg	[	8	]	!=	8'hff	)	||
(	data_rx_reg	[	9	]	!=	8'h00	)	||
(	data_rx_reg	[	10	]	!=	8'h01	)	||
(	data_rx_reg	[	11	]	!=	8'h00	)	||
(	data_rx_reg	[	12	]	!=	8'h00	)	||
(	data_rx_reg	[	13	]	!=	8'h03	)	||
(	data_rx_reg	[	14	]	!=	8'he8	)	||
(	data_rx_reg	[	15	]	!=	8'h00	)	||
(	data_rx_reg	[	16	]	!=	8'h00	)	||
(	data_rx_reg	[	17	]	!=	8'h07	)	||
(	data_rx_reg	[	18	]	!=	8'hd0	)	||
(	data_rx_reg	[	19	]	!=	8'h00	)	||
(	data_rx_reg	[	20	]	!=	8'h00	)	||
(	data_rx_reg	[	21	]	!=	8'h0b	)	||
(	data_rx_reg	[	22	]	!=	8'hb8	)	||
(	data_rx_reg	[	23	]	!=	8'h00	)	||
(	data_rx_reg	[	24	]	!=	8'h00	)	||
(	data_rx_reg	[	25	]	!=	8'h0f	)	||
(	data_rx_reg	[	26	]	!=	8'ha0	)	||
(	data_rx_reg	[	27	]	!=	8'h00	)	||
(	data_rx_reg	[	28	]	!=	8'h00	)	||
(	data_rx_reg	[	29	]	!=	8'h13	)	||
(	data_rx_reg	[	30	]	!=	8'h88	)	||
(	data_rx_reg	[	31	]	!=	8'h00	)	||
(	data_rx_reg	[	32	]	!=	8'h00	)	||
(	data_rx_reg	[	33	]	!=	8'h17	)	||
(	data_rx_reg	[	34	]	!=	8'h70	)	||
(	data_rx_reg	[	35	]	!=	8'h00	)	||
(	data_rx_reg	[	36	]	!=	8'h00	)	||
(	data_rx_reg	[	37	]	!=	8'h1b	)	||
(	data_rx_reg	[	38	]	!=	8'h58	)	||
(	data_rx_reg	[	39	]	!=	8'h00	)	||
(	data_rx_reg	[	40	]	!=	8'h00	)	||
(	data_rx_reg	[	41	]	!=	8'h1f	)	||
(	data_rx_reg	[	42	]	!=	8'h40	)	||
(	data_rx_reg	[	43	]	!=	8'h00	)	||
(	data_rx_reg	[	44	]	!=	8'h00	)	||
(	data_rx_reg	[	45	]	!=	8'h23	)	||
(	data_rx_reg	[	46	]	!=	8'h28	)	||
(	data_rx_reg	[	47	]	!=	8'h00	)	||
(	data_rx_reg	[	48	]	!=	8'h00	)	||
(	data_rx_reg	[	49	]	!=	8'h27	)	||
(	data_rx_reg	[	50	]	!=	8'h10	)	||
(	data_rx_reg	[	51	]	!=	8'h34	)	||
(	data_rx_reg	[	52	]	!=	8'he4	))
error_flag <= 1;
else error_flag <= 0;    end
    
    
    
   
    
    always @ (posedge clk)
    begin
        cnt_rx_dly <= cnt_rx;
        cnt_rx_dly1 <= cnt_rx_dly;
        cnt_rx_dly2 <= cnt_rx_dly1;
    end
    
    always @ (posedge clk)
    begin
        data_flash_reg[0] <= cnt_rx[0];
        data_flash_reg[1] <= data_flash_reg[0]; 
    end
    
//    always @ (posedge clk)
//    begin
//        cnt_tx_dly <= cnt_tx;
//    end
    
    always @ (posedge clk)
    begin
        data_rx_flash_reg[0] <= data_rx_flash;
        data_rx_flash_reg[1] <= data_rx_flash_reg[0];
    end
    
    always @ (posedge clk)
    begin
        tx_finish_reg[0] <= tx_finish;
        tx_finish_reg[1] <= tx_finish_reg[0];
    end
    
    
    
    
    always @ (*)
    begin
        case (current_state)
            idle:
            begin
                if (data_rx_flash_reg == 2'b01)//finish one byte data
                begin
                    if (data_rx == 8'd01)
                    begin
                        next_state = ins_choose;
                    end
                    else
                    begin
                        next_state = idle;
                    end
                end
            end
            ins_choose:
            begin
                if (data_rx_flash_reg == 2'b01)//finish one byte data
                begin
                    if (data_rx == 8'h03)
                    begin
                        next_state = para_rb;
                    end
                    else if (data_rx == 8'h10)
                    begin
                        next_state = para_wr;
                    end
                    else
                    begin
                        next_state = idle;
                    end
                end
                else begin
                    next_state = ins_choose;end
            end
            para_wr:
            begin
                if (cnt_rx_dly2 == 4'd6)//finish one byte data
                begin                     
                     next_state = cal_lenth;                   
                end
                else
                begin
                     next_state = para_wr;
                end
                    
            end
            para_rb:begin
                if (cnt_rx_dly2 == 4'd7)//come to check
                begin
                    next_state = crc_check;
                end
                else
                begin
                    next_state = para_rb;
                end
            end
            cal_lenth:begin
                if (cnt_rx_dly2 == data_rx_reg[6]+8)//come to check
                begin
                    next_state = crc_check;
                end
                else
                begin
                    next_state = cal_lenth;
                end
            end
            crc_check:
            begin
                if (data_rx_reg[1] == 8'h03)
                begin
                    if (crc_reg == {data_rx_reg[7],data_rx_reg[6]})
                    begin
                        next_state = rb_data_03;
                    end
                    else
                    begin
                        next_state = idle;
                    end
                end
                else if (data_rx_reg[1] == 8'h10)
                begin
                    if (crc_reg == {data_rx_reg[data_rx_reg[6]+8],data_rx_reg[data_rx_reg[6]+7]})
                    begin
                        next_state = rb_data_10;
                    end
                    else
                    begin
                        next_state = idle;
                    end
                end
                else 
                begin
                    next_state = idle;
                end
            end
            rb_data_03:
            begin
                if (cnt_tx == data_lenth)//depend on which one, the 'cnt_tx' are different in different command    
                begin
                    next_state = idle;
                end
                else
                begin
                    next_state = rb_data_03;
                end
            end
            rb_data_10:
            begin
                if (cnt_tx == 4'd8)//wr command is always 8 bytes
                begin
                    next_state = idle;
                end
                else
                begin
                    next_state = rb_data_10;
                end
            end
            default: next_state = idle;
        endcase
    end
    
reg [7:0] data_lenth;
reg [7:0] addr_h;
reg [7:0] addr_l;

//读状态响应信息总字节长度变化，不同情况下赋予data_lenth变量不同的值
always @(posedge clk or negedge rst ) begin
    if(!rst)
        data_lenth <= 8'h0;
    else if(next_state == rb_data_03)begin
        if(data_rx_reg[2] == 'h00 && data_rx_reg[3] == 'h64) //读状态
            data_lenth <= 8'h1b;
        else if(data_rx_reg[2] == 'h03 && data_rx_reg[3] == 'h00) //读IP
            data_lenth <= 8'h1f;  //31
        else if(data_rx_reg[2] == 'h03 && data_rx_reg[3] == 'h10)//读电源全状态
            data_lenth <= 8'he5;//229
        else if(data_rx_reg[2] == 'h03 && data_rx_reg[3] == 'he0)//读必选参数
            data_lenth <= 8'h10;
        else if(data_rx_reg[2] == 'h03 && data_rx_reg[3] == 'hf2)//读可选参数float
            data_lenth <= 8'h07;
        else if(data_rx_reg[2] == 'h03 && data_rx_reg[3] == 'hf5)//读可选参数int
            data_lenth <= 8'h07;
        else if(data_rx_reg[2] == 'h04 && data_rx_reg[3] == 'h10)
            data_lenth <= 8'h1d;
        
    end       
    else 
        data_lenth <= data_lenth;   
end
//可选存地址
always @(posedge clk or negedge rst) begin
    if(!rst)begin
        addr_h <= 'h0;
        addr_l <= 'h0;
    end
    else if(next_state == rb_data_10)begin
        if(data_rx_reg[2] == 'h03 && data_rx_reg[3] == 'hf0)begin
            addr_h <= data_rx_reg[8];
            addr_l <= data_rx_reg[7];
        end
    end
    else begin
        addr_h <= addr_h;
        addr_l <= addr_l;       
    end
    
end
    
    always @ (posedge clk or negedge rst)
    begin
        if (!rst)
        begin
            cnt_rx <= 4'd0;
        end
        else
        begin
            case (next_state)
                para_rb:
                begin
                    if (data_rx_flash_reg == 2'b01)//1 byte
                    begin
                        cnt_rx <= cnt_rx + 1'b1;
                    end
                    else 
                    begin
                        cnt_rx <= cnt_rx;
                    end
                end
                para_wr:
                begin
                    if (data_rx_flash_reg == 2'b01)// 1 byte
                    begin
                        cnt_rx <= cnt_rx + 1'b1;
                    end
                    else 
                    begin
                        cnt_rx <= cnt_rx;
                    end
                end
                cal_lenth:
                begin
                    if (data_rx_flash_reg == 2'b01)// 1 byte
                    begin
                        cnt_rx <= cnt_rx + 1'b1;
                    end
                    else 
                    begin
                        cnt_rx <= cnt_rx;
                    end
                end
                default:
                begin
                    cnt_rx <= 4'd0;
                end
            endcase
        end
    end
    
    
    always @ (posedge clk or negedge rst)
    begin
        if (!rst)
        begin
            cnt_tx <= 4'd0;
        end
        else
        begin
            case (next_state)
                rb_data_03: 
                begin
                    if (tx_finish_reg == 2'b01)//cnt_tx more than 10 bit,means the whole byte send, no more than 15
                    begin
                        cnt_tx <= cnt_tx + 1'b1;
                    end
                    else
                    begin
                        cnt_tx <= cnt_tx;
                    end
                end
                rb_data_10: 
                begin
                    if (tx_finish_reg == 2'b01)
                    begin
                        cnt_tx <= cnt_tx + 1'b1;
                    end
                    else
                    begin
                        cnt_tx <= cnt_tx;
                    end
                end
                default:cnt_tx <= 4'd0;
            endcase
        end
    end
    
    always @ (posedge clk or negedge rst)
    begin
        if (!rst)
        begin
            data_rx_reg[0] <= 8'd0;
            data_rx_reg[1] <= 8'd0;
            data_rx_reg[2] <= 8'd0;
            data_rx_reg[3] <= 8'd0;
            data_rx_reg[4] <= 8'd0;
            data_rx_reg[5] <= 8'd0;
            data_rx_reg[6] <= 8'd0;
            data_rx_reg[7] <= 8'd0;
            data_rx_reg[8] <= 8'd0;
            data_rx_reg[9] <= 8'd0;
            data_rx_reg[10] <= 8'd0;
            data_rx_reg[11] <= 8'd0;
            data_rx_reg[12] <= 8'd0;
        end
        else
        begin
            case (next_state)
                para_rb:
                begin
                    if ((data_flash_reg == 2'b01)||(data_flash_reg == 2'b10))
                    begin
                    case (cnt_rx)
                        8'd0:data_rx_reg[0] <= 8'd01;
                        8'd1:data_rx_reg[1] <= 8'h03;
                        8'd2:data_rx_reg[2] <= data_rx;
                        8'd3:data_rx_reg[3] <= data_rx;
                        8'd4:data_rx_reg[4] <= data_rx;
                        8'd5:data_rx_reg[5] <= data_rx;
                        8'd6:data_rx_reg[6] <= data_rx;
                        8'd7:data_rx_reg[7] <= data_rx;
                        8'd8:data_rx_reg[8] <= data_rx;
                        8'd9:data_rx_reg[9] <= data_rx;
                        8'd10:data_rx_reg[10] <= data_rx;
                        8'd11:data_rx_reg[11] <= data_rx;
                        8'd12:data_rx_reg[12] <= data_rx;
                        8'd13:data_rx_reg[13] <= data_rx;
                        8'd14:data_rx_reg[14] <= data_rx;
                        8'd15:data_rx_reg[15] <= data_rx;
                        8'd16:data_rx_reg[16] <= data_rx;
                        8'd17:data_rx_reg[17] <= data_rx;
                        8'd18:data_rx_reg[18] <= data_rx;
                        8'd19:data_rx_reg[19] <= data_rx;
                        8'd20:data_rx_reg[20] <= data_rx;
                        8'd21:data_rx_reg[21] <= data_rx;
                        8'd22:data_rx_reg[22] <= data_rx;
                        8'd23:data_rx_reg[23] <= data_rx;
                        8'd24:data_rx_reg[24] <= data_rx;
                        8'd25:data_rx_reg[25] <= data_rx;
                        8'd26:data_rx_reg[26] <= data_rx;
                        8'd27:data_rx_reg[27] <= data_rx;
                        8'd28:data_rx_reg[28] <= data_rx;
                        8'd29:data_rx_reg[29] <= data_rx;
                        8'd30:data_rx_reg[30] <= data_rx;
                        8'd31:data_rx_reg[31] <= data_rx;
                        8'd32:	data_rx_reg	[	32	]	<=	data_rx	;
                        8'd33:	data_rx_reg	[	33	]	<=	data_rx	;
                        8'd34:	data_rx_reg	[	34	]	<=	data_rx	;
                        8'd35:	data_rx_reg	[	35	]	<=	data_rx	;
                        8'd36:	data_rx_reg	[	36	]	<=	data_rx	;
                        8'd37:	data_rx_reg	[	37	]	<=	data_rx	;
                        8'd38:	data_rx_reg	[	38	]	<=	data_rx	;
                        8'd39:	data_rx_reg	[	39	]	<=	data_rx	;
                        8'd40:	data_rx_reg	[	40	]	<=	data_rx	;
                        8'd41:	data_rx_reg	[	41	]	<=	data_rx	;
                        8'd42:	data_rx_reg	[	42	]	<=	data_rx	;
                        8'd43:	data_rx_reg	[	43	]	<=	data_rx	;
                        8'd44:	data_rx_reg	[	44	]	<=	data_rx	;
                        8'd45:	data_rx_reg	[	45	]	<=	data_rx	;
                        8'd46:	data_rx_reg	[	46	]	<=	data_rx	;
                        8'd47:	data_rx_reg	[	47	]	<=	data_rx	;
                        8'd48:	data_rx_reg	[	48	]	<=	data_rx	;
                        8'd49:	data_rx_reg	[	49	]	<=	data_rx	;
                        8'd50:	data_rx_reg	[	50	]	<=	data_rx	;
                        8'd51:	data_rx_reg	[	51	]	<=	data_rx	;
                        8'd52:	data_rx_reg	[	52	]	<=	data_rx	;
                        8'd53:	data_rx_reg	[	53	]	<=	data_rx	;
                        8'd54:	data_rx_reg	[	54	]	<=	data_rx	;
                        8'd55:	data_rx_reg	[	55	]	<=	data_rx	;
                        8'd56:	data_rx_reg	[	56	]	<=	data_rx	;
                        8'd57:	data_rx_reg	[	57	]	<=	data_rx	;
                        8'd58:	data_rx_reg	[	58	]	<=	data_rx	;
                        8'd59:	data_rx_reg	[	59	]	<=	data_rx	;
                        8'd60:	data_rx_reg	[	60	]	<=	data_rx	;
                        8'd61:	data_rx_reg	[	61	]	<=	data_rx	;
                        8'd62:	data_rx_reg	[	62	]	<=	data_rx	;
                        8'd63:	data_rx_reg	[	63	]	<=	data_rx	;
                        8'd64:	data_rx_reg	[	64	]	<=	data_rx	;
                        8'd65:	data_rx_reg	[	65	]	<=	data_rx	;
                        8'd66:	data_rx_reg	[	66	]	<=	data_rx	;
                        8'd67:	data_rx_reg	[	67	]	<=	data_rx	;
                        8'd68:	data_rx_reg	[	68	]	<=	data_rx	;
                        8'd69:	data_rx_reg	[	69	]	<=	data_rx	;
                        8'd70:	data_rx_reg	[	70	]	<=	data_rx	;
                        8'd71:	data_rx_reg	[	71	]	<=	data_rx	;
                        8'd72:	data_rx_reg	[	72	]	<=	data_rx	;
                        8'd73:	data_rx_reg	[	73	]	<=	data_rx	;
                        8'd74:	data_rx_reg	[	74	]	<=	data_rx	;
                        8'd75:	data_rx_reg	[	75	]	<=	data_rx	;
                        8'd76:	data_rx_reg	[	76	]	<=	data_rx	;
                        8'd77:	data_rx_reg	[	77	]	<=	data_rx	;
                        8'd78:	data_rx_reg	[	78	]	<=	data_rx	;
                        8'd79:	data_rx_reg	[	79	]	<=	data_rx	;
                        8'd80:	data_rx_reg	[	80	]	<=	data_rx	;
                        8'd81:	data_rx_reg	[	81	]	<=	data_rx	;
                        8'd82:	data_rx_reg	[	82	]	<=	data_rx	;
                        8'd83:	data_rx_reg	[	83	]	<=	data_rx	;
                        8'd84:	data_rx_reg	[	84	]	<=	data_rx	;
                        8'd85:	data_rx_reg	[	85	]	<=	data_rx	;
                        8'd86:	data_rx_reg	[	86	]	<=	data_rx	;
                        8'd87:	data_rx_reg	[	87	]	<=	data_rx	;
                        8'd88:	data_rx_reg	[	88	]	<=	data_rx	;
                        8'd89:	data_rx_reg	[	89	]	<=	data_rx	;
                        8'd90:	data_rx_reg	[	90	]	<=	data_rx	;
                        8'd91:	data_rx_reg	[	91	]	<=	data_rx	;
                        8'd92:	data_rx_reg	[	92	]	<=	data_rx	;
                        8'd93:	data_rx_reg	[	93	]	<=	data_rx	;
                        8'd94:	data_rx_reg	[	94	]	<=	data_rx	;
                        8'd95:	data_rx_reg	[	95	]	<=	data_rx	;
                        8'd96:	data_rx_reg	[	96	]	<=	data_rx	;
                        8'd97:	data_rx_reg	[	97	]	<=	data_rx	;
                        8'd98:	data_rx_reg	[	98	]	<=	data_rx	;
                        8'd99:	data_rx_reg	[	99	]	<=	data_rx	;
                        8'd100:	data_rx_reg	[	100	]	<=	data_rx	;
                        8'd101:	data_rx_reg	[	101	]	<=	data_rx	;
                        8'd102:	data_rx_reg	[	102	]	<=	data_rx	;
                        8'd103:	data_rx_reg	[	103	]	<=	data_rx	;
                        8'd104:	data_rx_reg	[	104	]	<=	data_rx	;
                        8'd105:	data_rx_reg	[	105	]	<=	data_rx	;
                        8'd106:	data_rx_reg	[	106	]	<=	data_rx	;
                        8'd107:	data_rx_reg	[	107	]	<=	data_rx	;
                        8'd108:	data_rx_reg	[	108	]	<=	data_rx	;
                        8'd109:	data_rx_reg	[	109	]	<=	data_rx	;
                        8'd110:	data_rx_reg	[	110	]	<=	data_rx	;
                        8'd111:	data_rx_reg	[	111	]	<=	data_rx	;
                        8'd112:	data_rx_reg	[	112	]	<=	data_rx	;
                        8'd113:	data_rx_reg	[	113	]	<=	data_rx	;
                        8'd114:	data_rx_reg	[	114	]	<=	data_rx	;
                        8'd115:	data_rx_reg	[	115	]	<=	data_rx	;
                        8'd116:	data_rx_reg	[	116	]	<=	data_rx	;
                        8'd117:	data_rx_reg	[	117	]	<=	data_rx	;
                        8'd118:	data_rx_reg	[	118	]	<=	data_rx	;
                        8'd119:	data_rx_reg	[	119	]	<=	data_rx	;
                        8'd120:	data_rx_reg	[	120	]	<=	data_rx	;
                        8'd121:	data_rx_reg	[	121	]	<=	data_rx	;
                        8'd122:	data_rx_reg	[	122	]	<=	data_rx	;
                        8'd123:	data_rx_reg	[	123	]	<=	data_rx	;
                        8'd124:	data_rx_reg	[	124	]	<=	data_rx	;
                        8'd125:	data_rx_reg	[	125	]	<=	data_rx	;
                        8'd126:	data_rx_reg	[	126	]	<=	data_rx	;
                        8'd127:	data_rx_reg	[	127	]	<=	data_rx	;
                        8'd128:	data_rx_reg	[	128	]	<=	data_rx	;
                        8'd129:	data_rx_reg	[	129	]	<=	data_rx	;
                        8'd130:	data_rx_reg	[	130	]	<=	data_rx	;
                        8'd131:	data_rx_reg	[	131	]	<=	data_rx	;
                        8'd132:	data_rx_reg	[	132	]	<=	data_rx	;
                        8'd133:	data_rx_reg	[	133	]	<=	data_rx	;
                        8'd134:	data_rx_reg	[	134	]	<=	data_rx	;
                        8'd135:	data_rx_reg	[	135	]	<=	data_rx	;
                        8'd136:	data_rx_reg	[	136	]	<=	data_rx	;
                        8'd137:	data_rx_reg	[	137	]	<=	data_rx	;
                        8'd138:	data_rx_reg	[	138	]	<=	data_rx	;
                        8'd139:	data_rx_reg	[	139	]	<=	data_rx	;
                        8'd140:	data_rx_reg	[	140	]	<=	data_rx	;
                        8'd141:	data_rx_reg	[	141	]	<=	data_rx	;
                        8'd142:	data_rx_reg	[	142	]	<=	data_rx	;
                        8'd143:	data_rx_reg	[	143	]	<=	data_rx	;
                        8'd144:	data_rx_reg	[	144	]	<=	data_rx	;
                        8'd145:	data_rx_reg	[	145	]	<=	data_rx	;
                        8'd146:	data_rx_reg	[	146	]	<=	data_rx	;
                        8'd147:	data_rx_reg	[	147	]	<=	data_rx	;
                        8'd148:	data_rx_reg	[	148	]	<=	data_rx	;
                        8'd149:	data_rx_reg	[	149	]	<=	data_rx	;
                        8'd150:	data_rx_reg	[	150	]	<=	data_rx	;
                        8'd151:	data_rx_reg	[	151	]	<=	data_rx	;
                        8'd152:	data_rx_reg	[	152	]	<=	data_rx	;
                        8'd153:	data_rx_reg	[	153	]	<=	data_rx	;
                        8'd154:	data_rx_reg	[	154	]	<=	data_rx	;
                        8'd155:	data_rx_reg	[	155	]	<=	data_rx	;
                        8'd156:	data_rx_reg	[	156	]	<=	data_rx	;
                        8'd157:	data_rx_reg	[	157	]	<=	data_rx	;
                        8'd158:	data_rx_reg	[	158	]	<=	data_rx	;
                        8'd159:	data_rx_reg	[	159	]	<=	data_rx	;
                        8'd160:	data_rx_reg	[	160	]	<=	data_rx	;
                        8'd161:	data_rx_reg	[	161	]	<=	data_rx	;
                        8'd162:	data_rx_reg	[	162	]	<=	data_rx	;
                        8'd163:	data_rx_reg	[	163	]	<=	data_rx	;
                        8'd164:	data_rx_reg	[	164	]	<=	data_rx	;
                        8'd165:	data_rx_reg	[	165	]	<=	data_rx	;
                        8'd166:	data_rx_reg	[	166	]	<=	data_rx	;
                        8'd167:	data_rx_reg	[	167	]	<=	data_rx	;
                        8'd168:	data_rx_reg	[	168	]	<=	data_rx	;
                        8'd169:	data_rx_reg	[	169	]	<=	data_rx	;
                        8'd170:	data_rx_reg	[	170	]	<=	data_rx	;
                        8'd171:	data_rx_reg	[	171	]	<=	data_rx	;
                        8'd172:	data_rx_reg	[	172	]	<=	data_rx	;
                        8'd173:	data_rx_reg	[	173	]	<=	data_rx	;
                        8'd174:	data_rx_reg	[	174	]	<=	data_rx	;
                        8'd175:	data_rx_reg	[	175	]	<=	data_rx	;
                        8'd176:	data_rx_reg	[	176	]	<=	data_rx	;
                        8'd177:	data_rx_reg	[	177	]	<=	data_rx	;
                        8'd178:	data_rx_reg	[	178	]	<=	data_rx	;
                        8'd179:	data_rx_reg	[	179	]	<=	data_rx	;
                        8'd180:	data_rx_reg	[	180	]	<=	data_rx	;
                        8'd181:	data_rx_reg	[	181	]	<=	data_rx	;
                        8'd182:	data_rx_reg	[	182	]	<=	data_rx	;
                        8'd183:	data_rx_reg	[	183	]	<=	data_rx	;
                        8'd184:	data_rx_reg	[	184	]	<=	data_rx	;
                        8'd185:	data_rx_reg	[	185	]	<=	data_rx	;
                        8'd186:	data_rx_reg	[	186	]	<=	data_rx	;
                        8'd187:	data_rx_reg	[	187	]	<=	data_rx	;
                        8'd188:	data_rx_reg	[	188	]	<=	data_rx	;
                        8'd189:	data_rx_reg	[	189	]	<=	data_rx	;
                        8'd190:	data_rx_reg	[	190	]	<=	data_rx	;
                        8'd191:	data_rx_reg	[	191	]	<=	data_rx	;
                        8'd192:	data_rx_reg	[	192	]	<=	data_rx	;
                        8'd193:	data_rx_reg	[	193	]	<=	data_rx	;
                        8'd194:	data_rx_reg	[	194	]	<=	data_rx	;
                        8'd195:	data_rx_reg	[	195	]	<=	data_rx	;
                        8'd196:	data_rx_reg	[	196	]	<=	data_rx	;
                        8'd197:	data_rx_reg	[	197	]	<=	data_rx	;
                        8'd198:	data_rx_reg	[	198	]	<=	data_rx	;
                        8'd199:	data_rx_reg	[	199	]	<=	data_rx	;
                        8'd200:	data_rx_reg	[	200	]	<=	data_rx	;
                        8'd201:	data_rx_reg	[	201	]	<=	data_rx	;
                        8'd202:	data_rx_reg	[	202	]	<=	data_rx	;
                        8'd203:	data_rx_reg	[	203	]	<=	data_rx	;
                        8'd204:	data_rx_reg	[	204	]	<=	data_rx	;
                        8'd205:	data_rx_reg	[	205	]	<=	data_rx	;
                        8'd206:	data_rx_reg	[	206	]	<=	data_rx	;
                        8'd207:	data_rx_reg	[	207	]	<=	data_rx	;
                        8'd208:	data_rx_reg	[	208	]	<=	data_rx	;
                        8'd209:	data_rx_reg	[	209	]	<=	data_rx	;
                        8'd210:	data_rx_reg	[	210	]	<=	data_rx	;
                        8'd211:	data_rx_reg	[	211	]	<=	data_rx	;
                        8'd212:	data_rx_reg	[	212	]	<=	data_rx	;
                        8'd213:	data_rx_reg	[	213	]	<=	data_rx	;
                        8'd214:	data_rx_reg	[	214	]	<=	data_rx	;
                        8'd215:	data_rx_reg	[	215	]	<=	data_rx	;
                        8'd216:	data_rx_reg	[	216	]	<=	data_rx	;
                        8'd217:	data_rx_reg	[	217	]	<=	data_rx	;
                        8'd218:	data_rx_reg	[	218	]	<=	data_rx	;
                        8'd219:	data_rx_reg	[	219	]	<=	data_rx	;
                        8'd220:	data_rx_reg	[	220	]	<=	data_rx	;
                        8'd221:	data_rx_reg	[	221	]	<=	data_rx	;
                        8'd222:	data_rx_reg	[	222	]	<=	data_rx	;
                        8'd223:	data_rx_reg	[	223	]	<=	data_rx	;
                        8'd224:	data_rx_reg	[	224	]	<=	data_rx	;
                        8'd225:	data_rx_reg	[	225	]	<=	data_rx	;
                        8'd226:	data_rx_reg	[	226	]	<=	data_rx	;
                        8'd227:	data_rx_reg	[	227	]	<=	data_rx	;
                        8'd228:	data_rx_reg	[	228	]	<=	data_rx	;
                        8'd229:	data_rx_reg	[	229	]	<=	data_rx	;
                        8'd230:	data_rx_reg	[	230	]	<=	data_rx	;
                        8'd231:	data_rx_reg	[	231	]	<=	data_rx	;
                        8'd232:	data_rx_reg	[	232	]	<=	data_rx	;
                        8'd233:	data_rx_reg	[	233	]	<=	data_rx	;
                        8'd234:	data_rx_reg	[	234	]	<=	data_rx	;
                        8'd235:	data_rx_reg	[	235	]	<=	data_rx	;
                        8'd236:	data_rx_reg	[	236	]	<=	data_rx	;
                        8'd237:	data_rx_reg	[	237	]	<=	data_rx	;
                        8'd238:	data_rx_reg	[	238	]	<=	data_rx	;
                        8'd239:	data_rx_reg	[	239	]	<=	data_rx	;
                        8'd240:	data_rx_reg	[	240	]	<=	data_rx	;
                        8'd241:	data_rx_reg	[	241	]	<=	data_rx	;
                        8'd242:	data_rx_reg	[	242	]	<=	data_rx	;
                        8'd243:	data_rx_reg	[	243	]	<=	data_rx	;
                        8'd244:	data_rx_reg	[	244	]	<=	data_rx	;
                        8'd245:	data_rx_reg	[	245	]	<=	data_rx	;
                        8'd246:	data_rx_reg	[	246	]	<=	data_rx	;
                        8'd247:	data_rx_reg	[	247	]	<=	data_rx	;
                        8'd248:	data_rx_reg	[	248	]	<=	data_rx	;
                        8'd249:	data_rx_reg	[	249	]	<=	data_rx	;
                        8'd250:	data_rx_reg	[	250	]	<=	data_rx	;
                        8'd251:	data_rx_reg	[	251	]	<=	data_rx	;
                        8'd252:	data_rx_reg	[	252	]	<=	data_rx	;
                        8'd253:	data_rx_reg	[	253	]	<=	data_rx	;
                        8'd254:	data_rx_reg	[	254	]	<=	data_rx	;
                        8'd255:	data_rx_reg	[	255	]	<=	data_rx	;

                          
                    endcase
                    end
                    else
                    begin
                    end
                end
                para_wr,cal_lenth:
                begin
                    if ((data_flash_reg == 2'b01)||(data_flash_reg == 2'b10))
                    begin
                    case (cnt_rx)
                        4'd0:data_rx_reg[0] <= 8'd01;
                        4'd1:data_rx_reg[1] <= 8'h10;
                        4'd2: data_rx_reg[2]  <= data_rx;
                        4'd3: data_rx_reg[3]  <= data_rx;
                        4'd4: data_rx_reg[4]  <= data_rx;
                        4'd5: data_rx_reg[5]  <= data_rx;
                        4'd6: data_rx_reg[6]  <= data_rx;
                        4'd7: data_rx_reg[7]  <= data_rx;
                        4'd8: data_rx_reg[8]  <= data_rx;
                        4'd9: data_rx_reg[9]  <= data_rx;
                        4'd10: data_rx_reg[10] <= data_rx;
                        4'd11:data_rx_reg[11] <= data_rx;                       
                        8'd12:data_rx_reg[12] <= data_rx;
                        8'd13:data_rx_reg[13] <= data_rx;
                        8'd14:data_rx_reg[14] <= data_rx;
                        8'd15:data_rx_reg[15] <= data_rx;
                        8'd16:data_rx_reg[16] <= data_rx;
                        8'd17:data_rx_reg[17] <= data_rx;
                        8'd18:data_rx_reg[18] <= data_rx;
                        8'd19:data_rx_reg[19] <= data_rx;
                        8'd20:data_rx_reg[20] <= data_rx;
                        8'd21:data_rx_reg[21] <= data_rx;
                        8'd22:data_rx_reg[22] <= data_rx;
                        8'd23:data_rx_reg[23] <= data_rx;
                        8'd24:data_rx_reg[24] <= data_rx;
                        8'd25:data_rx_reg[25] <= data_rx;
                        8'd26:data_rx_reg[26] <= data_rx;
                        8'd27:data_rx_reg[27] <= data_rx;
                        8'd28:data_rx_reg[28] <= data_rx;
                        8'd29:data_rx_reg[29] <= data_rx;
                        8'd30:data_rx_reg[30] <= data_rx;
                        8'd31:data_rx_reg[31] <= data_rx;
                        8'd32:	data_rx_reg	[32]<=data_rx;
                        8'd33:	data_rx_reg	[33]<=data_rx;
                        8'd34:	data_rx_reg	[34]<=data_rx;
                        8'd35:	data_rx_reg	[35]<=data_rx;
                        8'd36:	data_rx_reg	[36]<=data_rx;
                        8'd37:	data_rx_reg	[37]<=data_rx;
                        8'd38:	data_rx_reg	[38]<=data_rx;
                        8'd39:	data_rx_reg	[39]<=data_rx;
                        8'd40:	data_rx_reg	[40]<=data_rx;
                        8'd41:	data_rx_reg	[41]<=data_rx;
                        8'd42:	data_rx_reg	[42]<=data_rx;
                        8'd43:	data_rx_reg	[43]<=data_rx;
                        8'd44:	data_rx_reg	[44]<=data_rx;
                        8'd45:	data_rx_reg	[45]<=data_rx;
                        8'd46:	data_rx_reg	[46]<=data_rx;
                        8'd47:	data_rx_reg	[47]<=data_rx;
                        8'd48:	data_rx_reg	[48]<=data_rx;
                        8'd49:	data_rx_reg	[49]<=data_rx;
                        8'd50:	data_rx_reg	[50]<=data_rx;
                        8'd51:	data_rx_reg	[51]<=data_rx;
                        8'd52:	data_rx_reg	[52]<=data_rx;
                        8'd53:	data_rx_reg	[53]<=data_rx;
                        8'd54:	data_rx_reg	[54]<=data_rx;
                        8'd55:	data_rx_reg	[55]<=data_rx;
                        8'd56:	data_rx_reg	[56]<=data_rx;
                        8'd57:	data_rx_reg	[57]<=data_rx;
                        8'd58:	data_rx_reg	[58]<=data_rx;
                        8'd59:	data_rx_reg	[59]<=data_rx;
                        8'd60:	data_rx_reg	[60]<=data_rx;
                        8'd61:	data_rx_reg	[61]<=data_rx;
                        8'd62:	data_rx_reg	[62]<=data_rx;
                        8'd63:	data_rx_reg	[63]<=data_rx;
                        8'd64:	data_rx_reg	[64]<=data_rx;
                        8'd65:	data_rx_reg	[65]<=data_rx;
                        8'd66:	data_rx_reg	[66]<=data_rx;
                        8'd67:	data_rx_reg	[67]<=data_rx;
                        8'd68:	data_rx_reg	[68]<=data_rx;
                        8'd69:	data_rx_reg	[69]<=data_rx;
                        8'd70:	data_rx_reg	[70]<=data_rx;
                        8'd71:	data_rx_reg	[71]<=data_rx;
                        8'd72:	data_rx_reg	[72]<=data_rx;
                        8'd73:	data_rx_reg	[73]<=data_rx;
                        8'd74:	data_rx_reg	[74]<=data_rx;
                        8'd75:	data_rx_reg	[75]<=data_rx;
                        8'd76:	data_rx_reg	[76]<=data_rx;
                        8'd77:	data_rx_reg	[77]<=data_rx;
                        8'd78:	data_rx_reg	[78]<=data_rx;
                        8'd79:	data_rx_reg	[79]<=data_rx;
                        8'd80:	data_rx_reg	[80]<=data_rx;
                        8'd81:	data_rx_reg	[81]<=data_rx;
                        8'd82:	data_rx_reg	[82]<=data_rx;
                        8'd83:	data_rx_reg	[83]<=data_rx;
                        8'd84:	data_rx_reg	[84]<=data_rx;
                        8'd85:	data_rx_reg	[85]<=data_rx;
                        8'd86:	data_rx_reg	[86]<=data_rx;
                        8'd87:	data_rx_reg	[87]<=data_rx;
                        8'd88:	data_rx_reg	[88]<=data_rx;
                        8'd89:	data_rx_reg	[89]<=data_rx;
                        8'd90:	data_rx_reg	[90]<=data_rx;
                        8'd91:	data_rx_reg	[91]<=data_rx;
                        8'd92:	data_rx_reg	[92]<=data_rx;
                        8'd93:	data_rx_reg	[93]<=data_rx;
                        8'd94:	data_rx_reg	[94]<=data_rx;
                        8'd95:	data_rx_reg	[95]<=data_rx;
                        8'd96:	data_rx_reg	[96]<=data_rx;
                        8'd97:	data_rx_reg	[97]<=data_rx;
                        8'd98:	data_rx_reg	[98]<=data_rx;
                        8'd99:	data_rx_reg	[99]<=data_rx;
                        8'd100:	data_rx_reg	[100]<=	data_rx	;
                        8'd101:	data_rx_reg	[101]<=	data_rx	;
                        8'd102:	data_rx_reg	[102]<=	data_rx	;
                        8'd103:	data_rx_reg	[103]<=	data_rx	;
                        8'd104:	data_rx_reg	[104]<=	data_rx	;
                        8'd105:	data_rx_reg	[105]<=	data_rx	;
                        8'd106:	data_rx_reg	[106]<=	data_rx	;
                        8'd107:	data_rx_reg	[107]<=	data_rx	;
                        8'd108:	data_rx_reg	[108]<=	data_rx	;
                        8'd109:	data_rx_reg	[109]<=	data_rx	;
                        8'd110:	data_rx_reg	[110]<=	data_rx	;
                        8'd111:	data_rx_reg	[111]<=	data_rx	;
                        8'd112:	data_rx_reg	[112]<=	data_rx	;
                        8'd113:	data_rx_reg	[113]<=	data_rx	;
                        8'd114:	data_rx_reg	[114]<=	data_rx	;
                        8'd115:	data_rx_reg	[115]<=	data_rx	;
                        8'd116:	data_rx_reg	[116]<=	data_rx	;
                        8'd117:	data_rx_reg	[117]<=	data_rx	;
                        8'd118:	data_rx_reg	[118]<=	data_rx	;
                        8'd119:	data_rx_reg	[119]<=	data_rx	;
                        8'd120:	data_rx_reg	[120]<=	data_rx	;
                        8'd121:	data_rx_reg	[121]<=	data_rx	;
                        8'd122:	data_rx_reg	[122]<=	data_rx	;
                        8'd123:	data_rx_reg	[123]<=	data_rx	;   
                        8'd124:	data_rx_reg	[124]<=	data_rx	;
                        8'd125:	data_rx_reg	[125]<=	data_rx	;
                        8'd126:	data_rx_reg	[126]<=	data_rx	;
                        8'd127:	data_rx_reg	[127]<=	data_rx	;
                        8'd128:	data_rx_reg	[128]<=	data_rx	;
                        8'd129:	data_rx_reg	[129]<=	data_rx	;
                        8'd130:	data_rx_reg	[130]<=	data_rx	;
                        8'd131:	data_rx_reg	[131]<=	data_rx	;
                        8'd132:	data_rx_reg	[132]<=	data_rx	;
                        8'd133:	data_rx_reg	[133]<=	data_rx	;
                        8'd134:	data_rx_reg	[134]<=	data_rx	;
                        8'd135:	data_rx_reg	[135]<=	data_rx	;
                        8'd136:	data_rx_reg	[136]<=	data_rx	;
                        8'd137:	data_rx_reg	[137]<=	data_rx	;
                        8'd138:	data_rx_reg	[138]<=	data_rx	;
                        8'd139:	data_rx_reg	[139]<=	data_rx	;
                        8'd140:	data_rx_reg	[140]<=	data_rx	;
                        8'd141:	data_rx_reg	[141]<=	data_rx	;
                        8'd142:	data_rx_reg	[142]<=	data_rx	;
                        8'd143:	data_rx_reg	[143]<=	data_rx	;
                        8'd144:	data_rx_reg	[144]<=	data_rx	;
                        8'd145:	data_rx_reg	[145]<=	data_rx	;
                        8'd146:	data_rx_reg	[146]<=	data_rx	;
                        8'd147:	data_rx_reg	[147]<=	data_rx	;
                        8'd148:	data_rx_reg	[148]<=	data_rx	;
                        8'd149:	data_rx_reg	[149]<=	data_rx	;
                        8'd150:	data_rx_reg	[150]<=	data_rx	;
                        8'd151:	data_rx_reg	[151]<=	data_rx	;
                        8'd152:	data_rx_reg	[152]<=	data_rx	;
                        8'd153:	data_rx_reg	[153]<=	data_rx	;
                        8'd154:	data_rx_reg	[154]<=	data_rx	;
                        8'd155:	data_rx_reg	[155]<=	data_rx	;
                        8'd156:	data_rx_reg	[156]<=	data_rx	;
                        8'd157:	data_rx_reg	[157]<=	data_rx	;
                        8'd158:	data_rx_reg	[158]<=	data_rx	;
                        8'd159:	data_rx_reg	[159]<=	data_rx	;
                        8'd160:	data_rx_reg	[160]<=	data_rx	;
                        8'd161:	data_rx_reg	[161]<=	data_rx	;
                        8'd162:	data_rx_reg	[162]<=	data_rx	;
                        8'd163:	data_rx_reg	[163]<=	data_rx	;
                        8'd164:	data_rx_reg	[164]<=	data_rx	;
                        8'd165:	data_rx_reg	[165]<=	data_rx	;
                        8'd166:	data_rx_reg	[166]<=	data_rx	;
                        8'd167:	data_rx_reg	[167]<=	data_rx	;
                        8'd168:	data_rx_reg	[168]<=	data_rx	;
                        8'd169:	data_rx_reg	[169]<=	data_rx	;
                        8'd170:	data_rx_reg	[170]<=	data_rx	;
                        8'd171:	data_rx_reg	[171]<=	data_rx	;
                        8'd172:	data_rx_reg	[172]<=	data_rx	;
                        8'd173:	data_rx_reg	[173]<=	data_rx	;
                        8'd174:	data_rx_reg	[174]<=	data_rx	;
                        8'd175:	data_rx_reg	[175]<=	data_rx	;
                        8'd176:	data_rx_reg	[176]<=	data_rx	;
                        8'd177:	data_rx_reg	[177]<=	data_rx	;
                        8'd178:	data_rx_reg	[178]<=	data_rx	;
                        8'd179:	data_rx_reg	[179]<=	data_rx	;
                        8'd180:	data_rx_reg	[180]<=	data_rx	;
                        8'd181:	data_rx_reg	[181]<=	data_rx	;
                        8'd182:	data_rx_reg	[182]<=	data_rx	;
                        8'd183:	data_rx_reg	[183]<=	data_rx	;
                        8'd184:	data_rx_reg	[184]<=	data_rx	;
                        8'd185:	data_rx_reg	[185]<=	data_rx	;
                        8'd186:	data_rx_reg	[186]<=	data_rx	;
                        8'd187:	data_rx_reg	[187]<=	data_rx	;
                        8'd188:	data_rx_reg	[188]<=	data_rx	;
                        8'd189:	data_rx_reg	[189]<=	data_rx	;
                        8'd190:	data_rx_reg	[190]<=	data_rx	;
                        8'd191:	data_rx_reg	[191]<=	data_rx	;
                        8'd192:	data_rx_reg	[192]<=	data_rx	;
                        8'd193:	data_rx_reg	[193]<=	data_rx	;
                        8'd194:	data_rx_reg	[194]<=	data_rx	;
                        8'd195:	data_rx_reg	[195]<=	data_rx	;
                        8'd196:	data_rx_reg	[196]<=	data_rx	;
                        8'd197:	data_rx_reg	[197]<=	data_rx	;
                        8'd198:	data_rx_reg	[198]<=	data_rx	;
                        8'd199:	data_rx_reg	[199]<=	data_rx	;
                        8'd200:	data_rx_reg	[200]<=	data_rx	;
                        8'd201:	data_rx_reg	[201]<=	data_rx	;
                        8'd202:	data_rx_reg	[202]<=	data_rx	;
                        8'd203:	data_rx_reg	[203]<=	data_rx	;
                        8'd204:	data_rx_reg	[204]<=	data_rx	;
                        8'd205:	data_rx_reg	[205]<=	data_rx	;
                        8'd206:	data_rx_reg	[206]<=	data_rx	;
                        8'd207:	data_rx_reg	[207]<=	data_rx	;
                        8'd208:	data_rx_reg	[208]<=	data_rx	;
                        8'd209:	data_rx_reg	[209]<=	data_rx	;
                        8'd210:	data_rx_reg	[210]<=	data_rx	;
                        8'd211:	data_rx_reg	[211]<=	data_rx	;
                        8'd212:	data_rx_reg	[212]<=	data_rx	;
                        8'd213:	data_rx_reg	[213]<=	data_rx	;
                        8'd214:	data_rx_reg	[214]<=	data_rx	;
                        8'd215:	data_rx_reg	[215]<=	data_rx	;
                        8'd216:	data_rx_reg	[216]<=	data_rx	;
                        8'd217:	data_rx_reg	[217]<=	data_rx	;
                        8'd218:	data_rx_reg	[218]<=	data_rx	;
                        8'd219:	data_rx_reg	[219]<=	data_rx	;
                        8'd220:	data_rx_reg	[220]<=	data_rx	;
                        8'd221:	data_rx_reg	[221]<=	data_rx	;
                        8'd222:	data_rx_reg	[222]<=	data_rx	;
                        8'd223:	data_rx_reg	[223]<=	data_rx	;
                        8'd224:	data_rx_reg	[224]<=	data_rx	;
                        8'd225:	data_rx_reg	[225]<=	data_rx	;
                        8'd226:	data_rx_reg	[226]<=	data_rx	;
                        8'd227:	data_rx_reg	[227]<=	data_rx	;
                        8'd228:	data_rx_reg	[228]<=	data_rx	;
                        8'd229:	data_rx_reg	[229]<=	data_rx	;
                        8'd230:	data_rx_reg	[230]<=	data_rx	;
                        8'd231:	data_rx_reg	[231]<=	data_rx	;
                        8'd232:	data_rx_reg	[232]<=	data_rx	;
                        8'd233:	data_rx_reg	[233]<=	data_rx	;
                        8'd234:	data_rx_reg	[234]<=	data_rx	;
                        8'd235:	data_rx_reg	[235]<=	data_rx	;
                        8'd236:	data_rx_reg	[236]<=	data_rx	;
                        8'd237:	data_rx_reg	[237]<=	data_rx	;
                        8'd238:	data_rx_reg	[238]<=	data_rx	;
                        8'd239:	data_rx_reg	[239]<=	data_rx	;
                        8'd240:	data_rx_reg	[240]<=	data_rx	;
                        8'd241:	data_rx_reg	[241]<=	data_rx	;
                        8'd242:	data_rx_reg	[242]<=	data_rx	;
                        8'd243:	data_rx_reg	[243]<=	data_rx	;
                        8'd244:	data_rx_reg	[244]<=	data_rx	;
                        8'd245:	data_rx_reg	[245]<=	data_rx	;
                        8'd246:	data_rx_reg	[246]<=	data_rx	;
                        8'd247:	data_rx_reg	[247]<=	data_rx	;
                        8'd248:	data_rx_reg	[248]<=	data_rx	;
                        8'd249:	data_rx_reg	[249]<=	data_rx	;
                        8'd250:	data_rx_reg	[250]<=	data_rx	;
                        8'd251:	data_rx_reg	[251]<=	data_rx	;
                        8'd252:	data_rx_reg	[252]<=	data_rx	;
                        8'd253:	data_rx_reg	[253]<=	data_rx	;
                        8'd254:	data_rx_reg	[254]<=	data_rx	;
                        8'd255:	data_rx_reg	[255]<=	data_rx	;

                          
                        default: ;
                    endcase
                    end
                    else
                    begin
                    end
                end
                default:;
            endcase
        end
    end
    
    always @ (posedge clk or negedge rst)
    begin
        if (!rst)
        begin
            data_tx <= 8'd0;
        end
        else
        begin
            case (next_state)
                rb_data_03://rd
                begin
                if(data_rx_reg[2] == 'h00 && data_rx_reg[3] == 'h64)begin
                    case (cnt_tx)
                        4'd0:data_tx <= 8'h01;
                        4'd1:data_tx <= 8'h03;
                        4'd2:data_tx <= 8'h16;
                        4'd3:data_tx <= i_in_reg[7:0];
                        4'd4:data_tx <= i_in_reg[15:8];
                        4'd5:data_tx <= i_in_reg[23:16];
                        4'd6:data_tx <= i_in_reg[31:24];
                        4'd7:data_tx <= v_in_reg[7:0];
                        4'd8:data_tx <= v_in_reg[15:8];
                        4'd9:data_tx <= v_in_reg[23:16];
                        4'd10:data_tx <= v_in_reg[31:24];
                        4'd11:data_tx <= state_data_reg[7:0];
                        4'd12:data_tx <= state_data_reg[15:8];
                        4'd13:data_tx <= state_data_reg[23:16];
                        4'd14:data_tx <= state_data_reg[31:24];
                        8'd15:data_tx <= 8'h0;
                        8'd16:data_tx <= 8'h0;
                        8'd17:data_tx <= 8'h0;
                        8'd18:data_tx <= 8'h0;
                        8'd19:data_tx <= 8'h0;
                        8'd20:data_tx <= 8'h0;
                        8'd21:data_tx <= 8'h0;
                        8'd22:data_tx <= 8'h0;
                        8'd23:data_tx <= 8'h0;
                        8'd24:data_tx <= 8'h0;
                        8'd25:data_tx <= crc_reg[7:0];
                        8'd26:data_tx <= crc_reg[15:8];
                        default: data_tx <= data_tx;
                    endcase
                end
                else if(data_rx_reg[2] == 'h03 && data_rx_reg[3] == 'h00)begin
                    case (cnt_tx)
                        4'd0:data_tx  <= 8'h01;
                        4'd1:data_tx  <= 8'h03;
                        4'd2:data_tx  <= 8'h1a;
                        4'd3:data_tx  <= IP_reg[7:0];
                        4'd4:data_tx  <= IP_reg[15:8];
                        4'd5:data_tx  <= IP_reg[23:16];
                        4'd6:data_tx  <= IP_reg[31:24];
                        4'd7:data_tx  <= IP_reg[39:32];
                        4'd8:data_tx  <= IP_reg[47:40];
                        4'd9:data_tx  <= IP_reg[55:48];
                        4'd10:data_tx <= IP_reg[63:56];
                        4'd11:data_tx <= netmask_reg[7:0];
                        4'd12:data_tx <= netmask_reg[15:8];
                        4'd13:data_tx <= netmask_reg[23:16];
                        4'd14:data_tx <= netmask_reg[31:24];
                        8'd15:data_tx <= netmask_reg[39:32];
                        8'd16:data_tx <= netmask_reg[47:40];
                        8'd17:data_tx <= netmask_reg[55:48];
                        8'd18:data_tx <= netmask_reg[63:56];
                        8'd19:data_tx <= gateway_reg[7:0];
                        8'd20:data_tx <= gateway_reg[15:8];
                        8'd21:data_tx <= gateway_reg[23:16];
                        8'd22:data_tx <= gateway_reg[31:24];
                        8'd23:data_tx <= gateway_reg[39:32];
                        8'd24:data_tx <= gateway_reg[47:40];
                        8'd25:data_tx <= gateway_reg[55:48];
                        8'd26:data_tx <= gateway_reg[63:56];
                        8'd27:data_tx <= type_reg[7:0];
                        8'd28:data_tx <= type_reg[15:8];
                        8'd29:data_tx <= crc_reg[7:0];
                        8'd30:data_tx <= crc_reg[15:8];
                        default: data_tx <= data_tx;
                    endcase
                end
                else if(data_rx_reg[2] == 'h03 && data_rx_reg[3]== 'h10)begin
                    case (cnt_tx)
                        8'd0 :data_tx <= 8'h01;
                        8'd1 :data_tx <= 8'h03;
                        8'd2 :data_tx <= 8'he0;
                        8'd3 :data_tx <= PLC1_status_reg[7:0];
                        8'd4 :data_tx <= PLC1_status_reg[15:8];
                        8'd5 :data_tx <= PLC1_status_reg[23:16];
                        8'd6 :data_tx <= PLC1_status_reg[31:24];
                        8'd7 :data_tx <= PLC2_status_reg[7:0];
                        8'd8 :data_tx <= PLC2_status_reg[15:8];
                        8'd9 :data_tx <= PLC2_status_reg[23:16];
                        8'd10:data_tx <= PLC2_status_reg[31:24];
                        8'd11:data_tx <= PLC2_status_reg[39:32];
                        8'd12:data_tx <= PLC2_status_reg[47:40];
                        8'd13:data_tx <= PLC2_status_reg[55:48];
                        8'd14:data_tx <= PLC2_status_reg[63:56];
                        8'd15:data_tx <= PLC2_status_reg[71:64];
                        8'd16:data_tx <= PLC2_status_reg[79:72];
                        8'd17:data_tx <= PLC2_status_reg[87:80];
                        8'd18:data_tx <= PLC2_status_reg[95:88];
                        8'd19:data_tx <= PLC2_status_reg[103:96];
                        8'd20:data_tx <= PLC2_status_reg[111:104];
                        8'd21:data_tx <= PLC2_status_reg[119:112];
                        8'd22:data_tx <= PLC2_status_reg[127:120];
                        8'd23:data_tx <= PLC2_status_reg[135:128];
                        8'd24:data_tx <= PLC2_status_reg[143:136];
                        8'd25:data_tx <= PLC2_status_reg[151:144];
                        8'd26:data_tx <= PLC2_status_reg[159:152];
                        8'd27:data_tx <= PLC2_status_reg[167:160];
                        8'd28:data_tx <= PLC2_status_reg[175:168];
                        8'd29:data_tx <= PLC2_status_reg[183:176];
                        8'd30:data_tx <= PLC2_status_reg[191:184];
                        8'd31:data_tx <= PLC2_status_reg[199:192];
                        8'd32:data_tx <= PLC2_status_reg[207:200];
                        8'd33:data_tx <= PLC2_status_reg[215:208];
                        8'd34:data_tx <= PLC2_status_reg[223:216];
                        8'd35:data_tx <= PLC3_status_reg[7:0];
                        8'd36:data_tx <= PLC3_status_reg[15:8];
                        8'd37:data_tx <= PLC3_status_reg[23:16];
                        8'd38:data_tx <= PLC3_status_reg[31:24];
                        8'd39:data_tx <= PLC3_status_reg[39:32];
                        8'd40:data_tx <= PLC3_status_reg[47:40];
                        8'd41:data_tx <= PLC3_status_reg[55:48];
                        8'd42:data_tx <= PLC3_status_reg[63:56];
                        8'd43:data_tx <= PLC3_status_reg[71:64];
                        8'd44:data_tx <= PLC3_status_reg[79:72];
                        8'd45:data_tx <= PLC3_status_reg[87:80];
                        8'd46:data_tx <= PLC3_status_reg[95:88];
                        8'd47:data_tx <= PLC3_status_reg[103:96];
                        8'd48:data_tx <= PLC3_status_reg[111:104];
                        8'd49:data_tx <= PLC3_status_reg[119:112];
                        8'd50:data_tx <= PLC3_status_reg[127:120];
                        8'd51:data_tx <= PLC3_status_reg[135:128];
                        8'd52:data_tx <= PLC3_status_reg[143:136];
                        8'd53:data_tx <= PLC3_status_reg[151:144];
                        8'd54:data_tx <= PLC3_status_reg[159:152];
                        8'd55:data_tx <= PLC3_status_reg[167:160];
                        8'd56:data_tx <= PLC3_status_reg[175:168];
                        8'd57:data_tx <= PLC3_status_reg[183:176];
                        8'd58:data_tx <= PLC3_status_reg[191:184];
                        8'd59:data_tx <= PLC3_status_reg[199:192];
                        8'd60:data_tx <= PLC3_status_reg[207:200];
                        8'd61:data_tx <= PLC3_status_reg[215:208];
                        8'd62:data_tx <= PLC3_status_reg[223:216];
                        8'd63:data_tx <= PLC3_status_reg[231:224];
                        8'd64:data_tx <= PLC3_status_reg[239:232];
                        8'd65:data_tx <= PLC3_status_reg[247:240];
                        8'd66:data_tx <= PLC3_status_reg[255:248];
                        8'd67:data_tx <= PLC4_status_reg[7:0];
                        8'd68:data_tx <= PLC4_status_reg[15:8];
                        8'd69:data_tx <= PLC4_status_reg[23:16];
                        8'd70:data_tx <= PLC4_status_reg[31:24];
                        8'd71:data_tx <= PLC4_status_reg[39:32];
                        8'd72:data_tx <= PLC4_status_reg[47:40];
                        8'd73:data_tx <= PLC4_status_reg[55:48];
                        8'd74:data_tx <= PLC4_status_reg[63:56];
                        8'd75:data_tx <= PLC4_status_reg[71:64];
                        8'd76:data_tx <= PLC4_status_reg[79:72];
                        8'd77:data_tx <= PLC4_status_reg[87:80];
                        8'd78:data_tx <= PLC4_status_reg[95:88];
                        8'd79:data_tx <= PLC4_status_reg[103:96];
                        8'd80:data_tx <= PLC4_status_reg[111:104];
                        8'd81:data_tx <= PLC4_status_reg[119:112];
                        8'd82:data_tx <= PLC4_status_reg[127:120];
                        8'd83:data_tx <= PLC4_status_reg[135:128];
                        8'd84:data_tx <= PLC4_status_reg[143:136];
                        8'd85:data_tx <= PLC4_status_reg[151:144];
                        8'd86:data_tx <= PLC4_status_reg[159:152];
                        8'd87:data_tx <= PLC4_status_reg[167:160];
                        8'd88:data_tx <= PLC4_status_reg[175:168];
                        8'd89:data_tx <= PLC4_status_reg[183:176];
                        8'd90:data_tx <= PLC4_status_reg[191:184];
                        8'd91:data_tx <= PLC4_status_reg[199:192];
                        8'd92:data_tx <= PLC4_status_reg[207:200];
                        8'd93:data_tx <= PLC4_status_reg[215:208];
                        8'd94:data_tx <= PLC4_status_reg[223:216];
                        8'd95:data_tx <= PLC4_status_reg[231:224];
                        8'd96:data_tx <= PLC4_status_reg[239:232];
                        8'd97:data_tx <= PLC4_status_reg[247:240];
                        8'd98:data_tx <= PLC4_status_reg[255:248];
                        8'd99:data_tx  <= PLC5_status_reg[7:0];
                        8'd100:data_tx <= PLC5_status_reg[15:8];
                        8'd101:data_tx <= PLC5_status_reg[23:16];
                        8'd102:data_tx <= PLC5_status_reg[31:24];
                        8'd103:data_tx <= PLC5_status_reg[39:32];
                        8'd104:data_tx <= PLC5_status_reg[47:40];
                        8'd105:data_tx <= PLC5_status_reg[55:48];
                        8'd106:data_tx <= PLC5_status_reg[63:56];
                        8'd107:data_tx <= PLC5_status_reg[71:64];
                        8'd108:data_tx <= PLC5_status_reg[79:72];
                        8'd109:data_tx <= PLC5_status_reg[87:80];
                        8'd110:data_tx <= PLC5_status_reg[95:88];
                        8'd111:data_tx <= PLC5_status_reg[103:96];
                        8'd112:data_tx <= PLC5_status_reg[111:104];
                        8'd113:data_tx <= PLC5_status_reg[119:112];
                        8'd114:data_tx <= PLC5_status_reg[127:120];
                        8'd115:data_tx <= PLC5_status_reg[135:128];
                        8'd116:data_tx <= PLC5_status_reg[143:136];
                        8'd117:data_tx <= PLC5_status_reg[151:144];
                        8'd118:data_tx <= PLC5_status_reg[159:152];
                        8'd119:data_tx <= PLC5_status_reg[167:160];
                        8'd120:data_tx <= PLC5_status_reg[175:168];
                        8'd121:data_tx <= PLC5_status_reg[183:176];
                        8'd122:data_tx <= PLC5_status_reg[191:184];
                        8'd123:data_tx <= PLC5_status_reg[199:192];
                        8'd124:data_tx <= PLC5_status_reg[207:200];
                        8'd125:data_tx <= PLC5_status_reg[215:208];
                        8'd126:data_tx <= PLC5_status_reg[223:216];
                        8'd127:data_tx <= PLC5_status_reg[231:224];
                        8'd128:data_tx <= PLC5_status_reg[239:232];
                        8'd129:data_tx <= PLC5_status_reg[247:240];
                        8'd130:data_tx <= PLC5_status_reg[255:248];
                        8'd131:data_tx <= PLC6_status_reg[7:0];
                        8'd132:data_tx <= PLC6_status_reg[15:8];
                        8'd133:data_tx <= PLC6_status_reg[23:16];
                        8'd134:data_tx <= PLC6_status_reg[31:24];
                        8'd135:data_tx <= PLC6_status_reg[39:32];
                        8'd136:data_tx <= PLC6_status_reg[47:40];
                        8'd137:data_tx <= PLC6_status_reg[55:48];
                        8'd138:data_tx <= PLC6_status_reg[63:56];
                        8'd139:data_tx <= PLC6_status_reg[71:64];
                        8'd140:data_tx <= PLC6_status_reg[79:72];
                        8'd141:data_tx <= PLC6_status_reg[87:80];
                        8'd142:data_tx <= PLC6_status_reg[95:88];
                        8'd143:data_tx <= PLC6_status_reg[103:96];
                        8'd144:data_tx <= PLC6_status_reg[111:104];
                        8'd145:data_tx <= PLC6_status_reg[119:112];
                        8'd146:data_tx <= PLC6_status_reg[127:120];
                        8'd147:data_tx <= PLC6_status_reg[135:128];
                        8'd148:data_tx <= PLC6_status_reg[143:136];
                        8'd149:data_tx <= PLC6_status_reg[151:144];
                        8'd150:data_tx <= PLC6_status_reg[159:152];
                        8'd151:data_tx <= PLC6_status_reg[167:160];
                        8'd152:data_tx <= PLC6_status_reg[175:168];
                        8'd153:data_tx <= PLC6_status_reg[183:176];
                        8'd154:data_tx <= PLC6_status_reg[191:184];
                        8'd155:data_tx <= PLC6_status_reg[199:192];
                        8'd156:data_tx <= PLC6_status_reg[207:200];
                        8'd157:data_tx <= PLC6_status_reg[215:208];
                        8'd158:data_tx <= PLC6_status_reg[223:216];
                        8'd159:data_tx <= PLC6_status_reg[231:224];
                        8'd160:data_tx <= PLC6_status_reg[239:232];
                        8'd161:data_tx <= PLC6_status_reg[247:240];
                        8'd162:data_tx <= PLC6_status_reg[255:248];
                        8'd163:data_tx <= PLC7_status_reg[7:0];
                        8'd164:data_tx <= PLC7_status_reg[15:8];
                        8'd165:data_tx <= PLC7_status_reg[23:16];
                        8'd166:data_tx <= PLC7_status_reg[31:24];
                        8'd167:data_tx <= PLC7_status_reg[39:32];
                        8'd168:data_tx <= PLC7_status_reg[47:40];
                        8'd169:data_tx <= PLC7_status_reg[55:48];
                        8'd170:data_tx <= PLC7_status_reg[63:56];
                        8'd171:data_tx <= PLC7_status_reg[71:64];
                        8'd172:data_tx <= PLC7_status_reg[79:72];
                        8'd173:data_tx <= PLC7_status_reg[87:80];
                        8'd174:data_tx <= PLC7_status_reg[95:88];
                        8'd175:data_tx <= PLC7_status_reg[103:96];
                        8'd176:data_tx <= PLC7_status_reg[111:104];
                        8'd177:data_tx <= PLC7_status_reg[119:112];
                        8'd178:data_tx <= PLC7_status_reg[127:120];
                        8'd179:data_tx <= PLC7_status_reg[135:128];
                        8'd180:data_tx <= PLC7_status_reg[143:136];
                        8'd181:data_tx <= PLC7_status_reg[151:144];
                        8'd182:data_tx <= PLC7_status_reg[159:152];
                        8'd183:data_tx <= PLC7_status_reg[167:160];
                        8'd184:data_tx <= PLC7_status_reg[175:168];
                        8'd185:data_tx <= PLC7_status_reg[183:176];
                        8'd186:data_tx <= PLC7_status_reg[191:184];
                        8'd187:data_tx <= PLC7_status_reg[199:192];
                        8'd188:data_tx <= PLC7_status_reg[207:200];
                        8'd189:data_tx <= PLC7_status_reg[215:208];
                        8'd190:data_tx <= PLC7_status_reg[223:216];
                        8'd191:data_tx <= PLC7_status_reg[231:224];
                        8'd192:data_tx <= PLC7_status_reg[239:232];
                        8'd193:data_tx <= PLC7_status_reg[247:240];
                        8'd194:data_tx <= PLC7_status_reg[255:248];
                        8'd195:data_tx <= PLC8_status_reg[7:0];
                        8'd196:data_tx <= PLC8_status_reg[15:8];
                        8'd197:data_tx <= PLC8_status_reg[23:16];
                        8'd198:data_tx <= PLC8_status_reg[31:24];
                        8'd199:data_tx <= PLC8_status_reg[39:32];
                        8'd200:data_tx <= PLC8_status_reg[47:40];
                        8'd201:data_tx <= PLC8_status_reg[55:48];
                        8'd202:data_tx <= PLC8_status_reg[63:56];
                        8'd203:data_tx <= PLC8_status_reg[71:64];
                        8'd204:data_tx <= PLC8_status_reg[79:72];
                        8'd205:data_tx <= PLC8_status_reg[87:80];
                        8'd206:data_tx <= PLC8_status_reg[95:88];
                        8'd207:data_tx <= PLC8_status_reg[103:96];
                        8'd208:data_tx <= PLC8_status_reg[111:104];
                        8'd209:data_tx <= PLC8_status_reg[119:112];
                        8'd210:data_tx <= PLC8_status_reg[127:120];
                        8'd211:data_tx <= PLC8_status_reg[135:128];
                        8'd212:data_tx <= PLC8_status_reg[143:136];
                        8'd213:data_tx <= PLC8_status_reg[151:144];
                        8'd214:data_tx <= PLC8_status_reg[159:152];
                        8'd215:data_tx <= PLC8_status_reg[167:160];
                        8'd216:data_tx <= PLC8_status_reg[175:168];
                        8'd217:data_tx <= PLC8_status_reg[183:176];
                        8'd218:data_tx <= PLC8_status_reg[191:184];
                        8'd219:data_tx <= PLC8_status_reg[199:192];
                        8'd220:data_tx <= PLC8_status_reg[207:200];
                        8'd221:data_tx <= PLC8_status_reg[215:208];
                        8'd222:data_tx <= PLC8_status_reg[223:216];
                        8'd223:data_tx <= PLC8_status_reg[231:224];
                        8'd224:data_tx <= PLC8_status_reg[239:232];
                        8'd225:data_tx <= PLC8_status_reg[247:240];
                        8'd226:data_tx <= PLC8_status_reg[255:248];
                        8'd227:data_tx <= crc_reg[7:0];
                        8'd228:data_tx <= crc_reg[15:8];
                        default: data_tx <= data_tx;
                    endcase
                end
                else if(data_rx_reg[2] == 'h03 && data_rx_reg[3] == 'he0)begin
                    case(cnt_tx)
                        8'd0 :data_tx <= 8'h01;
                        8'd1 :data_tx <= 8'h03;
                        8'd2 :data_tx <= 8'h0c;//协议里为0c，三字节
                        8'd3 :data_tx <= read100_reg[7:0];
                        8'd4 :data_tx <= read100_reg[15:8];
                        8'd5 :data_tx <= read100_reg[23:16];
                        8'd6 :data_tx <= read100_reg[31:24];
                        8'd7 :data_tx <= read101_reg[7:0];
                        8'd8 :data_tx <= read101_reg[15:8];
                        8'd9 :data_tx <= read101_reg[23:16];
                        8'd10:data_tx <= read101_reg[31:24];
                        8'd11:data_tx <= read102_reg[7:0];
                        8'd12:data_tx <= read102_reg[15:8];
                        8'd13:data_tx <= read102_reg[23:16];
                        8'd14:data_tx <= read102_reg[31:24];                       
                        8'd15 :data_tx <= crc_reg[7:0];
                        8'd16 :data_tx <= crc_reg[15:8]; 
                        default: data_tx <= data_tx; 
                    endcase
                end 
                else if(data_rx_reg[2] == 'h03 && data_rx_reg[3] == 'hf2)  begin
                    case(cnt_tx)
                        8'd0 :data_tx <= 8'h01;
                        8'd1 :data_tx <= 8'h03;
                        8'd2 :data_tx <= 8'h04;
                        8'd3 :data_tx <= flt_num[7:0];
                        8'd4 :data_tx <= flt_num[15:8];
                        8'd5 :data_tx <= crc_reg[7:0]; 
                        8'd6 :data_tx <= crc_reg[15:8];
                        default: data_tx <= data_tx;
                    endcase
                end
                else if(data_rx_reg[2] == 'h03 && data_rx_reg[3] == 'hf5)  begin
                    case(cnt_tx)
                        8'd0 :data_tx <= 8'h01;
                        8'd1 :data_tx <= 8'h03;
                        8'd2 :data_tx <= 8'h04;
                        8'd3 :data_tx <= int_num[7:0];
                        8'd4 :data_tx <= int_num[15:8];
                        8'd5 :data_tx <= crc_reg[7:0]; 
                        8'd6 :data_tx <= crc_reg[15:8];
                        default: data_tx <= data_tx;
                    endcase
                end 
                else if (data_rx_reg[2] == 'h04 && data_rx_reg[3] == 'h10) begin
                    case (cnt_tx)
                        8'd0 : data_tx <= 8'h01;
                        8'd1 : data_tx <= 8'h03;
                        8'd2 : data_tx <= 8'h18;
                        8'd3 : data_tx <= avg_i_1_reg[7:0];
                        8'd4 : data_tx <= avg_i_1_reg[15:8];
                        8'd5 : data_tx <= avg_i_1_reg[23:16];
                        8'd6 : data_tx <= avg_i_1_reg[31:24];
                        8'd7 : data_tx <= avg_i_2_reg[7:0];
                        8'd8 : data_tx <= avg_i_2_reg[15:8];
                        8'd9 : data_tx <= avg_i_2_reg[23:16];
                        8'd10: data_tx <= avg_i_2_reg[31:24];
                        8'd11: data_tx <= avg_i_3_reg[7:0];
                        8'd12: data_tx <= avg_i_3_reg[15:8];
                        8'd13: data_tx <= avg_i_3_reg[23:16];
                        8'd14: data_tx <= avg_i_3_reg[31:24];
                        8'd15: data_tx <= avg_i_4_reg[7:0];
                        8'd16: data_tx <= avg_i_4_reg[15:8];
                        8'd17: data_tx <= avg_i_4_reg[23:16];
                        8'd18: data_tx <= avg_i_4_reg[31:24];
                        8'd19: data_tx <= avg_i_5_reg[7:0];
                        8'd20: data_tx <= avg_i_5_reg[15:8];
                        8'd21: data_tx <= avg_i_5_reg[23:16];
                        8'd22: data_tx <= avg_i_5_reg[31:24];
                        8'd23: data_tx <= avg_i_6_reg[7:0];
                        8'd24: data_tx <= avg_i_6_reg[15:8];
                        8'd25: data_tx <= avg_i_6_reg[23:16];
                        8'd26: data_tx <= avg_i_6_reg[31:24];
                        8'd27: data_tx <= crc_reg[7:0]; 
                        8'd28: data_tx <= crc_reg[15:8];
                        default: data_tx <= data_tx;
                    endcase
                end          
                end
                rb_data_10://wr 
                begin
                    case (cnt_tx)
                        4'd0:data_tx <= 8'h01;
                        4'd1:data_tx <= 8'h10;
                        4'd2:data_tx <= data_rx_reg[2];
                        4'd3:data_tx <= data_rx_reg[3];
                        4'd4:data_tx <= data_rx_reg[4];
                        4'd5:data_tx <= data_rx_reg[5];
                        4'd6:data_tx <= crc_reg[7:0];
                        4'd7:data_tx <= crc_reg[15:8];
                        default: data_tx <= data_tx;
                    endcase
                end
                default: data_tx <= data_tx;
            endcase
        end
    end
    always @(posedge clk or negedge rst) begin
        if(!rst)
            flt_num <= 'h0;
        else if(next_state == cal_lenth)begin
            case({addr_h,addr_l})
            16'h05:flt_num <= write05_reg;
            16'h06:flt_num <= write06_reg;
            16'h07:flt_num <= write07_reg;
            16'h08:flt_num <= write08_reg;
            16'h09:flt_num <= write09_reg;
            endcase
        end
        else begin
            flt_num <= flt_num;
        end         
    end

    always @(posedge clk or negedge rst) begin
        if(!rst)
            int_num <= 'h0;
        else if(next_state == cal_lenth)begin
            case({addr_h,addr_l})
            16'h00:int_num <= write00_reg;
            16'h01:int_num <= write01_reg;
            16'h02:int_num <= write02_reg;
            16'h03:int_num <= write03_reg;
            16'h04:int_num <= write04_reg;
            endcase
        end
        else begin
            int_num <= int_num;
        end
    end
    
    always @ (posedge clk or negedge rst)
    begin
        if (!rst)
        begin
            data_tx_flash <= 1'b0;
        end
        else
        begin
            case (next_state)
                rb_data_03:
                begin
                    if (tx_finish_reg == 2'b01) //cnt_tx more than 10 bit,means the whole byte send, no more than 15
                    begin
                        data_tx_flash <= 1'b0;//when data_tx_flash = 0 means that one byte datas has sends
                    end
                    else if(cnt_tx == 4'd0)
                    begin
                        data_tx_flash <= 1'b1;
                    end
                    else if (data_tx_flash == 1'b0)
                    begin
                        data_tx_flash <= 1'b1;
                    end
                    else
                    begin
                        data_tx_flash <= data_tx_flash;
                    end
                end
                rb_data_10:
                begin
                    if (tx_finish_reg == 2'b01)
                    begin
                        data_tx_flash <= 1'b0;
                    end
                    else if(cnt_tx == 4'd0)
                    begin
                        data_tx_flash <= 1'b1;
                    end
                    else if (data_tx_flash == 1'b0)
                    begin
                        data_tx_flash <= 1'b1;
                    end
                    else
                    begin
                        data_tx_flash <= data_tx_flash;
                    end
                end
                default: data_tx_flash <= 1'b0;
            endcase
        end
    end
    
    always @ (posedge clk or negedge rst)
    begin
        if (!rst)
        begin
            vld <= 1'b0;
        end
        else
        begin
            case (next_state)
                ins_choose: vld <= 1'b0;
                para_rb:
                begin
                    if (cnt_crc == 4'd1)
                    begin
                        vld <= 1'b1;
                    end
                    else if (cnt_crc == 4'd6)// maybe wrong
                    begin
                        vld <= 1'b0;
                    end
                    else
                    begin
                        vld <= vld;
                    end
                end
                para_wr,cal_lenth:
                begin
                    if (cnt_crc == 4'd1)
                    begin
                        vld <= 1'b1;
                    end
                    else if (cnt_crc == 4'd7 +  data_rx_reg[6])
                    begin
                        vld <= 1'b0;
                    end
                    else
                    begin
                        vld <= vld;
                    end
                end
                rb_data_03:
                begin
                    if (cnt_crc == 4'd1)
                    begin
                        vld <= 1'b1;
                    end
                    else if (cnt_crc == data_lenth - 2)//change
                    begin
                        vld <= 1'b0;
                    end
                    else
                    begin
                        vld <= vld;
                    end
                end
                rb_data_10:
                begin
                    if (cnt_crc == 4'd1)
                    begin
                        vld <= 1'b1;
                    end
                    else if (cnt_crc == 4'd6)
                    begin
                        vld <= 1'b0;
                    end
                    else
                    begin
                        vld <= vld;
                    end
                end
                default: vld <= 1'b0;
            endcase
        end
    end
    
    always @ (posedge clk or negedge rst)
    begin
        if (!rst)
        begin
            data_crc <= 8'd0;
        end
        else
        begin
            case (next_state)
                ins_choose: data_crc <= 8'hff;
                para_rb:
                begin
                    case (cnt_crc)//need 16 clk for calculate crc
                        8'd1:data_crc <= 8'h01;
                        8'd2:data_crc <= 8'h03;
                        8'd3:data_crc <= data_rx_reg[2];
                        8'd4:data_crc <= data_rx_reg[3];
                        8'd5:data_crc <= data_rx_reg[4];
                        8'd6:data_crc <= data_rx_reg[5];
                        default: data_crc <= 8'hff;
                    endcase
                end
                para_wr,cal_lenth:
                begin
                    case (cnt_crc)
                        8'd1:data_crc <= 8'h01;
                        8'd2:data_crc <= 8'h10;
                        8'd3:data_crc <= data_rx_reg[2];
                        8'd4:data_crc <= data_rx_reg[3];
                        8'd5:data_crc <= data_rx_reg[4];
                        8'd6:data_crc <= data_rx_reg[5];
                        8'd7:data_crc <= data_rx_reg[6];
                        8'd8:data_crc <= data_rx_reg[7];
                        8'd9:data_crc <= data_rx_reg[8];
                        8'd10:data_crc <= data_rx_reg[9];
                        8'd11:data_crc <= data_rx_reg[10];
                        8'd12:data_crc <= data_rx_reg[11];
                        8'd13:data_crc <= data_rx_reg[12];
                        8'd14:data_crc <= data_rx_reg[13];
                        8'd15:data_crc <= data_rx_reg[14];
                        8'd16:data_crc <= data_rx_reg[15];
                        8'd17:data_crc <= data_rx_reg[16];
                        8'd18:data_crc <= data_rx_reg[17];
                        8'd19:data_crc <= data_rx_reg[18];
                        8'd20:data_crc <= data_rx_reg[19];
                        8'd21:data_crc <= data_rx_reg[20];
                        8'd22:data_crc <= data_rx_reg[21];
                        8'd23:data_crc <= data_rx_reg[22];
                        8'd24:data_crc <= data_rx_reg[23];
                        8'd25:data_crc <= data_rx_reg[24];
                        8'd26:data_crc <= data_rx_reg[25];
                        8'd27:data_crc <= data_rx_reg[26];
                        8'd28:data_crc <= data_rx_reg[27];
                        8'd29:data_crc <= data_rx_reg[28];
                        8'd30:data_crc <= data_rx_reg[29];
                        8'd31:data_crc <= data_rx_reg[30];
                        8'd32:data_crc <= data_rx_reg[31];                      
                        8'd33:data_crc <= data_rx_reg	[	32	]	;
                        8'd34:data_crc <= data_rx_reg	[	33	]	;
                        8'd35:data_crc <= data_rx_reg	[	34	]	;
                        8'd36:data_crc <= data_rx_reg	[	35	]	;
                        8'd37:data_crc <= data_rx_reg	[	36	]	;
                        8'd38:data_crc <= data_rx_reg	[	37	]	;
                        8'd39:data_crc <= data_rx_reg	[	38	]	;
                        8'd40:data_crc <= data_rx_reg	[	39	]	;
                        8'd41:data_crc <= data_rx_reg	[	40	]	;
                        8'd42:data_crc <= data_rx_reg	[	41	]	;
                        8'd43:data_crc <= data_rx_reg	[	42	]	;
                        8'd44:data_crc <= data_rx_reg	[	43	]	;
                        8'd45:data_crc <= data_rx_reg	[	44	]	;
                        8'd46:data_crc <= data_rx_reg	[	45	]	;
                        8'd47:data_crc <= data_rx_reg	[	46	]	;
                        8'd48:data_crc <= data_rx_reg	[	47	]	;
                        8'd49:data_crc <= data_rx_reg	[	48	]	;
                        8'd50:data_crc <= data_rx_reg	[	49	]	;
                        8'd51:data_crc <= data_rx_reg	[	50	]	;
                        8'd52:data_crc <= data_rx_reg	[	51	]	;
                        8'd53:data_crc <= data_rx_reg	[	52	]	;
                        8'd54:data_crc <= data_rx_reg	[	53	]	;
                        8'd55:data_crc <= data_rx_reg	[	54	]	;
                        8'd56:data_crc <= data_rx_reg	[	55	]	;
                        8'd57:data_crc <= data_rx_reg	[	56	]	;
                        8'd58:data_crc <= data_rx_reg	[	57	]	;
                        8'd59:data_crc <= data_rx_reg	[	58	]	;
                        8'd60:data_crc <= data_rx_reg	[	59	]	;
                        8'd61:data_crc <= data_rx_reg	[	60	]	;
                        8'd62:data_crc <= data_rx_reg	[	61	]	;
                        8'd63:data_crc <= data_rx_reg	[	62	]	;
                        8'd64:data_crc <= data_rx_reg	[	63	]	;
                        8'd65:data_crc <= data_rx_reg	[	64	]	;
                        8'd66:data_crc <= data_rx_reg	[	65	]	;
                        8'd67:data_crc <= data_rx_reg	[	66	]	;
                        8'd68:data_crc <= data_rx_reg	[	67	]	;
                        8'd69:data_crc <= data_rx_reg	[	68	]	;
                        8'd70:data_crc <= data_rx_reg	[	69	]	;
                        8'd71:data_crc <= data_rx_reg	[	70	]	;
                        8'd72:data_crc <= data_rx_reg	[	71	]	;
                        8'd73:data_crc <= data_rx_reg	[	72	]	;
                        8'd74:data_crc <= data_rx_reg	[	73	]	;
                        8'd75:data_crc <= data_rx_reg	[	74	]	;
                        8'd76:data_crc <= data_rx_reg	[	75	]	;
                        8'd77:data_crc <= data_rx_reg	[	76	]	;
                        8'd78:data_crc <= data_rx_reg	[	77	]	;
                        8'd79:data_crc <= data_rx_reg	[	78	]	;
                        8'd80:data_crc <= data_rx_reg	[	79	]	;
                        8'd81:data_crc <= data_rx_reg	[	80	]	;
                        8'd82:data_crc <= data_rx_reg	[	81	]	;
                        8'd83:data_crc <= data_rx_reg	[	82	]	;
                        8'd84:data_crc <= data_rx_reg	[	83	]	;
                        8'd85:data_crc <= data_rx_reg	[	84	]	;
                        8'd86:data_crc <= data_rx_reg	[	85	]	;
                        8'd87:data_crc <= data_rx_reg	[	86	]	;
                        8'd88:data_crc <= data_rx_reg	[	87	]	;
                        8'd89:data_crc <= data_rx_reg	[	88	]	;
                        8'd90:data_crc <= data_rx_reg	[	89	]	;
                        8'd91:data_crc <= data_rx_reg	[	90	]	;
                        8'd92:data_crc <= data_rx_reg	[	91	]	;
                        8'd93:data_crc <= data_rx_reg	[	92	]	;
                        8'd94:data_crc <= data_rx_reg	[	93	]	;
                        8'd95:data_crc <= data_rx_reg	[	94	]	;
                        8'd96:data_crc <= data_rx_reg	[	95	]	;
                        8'd97:data_crc <= data_rx_reg	[	96	]	;
                        8'd98:data_crc <= data_rx_reg	[	97	]	;
                        8'd99:data_crc <= data_rx_reg	[	98	]	;
                        8'd100:	data_crc <=	data_rx_reg	[	99	]	;
                        8'd101:	data_crc <=	data_rx_reg	[	100	]	;
                        8'd102:	data_crc <=	data_rx_reg	[	101	]	;
                        8'd103:	data_crc <=	data_rx_reg	[	102	]	;
                        8'd104:	data_crc <=	data_rx_reg	[	103	]	;
                        8'd105:	data_crc <=	data_rx_reg	[	104	]	;
                        8'd106:	data_crc <=	data_rx_reg	[	105	]	;
                        8'd107:	data_crc <=	data_rx_reg	[	106	]	;
                        8'd108:	data_crc <=	data_rx_reg	[	107	]	;
                        8'd109:	data_crc <=	data_rx_reg	[	108	]	;
                        8'd110:	data_crc <=	data_rx_reg	[	109	]	;
                        8'd111:	data_crc <=	data_rx_reg	[	110	]	;
                        8'd112:	data_crc <=	data_rx_reg	[	111	]	;
                        8'd113:	data_crc <=	data_rx_reg	[	112	]	;
                        8'd114:	data_crc <=	data_rx_reg	[	113	]	;
                        8'd115:	data_crc <=	data_rx_reg	[	114	]	;
                        8'd116:	data_crc <=	data_rx_reg	[	115	]	;
                        8'd117:	data_crc <=	data_rx_reg	[	116	]	;
                        8'd118:	data_crc <=	data_rx_reg	[	117	]	;
                        8'd119:	data_crc <=	data_rx_reg	[	118	]	;
                        8'd120:	data_crc <=	data_rx_reg	[	119	]	;
                        8'd121:	data_crc <=	data_rx_reg	[	120	]	;
                        8'd122:	data_crc <=	data_rx_reg	[	121	]	;
                        8'd123:	data_crc <=	data_rx_reg	[	122	]	;
                        8'd124:	data_crc <=	data_rx_reg	[	123	]	;
                        8'd125:	data_crc <=	data_rx_reg	[	124	]	;
                        8'd126:	data_crc <=	data_rx_reg	[	125	]	;
                        8'd127:	data_crc <=	data_rx_reg	[	126	]	;
                        8'd128:	data_crc <=	data_rx_reg	[	127	]	;
                        8'd129:	data_crc <=	data_rx_reg	[	128	]	;
                        8'd130:	data_crc <=	data_rx_reg	[	129	]	;
                        8'd131:	data_crc <=	data_rx_reg	[	130	]	;
                        8'd132:	data_crc <=	data_rx_reg	[	131	]	;
                        8'd133:	data_crc <=	data_rx_reg	[	132	]	;
                        8'd134:	data_crc <=	data_rx_reg	[	133	]	;
                        8'd135:	data_crc <=	data_rx_reg	[	134	]	;
                        8'd136:	data_crc <=	data_rx_reg	[	135	]	;
                        8'd137:	data_crc <=	data_rx_reg	[	136	]	;
                        8'd138:	data_crc <=	data_rx_reg	[	137	]	;
                        8'd139:	data_crc <=	data_rx_reg	[	138	]	;
                        8'd140:	data_crc <=	data_rx_reg	[	139	]	;
                        8'd141:	data_crc <=	data_rx_reg	[	140	]	;
                        8'd142:	data_crc <=	data_rx_reg	[	141	]	;
                        8'd143:	data_crc <=	data_rx_reg	[	142	]	;
                        8'd144:	data_crc <=	data_rx_reg	[	143	]	;
                        8'd145:	data_crc <=	data_rx_reg	[	144	]	;
                        8'd146:	data_crc <=	data_rx_reg	[	145	]	;
                        8'd147:	data_crc <=	data_rx_reg	[	146	]	;
                        8'd148:	data_crc <=	data_rx_reg	[	147	]	;
                        8'd149:	data_crc <=	data_rx_reg	[	148	]	;
                        8'd150:	data_crc <=	data_rx_reg	[	149	]	;
                        8'd151:	data_crc <=	data_rx_reg	[	150	]	;
                        8'd152:	data_crc <=	data_rx_reg	[	151	]	;
                        8'd153:	data_crc <=	data_rx_reg	[	152	]	;
                        8'd154:	data_crc <=	data_rx_reg	[	153	]	;
                        8'd155:	data_crc <=	data_rx_reg	[	154	]	;
                        8'd156:	data_crc <=	data_rx_reg	[	155	]	;
                        8'd157:	data_crc <=	data_rx_reg	[	156	]	;
                        8'd158:	data_crc <=	data_rx_reg	[	157	]	;
                        8'd159:	data_crc <=	data_rx_reg	[	158	]	;
                        8'd160:	data_crc <=	data_rx_reg	[	159	]	;
                        8'd161:	data_crc <=	data_rx_reg	[	160	]	;
                        8'd162:	data_crc <=	data_rx_reg	[	161	]	;
                        8'd163:	data_crc <=	data_rx_reg	[	162	]	;
                        8'd164:	data_crc <=	data_rx_reg	[	163	]	;
                        8'd165:	data_crc <=	data_rx_reg	[	164	]	;
                        8'd166:	data_crc <=	data_rx_reg	[	165	]	;
                        8'd167:	data_crc <=	data_rx_reg	[	166	]	;
                        8'd168:	data_crc <=	data_rx_reg	[	167	]	;
                        8'd169:	data_crc <=	data_rx_reg	[	168	]	;
                        8'd170:	data_crc <=	data_rx_reg	[	169	]	;
                        8'd171:	data_crc <=	data_rx_reg	[	170	]	;
                        8'd172:	data_crc <=	data_rx_reg	[	171	]	;
                        8'd173:	data_crc <=	data_rx_reg	[	172	]	;
                        8'd174:	data_crc <=	data_rx_reg	[	173	]	;
                        8'd175:	data_crc <=	data_rx_reg	[	174	]	;
                        8'd176:	data_crc <=	data_rx_reg	[	175	]	;
                        8'd177:	data_crc <=	data_rx_reg	[	176	]	;
                        8'd178:	data_crc <=	data_rx_reg	[	177	]	;
                        8'd179:	data_crc <=	data_rx_reg	[	178	]	;
                        8'd180:	data_crc <=	data_rx_reg	[	179	]	;
                        8'd181:	data_crc <=	data_rx_reg	[	180	]	;
                        8'd182:	data_crc <=	data_rx_reg	[	181	]	;
                        8'd183:	data_crc <=	data_rx_reg	[	182	]	;
                        8'd184:	data_crc <=	data_rx_reg	[	183	]	;
                        8'd185:	data_crc <=	data_rx_reg	[	184	]	;
                        8'd186:	data_crc <=	data_rx_reg	[	185	]	;
                        8'd187:	data_crc <=	data_rx_reg	[	186	]	;
                        8'd188:	data_crc <=	data_rx_reg	[	187	]	;
                        8'd189:	data_crc <=	data_rx_reg	[	188	]	;
                        8'd190:	data_crc <=	data_rx_reg	[	189	]	;
                        8'd191:	data_crc <=	data_rx_reg	[	190	]	;
                        8'd192:	data_crc <=	data_rx_reg	[	191	]	;
                        8'd193:	data_crc <=	data_rx_reg	[	192	]	;
                        8'd194:	data_crc <=	data_rx_reg	[	193	]	;
                        8'd195:	data_crc <=	data_rx_reg	[	194	]	;
                        8'd196:	data_crc <=	data_rx_reg	[	195	]	;
                        8'd197:	data_crc <=	data_rx_reg	[	196	]	;
                        8'd198:	data_crc <=	data_rx_reg	[	197	]	;
                        8'd199:	data_crc <=	data_rx_reg	[	198	]	;
                        8'd200:	data_crc <=	data_rx_reg	[	199	]	;
                        8'd201:	data_crc <=	data_rx_reg	[	200	]	;
                        8'd202:	data_crc <=	data_rx_reg	[	201	]	;
                        8'd203:	data_crc <=	data_rx_reg	[	202	]	;
                        8'd204:	data_crc <=	data_rx_reg	[	203	]	;
                        8'd205:	data_crc <=	data_rx_reg	[	204	]	;
                        8'd206:	data_crc <=	data_rx_reg	[	205	]	;
                        8'd207:	data_crc <=	data_rx_reg	[	206	]	;
                        8'd208:	data_crc <=	data_rx_reg	[	207	]	;
                        8'd209:	data_crc <=	data_rx_reg	[	208	]	;
                        8'd210:	data_crc <=	data_rx_reg	[	209	]	;
                        8'd211:	data_crc <=	data_rx_reg	[	210	]	;
                        8'd212:	data_crc <=	data_rx_reg	[	211	]	;
                        8'd213:	data_crc <=	data_rx_reg	[	212	]	;
                        8'd214:	data_crc <=	data_rx_reg	[	213	]	;
                        8'd215:	data_crc <=	data_rx_reg	[	214	]	;
                        8'd216:	data_crc <=	data_rx_reg	[	215	]	;
                        8'd217:	data_crc <=	data_rx_reg	[	216	]	;
                        8'd218:	data_crc <=	data_rx_reg	[	217	]	;
                        8'd219:	data_crc <=	data_rx_reg	[	218	]	;
                        8'd220:	data_crc <=	data_rx_reg	[	219	]	;
                        8'd221:	data_crc <=	data_rx_reg	[	220	]	;
                        8'd222:	data_crc <=	data_rx_reg	[	221	]	;
                        8'd223:	data_crc <=	data_rx_reg	[	222	]	;
                        8'd224:	data_crc <=	data_rx_reg	[	223	]	;
                        8'd225:	data_crc <=	data_rx_reg	[	224	]	;
                        8'd226:	data_crc <=	data_rx_reg	[	225	]	;
                        8'd227:	data_crc <=	data_rx_reg	[	226	]	;
                        8'd228:	data_crc <=	data_rx_reg	[	227	]	;
                        8'd229:	data_crc <=	data_rx_reg	[	228	]	;
                        8'd230:	data_crc <=	data_rx_reg	[	229	]	;
                        8'd231:	data_crc <=	data_rx_reg	[	230	]	;
                        8'd232:	data_crc <=	data_rx_reg	[	231	]	;
                        8'd233:	data_crc <=	data_rx_reg	[	232	]	;
                        8'd234:	data_crc <=	data_rx_reg	[	233	]	;
                        8'd235:	data_crc <=	data_rx_reg	[	234	]	;
                        8'd236:	data_crc <=	data_rx_reg	[	235	]	;
                        8'd237:	data_crc <=	data_rx_reg	[	236	]	;
                        8'd238:	data_crc <=	data_rx_reg	[	237	]	;
                        8'd239:	data_crc <=	data_rx_reg	[	238	]	;
                        8'd240:	data_crc <=	data_rx_reg	[	239	]	;
                        8'd241:	data_crc <=	data_rx_reg	[	240	]	;
                        8'd242:	data_crc <=	data_rx_reg	[	241	]	;
                        8'd243:	data_crc <=	data_rx_reg	[	242	]	;
                        8'd244:	data_crc <=	data_rx_reg	[	243	]	;
                        8'd245:	data_crc <=	data_rx_reg	[	244	]	;
                        8'd246:	data_crc <=	data_rx_reg	[	245	]	;
                        8'd247:	data_crc <=	data_rx_reg	[	246	]	;
                        8'd248:	data_crc <=	data_rx_reg	[	247	]	;
                        8'd249:	data_crc <=	data_rx_reg	[	248	]	;
                        8'd250:	data_crc <=	data_rx_reg	[	249	]	;
                        8'd251:	data_crc <=	data_rx_reg	[	250	]	;
                        8'd252:	data_crc <=	data_rx_reg	[	251	]	;
                        8'd253:	data_crc <=	data_rx_reg	[	252	]	;
                        8'd254:	data_crc <=	data_rx_reg	[	253	]	;
                        8'd255:	data_crc <=	data_rx_reg	[	254	]	;
                        9'd256:	data_crc <=	data_rx_reg	[	255	]	;

                        default: data_crc <= 8'hff;
                    endcase
                end
                rb_data_03:
                begin
                    if(data_rx_reg[2] == 'h00 && data_rx_reg[3] == 'h64 )begin
                    case (cnt_crc)
                        4'd1:data_crc <= 8'h01;
                        4'd2:data_crc <= 8'h03;
                        4'd3:data_crc <= 8'h16;
                        4'd4:data_crc <= i_in_reg[7:0];
                        4'd5:data_crc <= i_in_reg[15:8];
                        4'd6:data_crc <= i_in_reg[23:16];
                        4'd7:data_crc <= i_in_reg[31:24];
                        4'd8:data_crc <= v_in_reg[7:0];
                        4'd9:data_crc <= v_in_reg[15:8];
                        4'd10:data_crc <= v_in_reg[23:16];
                        4'd11:data_crc <= v_in_reg[31:24];
                        4'd12:data_crc <= state_data_reg[7:0];
                        4'd13:data_crc <= state_data_reg[15:8];
                        4'd14:data_crc <= state_data_reg[23:16];
                        4'd15:data_crc <= state_data_reg[31:24];
                        8'd16:data_crc <= 8'h0;
                        8'd17:data_crc <= 8'h0;
                        8'd18:data_crc <= 8'h0;
                        8'd19:data_crc <= 8'h0;
                        8'd20:data_crc <= 8'h0;
                        8'd21:data_crc <= 8'h0;
                        8'd22:data_crc <= 8'h0;
                        8'd23:data_crc <= 8'h0;
                        8'd24:data_crc <= 8'h0;
                        8'd25:data_crc <= 8'h0;
                        default: data_crc <= 8'hff;
                    endcase
                    end
                    else if(data_rx_reg[2] == 'h03 && data_rx_reg[3] == 'h00)begin
                    case(cnt_crc)
                        4'd1:data_crc <= 8'h01;
                        4'd2:data_crc <= 8'h03;
                        4'd3:data_crc <= 8'h1a;
                        4'd4:data_crc <= IP_reg[7:0];
                        4'd5:data_crc <= IP_reg[15:8];
                        4'd6:data_crc <= IP_reg[23:16];
                        4'd7:data_crc <= IP_reg[31:24];
                        4'd8:data_crc <= IP_reg[39:32];
                        4'd9:data_crc <= IP_reg[47:40];
                        4'd10:data_crc <=IP_reg[55:48];
                        4'd11:data_crc <= IP_reg[63:56];
                        4'd12:data_crc <= netmask_reg[7:0];
                        4'd13:data_crc <= netmask_reg[15:8];
                        4'd14:data_crc <= netmask_reg[23:16];
                        4'd15:data_crc <= netmask_reg[31:24];
                        8'd16:data_crc <= netmask_reg[39:32];
                        8'd17:data_crc <= netmask_reg[47:40];
                        8'd18:data_crc <= netmask_reg[55:48];
                        8'd19:data_crc <= netmask_reg[63:56];
                        8'd20:data_crc <= gateway_reg[7:0];
                        8'd21:data_crc <= gateway_reg[15:8];
                        8'd22:data_crc <= gateway_reg[23:16];
                        8'd23:data_crc <= gateway_reg[31:24];
                        8'd24:data_crc <= gateway_reg[39:32];
                        8'd25:data_crc <= gateway_reg[47:40];
                        8'd26:data_crc <= gateway_reg[55:48];
                        8'd27:data_crc <= gateway_reg[63:56];
                        8'd28:data_crc <= type_reg[7:0];
                        8'd29:data_crc <= type_reg[15:8];
                        default: data_crc <= 8'hff;
                    endcase
                    end
                    else if(data_rx_reg[2] == 'h03 && data_rx_reg[3] == 'h10)begin
                        case(cnt_crc)
                        8'd1: data_crc <=8'h01;
                        8'd2: data_crc <=8'h03;
                        8'd3: data_crc <=8'he0;
                        8'd4: data_crc <=PLC1_status_reg[7:0];
                        8'd5: data_crc <=PLC1_status_reg[15:8];
                        8'd6: data_crc <=PLC1_status_reg[23:16];
                        8'd7: data_crc <=PLC1_status_reg[31:24];
                        8'd8: data_crc <=PLC2_status_reg[7:0];
                        8'd9: data_crc <=PLC2_status_reg[15:8];
                        8'd10:data_crc <=PLC2_status_reg[23:16];
                        8'd11:data_crc <=PLC2_status_reg[31:24];
                        8'd12:data_crc <=PLC2_status_reg[39:32];
                        8'd13:data_crc <=PLC2_status_reg[47:40];
                        8'd14:data_crc <=PLC2_status_reg[55:48];
                        8'd15:data_crc <=PLC2_status_reg[63:56];
                        8'd16:data_crc <=PLC2_status_reg[71:64];
                        8'd17:data_crc <=PLC2_status_reg[79:72];
                        8'd18:data_crc <=PLC2_status_reg[87:80];
                        8'd19:data_crc <=PLC2_status_reg[95:88];
                        8'd20:data_crc <=PLC2_status_reg[103:96];
                        8'd21:data_crc <=PLC2_status_reg[111:104];
                        8'd22:data_crc <=PLC2_status_reg[119:112];
                        8'd23:data_crc <=PLC2_status_reg[127:120];
                        8'd24:data_crc <=PLC2_status_reg[135:128];
                        8'd25:data_crc <=PLC2_status_reg[143:136];
                        8'd26:data_crc <=PLC2_status_reg[151:144];
                        8'd27:data_crc <=PLC2_status_reg[159:152];
                        8'd28:data_crc <=PLC2_status_reg[167:160];
                        8'd29:data_crc <=PLC2_status_reg[175:168];
                        8'd30:data_crc <=PLC2_status_reg[183:176];
                        8'd31:data_crc <=PLC2_status_reg[191:184];
                        8'd32:data_crc <=PLC2_status_reg[199:192];
                        8'd33:data_crc <=PLC2_status_reg[207:200];
                        8'd34:data_crc <=PLC2_status_reg[215:208];
                        8'd35:data_crc <=PLC2_status_reg[223:216];
                        8'd36:data_crc <=PLC3_status_reg[7:0];
                        8'd37:data_crc <=PLC3_status_reg[15:8];
                        8'd38:data_crc <=PLC3_status_reg[23:16];
                        8'd39:data_crc <=PLC3_status_reg[31:24];
                        8'd40:data_crc <=PLC3_status_reg[39:32];
                        8'd41:data_crc <=PLC3_status_reg[47:40];
                        8'd42:data_crc <=PLC3_status_reg[55:48];
                        8'd43:data_crc <=PLC3_status_reg[63:56];
                        8'd44:data_crc <=PLC3_status_reg[71:64];
                        8'd45:data_crc <=PLC3_status_reg[79:72];
                        8'd46:data_crc <=PLC3_status_reg[87:80];
                        8'd47:data_crc <=PLC3_status_reg[95:88];
                        8'd48:data_crc <=PLC3_status_reg[103:96];
                        8'd49:data_crc <=PLC3_status_reg[111:104];
                        8'd50:data_crc <=PLC3_status_reg[119:112];
                        8'd51:data_crc <=PLC3_status_reg[127:120];
                        8'd52:data_crc <=PLC3_status_reg[135:128];
                        8'd53:data_crc <=PLC3_status_reg[143:136];
                        8'd54:data_crc <=PLC3_status_reg[151:144];
                        8'd55:data_crc <=PLC3_status_reg[159:152];
                        8'd56:data_crc <=PLC3_status_reg[167:160];
                        8'd57:data_crc <=PLC3_status_reg[175:168];
                        8'd58:data_crc <=PLC3_status_reg[183:176];
                        8'd59:data_crc <=PLC3_status_reg[191:184];
                        8'd60:data_crc <=PLC3_status_reg[199:192];
                        8'd61:data_crc <=PLC3_status_reg[207:200];
                        8'd62:data_crc <=PLC3_status_reg[215:208];
                        8'd63:data_crc <=PLC3_status_reg[223:216];
                        8'd64:data_crc <=PLC3_status_reg[231:224];
                        8'd65:data_crc <=PLC3_status_reg[239:232];
                        8'd66:data_crc <=PLC3_status_reg[247:240];
                        8'd67:data_crc <=PLC3_status_reg[255:248];
                        8'd68:data_crc <=PLC4_status_reg[7:0];
                        8'd69:data_crc <=PLC4_status_reg[15:8];
                        8'd70:data_crc <=PLC4_status_reg[23:16];
                        8'd71:data_crc <=PLC4_status_reg[31:24];
                        8'd72:data_crc <=PLC4_status_reg[39:32];
                        8'd73:data_crc <=PLC4_status_reg[47:40];
                        8'd74:data_crc <=PLC4_status_reg[55:48];
                        8'd75:data_crc <=PLC4_status_reg[63:56];
                        8'd76:data_crc <=PLC4_status_reg[71:64];
                        8'd77:data_crc <=PLC4_status_reg[79:72];
                        8'd78:data_crc <=PLC4_status_reg[87:80];
                        8'd79:data_crc <=PLC4_status_reg[95:88];
                        8'd80:data_crc <=PLC4_status_reg[103:96];
                        8'd81:data_crc <=PLC4_status_reg[111:104];
                        8'd82:data_crc <=PLC4_status_reg[119:112];
                        8'd83:data_crc <=PLC4_status_reg[127:120];
                        8'd84:data_crc <=PLC4_status_reg[135:128];
                        8'd85:data_crc <=PLC4_status_reg[143:136];
                        8'd86:data_crc <=PLC4_status_reg[151:144];
                        8'd87:data_crc <=PLC4_status_reg[159:152];
                        8'd88:data_crc <=PLC4_status_reg[167:160];
                        8'd89:data_crc <=PLC4_status_reg[175:168];
                        8'd90:data_crc <=PLC4_status_reg[183:176];
                        8'd91:data_crc <=PLC4_status_reg[191:184];
                        8'd92:data_crc <=PLC4_status_reg[199:192];
                        8'd93:data_crc <=PLC4_status_reg[207:200];
                        8'd94:data_crc <=PLC4_status_reg[215:208];
                        8'd95:data_crc <=PLC4_status_reg[223:216];
                        8'd96:data_crc <=PLC4_status_reg[231:224];
                        8'd97:data_crc <=PLC4_status_reg[239:232];
                        8'd98:data_crc <=PLC4_status_reg[247:240];
                        8'd99:data_crc <=PLC4_status_reg[255:248];
                        8'd100:data_crc <=PLC5_status_reg[7:0];
                        8'd101:data_crc <=PLC5_status_reg[15:8];
                        8'd102:data_crc <=PLC5_status_reg[23:16];
                        8'd103:data_crc <=PLC5_status_reg[31:24];
                        8'd104:data_crc <=PLC5_status_reg[39:32];
                        8'd105:data_crc <=PLC5_status_reg[47:40];
                        8'd106:data_crc <=PLC5_status_reg[55:48];
                        8'd107:data_crc <=PLC5_status_reg[63:56];
                        8'd108:data_crc <=PLC5_status_reg[71:64];
                        8'd109:data_crc <=PLC5_status_reg[79:72];
                        8'd110:data_crc <=PLC5_status_reg[87:80];
                        8'd111:data_crc <=PLC5_status_reg[95:88];
                        8'd112:data_crc <=PLC5_status_reg[103:96];
                        8'd113:data_crc <=PLC5_status_reg[111:104];
                        8'd114:data_crc <=PLC5_status_reg[119:112];
                        8'd115:data_crc <=PLC5_status_reg[127:120];
                        8'd116:data_crc <=PLC5_status_reg[135:128];
                        8'd117:data_crc <=PLC5_status_reg[143:136];
                        8'd118:data_crc <=PLC5_status_reg[151:144];
                        8'd119:data_crc <=PLC5_status_reg[159:152];
                        8'd120:data_crc <=PLC5_status_reg[167:160];
                        8'd121:data_crc <=PLC5_status_reg[175:168];
                        8'd122:data_crc <=PLC5_status_reg[183:176];
                        8'd123:data_crc <=PLC5_status_reg[191:184];
                        8'd124:data_crc <=PLC5_status_reg[199:192];
                        8'd125:data_crc <=PLC5_status_reg[207:200];
                        8'd126:data_crc <=PLC5_status_reg[215:208];
                        8'd127:data_crc <=PLC5_status_reg[223:216];
                        8'd128:data_crc <=PLC5_status_reg[231:224];
                        8'd129:data_crc <=PLC5_status_reg[239:232];
                        8'd130:data_crc <=PLC5_status_reg[247:240];
                        8'd131:data_crc <=PLC5_status_reg[255:248];
                        8'd132:data_crc <=PLC6_status_reg[7:0];
                        8'd133:data_crc <=PLC6_status_reg[15:8];
                        8'd134:data_crc <=PLC6_status_reg[23:16];
                        8'd135:data_crc <=PLC6_status_reg[31:24];
                        8'd136:data_crc <=PLC6_status_reg[39:32];
                        8'd137:data_crc <=PLC6_status_reg[47:40];
                        8'd138:data_crc <=PLC6_status_reg[55:48];
                        8'd139:data_crc <=PLC6_status_reg[63:56];
                        8'd140:data_crc <=PLC6_status_reg[71:64];
                        8'd141:data_crc <=PLC6_status_reg[79:72];
                        8'd142:data_crc <=PLC6_status_reg[87:80];
                        8'd143:data_crc <=PLC6_status_reg[95:88];
                        8'd144:data_crc <=PLC6_status_reg[103:96];
                        8'd145:data_crc <=PLC6_status_reg[111:104];
                        8'd146:data_crc <=PLC6_status_reg[119:112];
                        8'd147:data_crc <=PLC6_status_reg[127:120];
                        8'd148:data_crc <=PLC6_status_reg[135:128];
                        8'd149:data_crc <=PLC6_status_reg[143:136];
                        8'd150:data_crc <=PLC6_status_reg[151:144];
                        8'd151:data_crc <=PLC6_status_reg[159:152];
                        8'd152:data_crc <=PLC6_status_reg[167:160];
                        8'd153:data_crc <=PLC6_status_reg[175:168];
                        8'd154:data_crc <=PLC6_status_reg[183:176];
                        8'd155:data_crc <=PLC6_status_reg[191:184];
                        8'd156:data_crc <=PLC6_status_reg[199:192];
                        8'd157:data_crc <=PLC6_status_reg[207:200];
                        8'd158:data_crc <=PLC6_status_reg[215:208];
                        8'd159:data_crc <=PLC6_status_reg[223:216];
                        8'd160:data_crc <=PLC6_status_reg[231:224];
                        8'd161:data_crc <=PLC6_status_reg[239:232];
                        8'd162:data_crc <=PLC6_status_reg[247:240];
                        8'd163:data_crc <=PLC6_status_reg[255:248];
                        8'd164:data_crc <=PLC7_status_reg[7:0];
                        8'd165:data_crc <=PLC7_status_reg[15:8];
                        8'd166:data_crc <=PLC7_status_reg[23:16];
                        8'd167:data_crc <=PLC7_status_reg[31:24];
                        8'd168:data_crc <=PLC7_status_reg[39:32];
                        8'd169:data_crc <=PLC7_status_reg[47:40];
                        8'd170:data_crc <=PLC7_status_reg[55:48];
                        8'd171:data_crc <=PLC7_status_reg[63:56];
                        8'd172:data_crc <=PLC7_status_reg[71:64];
                        8'd173:data_crc <=PLC7_status_reg[79:72];
                        8'd174:data_crc <=PLC7_status_reg[87:80];
                        8'd175:data_crc <=PLC7_status_reg[95:88];
                        8'd176:data_crc <=PLC7_status_reg[103:96];
                        8'd177:data_crc <=PLC7_status_reg[111:104];
                        8'd178:data_crc <=PLC7_status_reg[119:112];
                        8'd179:data_crc <=PLC7_status_reg[127:120];
                        8'd180:data_crc <=PLC7_status_reg[135:128];
                        8'd181:data_crc <=PLC7_status_reg[143:136];
                        8'd182:data_crc <=PLC7_status_reg[151:144];
                        8'd183:data_crc <=PLC7_status_reg[159:152];
                        8'd184:data_crc <=PLC7_status_reg[167:160];
                        8'd185:data_crc <=PLC7_status_reg[175:168];
                        8'd186:data_crc <=PLC7_status_reg[183:176];
                        8'd187:data_crc <=PLC7_status_reg[191:184];
                        8'd188:data_crc <=PLC7_status_reg[199:192];
                        8'd189:data_crc <=PLC7_status_reg[207:200];
                        8'd190:data_crc <=PLC7_status_reg[215:208];
                        8'd191:data_crc <=PLC7_status_reg[223:216];
                        8'd192:data_crc <=PLC7_status_reg[231:224];
                        8'd193:data_crc <=PLC7_status_reg[239:232];
                        8'd194:data_crc <=PLC7_status_reg[247:240];
                        8'd195:data_crc <=PLC7_status_reg[255:248];
                        8'd196:data_crc <=PLC8_status_reg[7:0];
                        8'd197:data_crc <=PLC8_status_reg[15:8];
                        8'd198:data_crc <=PLC8_status_reg[23:16];
                        8'd199:data_crc <=PLC8_status_reg[31:24];
                        8'd200:data_crc <=PLC8_status_reg[39:32];
                        8'd201:data_crc <=PLC8_status_reg[47:40];
                        8'd202:data_crc <=PLC8_status_reg[55:48];
                        8'd203:data_crc <=PLC8_status_reg[63:56];
                        8'd204:data_crc <=PLC8_status_reg[71:64];
                        8'd205:data_crc <=PLC8_status_reg[79:72];
                        8'd206:data_crc <=PLC8_status_reg[87:80];
                        8'd207:data_crc <=PLC8_status_reg[95:88];
                        8'd208:data_crc <=PLC8_status_reg[103:96];
                        8'd209:data_crc <=PLC8_status_reg[111:104];
                        8'd210:data_crc <=PLC8_status_reg[119:112];
                        8'd211:data_crc <=PLC8_status_reg[127:120];
                        8'd212:data_crc <=PLC8_status_reg[135:128];
                        8'd213:data_crc <=PLC8_status_reg[143:136];
                        8'd214:data_crc <=PLC8_status_reg[151:144];
                        8'd215:data_crc <=PLC8_status_reg[159:152];
                        8'd216:data_crc <=PLC8_status_reg[167:160];
                        8'd217:data_crc <=PLC8_status_reg[175:168];
                        8'd218:data_crc <=PLC8_status_reg[183:176];
                        8'd219:data_crc <=PLC8_status_reg[191:184];
                        8'd220:data_crc <=PLC8_status_reg[199:192];
                        8'd221:data_crc <=PLC8_status_reg[207:200];
                        8'd222:data_crc <=PLC8_status_reg[215:208];
                        8'd223:data_crc <=PLC8_status_reg[223:216];
                        8'd224:data_crc <=PLC8_status_reg[231:224];
                        8'd225:data_crc <=PLC8_status_reg[239:232];
                        8'd226:data_crc <=PLC8_status_reg[247:240];
                        8'd227:data_crc <=PLC8_status_reg[255:248]; 
                        default: data_crc <= 8'hff;  
                        endcase                    
                    end
                else if(data_rx_reg[2] == 'h03 && data_rx_reg[3] == 'he0)begin
                    case(cnt_crc)
                        8'd1 :data_crc <= 8'h01;
                        8'd2 :data_crc <= 8'h03;
                        8'd3 :data_crc <= 8'h0c;//协议里为0c，三字节
                        8'd4 :data_crc <= read100_reg[7:0];
                        8'd5 :data_crc <= read100_reg[15:8];
                        8'd6 :data_crc <= read100_reg[23:16];
                        8'd7 :data_crc <= read100_reg[31:24];
                        8'd8 :data_crc <= read101_reg[7:0];
                        8'd9 :data_crc <= read101_reg[15:8];
                        8'd10:data_crc <= read101_reg[23:16];
                        8'd11:data_crc <= read101_reg[31:24];
                        8'd12:data_crc <= read102_reg[7:0];
                        8'd13:data_crc <= read102_reg[15:8];
                        8'd14:data_crc <= read102_reg[23:16];
                        8'd15:data_crc <= read102_reg[31:24]; 
                        default: data_crc <= 8'hff;
                    endcase
                end
                else if(data_rx_reg[2] == 'h03 && data_rx_reg[3] == 'hf2)  begin
                    case(cnt_crc)
                        8'd1 :data_crc <= 8'h01;
                        8'd2 :data_crc <= 8'h03;
                        8'd3: data_crc <= 8'h04;
                        8'd4 :data_crc <= flt_num[7:0];
                        8'd5 :data_crc <= flt_num[15:8];
                        default: data_crc <= 8'hff;
                    endcase
                end
                else if(data_rx_reg[2] == 'h03 && data_rx_reg[3] == 'hf5)  begin
                    case(cnt_crc)
                        8'd1 :data_crc <= 8'h01;
                        8'd2 :data_crc <= 8'h03;
                        8'd3: data_crc <= 8'h04;
                        8'd4 :data_crc <= int_num[7:0];
                        8'd5 :data_crc <= int_num[15:8];
                        default: data_crc <= 8'hff;
                    endcase
                end
                else if (data_rx_reg[2] == 'h04 && data_rx_reg[3] == 'h10) begin
                    case(cnt_crc)
                        8'd1 :data_crc <= 8'h01;
                        8'd2 :data_crc <= 8'h03;
                        8'd3 :data_crc <= 8'h18;
                        8'd4 :data_crc <= avg_i_1_reg[7:0];
                        8'd5 :data_crc <= avg_i_1_reg[15:8];
                        8'd6 :data_crc <= avg_i_1_reg[23:16];
                        8'd7 :data_crc <= avg_i_1_reg[31:24];
                        8'd8 :data_crc <= avg_i_2_reg[7:0];
                        8'd9 :data_crc <= avg_i_2_reg[15:8];
                        8'd10:data_crc <= avg_i_2_reg[23:16];
                        8'd11:data_crc <= avg_i_2_reg[31:24];
                        8'd12:data_crc <= avg_i_3_reg[7:0];
                        8'd13:data_crc <= avg_i_3_reg[15:8];
                        8'd14:data_crc <= avg_i_3_reg[23:16];
                        8'd15:data_crc <= avg_i_3_reg[31:24];
                        8'd16:data_crc <= avg_i_4_reg[7:0];
                        8'd17:data_crc <= avg_i_4_reg[15:8];
                        8'd18:data_crc <= avg_i_4_reg[23:16];
                        8'd19:data_crc <= avg_i_4_reg[31:24];
                        8'd20:data_crc <= avg_i_5_reg[7:0];
                        8'd21:data_crc <= avg_i_5_reg[15:8];
                        8'd22:data_crc <= avg_i_5_reg[23:16];
                        8'd23:data_crc <= avg_i_5_reg[31:24];
                        8'd24:data_crc <= avg_i_6_reg[7:0];
                        8'd25:data_crc <= avg_i_6_reg[15:8];
                        8'd26:data_crc <= avg_i_6_reg[23:16];
                        8'd27:data_crc <= avg_i_6_reg[31:24];                     
                    endcase   
                end
                end
                rb_data_10:
                begin
                    case (cnt_crc)
                        4'd1:data_crc <= 8'h01;
                        4'd2:data_crc <= 8'h10;
                        4'd3:data_crc <= data_rx_reg[2];
                        4'd4:data_crc <= data_rx_reg[3];
                        4'd5:data_crc <= data_rx_reg[4];
                        4'd6:data_crc <= data_rx_reg[5];
                        default: data_crc <= 8'hff;
                    endcase
                end
                default: data_crc <= 8'hff;
            endcase
        end
    end
    
    always @ (posedge clk)
    begin
        case (next_state)
            para_rb:
            begin
                if (cnt_crc == 4'd7)//rb after 7 byte,comes to crc check
                begin
                    crc_reg <= crc_calcu;
                end
                else
                begin
                    crc_reg <= crc_reg;
                end
            end
            para_wr,cal_lenth:
            begin
                if (cnt_crc == 4'd8 + data_rx_reg[6])
                begin
                    crc_reg <= crc_calcu;
                end
                else
                begin
                    crc_reg <= crc_reg;
                end
            end
            rb_data_03:
            begin
                if (cnt_crc == data_lenth - 1)//change
                begin
                    crc_reg <= crc_calcu;
                end
                else
                begin
                    crc_reg <= crc_reg;
                end
            end
            rb_data_10:
            begin
                if (cnt_crc == 4'd7)
                begin
                    crc_reg <= crc_calcu;
                end
                else
                begin
                    crc_reg <= crc_reg;
                end
            end
            default: crc_reg <= crc_reg;
        endcase
    end
    
    always @ (posedge clk)
    begin
        if (next_state == rb_data_10)
        begin
            case ({data_rx_reg[2],data_rx_reg[3]})
                16'h000A:
                begin
                    if (data_rx_reg[8] == 8'h01)
                    begin
                        rs485_run <= 1'b1;
                    end
                    else
                    begin
                        rs485_stop <= 1'b1;
                    end
                end
                16'h000B:rs485_reset <= 1'b1;
                16'h000C:begin
                write06_rs485 <= {data_rx_reg[10],data_rx_reg[9],data_rx_reg[8],data_rx_reg[7]};
                write06_flash <= 1'b1;
                end
//                16'h12:kp_rs485 <= {data_rx_reg[7],data_rx_reg[8],data_rx_reg[9],data_rx_reg[10]};
//                16'h14:ki_rs485 <= {data_rx_reg[7],data_rx_reg[8],data_rx_reg[9],data_rx_reg[10]};
                default:;
            endcase
        end
        else if (next_state == idle)
        begin
            rs485_run <= 1'b0;
            rs485_stop <= 1'b0;
            rs485_reset <= 1'b0;
            write06_rs485 <= write06_rs485;
            write06_flash <= 1'b0;
//            kp_rs485 <= kp_rs485;
//            ki_rs485 <= ki_rs485;
        end
        else
        begin
            rs485_run <= rs485_run;
            rs485_stop <= rs485_stop;
            rs485_reset <= rs485_reset;
            write06_rs485 <= write06_rs485;
            write06_flash <= 1'b0;
//            kp_rs485 <= kp_rs485;
//            ki_rs485 <= ki_rs485;
        end
    end
    
    
//    always @ (posedge clk)
//    begin
//        if (next_state == rb_data_10)
//        begin
//            case (data_rx_reg[3])
//                8'h26:write06_flash <= 1'b1;
//                8'h12:kp_flash <= 1'b1;
//                8'h14:ki_flash <= 1'b1;
//                default:;
//            endcase
//        end
//        else
//        begin
//            write06_flash <= 1'b0;
//            kp_flash <= 1'b0;
//            ki_flash <= 1'b0;
//        end
//    end
    
    
    always @ (posedge clk or negedge rst)
    begin
        if (!rst)
        begin
            cnt_crc <= 9'd256;
        end
        else
        begin
            case (next_state)
                para_rb:
                begin
                    if (cnt_rx == 4'd4)//from the 4th byte,after function ,cnt_rx begim tocal
                    begin
                        cnt_crc <= 4'd0;
                    end
                    else if (cnt_rx == 4'd5)//from the 7th, crc low byte
                    begin
                        if (cnt_crc == 9'd256)//no more than 15?
                        begin
                            cnt_crc <= cnt_crc;
                        end
                        else 
                        begin
                            cnt_crc <= cnt_crc + 1'b1;//1 byte 1 clk
                        end
                    end
                    else
                    begin
                        cnt_crc <= 9'd256;
                    end
                end
                para_wr,cal_lenth:
                begin
                    if (cnt_rx == 4'd5 + data_rx_reg[6])
                    begin
                        cnt_crc <= 4'd0;
                    end
                    else if (cnt_rx == 4'd6 + data_rx_reg[6])
                    begin
                        if (cnt_crc == 9'd256)
                        begin
                            cnt_crc <= cnt_crc;
                        end
                        else 
                        begin
                            cnt_crc <= cnt_crc + 1'b1;
                        end
                    end
                    else
                    begin
                        cnt_crc <= 9'd256;
                    end
                end
                rb_data_03:
                begin
                    if (cnt_tx == 4'd3)
                    begin
                        cnt_crc <= 4'd0;
                    end
                    else if (cnt_tx == 4'd4)
                    begin
                        if (cnt_crc == 8'd251)
                        begin
                            cnt_crc <= cnt_crc;
                        end
                        else 
                        begin
                            cnt_crc <= cnt_crc + 1'b1;
                        end
                    end
                    else
                    begin
                        cnt_crc <= 8'd251;
                    end
                end
                rb_data_10:
                begin
                    if (cnt_tx == 4'd3)
                    begin
                        cnt_crc <= 4'd0;
                    end
                    else if (cnt_tx == 4'd4)
                    begin
                        if (cnt_crc == 9'd256)
                        begin
                            cnt_crc <= cnt_crc;
                        end
                        else 
                        begin
                            cnt_crc <= cnt_crc + 1'b1;
                        end
                    end
                    else
                    begin
                        cnt_crc <= 9'd256;
                    end
                end
                default:
                begin
                    cnt_crc <= 9'd256;
                end
            endcase
        end
    end
    
    always @ (posedge clk)
    begin
        if (next_state == rb_data_03)
        begin
            i_in_reg <= i_in_reg;
        end
        else
        begin
            i_in_reg <= i_in;
        end
    end
    
    always @ (posedge clk)
    begin
        if (next_state == rb_data_03)
        begin
            v_in_reg <= v_in_reg;
        end
        else
        begin
            v_in_reg <= v_in;
        end
    end
    
    always @ (posedge clk)
    begin
        if (next_state == rb_data_03)
        begin
            state_data_reg <= state_data_reg;
        end
        else
        begin
            state_data_reg <= state_data;
        end
    end
//新增部分2023.08.08
    always @ (posedge clk)
    begin
        if (next_state == rb_data_03)
        begin
            IP_reg <= IP_reg;
            netmask_reg <= netmask_reg;
            gateway_reg <= gateway_reg;
            type_reg <= type_reg;
        end
        else
        begin
            IP_reg <= IP;
            netmask_reg <= netmask;
            gateway_reg <= gateway;
            type_reg <= type;
        end
    end

    always @ (posedge clk)
    begin
        if (next_state == rb_data_03)
        begin
            PLC1_status_reg <= PLC1_status_reg ;
            PLC2_status_reg <= PLC2_status_reg ;
            PLC3_status_reg <= PLC3_status_reg ;
            PLC4_status_reg <= PLC4_status_reg ;
            PLC5_status_reg <= PLC5_status_reg ;
            PLC6_status_reg <= PLC6_status_reg ;
            PLC7_status_reg <= PLC7_status_reg ;
            PLC8_status_reg <= PLC8_status_reg ;
        end
        else
        begin
            PLC1_status_reg <=PLC1_status;
            PLC2_status_reg <=PLC2_status;
            PLC3_status_reg <=PLC3_status;
            PLC4_status_reg <=PLC4_status;
            PLC5_status_reg <=PLC5_status;
            PLC6_status_reg <=PLC6_status;
            PLC7_status_reg <=PLC7_status;
            PLC8_status_reg <=PLC8_status;
            
        end
    end

    always @ (posedge clk)
    begin
        if (next_state == rb_data_03)
        begin
           read100_reg <= read100_reg;
        end
        else
        begin
            read100_reg <= read100;
        end
    end
    always @ (posedge clk)
    begin
        if (next_state == rb_data_03)
        begin
           read101_reg <= read101_reg;
        end
        else
        begin
            read101_reg <= read101;
        end
    end    
    always @ (posedge clk)
    begin
        if (next_state == rb_data_03)
        begin
           read102_reg <= read102_reg;
        end
        else
        begin
            read102_reg <= read102;
        end
    end
    always @(posedge clk )
     begin
        if (next_state == rb_data_03)
        begin
            write00_reg <= write00_reg;
            write01_reg <= write01_reg;
            write02_reg <= write02_reg;
            write03_reg <= write03_reg;
            write04_reg <= write04_reg;
            write05_reg <= write05_reg;    
        end
        else begin
            write00_reg <= write00;
            write01_reg <= write01;
            write02_reg <= write02;
            write03_reg <= write03;
            write04_reg <= write04;
            write05_reg <= write05;           
        end
        
    end
    always @(posedge clk) begin
        if(next_state == rb_data_03)begin
           write07_reg <= write07_reg;
           write08_reg <= write08_reg;
           write09_reg <= write09_reg;
           write06_reg <= write06_reg; 
        end
        else begin
           write07_reg <= write07;
           write08_reg <= write08;
           write09_reg <= write09;
           write06_reg <= write06; 
        end
        
    end

    always @(posedge clk) begin
        if(next_state == rb_data_03)begin
            avg_i_1_reg <= avg_i_1_reg;
            avg_i_2_reg <= avg_i_2_reg;
            avg_i_3_reg <= avg_i_3_reg;
            avg_i_4_reg <= avg_i_4_reg;
            avg_i_5_reg <= avg_i_5_reg;
            avg_i_6_reg <= avg_i_6_reg;
        end
        else begin
            avg_i_1_reg <=  avg_i_1 ;
            avg_i_2_reg <=  avg_i_2 ;
            avg_i_3_reg <=  avg_i_3 ;
            avg_i_4_reg <=  avg_i_4 ;
            avg_i_5_reg <=  avg_i_5 ;
            avg_i_6_reg <=  avg_i_6 ;
        end
        

        
    end
    
    
//    ila_0 your_instance_name (
//	.clk(clk), // input wire clk


//	.probe0(rs485_stop), // input wire [15:0]  probe0  
//	.probe1(rs485_reset), // input wire [15:0]  probe1 
//	.probe2(write06_rs485), // input wire [31:0]  probe2 
//	.probe3(write06_flash), // input wire [0:0]  probe3 
//	.probe4(v_in_reg), // input wire [31:0]  probe4 
//	.probe5(i_in_reg), // input wire [31:0]  probe5 
//	.probe6(state_data_reg) // input wire [31:0]  probe6
//);
    
endmodule
