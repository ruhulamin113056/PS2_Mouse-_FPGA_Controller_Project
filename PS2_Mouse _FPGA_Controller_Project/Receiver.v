`timescale 1ns / 1ps

module Receiver
	#(
		parameter DBIT = 8,   // # data bits
					 SB_TICK = 16 // # ticks for stop bits
	 )
	 (
		input wire clk, reset,
		input wire rx, s_tick, // sampling tick from baud rate generator
		output reg rx_done_tick, // status signal indicates recieving process is complete
		output wire [7:0] dout
    );

	// symbolic state declaration
	localparam [1:0]
		idle  = 2'b00,
		start = 2'b01,
		data  = 2'b10,
		stop  = 2'b11;
		
	// signal declaration
	reg [1:0] state_reg, state_next; //-------------
	reg [3:0] s_reg, s_next;  // sampling tick counter register
	reg [2:0] n_reg, n_next;  // number of data bit counter register
	reg [7:0] b_reg, b_next;  // shifted bits register
	
	// body
	// FSMD state & data registers
	always @ (posedge clk, posedge reset)
		if(reset)
			begin
				state_reg <= idle;
				s_reg <= 0;
				n_reg <= 0;
				b_reg <= 0;
			end
		else
			begin
				state_reg <= state_next;
				s_reg <= s_next;
				n_reg <= n_next;
				b_reg <= b_next;
			end
			
	// FSMD next-state logic
	always @*
		begin
			state_next = state_reg;
			rx_done_tick = 1'b0;
			s_next = s_reg;
			n_next = n_reg;
			b_next = b_reg;
			case(state_reg)
				idle:
					if(~rx)
						begin
							state_next = start;
							s_next = 0;
						end
				start:    //------------------------ processing of start bit ---------------
					if(s_tick)
						if(s_reg==7)   // sampling tick counter register counts upto 7
							begin
								state_next = data;
								s_next = 0;
								n_next = 0;
							end
						else
							s_next = s_reg + 1;
				data:     //------------------------ processing of data bits ---------------
					if(s_tick)
						if(s_reg==15)   // sampling tick counter register counts upto 15
							begin
								s_next = 0;
								b_next = {rx,b_reg[7:1]};// The retrieved bits are shifted into and reassembled in the bits register
								if(n_reg==(DBIT-1))      // number of data bit counter register counts bits received
									state_next = stop;
								else
									n_next = n_reg + 1;
							end
						else
							s_next = s_reg + 1;
				stop:     //------------------------ processing of stop bit ---------------
					if(s_tick)
						if(s_reg==(SB_TICK-1)) // sampling tick counter register counts upto SB_TICK-1 = 15
							begin
								state_next = idle;
								rx_done_tick = 1'b1;
							end
						else
							s_next = s_reg + 1; 
			endcase
		end
		// output 
		assign dout = b_reg;
		
endmodule
