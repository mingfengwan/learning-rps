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

module markov(clock, reset, start, user, choice);
	input clock, reset, start;
	input [1:0] user;
	reg [1:0] previous;
	reg [3:0] comb;
	reg [7:0] matrix [8:0][2:0];
	output [1:0] choice;
	reg [3:0] count = 4'b0;
		
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
	always @(*) begin
	
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
		if (blc) //m1 < m2
			choice = 2'b10;
		
		else if (agc) begin //m0 > m2
			choice = {1'b0, random_choice[0]};
		end
		else begin
			choice = random_choice;
		end
			
	end

	else begin
		if (agb) begin //m0 > m1
			if (bgc) //m1 > m2
				choice = 2'b00;
			else begin
				if (agc) //m0 > m2
					choice = 2'b00;
				else
					choice = 2'b10; 
			end
		end
		else begin
			if (agc) //m0 > m2
				choice = 2'b01;
			else begin
				if (bgc) //m1 > m2
					choice = 2'b01;
				else //pick paper (10)
					choice = 2'b10;
			end
		end
	end
	end

endmodule

module reinforce(clock, reset, start, user_choice, choice, ready);
	input clock, reset, start;
	input [1:0] user_choice;
	reg [6:0] count_comp;
	reg [31:0] pre_reward = 32'b0;
	reg [1:0] pre_user;
	reg [31:0] current_reward;
	wire [31:0] new_reward;
	wire [1:0] random_choice;
	output [1:0] choice;
	output reg ready = 1'b0;
	wire [31:0] theta_out [2:0];
	reg [31:0] matrix [2:0][2:0];
	reg [31:0] reward [59:0];
	reg [1:0] action [59:0];
	reg [1:0] user [59:0];
	reg [5:0] game = 6'b0;
	reg [5:0] t_tracker = 6'b0;
	parameter random21 = 32'b00111110_01010111_00001010_00111101;
	parameter random34 = 32'b00111110_10101110_00010100_01111011;
	parameter random45 = 32'b00111110_11100110_01100110_01100110;
	
	parameter one = 32'b0_01111111_00000000000000000000000;
	parameter zero = 32'b0;
	parameter negone = 32'b10111111_10000000_00000000_00000000;
	
	random r0(.clock(clock), .choice(random_choice));
	
	theta t0(.clock(clock), .at(action[t_tracker]), 
	.matrix0(matrix[pre_user][0]),
	.matrix1(matrix[pre_user][1]),
	.matrix2(matrix[pre_user][2]),
	.reward(reward[game - t_tracker - 6'b1]), 
	.theta_out0(theta_out[0]), .theta_out1(theta_out[1]), .theta_out2(theta_out[2]));
	
	comparator_32 c0(clock, matrix[user_choice][0], matrix[user_choice][1], matrix[user_choice][2], choice);
	
	float_adder f0(.clock(clock), .add_sub(1'b1), .dataa(pre_reward), 
	.datab(current_reward), .result(new_reward));
	
	always @(posedge clock, negedge reset, negedge start) begin
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
		
		else if (!start) begin
			if (ready) begin
				if (game < 60) begin
					t_tracker <= 6'b0;
					count_comp <= 7'b0;
					ready <= 1'b0;
				end
				if (game > 0) begin
					pre_reward <= reward[game - 6'b1];
				end
				else begin
					pre_reward <= 32'b0;
				end
			end
		end
		
		else if (t_tracker == game) begin
			action[game] <= choice;
			user[game] <= user_choice;
			ready <= 1'b1;
			reward[game] <= new_reward;
			count_comp <= count_comp + 7'b1;
		end
		
		else if (count_comp == 0) begin
			if (t_tracker == 0) begin
				pre_user <= random_choice;
			end
			else begin
				pre_user <= user[t_tracker - 6'b1];
			end
			count_comp <= count_comp + 7'b1;
		end
	
		else if (count_comp == 100) begin
			matrix[pre_user][0] <= theta_out[0];
			matrix[pre_user][1] <= theta_out[1];
			matrix[pre_user][2] <= theta_out[2];
		
			t_tracker <= t_tracker + 6'b1;
			count_comp <= 7'b0;
		end
		
		else if (count_comp < 100) begin
			count_comp <= count_comp + 7'b1;
		end
	end
	
	always @(negedge start, negedge reset) begin
		if (!start) begin
			if (ready) begin
				game <= game + 6'b1;
			end
		end
		
		if (!reset) begin
			game <= 6'b0;
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
	wire [31:0] e_sum, e_temp, pi0, pi1, pi2, deri0, deri1, deri2;
	reg [31:0] minus0, minus1, minus2;
	wire [31:0] product0, product1, product2, reward_alpha;
	wire [31:0] e_out [2:0];
	output [31:0] theta_out0, theta_out1, theta_out2;
	
	ALTFP_EXa e0(.clock(clock), .data(matrix0), .result(e_out[0])); //e^p0
	ALTFP_EXa e1(.clock(clock), .data(matrix1), .result(e_out[1])); //e^p1
	ALTFP_EXa e2(.clock(clock), .data(matrix2), .result(e_out[2])); //e^p2
	
	float_adder f0(.clock(clock), .add_sub(1'b1), .dataa(e_out[0]), .datab(e_out[1]), .result(e_temp)); //e^p0 + e^p1
	float_adder f1(.clock(clock), .add_sub(1'b1), .dataa(e_out[2]), .datab(e_temp), .result(e_sum)); //e^p0 + e^p1 + e^p2
	
	float_div d0(.clock(clock), .dataa(e_out[0]), .datab(e_sum), .result(pi0)); //pi(a0, ct)
	float_div d1(.clock(clock), .dataa(e_out[1]), .datab(e_sum), .result(pi1)); //pi(a1, ct)
	float_div d2(.clock(clock), .dataa(e_out[2]), .datab(e_sum), .result(pi2)); //pi(a2, ct)
	
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

