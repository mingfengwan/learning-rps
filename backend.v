module backend(SW, KEY, CLOCK_50, LEDR, HEX0, HEX1);
    input [9:0] SW;
    input [3:0] KEY;
    input CLOCK_50;
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1;
	 
	 markov(.clock(CLOCK_50), .reset(KEY[0]), .start(KEY[1]), .user(SW[1:0]), .choice(LEDR[1:0]));

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

module reinforce(clock, reset, current_reward, user, choice);
	input clock;
	input [7:0] current_reward;
	input reset;
	input [3:0] combination;
	output reg [1:0] choice;
	reg [8:0] prob;
	reg seq;
	reg [31:0] matrix[2:0][2:0];
	reg ready = 1'b0;
	reg [31:0] reward [59:0][2:0][2:0];
	reg [1:0] action [59:0];
	reg [5:0] game = 6'b0;
	reg comp = 1'b0;
	reg [5:0] r_tracker = 6'b0;
	reg [7:0] alpha = 0000_1101;
	reg [5:0] t_tracker = 6'b0;
	reg e, previous; //TODO
	
	initialize_prob p0(clock, prob, seq);
	
	always @(posedge clock) begin
		if (!ready) begin
			if (seq == 1'b1) begin
				matrix[0][0] <= {5'b0, prob[2:0]};
				matrix[0][1] <= {5'b0, prob[5:3]};
				matrix[0][2] <= {5'b0, prob[8:6]};
				matrix[1][0] <= {5'b0, prob[2:0]};
				matrix[1][1] <= {5'b0, prob[5:3]};
				matrix[1][2] <= {5'b0, prob[8:6]};
				matrix[2][0] <= {5'b0, prob[2:0]};
				matrix[2][1] <= {5'b0, prob[5:3]};
				matrix[2][2] <= {5'b0, prob[8:6]};
				ready <= 1'b1;
			end
			else begin
				matrix[0][0] = {5'b0, prob[8:6]};
				matrix[0][1] = {5'b0, prob[5:3]};
				matrix[0][2] = {5'b0, prob[2:0]};
				matrix[1][0] = {5'b0, prob[8:6]};
				matrix[1][1] = {5'b0, prob[5:3]};
				matrix[1][2] = {5'b0, prob[2:0]};
				matrix[2][0] = {5'b0, prob[8:6]};
				matrix[2][1] = {5'b0, prob[5:3]};
				matrix[2][2] = {5'b0, prob[2:0]};
				ready = 1'b1;
			end
		end
		
		if (comp) begin
			if (t_tracker < game) begin
				t_tracker <= t_tracker + 1'b1;
				matrix[action[t_tracker]][0] <= matrix[action[t_tracker]][0] + alpha*reward[game - t_tracker]*(e^(matrix[1]) + e^(matrix[action[t_tracker]][2])/ (e^(matrix[action[t_tracker]][0]) + e^(matrix[action[t_tracker]][1]) + e^(matrix[action[t_tracker]][2])));
				matrix[action[t_tracker]][1] <= matrix[action[t_tracker]][1] + alpha*reward[game - t_tracker]*(e^(matrix[0]) + e^(matrix[action[t_tracker]][2])/ (e^(matrix[action[t_tracker]][0]) + e^(matrix[action[t_tracker]][1]) + e^(matrix[action[t_tracker]][2])));
				matrix[action[t_tracker]][2] <= matrix[action[t_tracker]][2] + alpha*reward[game - t_tracker]*(e^(matrix[1]) + e^(matrix[action[t_tracker]][0])/ (e^(matrix[action[t_tracker]][0]) + e^(matrix[action[t_tracker]][1]) + e^(matrix[action[t_tracker]][2])));
			end
			
			else begin
				t_tracker <= 6'b0;
				comp <= 1'b0;
			end	
		end
	end
	
	always @(combination) begin
		if (game < 60) begin
			action[game] = combination[1:0];
			reward[game][previous][previous] = reward[game - 6'b1][previous][previous] + 32'b1;
			game = game + 6'b1;
			comp = 1'b1;
		end
	end
	
endmodule

module theta(at, ak, ct, matrix, reward);
	parameter one = 32'b0_01111111_00000000000000000000000;
	
	
endmodule

