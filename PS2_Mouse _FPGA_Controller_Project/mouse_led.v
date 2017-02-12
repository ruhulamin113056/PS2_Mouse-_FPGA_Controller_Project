`timescale 1ns / 1ps

module mouse_led
	(
		input wire clk, reset,
		inout wire ps2d, ps2c,
		output reg [7:0] Led
    );

	// signal declaration
	reg [9:0] p_reg;
	wire [9:0] p_next;
	wire [8:0] xm;
	wire [2:0] btnm;
	wire m_done_tick;
	
	// body
	// instantiation
	mouse mouse_unit
		(.clk(clk), .reset(reset), .ps2d(ps2d), .ps2c(ps2c),
		 .xm(xm), .ym(ym), .btnm(btnm));
		 
	// counter
	always @(posedge clk, posedge reset)
		if(reset)
			p_reg <= 0;
		else 
			p_reg <= p_next;
	assign p_next = (~m_done_tick) ? p_reg : // no activity
						 (btnm[0]) ? 10'b0 : // left button
						 (btnm[1]) ? 10'h3ff: // right button
						 p_reg + {xm[8], xm}; // x movement
						 
   always @*
		case (p_reg[9:7])
			3'b000: Led = 8'b10000000;
			3'b001: Led = 8'b01000000;
			3'b010: Led = 8'b00100000;
			3'b011: Led = 8'b00010000;
			3'b100: Led = 8'b00001000;
			3'b101: Led = 8'b00000100;
			3'b110: Led = 8'b00000010;
			default: Led = 8'b10000001;
		endcase
		
endmodule
