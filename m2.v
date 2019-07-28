module pic_display 	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	

	wire reset_n, enable, q;
	reg [2:0] colour;
	reg [7:0] x, y;



     	reg x_direction, y_direction;
	
	//for x address
	always@(posedge CLOCK_50)
	begin
		if(reset_n == 1'b0)
			x_direction <= 1'b1;
		else
		begin
			if(x_direction == 1'b1)
			begin
				if(x + 1 > 8'b10100000)
					x_direction <= 1'b0;
				else
					x_direction <= 1'b1;
			   end
			else
			begin
				if(x == 8'b00000000)
					x_direction <= 1'b1;
				else
					x_direction <= 1'b0;
			end
		end
	end
	
	always@(posedge CLOCK_50, negedge reset_n)begin
	   if(reset_n == 1'b0)begin
			x <= 8'b00000000;
		end
		else if(x_direction == 1'b1)
				x <= x + 1'b1;
		else
				x <= x - 1'b1;
		end


	//for y address
	always@(posedge CLOCK_50, negedge reset_n)begin
	   if(reset_n == 1'b0)begin
			y <= 60;
		end
		else if(y_direction == 1'b1)
				y <= y + 1'b1;
		else
				y <= y - 1'b1;
		end
		
	always@(posedge CLOCK_50)
	begin
		if(reset_n == 1'b0)
			y_direction <= 1'b0;
		else	

			begin
				if(y_in + 1 > 8'0111000)
					y_direction <= 1'b0;
				else
					y_direction <= 1'b1;
			   end
			else
			begin
				if(y_in == 8'b00000000)
					y_direction <= 1'b1;
				else
					y_direction <= 1'b0;
			end
		end
	end


	//
	wire addr;
	vga_address_translator t1(x, y, addr)
	defparam t1.RESOLUTION = "160x120";


	pic p_0(       //Rom file
	address(addr),
	clock(VGA_CLK),
	q(q));
	
	

	assign reset_n = KEY[0];
	assign enable = SW[9];
	always @(posedge VGA_CLK or negedge reset_n)
	begin
		if (!reset_n)
			colour <= 3'b000 

		else if (enable == 1)
			case (q)
				1'b1: begin
					colour <= 3'b111;
				1'b0: begin
					colour <= 3'b000; 
			endcase
		else
			colour <= 3'b000 


	end


	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(1),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "TRUE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
endmodule



/*
module delay_counter(clock,reset_n,enable,enable_fc);
		input clock;
		input reset_n;
		input enable;
		output enable_fc;
		reg [19:0] q;
		
		always @(posedge clock)
		begin
			if(reset_n == 1'b0)
				q <= 833334;
			else if(enable ==1'b1)
			begin
			   if ( q == 20'd0 )
					q <= 833334;
				else
					q <= q - 1'b1;
			end
		end
		
		assign enable_fc = (q ==  20'd0) ? 1 : 0;
endmodule


module frame_counter(clock,reset_n,enable,enable_xy,colour_1,colour);
	input clock,reset_n,enable;
	input [2:0]colour;
	output  enable_xy;
	output [2:0]colour_1;
	reg [3:0]q;
	
	always @(posedge clock)
	begin
		if(reset_n == 1'b0)
			q <= 4'b0000;
		else if(enable == 1'b1)
		begin
		  if(q == 4'b1111)
			  q <= 4'b0000;
		  else
			  q <= q + 1'b1; 
		end
   end
	
	// change coordinate every 15 frame, by enabling x_counter and y_counter.
	assign enable_xy = (q == 4'b1111) ? 1 : 0;  // count 15 frames. 
	assign colour_1 = (q == 4'b1111) ? 3'b000 : colour;
endmodule



module x_counter(x_in,clock,reset_n,enable,x_out);
	input clock,enable,reset_n;
	input [7:0] x_in;
	output reg[7:0] x_out;
	reg direction;
	
	always@(posedge clock)
	begin
		if(reset_n == 1'b0)
			direction <= 1'b1;
		else
		begin
			if(direction == 1'b1)
			begin
				if(x_in + 1 > 8'b10100000)
					direction <= 1'b0;
				else
					direction <= 1'b1;
			   end
			else
			begin
				if(x_in == 8'b00000000)
					direction <= 1'b1;
				else
					direction <= 1'b0;
			end
		end
	end
	
	always@(negedge enable, negedge reset_n)begin
	   if(reset_n == 1'b0)begin
			x_out <= 8'b00000000;
		end
		else if(direction == 1'b1)
				x_out <= x_out + 1'b1;
		else
				x_out <= x_out - 1'b1;
		end
endmodule


module y_counter(y_in,clock,reset_n,enable,y_out);
	input clock,enable,reset_n;
	input [7:0] y_in;
	output reg[7:0] y_out;
	reg direction;
	
	always@(negedge enable, negedge reset_n)begin
	   if(reset_n == 1'b0)begin
			y_out <= 60;
		end
		else if(direction == 1'b1)
				y_out <= y_out + 1'b1;
		else
				y_out <= y_out - 1'b1;
		end
		
	always@(posedge clock)
	begin
		if(reset_n == 1'b0)
			direction <= 1'b0;
		else	
		begin
			if(direction == 1'b1)
			begin
				if(y_in + 1 > 8'1111000)
					direction <= 1'b0;
				else
					direction <= 1'b1;
			   end
			else
			begin
				if(y_in == 8'b00000000)
					direction <= 1'b1;
				else
					direction <= 1'b0;
			end
		end
	end
endmodule
*/
