//Milestone_1, have the random player


module exa(SW, KEY,CLOCK_50, HEX0, HEX1, HEX2, HEX4, HEX5, LEDR);
	input [9:0] SW; // SW[9] is load
	input [3:0] KEY; // KEY[0] is reset
	input CLOCK_50;
	output [6:0] HEX0, HEX1, HEX2, HEX4, HEX5;
	output [9:0] LEDR;//LEDR[0] = 1, means player wins this game, LEDR[1] = 1, means computer wins this game. LEDR[2] = 1 means a draw


	wire start;
	wire [1:0] user, com;
	//need to have a multiplexer for computer's choice
	wire com_ra, com_m, com_re;  // com choice for random, makov, reinforce
	reg [7:0] com_score, user_score;
	reg equ, uwin, cwin;
	
	
	parameter ROCK = 0;
	parameter PAPER = 1;
	parameter SCISSOR = 2;
	
	assign user = SW[1:0]; // 00 is rock, 01 is scissor, 10 is paper
	assign start = SW[9]; 
	assign reset = KEY[0];
		
	//reg reset_u, reset_c to start drawing
	reg reset_u, reset_c, player, choice_u, choice_c;
	wire VGA_CLK, VGA_HS, VGA_VS,VGA_BLANK_N,VGA_SYNC_N;
	wire [9:0]	VGA_R, VGA_G, VGA_B;
	
	assign reset_u = KEY[1];
	assign reset_c = KEY[2];
	
	markov mar (.clock(CLOCK_50), .reset(reset), .combination(???????), .choice(com_m));
	reinforce re(.clock(CLOCK_50), .reset(reset), .current_reward(????), .combination(????), .choice(choice_re));
	random computer(
	.clock(CLOCK_50),
	.choice(com_ra)
	);
	//computer's choice
	always @(*)
	begin
	case(SW[9:8])
	2'b00: com = com_ra;
	2'b01: com = com_m;
	2'b10: com = com_re;
	end
	
	 m2 user(
		.CLOCK_50(CLOCK_50),						
		.reset_n(reset_u),
		.player(0),
		.choice(choice_u),
		.VGA_CLK(VGA_HS),   						
		.VGA_HS(VGA_HS),							
		.VGA_VS(VGA_VS),							
		.VGA_BLANK_N(VGA_BLANK_N),						
		.VGA_SYNC_N(VGA_SYNC_N),						
		.VGA_R(VGA_R),   						
		.VGA_G(VGA_G),	 						
		.VGA_B(VGA_B)   						
	);
	
	m2 computer(
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
	);

	always @(posedge CLOCK_50)
	begin
		if (!reset) begin
		    user_score <= 8'b0;
		    com_score <= 8'b0;
		    equ <= 0;
		    uwin <= 0;
		    cwin <= 0;
		end
		else if (start == 1)begin
		    if (user == 2'b0) begin //user is rock
			choice_u <= 0;
			case (com) //com is rock
			2'b00: begin equ <= 1;
				     uwin <= 0;
				     cwin <= 0;
					  choice_c <=0;
			end
			2'b01: begin equ <= 0; //com is scissor
				     uwin <= 1;
				     cwin <= 0;
				     user_score <= user_score + 1'b1;
					  choice_c <= 1;
			end
			2'b10: begin equ <= 0; //com is paper
				     uwin <= 0;
				     cwin <= 1;
				     com_score <= com_score + 1'b1;
					  choice_c <= 2;
			end
			endcase
			end
			
		   else if (user == 2'b01) begin //user is scissor
			choice_u <= 1;
			case (com) //com is rock
			2'b00: begin equ <= 0;
				     uwin <= 0;
				     cwin <= 1;
				     com_score <= com_score + 1'b1;
					  choice_c <=0;
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
			case (com) //com is rock
			2'b00: begin equ <= 0;
				     uwin <= 1;
				     cwin <= 0;
				     user_score <= user_score + 1'b1;
					  choice_c <=0;

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
	   .seg(HEX0)
	);

	//user's score -- unfinished
	hex_decoder h1(
	   .hex_num(user_score[3:0]),
	   .seg(HEX1) 
		);

	hex_decoder h2(
	   .hex_num(user_score[7:4]),
	   .seg(HEX2)
		);	



	hex_decoder h3(
	   .hex_num({2'b00, com}),
	   .seg(HEX4) 
			);

	//computer's score
	hex_decoder h4(
	   .hex_num(com_score[3:0]),
	   .seg(HEX5) 
			);

	hex_decoder h5(
	   .hex_num(com_score[7:4]),
	   .seg(HEX6)
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


