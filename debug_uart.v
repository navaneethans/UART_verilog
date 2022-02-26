`timescale 1ns / 1ps

//--------------------------------------------------------------------//
// MimasV2 UART RTL Sample Code
// Numato Lab
// http://www.numato.com
// http://www.numato.cc
// License : CC BY-SA (http:-creativecommons.org/licenses/by-sa/2.0/)
//--------------------------------------------------------------------//module debug_signal(      
module debug_uart(      
	input  [63:0]debug_data,
	output [63:0]debug_set,
	output reg [7:0]data,
	input   clk,
	output  tx,
	input   rx
	);

	
	 
    reg  [7:0] data_in  ;   
    wire [7:0] data_out ;    
    wire       full     ;
    wire       empty    ;
    // Signals for UART submodule 
    wire       rd_uart = ~empty ;
	reg        wr_uart ;
	
	reg [63:0]data_reg;
	reg [2:0]cnt;
	reg reset=1;
	
	assign debug_set = data_reg;
	
	always@(posedge clk) 
		if(reset)
			reset <= 0;
		else
			reset <= 0;
	 always@(posedge clk)
		 if(reset)
			data <= 0; 
		 else if(~empty)
			data <= data_out;	
	
    always@(posedge clk)
		if(reset) begin 
			data_reg <= 0; 
			wr_uart <= 0;
		end 
		else if(~full) begin 
			if(cnt == 0)
				data_reg <= debug_data;
			else 
				data_reg <= debug_set;
			if((data_reg == debug_data)&&(cnt == 0))
				wr_uart  <= 0;
			else 
				wr_uart  <= 1;
		end 
		else begin 
			//data_reg <= 0; 
			wr_uart <= 0;
		end 
		
	always@(posedge clk)
		if(reset) begin 
			cnt		<= 0;
		end 
		else if(~full & wr_uart) begin 
			cnt		 <= cnt + 1'b1;
		end 

	
	always@(cnt)
		case(cnt)
			0 : data_in <= data_reg[63:56];//7:0
			1 : data_in <= data_reg[55:48];//15:8
			2 : data_in <= data_reg[47:40];//23:16
			3 : data_in <= data_reg[39:32];//31:24
			4 : data_in <= data_reg[31:24];//39:32
			5 : data_in <= data_reg[23:16];//47:40
			6 : data_in <= data_reg[15:8];//55:48
			7 : data_in <= data_reg[7:0];//63:56
			default : data_in <= 0;
		endcase
	
	//assign rx = tx;
	
	
	
    // Instantiation of uart module
    // DIVISOR = 326 for 19200 baudrate, 100MHz sys clock
	// DIVISOR = 81 for 19200 baudrate, 25MHz sys clock
	// DIVISOR = 54 for 115200 baudrate, 100MHz sys clock
	// DIVISOR = 13 for 115200 baudrate, 25MHz sys clock
	
    uart #(     .DIVISOR		(9'd81),  //divider circuit = clk/(16*baud rate) 
                .DVSR_BIT		(4'd9)	, // # bits of divider circuit
                .Data_Bits		(4'd8)	,
                .FIFO_Add_Bit	(3'd3)
    ) uart (    .clk			(clk),
                .rd_uart		(rd_uart)	,
                .reset			(reset)		,	
                .rx				(rx)		,
                .w_data			(data_in)	,
                .wr_uart		(wr_uart)	,
                .r_data			(data_out)	,
                .rx_empty		(empty)		,
                .tx				(tx)		,
                .tx_full		(full)
           );             
endmodule
