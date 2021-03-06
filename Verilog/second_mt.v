//Milestone_1, have the random player


module second_mt(SW, KEY,CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR);
	input [9:0] SW; // SW[9] is load
	input [3:0] KEY; // KEY[0] is reset
	input CLOCK_50;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output [9:0] LEDR;//LEDR[0] = 1, means player wins this game, LEDR[1] = 1, means computer wins this game. LEDR[2] = 1 means a draw


	wire start;
	wire [1:0] user;

	reg [1:0] com, com_loaded;
	reg [7:0] com_score, user_score;
	reg equ, uwin, cwin;
	wire [1:0] com_ra, com_m, com_re;  // com choice for random, makov, reinforce
	
	wire			VGA_CLK;   				//	VGA Clock
	wire			VGA_HS;					//	VGA H_SYNC
	wire			VGA_VS;					//	VGA V_SYNC
	wire			VGA_BLANK_N;				//	VGA BLANK
	wire			VGA_SYNC_N;				//	VGA SYNC
	wire	[9:0]	VGA_R;   				//	VGA Red[9:0]
	wire	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	wire	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	
	assign user = SW[1:0]; // 00 is rock, 01 is scissor, 10 is paper
	assign start = KEY[1]; 
	assign reset = KEY[0];
	
	reg go;
	
	
	parameter ROCK = 0;
	parameter PAPER = 1;
	parameter SCISSOR = 2;
	
		
	// reset_u, reset_c to start drawing
	//wire reset_u, reset_c;
	reg  player;
	reg [1:0] choice_u, choice_c;
	
	
	
	//assign reset_u = KEY[2];
	//assign reset_c = KEY[3];
	
	markov mar (.clock(CLOCK_50), .reset(reset), .start(start), .combination({com_loaded, user}), .choice(com_m));
	//reinforce re(.clock(CLOCK_50), .reset(reset), .current_reward(????), .combination(????), .choice(choice_re));
	random computer(
	.clock(CLOCK_50),
	.choice(com_ra)
	);
	//computer's choice
	always @(*)
	
	case(SW[9:8])
	2'b00: com = com_ra;
	2'b01: com = com_m;
	2'b10: com = com_re;
	default: com = com_ra;
	endcase
	
	 m2 user_draw (
		.CLOCK_50(CLOCK_50),						
		.reset_n(KEY[0]),
		//.player(0),
		choice(user),
		.VGA_CLK(VGA_HS),   						
		.VGA_HS(VGA_HS),							
		.VGA_VS(VGA_VS),							
		.VGA_BLANK_N(VGA_BLANK_N),						
		.VGA_SYNC_N(VGA_SYNC_N),						
		.VGA_R(VGA_R),   						
		.VGA_G(VGA_G),	 						
		.VGA_B(VGA_B)   						
	);
	
	/*m2 computer_draw(
		.CLOCK_50(CLOCK_50),						
		.reset_n(reset_c),
		.player(1),
		.choice(choice_c),
		.VGA_CLK(VGA_HS),   						
		.VGA_HS(VGA_HS),							
		.VGA_VS(VGA_VS),							
		.VGA_BLANK_N(VGA_BLANK_N),						
		.VGA_SYNC_N(VGA_SYNC_N),						
		.VGA_R(VGA_R),   						
		.VGA_G(VGA_G),	 						
		.VGA_B(VGA_B)   						
	);*/
	

	always @(negedge start, negedge reset)
		begin
		if (!reset) begin
		    user_score <= 8'b0;
		    com_score <= 8'b0;
		    equ <= 0;
		    uwin <= 0;
		    cwin <= 0;
			 com_loaded <= 2'b0;
			 go <= 0;
		end
		else if (start == 0)begin
			com_loaded <= com;
		   if (user == 2'b0) begin //user is rock
			choice_u <= 0;
			case (com_loaded) //com is rock
			2'b00: begin equ <= 1;
				     uwin <= 0;
				     cwin <= 0;
					  choice_c <= 2'b0;
			end
		
			2'b01: begin equ <= 0; //com is scissor
					  go <= 1'b0;
				     uwin <= 1;
				     cwin <= 0;
				     user_score <= user_score + 1'b1;
					  choice_c <= 2'b01;
			end
			2'b10: begin equ <= 0; //com is paper
				     uwin <= 0;
				     cwin <= 1;
				     com_score <= com_score + 1'b1;
					  choice_c <= 2'b10;
			end
			endcase
			end
			
		   else if (user == 2'b01) begin //user is scissor
			choice_u <= 1;
			case (com_loaded) //com is rock
			2'b00: begin equ <= 0;
				     uwin <= 0;
				     cwin <= 1;
				     com_score <= com_score + 1'b1;
					  choice_c <= 0;
			end
			2'b01: begin equ <= 1; //com is scissor
				     uwin <= 0;
				     cwin <= 0;
					  choice_c <= 1;
				     
			end
			2'b10: begin equ <= 0; //com is paper
				     uwin <= 1;
				     cwin <= 0;
				     user_score <= user_score + 1'b1;
					  choice_c <= 2;
			end
			endcase
			end

		    else if (user == 2'b01) begin //user is paper
			 choice_u <= 2;
			case (com_loaded) //com is rock
			2'b00: begin equ <= 0;
				     uwin <= 1;
				     cwin <= 0;
				     user_score <= user_score + 1'b1;
					  choice_c <= 0;

			end
			2'b01: begin equ <= 0; //com is scissor
				     uwin <= 0;
				     cwin <= 1;
				     com_score <= com_score + 1'b1; 
					  choice_c <= 1;
			end
			2'b10: begin equ <= 0; //com is paper
				     uwin <= 1;
				     cwin <= 0;
					  choice_c <= 2;
				     
			end
			endcase
			end


		end
		else begin
		    equ <= 0;
		    uwin <= 0;
		    cwin <= 0;
		end
	end

	assign LEDR[0] = uwin ? 1 :0; //player wins
	assign LEDR[1] = cwin ? 1 :0; //com wins
	assign LEDR[2] = equ ? 1 :0; //draw


	//user's choice 
	hex_decoder h0(
	   .hex_num({2'b00, user}),
	   .seg(HEX2)
	);

	//user's score -- unfinished
	hex_decoder h1(
	   .hex_num(user_score[3:0]),
	   .seg(HEX0) 
		);

	hex_decoder h2(
	   .hex_num(user_score[7:4]),
	   .seg(HEX1)
		);	



	hex_decoder h3(
	   .hex_num({2'b00, com_loaded}),
	   .seg(HEX3) 
			);

	//computer's score
	hex_decoder h4(
	   .hex_num(com_score[3:0]),
	   .seg(HEX4) 
			);

	hex_decoder h5(
	   .hex_num(com_score[7:4]),
	   .seg(HEX5)
			);


endmodule


//module screen_display();

//endmodule




//module mux2to1(x, y, s, m);
//    input x; //selected when s is 0
//    input y; //selected when s is 1
//    input s; //select signal
//    output m; //output
  
//    assign m = s & y | ~s & x;
    
//endmodule





module m2 	
	(
		CLOCK_50,						//	On Board 50 MHz
		reset_n,
		//player,
		choice,
		// Your inputs and outputs here
      //KEY,
      //SW,
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
	//input   [9:0]   SW;
	//input   [3:0]   KEY;
	input reset_n;
	//input player; // 0 for user,1 for computer
	input [1:0] choice; // 001 is rock, 010 is scissor, 100 is paper
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
	
	assign reset_n = KEY[0];
	reg [2:0] colour;
	reg [7:0] x = 8'b0;
	reg [6:0] y = 7'b0;
	reg writeEn = 1'b1;


	

	always@(posedge CLOCK_50)
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
		if (choice == 2'b00) // choice is rock
				q <= q_r;
		else if (choice == 2'b01) // choice is scissor
				q <= q_s;
		else //choice is paper
				q <= q_p;
			 
			
	end
	

	
	wire [14:0] addr;
	vga_address_translator t1(x, y, addr);
	defparam t1.RESOLUTION = "160x120";

	wire q_raw;
	//rom module to store mif
	/*pic p_0(      
	.address(addr),
	.clock(VGA_CLK),
	.q(q_r));
	*/
	
	
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






module random(
	input clock,
	output reg [1:0] choice = 2'b0
	);
	
	always @(posedge clock) begin
		if (choice < 2)
			choice <= choice + 1'b1;
		else 
			choice <= 2'b0;
	end	
endmodule

module initialize_prob(
	input clock,
	output reg [8:0] prob = 9'b0,
	output reg seq = 1'b0
	);
	
	always @(posedge clock) begin
		prob <= prob + 1'b1;
		if (prob == 511) begin
			seq <= ~seq;
		end
	end	
endmodule

module markov(clock, reset, start, combination, choice);
	input clock, start;
	input reset;
	input [3:0] combination;
	reg [3:0] previous;
	wire [1:0] random_choice;
	reg [7:0] matrix [10:0][2:0];
	output reg [1:0] choice;
	reg ready = 1'b0;
	reg [3:0] count = 4'b0;
	
	random r0(.clock(clock), .choice(random_choice));
	
	always @(posedge clock, negedge start, negedge reset, negedge ready) begin
		if (reset == 1'b0) begin
			ready <= 1'b0;
			count <= 1'b0;
		end
		
		if (!ready) begin
			
			if (count == 9) begin
				ready <= 1'b1;
				count <= 4'b0;
			end
			else begin
				count <= count + 1'b1;
				matrix[count][0] <= 8'b0;
				matrix[count][1] <= 8'b0;
				matrix[count][2] <= 8'b0;
			end
			
		end
		
		if (start == 1'b0)begin
	
		if (ready & !(^previous === 1'bX)) begin
			matrix[previous][combination[1:0]] = matrix[previous][combination[1:0]] + 8'b1;
			
			if (matrix[combination][0] == matrix[combination][1]) begin
				if (matrix[combination][0] < matrix[combination][2]) //user pick 10 (paper)
					choice = 2'b01;
				
				else if (matrix[combination][0] > matrix[combination][2]) begin //user pick 00 (rock) or 01 (scissor)
					choice = {random_choice[0], 1'b0};
				end
				else begin
					choice = random_choice;
				end
					
			end
				
			else begin
				if (matrix[combination][0] > matrix[combination][1]) begin
					if (matrix[combination][1] > matrix[combination][2]) //user pick 00 (rock)
						choice = 2'b10;
					else begin
						if (matrix[combination][0] > matrix[combination][2]) //user pick 00 (rock)
							choice = 2'b10;
						else
							choice = 2'b01; //user pick 10 (paper)
					end
				end
				else begin
					if (matrix[combination][0] > matrix[combination][2]) //user pick 01 (scissor)
						choice = 2'b00;
					else begin
						if (matrix[combination][1] > matrix[combination][2]) //user pick 01 (scissor)
							choice = 2'b00;
						else //user pick paper (10)
							choice = 2'b01;
					end
				end
			end	
		end
		
		else begin
			choice = random_choice;
		end
		previous = combination;
		//$display("%p", matrix);
	end
	end
endmodule

