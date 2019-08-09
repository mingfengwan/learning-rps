//Milestone_2, have the random player& Markov's player


module m3(SW, KEY,CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR,
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
	wire [1:0] user;

	reg [1:0] com, com_loaded;
	reg [7:0] com_score, user_score;
	reg equ, uwin, cwin;
	wire [1:0] com_ra, com_m, com_re;  // com choice for random, makov, reinforce
	
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
	
	markov mar(.clock(CLOCK_50), .reset(reset), .start(start), .user(user), .choice(com_m));
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
	
	 screen_display user_draw (
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
	
	/*screen_display computer_draw(
		.CLOCK_50(CLOCK_50),						
		.reset_n(reset_c),
		.player(1),
		.choice(com_loaded),
		.VGA_CLK(VGA_HS),   						
		.VGA_HS(VGA_HS),							
		.VGA_VS(VGA_VS),							
		.VGA_BLANK_N(VGA_BLANK_N),						
		.VGA_SYNC_N(VGA_SYNC_N),						
		.VGA_R(VGA_R),   						
		.VGA_G(VGA_G),	 						
		.VGA_B(VGA_B)   						
	);
	*/

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
			//choice_u <= 0;
			case (com_loaded) //com is rock
			2'b00: begin equ <= 1;
				     uwin <= 0;
				     cwin <= 0;
					  //choice_c <= 2'b0;
			end
		
			2'b01: begin equ <= 0; //com is scissor
					  go <= 1'b0;
				     uwin <= 1;
				     cwin <= 0;
				     user_score <= user_score + 1'b1;
					  //choice_c <= 2'b01;
			end
			2'b10: begin equ <= 0; //com is paper
				     uwin <= 0;
				     cwin <= 1;
				     com_score <= com_score + 1'b1;
					  //choice_c <= 2'b10;
			end
			endcase
			end
			
		   else if (user == 2'b01) begin //user is scissor
			//choice_u <= 1;
			case (com_loaded) //com is rock
			2'b00: begin equ <= 0;
				     uwin <= 0;
				     cwin <= 1;
				     com_score <= com_score + 1'b1;
					  //choice_c <= 0;
			end
			2'b01: begin equ <= 1; //com is scissor
				     uwin <= 0;
				     cwin <= 0;
					  //choice_c <= 1;
				     
			end
			2'b10: begin equ <= 0; //com is paper
				     uwin <= 1;
				     cwin <= 0;
				     user_score <= user_score + 1'b1;
					  //choice_c <= 2;
			end
			endcase
			end

		   else if (user == 2'b10) begin //user is paper
		   //choice_u <= 2;
			case (com_loaded) //com is rock
			2'b00: begin equ <= 0;
				     uwin <= 1;
				     cwin <= 0;
				     user_score <= user_score + 1'b1;
					  //choice_c <= 0;

			end
			2'b01: begin equ <= 0; //com is scissor
				     uwin <= 0;
				     cwin <= 1;
				     com_score <= com_score + 1'b1; 
					  //choice_c <= 1;
			end
			2'b10: begin equ <= 0; //com is paper
				     uwin <= 1;
				     cwin <= 0;
					  //choice_c <= 2;
				     
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





module screen_display	
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


	

	//always@(posedge CLOCK_50, negedge reset_n)
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

module markov(clock, reset, start, user, choice);
	input clock, reset, start;
	input [1:0] user;
	reg [1:0] previous;
	reg [3:0] comb;
	wire [1:0] random_choice;
	reg [7:0] matrix [8:0][2:0];
	output [1:0] choice;
	reg [3:0] count = 4'b0;
	
	random r0(.clock(clock), .choice(random_choice));
	
	comparator_matrix c0(matrix[comb][0], matrix[comb][1], matrix[comb][2], choice);
	
	always @(user, choice) begin
		case({user, choice})
			0000: comb = 4'd0;
			0001: comb = 4'd1;
			0010: comb = 4'd2;
			0100: comb = 4'd3;
			0101: comb = 4'd4;
			0110: comb = 4'd5;
			1000: comb = 4'd6;
			1001: comb = 4'd7;
			1010: comb = 4'd8;
		endcase
	end
	
	always @(posedge clock, negedge reset, negedge start) begin
		if (!reset) begin
			count <= 4'b0;
		end
		
		else if (!start) begin
			if (!(^previous === 1'bX)) begin
				matrix[previous][user] <= matrix[previous][user] + 8'b1;
			end
			previous <= comb;
			//$display("%p", matrix);
		end
		
		else if (count < 9) begin
			count <= count + 1'b1;
			matrix[count][0] <= 8'b0;
			matrix[count][1] <= 8'b0;
			matrix[count][2] <= 8'b0;
		end
		
	end
endmodule

module comparator_matrix(m0, m1, m2, choice);
	input [7:0] m0, m1, m2;
	wire [1:0] random_choice;
	output reg [1:0] choice;
	
	random r0(.clock(clock), .choice(random_choice));
	always @(m0, m1, m2) begin
	if (m0 == m1) begin
		if (m0 < m2) //user pick 10 (paper)
			choice = 2'b01;
		
		else if (m0 > m2) begin //user pick 00 (rock) or 01 (scissor)
			choice = {random_choice[0], 1'b0};
		end
		else begin
			choice = random_choice;
		end
			
	end

	else begin
		if (m0 > m1) begin
			if (m1 > m2) //user pick 00 (rock)
				choice = 2'b10;
			else begin
				if (m0 > m2) //user pick 00 (rock)
					choice = 2'b10;
				else
					choice = 2'b01; //user pick 10 (paper)
			end
		end
		else begin
			if (m0 > m2) //user pick 01 (scissor)
				choice = 2'b00;
			else begin
				if (m1 > m2) //user pick 01 (scissor)
					choice = 2'b00;
				else //user pick paper (10)
					choice = 2'b01;
			end
		end
	end
	end
endmodule

module comparator_32(clock, m0, m1, m2, choice);
	input [31:0] m0, m1, m2;
	input clock;
	wire [1:0] random_choice;
	wire aeb, agb, alb, bec, bgc, blc, aec, agc, alc;
	output reg [1:0] choice;
	
	random r0(.clock(clock), .choice(random_choice));
	float_compare c0(.clock(clock), .dataa(m0), .datab(m1), .aeb(aeb), .agb(agb), .alb(alb));
	float_compare c1(.clock(clock), .dataa(m1), .datab(m2), .aeb(bec), .agb(bgc), .alb(blc));
	float_compare c2(.clock(clock), .dataa(m0), .datab(m2), .aeb(aec), .agb(agc), .alb(alc));
	
	always @(*) begin
	if (aeb) begin //m0 == m1
		if (blc) //m1 < m2, user pick 10 (paper)
			choice = 2'b01;
		
		else if (agc) begin //m0 > m2, user pick 00 (rock) or 01 (scissor)
			choice = {random_choice[0], 1'b0};
		end
		else begin
			choice = random_choice;
		end
			
	end

	else begin
		if (agb) begin //m0 > m1
			if (bgc) //m1 > m2, user pick 00 (rock)
				choice = 2'b10;
			else begin
				if (agc) //m0 > m2, user pick 00 (rock)
					choice = 2'b10;
				else
					choice = 2'b01; //user pick 10 (paper)
			end
		end
		else begin
			if (agc) //m0 > m2, user pick 01 (scissor)
				choice = 2'b00;
			else begin
				if (bgc) //m1 > m2 user pick 01 (scissor)
					choice = 2'b00;
				else //user pick paper (10)
					choice = 2'b01;
			end
		end
	end
	end

endmodule

module reinforce(clock, reset, start, user_choice, choice, ready);
	input clock, start;
	input [1:0] user_choice;
	reg [6:0] count_comp;
	reg [31:0] current_reward;
	input reset;
	output reg [1:0] choice;
	output reg ready = 1'b0;
	wire [31:0] theta_out [2:0];
	reg [31:0] matrix[2:0][2:0];
	reg [31:0] reward [59:0];
	reg [1:0] action [59:0];
	reg [1:0] user [59:0];
	reg [5:0] game = 6'b0;
	reg comp = 1'b0;
	reg [5:0] r_tracker = 6'b0;
	reg [5:0] t_tracker = 6'b0;
	parameter random21 = 00111110_01010111_00001010_00111101;
	parameter random34 = 00111110_10101110_00010100_01111011;
	parameter random45 = 00111110_11100110_01100110_01100110;
	
	parameter one = 32'b0_01111111_00000000000000000000000;
	parameter zero = 32'b0;
	parameter negone = 32'b10111111_10000000_00000000_00000000;
	//TODO: add ready 
	random r0(.clock(clock), .choice(random_choice));
	
	theta t0(.clock(clock), .at(action[t_tracker]), 
	.matrix0(matrix[user[t_tracker - 6'b1]][0]),
	.matrix1(matrix[user[t_tracker - 6'b1]][1]),
	.matrix2(matrix[user[t_tracker - 6'b1]][2]),
	.reward(reward[game - t_tracker]), 
	.theta_out0(theta_out[0]), .theta_out1(theta_out[1]), .theta_out2(theta_out[2]));
	
	comparator_32(matrix[user_choice][0], matrix[user_choice][1], matrix[user_choice][2], choice);
	
	float_adder f0(.clock(clock), .add_sub(1'b1), .dataa(reward[game - 6'b1]), 
	.datab(current_reward), .result(reward[game]));
	
	always @(posedge clock, negedge reset) begin
		if (!reset) begin
			if (random_choice == 2'b1) begin
				matrix[0][0] <= random21;
				matrix[0][1] <= random34;
				matrix[0][2] <= random45;
				matrix[1][0] <= random34;
				matrix[1][1] <= random21;
				matrix[1][2] <= random45;
				matrix[2][0] <= random34;
				matrix[2][1] <= random21;
				matrix[2][2] <= random45;
			end
			else begin
				matrix[0][0] <= random34;
				matrix[0][1] <= random45;
				matrix[0][2] <= random21;
				matrix[1][0] <= random21;
				matrix[1][1] <= random34;
				matrix[1][2] <= random45;
				matrix[2][0] <= random45;
				matrix[2][1] <= random21;
				matrix[2][2] <= random34;
			end
		end
	
		else if (count_comp == 100) begin
			if (t_tracker < game) begin
				t_tracker <= t_tracker + 6'b1;
				count_comp <= 7'b0;
			end
			else begin
				action[game] <= choice;
				if (game == 0) begin
					reward[0] <= current_reward;
				end
				user[game] <= user_choice;
				game <= game + 6'b1;
				ready = 1'b1;
			end
		end
		
		else if (count_comp < 100) begin
			count_comp <= count_comp + 7'b1;
		end
	end
	
	always @(negedge start) begin
		if (game < 60) begin
			t_tracker <= 6'b0;
			count_comp <= 7'b0;
		end
	end
	
	always @(*) begin
		if (user_choice == 2'b0) begin //user is rock
			case (choice) //choice is rock
				2'b00: begin
					current_reward = zero;
				end
			
				2'b01: begin
					current_reward = negone;
				end
				2'b10: begin //com is paper
					current_reward = one;     
				end
			endcase
		end
			
		else if (user_choice == 2'b01) begin //user is scissor
			case (choice) //com is rock
				2'b00: begin
					current_reward = one;
				end
				2'b01: begin //com is scissor
					current_reward = zero; 
				end
				2'b10: begin //com is paper
					current_reward = negone;  
				end
			endcase
		end

		else if (user_choice == 2'b10) begin //user is paper
			case (choice) //com is rock
				2'b00: begin 
					current_reward = negone;
				end
				2'b01: begin //com is scissor
					current_reward = one;
				end
				2'b10: begin 
					current_reward = zero;
				end
			endcase
		end
	end
	
endmodule

module theta(clock, matrix0, matrix1, matrix2, at, reward, theta_out0, theta_out1, theta_out2);
	input clock;
	input [1:0] at;
	input [31:0] reward;
	input [31:0] matrix0, matrix1, matrix2;
	parameter one = 32'b0_01111111_00000000000000000000000;
	parameter zero = 32'b0;
	parameter alpha = 32'b0_01111110_11100110011001100110011;
	reg count;
	reg [31:0] e_sum, e_temp, minus0, minus1, minus2, pi0, pi1, pi2, deri0, deri1, deri2, product, reward_pro;
	reg [31:0] e_out [2:0];
	output [31:0] theta_out0, theta_out1, theta_out2;
	
	ALTFP_EXa e0(.clock(clock), .data(matrix0), .result(e_out[0])); //e^p0
	ALTFP_EXa e1(.clock(clock), .data(matrix1), .result(e_out[1])); //e^p1
	ALTFP_EXa e2(.clock(clock), .data(matrix2), .result(e_out[2])); //e^p2
	
	float_adder f0(.clock(clock), .add_sub(1'b1), .dataa(e_out[0]), .datab(e_out[1]), .result(e_temp)); //e^p0 + e^p1
	float_adder f1(.clock(clock), .add_sub(1'b1), .dataa(e_out[2]), .datab(e_temp), .result(e_sum)); //e^p0 + e^p1 + e^p2
	
	float_divider d0(.clock(clock), .dataa(e_out[0]), .datab(e_sum), .result(pi0)); //pi(a0, ct)
	float_divider d1(.clock(clock), .dataa(e_out[1]), .datab(e_sum), .result(pi1)); //pi(a1, ct)
	float_divider d2(.clock(clock), .dataa(e_out[2]), .datab(e_sum), .result(pi2)); //pi(a2, ct)
	
	float_adder f2(.clock(clock), .add_sub(1'b0), .dataa(minus0), .datab(pi0), .result(deri0)); //-pi(a0, ct) or 1 - pi(a0, ct)
	float_adder f3(.clock(clock), .add_sub(1'b0), .dataa(minus1), .datab(pi1), .result(deri1)); //-pi(a1, ct) or 1 - pi(a1, ct)
	float_adder f4(.clock(clock), .add_sub(1'b0), .dataa(minus2), .datab(pi2), .result(deri2)); //-pi(a2, ct) or 1 - pi(a2, ct)
	
	float_multi mo(.clock(clock), .dataa(reward), .datab(alpha), .result(reward_alpha)); //alpha * reward
	float_multi m1(.clock(clock), .dataa(reward_alpha), .datab(deri0), .result(product0)); //deri * alpha * reward
	float_multi m2(.clock(clock), .dataa(reward_alpha), .datab(deri1), .result(product1)); //deri * alpha * reward
	float_multi m3(.clock(clock), .dataa(reward_alpha), .datab(deri2), .result(product2)); //deri * alpha * reward
	
	float_adder f5(.clock(clock), .add_sub(1'b1), .dataa(matrix0), .datab(product0), .result(theta_out0));
	float_adder f6(.clock(clock), .add_sub(1'b1), .dataa(matrix1), .datab(product1), .result(theta_out1));
	float_adder f7(.clock(clock), .add_sub(1'b1), .dataa(matrix2), .datab(product2), .result(theta_out2));
	
	always @(*) begin
		case (at)
			2'b00: begin
				minus0 = one;
				minus1 = zero;
				minus2 = zero;
			end
			2'b01: begin
				minus0 = zero;
				minus1 = one;
				minus2 = zero;
			end
			2'b10: begin
				minus0 = zero;
				minus1 = zero;
				minus2 = one;
			end
		endcase
	end
	
endmodule

