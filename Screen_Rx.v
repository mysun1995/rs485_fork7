
module Screen_Rx
	(
	clk_29491200Hz,
	rx_in,
	data_out,
	rx_finish//1 is flash
	);
	
input			clk_29491200Hz;
input			rx_in;		
output[10:0]	data_out;
output			rx_finish;	

reg[15:0] clk_counter =0;	
//initial clk_counter = 8'b0000;
always@(posedge clk_29491200Hz)
begin
	if(!rx_finish)	clk_counter <= (clk_counter == 16'd245)?8'h0:(clk_counter +1'b1);	
	else			clk_counter <= 16'd0;											
end

reg[3:0] bps_counter = 0;	

always@(posedge clk_29491200Hz)
begin
	if(clk_counter == 16'd245)	bps_counter <= (bps_counter == 4'b1010)?4'b1010:(bps_counter +1'b1);	
	else if(rx_finish)		bps_counter <= 4'b0000;													
	else					bps_counter <= bps_counter;
end

reg rx_finish = 1;	

always@(posedge clk_29491200Hz)
begin
	if((!rx_in) && rx_finish)									rx_finish <= 1'b0;	
	else if((bps_counter == 4'b1010) && (clk_counter == 16'd245))	rx_finish <= 1'b1;
	else														rx_finish <= rx_finish;
end

reg data_reg1 = 0;	

always@(posedge clk_29491200Hz)
begin
	data_reg1 <= (clk_counter == 16'd46)?rx_in:data_reg1;	
end

reg data_reg2 = 0;	
//initial data_reg2 = 1'b0;
always@(posedge clk_29491200Hz)
begin
	data_reg2 <= (clk_counter == 16'd109)?rx_in:data_reg2;	
end

reg data_reg3 = 0;
//initial data_reg3 = 1'b0;	//第三眼瞅见的
always@(posedge clk_29491200Hz)
begin
	data_reg3 <= (clk_counter == 16'd172)?rx_in:data_reg3;	
end

reg data_reg =0;	
//initial data_reg =1'b0;
always@(posedge clk_29491200Hz)
begin
	data_reg <= (clk_counter == 16'd203)?((data_reg1 && data_reg2) || (data_reg3 && data_reg2) || (data_reg1 && data_reg3)):data_reg;	//计数�?10的时候想想，瞅了三眼，如果有至少两眼瞅见1就认为是1，如果至少两眼瞅�?0就认为是0
end

reg[10:0] data_out_reg = 11'h000;	
//initial data_out_reg = 11'h000;
always@(posedge clk_29491200Hz)
begin
	data_out_reg <= (clk_counter == 16'd220)?{data_reg,data_out_reg[10:1]}:data_out_reg;	
end
//-----------------------------------------------------------
reg[10:0] data_out_temp = 11'h000;
//initial data_out = 11'h000;
always@(posedge rx_finish)
begin
	data_out_temp <= (rx_finish)?data_out_reg:data_out_temp;	
end

wire [7:0]data_out;
assign data_out = data_out_temp[8:1];





endmodule




