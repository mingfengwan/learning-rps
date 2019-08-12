module m3
	(
		CLOCK_50,						//	On Board 50 MHz
		//reset_n,
		//player,
		//choice,
		// Your inputs and outputs here
		//colour
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
		VGA_B,   						//	VGA Blue[9:0]
		HEX0, HEX1, LEDR
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;
	//input reset_n;
   wire reset_n;
	assign reset_n = KEY[0];
	//input [2:0] colour
	//input player;
	//assign player = SW[9]; // 0 for user,1 for computer
	
	
	//input [3:0] choice; // 00 is rock, 01 is scissor, 10 is paper; 3-2 is computer,1-0 is use
	wire [3:0] choice; 
	assign choice = SW[3:0];
	wire [1:0] choice_c, choice_u;
	assign choice_c = choice[3:2];
	assign choice_u = choice[1:0];

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
	
	output [6:0] HEX0, HEX1;
	output [9:0] LEDR;
	


   wire	q_s, q_r, q_p;
	reg q;
	
	
	reg [2:0] colour;
	
	reg [7:0] x_c;
	reg [6:0] y_c;
	reg En_c;
	reg [7:0] x_u;
	reg [6:0] y_u;
	reg En_u;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	//assign writeEn = (En_c || En_u); 
	assign x = En_c ? x_c : x_u;
	assign y = En_c ? y_c : y_u;
	assign writeEn = (En_c | En_u);
	
	reg [1:0] curr_draw;
	assign LEDR[0] = writeEn;
	assign LEDR[1] = En_c;
	assign LEDR[2] = En_u;
	
	hex_decoder h3(
	   .hex_num({2'b00, choice_u}),
	   .seg(HEX0) 
			);

	//computer's score
	hex_decoder h4(
	   .hex_num({2'b00, choice_c}),
	   .seg(HEX1) 
			);

	

	always@(posedge CLOCK_50, negedge reset_n)
	begin
		if(reset_n == 1'b0)
			begin
			x_c <= 8'b0;
			x_u <= 8'b01010000;
			y_c <= 7'b0;
			y_u <= 7'b0;
			En_c <= 1'b1;
			En_u <= 1'b0;
			curr_draw <= choice_c;
			//x <= x_c;
			//y <= y_c;
			end

		else
		begin
			if(x_c > 8'b01010000 || x_c == 8'b01010000) begin
				x_c <= 8'b0;
				if (y_c > 7'b1111000 || y_c == 7'b1111000) begin
					x_c <= 8'b01010000;
					y_c <= 7'b1111000;
					En_c <= 1'b0;
					En_u <= 1'b1;
					curr_draw <= choice_u;
					//x <= x_u;
					//y <= y_u;
				end
				
				else
					y_c <= y_c + 1'b1;
			end
			else 
				x_c <= x_c + 1'b1;
			if (x_c  < 8'b01010000 && y_c < 7'b1111000)
				En_c <= 1'b1;
			else
				En_c <= 1'b0;
			
	
			if (En_u == 1'b'1) begin
				if(x_u > 8'b10100000 || x_u == 8'b10100000) begin
						x_u <= 8'b01010000;
						if (y_u > 7'b1111000 || y_u == 7'b1111000) begin
							x_u <= 8'b10100000;
							y_c <= 7'b1111000;
							En_u <= 1'b0;
						end
						else
							y_u <= y_u + 1'b1;
				end
			
				else
					x_u <= x_u + 1'b1;
			end
			if ((x_c > 8'b01010000 || x_c == 8'b01010000)  && (y_u < 7'b1111000))
				En_u <= 1'b1;
			else
				En_u <= 1'b0;
		end	
		
			 
			
	end
	always @(*) begin
		if (curr_draw == 2'b00) // choice is rock
				q = q_r;
		else if (curr_draw == 2'b01) // choice is scissor
				q = q_s;
		else //choice is paper
				q = q_p;
	end
	

	
	wire [14:0] addr;
	image_translator t1(x, y, addr);
	defparam t1.RESOLUTION = "160x120";


	
	
	//rom module to store scissor.mif
	new_scissor s0(
	.address(addr),
	.clock(CLOCK_50),
	.q(q_s));
	
	//rom module to store paper.mif
	new_paper p0(
	.address(addr),
	.clock(CLOCK_50),
	.q(q_p));
	//rom module to store rock.mif
	new_rock r0 (
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
					if (En_u == 1'b1) //user's choice, background is black
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


/* This module converts a user specified coordinates into a memory address.
 * The output of the module depends on the resolution set by the user.
 */
module image_translator(x, y, mem_address);

	parameter RESOLUTION = "320x240";
	/* Set this parameter to "160x120" or "320x240". It will cause the VGA adapter to draw each dot on
	 * the screen by using a block of 4x4 pixels ("160x120" resolution) or 2x2 pixels ("320x240" resolution).
	 * It effectively reduces the screen resolution to an integer fraction of 640x480. It was necessary
	 * to reduce the resolution for the Video Memory to fit within the on-chip memory limits.
	 */

	input [((RESOLUTION == "320x240") ? (8) : (7)):0] x; 
	input [((RESOLUTION == "320x240") ? (7) : (6)):0] y;	
	output reg [((RESOLUTION == "320x240") ? (16) : (14)):0] mem_address;
	
	/* The basic formula is address = y*WIDTH + x;
	 * For 320x240 resolution we can write 320 as (256 + 64). Memory address becomes
	 * (y*256) + (y*64) + x;
	 * This simplifies multiplication a simple shift and add operation.
	 * A leading 0 bit is added to each operand to ensure that they are treated as unsigned
	 * inputs. By default the use a '+' operator will generate a signed adder.
	 * Similarly, for 160x120 resolution we write 160 as 128+32.
	 */
	wire [16:0] res_320x240 = ({1'b0, y, 8'd0} + {1'b0, y, 6'd0} + {1'b0, x});
	//wire [15:0] res_160x120 = ({1'b0, y, 7'd0} + {1'b0, y, 5'd0} + {1'b0, x});
	wire [15:0] res_160x120 = ({2'b0, y, 6'd0} + {2'b0, y, 4'd0} + {1'b0, x});
	
	always @(*)
	begin
		if (RESOLUTION == "320x240")
			mem_address = res_320x240;
		else
			mem_address = res_160x120[14:0];
	end
endmodule


module hex_decoder(hex_num, seg);
    input [3:0] hex_num;
    output reg [6:0] seg;
   
    always @(*)
        case (hex_num)
            4'h0: seg = 7'b100_0000;
            4'h1: seg = 7'b111_1001;
            4'h2: seg = 7'b010_0100;
            4'h3: seg = 7'b011_0000;
            4'h4: seg = 7'b001_1001;
            4'h5: seg = 7'b001_0010;
            4'h6: seg = 7'b000_0010;
            4'h7: seg = 7'b111_1000;
            4'h8: seg = 7'b000_0000;
            4'h9: seg = 7'b001_1000;
            4'hA: seg = 7'b000_1000;
            4'hB: seg = 7'b000_0011;
            4'hC: seg = 7'b100_0110;
            4'hD: seg = 7'b010_0001;
            4'hE: seg = 7'b000_0110;
            4'hF: seg = 7'b000_1110;   
            default: seg = 7'h7f;
        endcase
endmodule








/*module gra
	(
		CLOCK_50,						//	On Board 50 MHz
		//reset_n,
		//player,
		//choice,
		// Your inputs and outputs here
		//colour
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
	//input [2:0] colour
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
	
	reg [7:0] x_c;
	reg [6:0] y_c;
	reg writeEn_u;
	reg [7:0] x_u;
	reg [6:0] y_u;
	reg writeEn_c;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	assign x = player ? x_c : x_u;
	assign y = player ? y_c : y_u;
	assign writeEn = player ? writeEn_c : writeEn_u;


	

	always@(posedge CLOCK_50, negedge reset_n)
	begin
		if(reset_n == 1'b0)
			begin
			x_c <= 8'b0;
			x_u <= 8'b01010000;
			y_c <= 7'b0;
			y_u <= 7'b0;
			writeEn_c <= 1'b1;
			writeEn_u <= 1'b1;
			end

		else
		begin
			if(x_u > 8'b10100000 || x_u == 8'b10100000) begin
				x_u <= 8'b01010000;
				if (y_u > 7'b1111000 || y_u == 7'b1111000)
					writeEn_u <= 1'b0;
				else
					y_u <= y_u + 1'b1;
			end
			else
				x_u <= x_u + 1'b1;
			if (x_u  < 8'b10100000 && y_u < 7'b1111000)
				writeEn_u <= 1'b1;
			else
				writeEn_u <= 1'b0;
				
				
			if(x_c > 8'b01010000 || x_c == 8'b01010000) begin
				x_c <= 8'b0;
				if (y_c > 7'b1111000 || y_c == 7'b1111000)
					writeEn_c <= 1'b0;
				else
					y_c <= y_c + 1'b1;
			end
			else
				x_c <= x_c + 1'b1;
			if (x_c  < 8'b01010000 && y_c < 7'b1111000)
				writeEn_c <= 1'b1;
			else
				writeEn_c <= 1'b0;
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
	image_translator t1(x, y, addr);
	defparam t1.RESOLUTION = "160x120";


	
	
	//rom module to store scissor.mif
	new_scissor s0(
	.address(addr),
	.clock(CLOCK_50),
	.q(q_s));
	
	//rom module to store paper.mif
	new_paper p0(
	.address(addr),
	.clock(CLOCK_50),
	.q(q_p));
	//rom module to store rock.mif
	new_rock r0 (
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





module image_translator(x, y, mem_address);

	parameter RESOLUTION = "320x240";
	

	input [((RESOLUTION == "320x240") ? (8) : (7)):0] x; 
	input [((RESOLUTION == "320x240") ? (7) : (6)):0] y;	
	output reg [((RESOLUTION == "320x240") ? (16) : (14)):0] mem_address;
	
	wire [16:0] res_320x240 = ({1'b0, y, 8'd0} + {1'b0, y, 6'd0} + {1'b0, x});
	//wire [15:0] res_160x120 = ({1'b0, y, 7'd0} + {1'b0, y, 5'd0} + {1'b0, x});
	wire [15:0] res_160x120 = ({2'b0, y, 6'd0} + {2'b0, y, 4'd0} + {1'b0, x});
	
	always @(*)
	begin
		if (RESOLUTION == "320x240")
			mem_address = res_320x240;
		else
			mem_address = res_160x120[14:0];
	end
endmodule
*/

