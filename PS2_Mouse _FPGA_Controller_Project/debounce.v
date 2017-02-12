`timescale 1ns / 1ps

module debounce
	(
		input wire clk, reset,
		input wire sw,
		output reg db_level, db_tick
    );

	// symbolic state declaration
	localparam [1:0]
		zero  = 2'b00,
		wait0 = 2'b01,
		one   = 2'b10,
		wait1 = 2'b11;
		
	// number of counter bits (2^N*10ns = 40ms)
	localparam N = 22;
	
	// signal declaration
	reg [N-1:0] q_reg, q_next;
	reg [1:0] state_reg, state_next;
	
	// body
	// fsmd state & data registers
	always @(posedge clk, posedge reset)
		if(reset)
			begin
				state_reg <= zero;
				q_reg     <= 0;
			end
		else
			begin
				state_reg <= state_next;
				q_reg     <= q_next;
			end
	
	// next-state logic & data path functional units/ routines
	always @*
		begin
			state_next = state_reg;		// default state : 
			q_next     = q_reg;			// default q:
			db_tick    = 1'b0;			// default output: 0
			case(state_reg)
				zero:
					begin
						db_level = 1'b0;
						if(sw)
							begin
								state_next = wait1;
								q_next = {N{1'b1}}; // load 1...1
							end
					end
				wait1:
					begin
						db_level = 1'b0;
						if(sw)
							begin
								q_next = q_reg -1;
								if(q_next == 0)
									begin
										state_next = one;
										db_tick = 1'b1;
									end
							end
						else
							state_next = zero; // sw ==0
					end
				one:
					begin
						db_level = 1'b1;
						if(~sw)
							begin
								state_next = wait0;
								q_next = {N{1'b1}}; // load 1..1
							end
					end
				wait0:
					begin
						db_level = 1'b1;
						if(~sw)
							begin
								q_next = q_reg - 1;
								if(q_next == 0)
									state_next = zero;
							end
						else 
							state_next = one; // sw == 1
					end
				default: state_next = zero;
			endcase
		end

endmodule
