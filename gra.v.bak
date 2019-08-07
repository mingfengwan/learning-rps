module gra(SW, KEY,CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, 
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B);
	input [9:0] SW; // SW[9] is load
	input [3:0] KEY; // KEY[0] is reset
	input CLOCK_50;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output [9:0] LEDR;//LEDR[0] = 1, means player wins this game, LEDR[1] = 1, means computer wins this game. LEDR[2] = 1 means a draw


	wire start;


	
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	
	assign user = SW[1:0]; // 00 is rock, 01 is scissor, 10 is paper
	assign start = KEY[1]; 
	
	screen_display u0 (
		.CLOCK_50(CLOCK_50),						
		.reset_n(start),
		//.player(0),
		.choice(user),
		.VGA_CLK(VGA_CLK),   						
		.VGA_HS(VGA_HS),							
		.VGA_VS(VGA_VS),							
		.VGA_BLANK_N(VGA_BLANK_N),						
		.VGA_SYNC_N(VGA_SYNC_N),						
		.VGA_R(VGA_R),   						
		.VGA_G(VGA_G),	 						
		.VGA_B(VGA_B)   						
	);
		
	assign LEDR[0] = 1'b1;
endmodule



module screen_display	
	(
		CLOCK_50,						//	On Board 50 MHz
		reset_n,
		//player,
		choice,
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
	//input   [9:0]   SW;
	//input   [3:0]   KEY;
	input reset_n;
	//assign reset_n = KEY[0];
	//input player; // 0 for user,1 for computer
	input [1:0] choice; // 00 is rock, 01 is scissor, 10 is paper
	//assign choice = SW[1:0];

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
	
	

	wire reset_n, enable;
   wire	q_s, q_r, q_p;
	reg q;
	
	
	reg [2:0] colour;
	reg [7:0] x = 8'b0;
	reg [6:0] y = 7'b0;
	reg writeEn = 1'b1;


	
	always@(posedge CLOCK_50, negedge reset_n)

	begin
		if(reset_n == 1'b0)
			begin
			x <= 8'b0;
			y <= 7'b0;
			writeEn <= 1'b1;
			end

		else
		begin
			if(x + 1 > 8'b10100000) begin
				x <= 1'b0;
				y <= y + 1'b1;
			end
			else
				x <= x + 1'b1;
			if (y + 1 > 7'b1111000)
				writeEn <= 1'b0;

		end	
	end
	
	always @(*) begin
		if (choice == 2'b00) // choice is rock
				q = q_r;
		else if (choice == 2'b01) // choice is scissor
				q = q_s;
		else //choice is paper
				q = q_p;
	end
	

	
	wire [14:0] addr;
	vga_address_translator t1(x, y, addr);
	defparam t1.RESOLUTION = "160x120";

	
	
	//rom module to store scissor.mif
	scissor s0(
	.address(addr),
	.clock(CLOCK_50),
	.q(q_s));
	
	//rom module to store paper.mif
	paper p0(
	.address(addr),
	.clock(CLOCK_50),
	.q(q_p));
	//rom module to store rock.mif
	rock r0 (
	.address(addr),
	.clock(CLOCK_50),
	.q(q_r));
	
	
	//always @(posedge VGA_CLK or negedge reset_n)
	always @(posedge VGA_CLK or negedge reset_n)
	begin
		if (!reset_n)
			colour <= 3'b000;
		else begin
			case (q)
				1'b1: begin
					//if (player == 0) //user's choice, background is black
						//colour <= 3'b000;
					//else
					colour <= 3'b111; //computer's choice, background is white
				end
				1'b0: begin
					colour <= 3'b010;
				end
			endcase
		end
	

	end


	vga_adapter VGA(
			.resetn(reset_n),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
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
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
endmodule




/*

module gra
	(
		CLOCK_50,						//	On Board 50 MHz
		//reset_n,
		//player,
		//choice,
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
	//input reset_n;
	wire player;
	assign player = SW[9]; // 0 for user,1 for computer
	wire [1:0] choice; // 001 is rock, 010 is scissor, 100 is paper
	assign choice = SW[1:0];

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
	
	

	wire reset_n;
   wire	q_s, q_r, q_p;
	reg q;
	
	assign reset_n = KEY[0];
	reg [2:0] colour;
	reg [7:0] x = 8'b0;
	reg [6:0] y = 7'b0;
	reg writeEn = 1'b1;


	

	always@(posedge CLOCK_50, negedge reset_n)
	begin
		if(reset_n == 1'b0)
			begin
			x <= 8'b0;
			y <= 7'b0;
			writeEn <= 1'b1;
			end

		else
		begin
			if(x + 1 > 8'b10100000) begin
				x <= 1'b0;
				y <= y + 1'b1;
			end
			else
				x <= x + 1'b1;
			if (y + 1 > 7'b1111000)
				writeEn <= 1'b0;

		end	
		
			 
			
	end
	always @(*) begin
		if (choice == 2'b00) // choice is rock
				q = q_r;
		else if (choice == 2'b01) // choice is scissor
				q = q_s;
		else //choice is paper
				q = q_p;
	end
	

	
	wire [14:0] addr;
	vga_address_translator t1(x, y, addr);
	defparam t1.RESOLUTION = "160x120";


	
	
	//rom module to store scissor.mif
	scissor s0(
	.address(addr),
	.clock(CLOCK_50),
	.q(q_s));
	
	//rom module to store paper.mif
	paper p0(
	.address(addr),
	.clock(CLOCK_50),
	.q(q_p));
	//rom module to store rock.mif
	rock r0 (
	.address(addr),
	.clock(CLOCK_50),
	.q(q_r));
	
	
	//always @(posedge VGA_CLK or negedge reset_n)
	always @(posedge VGA_CLK or negedge reset_n)
	begin
		if (!reset_n)
			colour <= 3'b000;
		else begin
			case (q)
				1'b1: begin
					if (player == 0) //user's choice, background is black
						colour <= 3'b000;
					else
						colour <= 3'b111; //computer's choice, background is white
				end
				1'b0: begin
					colour <= 3'b010;
				end
			endcase
		end
	

	end


	vga_adapter VGA(
			.resetn(reset_n),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
endmodule 
*/




