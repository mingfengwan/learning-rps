module backend(SW, KEY, CLOCK_50, LEDR, HEX0, HEX1);
    input [9:0] SW;
    input [3:0] KEY;
    input CLOCK_50;
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1;

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
	output reg prob [8:0] = 9'b0,
	output reg seq = 1'b0
	);
	
	always @(posedge clock) begin
		prob <= prob + 1'b1;
		if (prob == 511) begin
			seq <= ~seq;
		end
	end	
endmodule

module markov(clock, reset, combination, choice);
	input clock;
	input reset;
	input [3:0] combination;
	reg [3:0] previous;
	wire [1:0] random_choice;
	reg [7:0] matrix [8:0][2:0];
	output reg [1:0] choice;
	reg ready = 1'b0;
	reg [3:0] count = 4'b0;
	
	random r0(.clock(clock), .choice(random_choice));
	
	always @(posedge clock) begin
		if (!ready) begin
			
			if (count_sub == 9) begin
				ready <= 1'b1;
			end
			else begin
				count <= count + 1'b1;
				matrix[count] <= 3'b0;
			end
			
		end
	end
	
	always @(combination) begin
		if (reset == 1'b0) begin
			ready = 1'b0;
		end
		
		if (ready & !(^previous === 1'bX)) begin
			matrix[previous][combination[1:0]] = matrix[previous][combination[1:0]] + 1'b1;
			
			if (matrix[combination][0] == matrix[combination][1]) begin
				if (matrix[combination][0] < matrix[combination][2])
					choice = 2'b10;
				else begin
					if (matrix[combination][0] > matrix[combination][2]) begin
						choice = {1'b0, random_choice[0]};
					end
				end
					
			end
				
			else begin
				if (matrix[combination][0] > matrix[combination][1]) begin
					if (matrix[combination][1] > matrix[combination][2])
						choice = 2'b0;
					else begin
						if (matrix[combination][0] > matrix[combination][2])
							choice = 2'b0;
						else
							choice = 2'b10;
					end
				end
				else begin
					if (matrix[combination][0] > matrix[combination][2])
						choice = 2'b1;
					else begin
						if (matrix[combination][1] > matrix[combination][2])
							choice = 2'b1;
						else
							choice = 2'b10;
					end
				end
			end	
		end
		
		else begin
			choice = random_choice;
		end
		previous = combination;
	end
endmodule

module reinforce(clock, reset, combination, choice);
	input clock;
	input [7:0] current_reward;
	input reset;
	input [3:0] combination;
	output reg [1:0] choice;
	reg [8:0] prob;
	reg seq;
	reg [7:0] matrix0 [2:0];
	reg [2:0] matrix1 [0:7];
	reg [2:0] matrix2 [0:7];
	reg ready = 1'b0;
	reg [7:0] reward [59:0];
	reg [59:0] action [0:1];
	reg [5:0] game = 6'b0;
	reg comp = 1'b0;
	reg [5:0] r_tracker = 6'b0;
	reg [7:0] alpha = 0000_1101;
	reg [5:0] reward_sum = 6'b0;
	reg [5:0] t_tracker = 6'b0;
	
	initialize_prob(clock, prob, seq);
	
	always @(posedge clock) begin
		if (!ready) begin
			if (seq == 1'b1) begin
				matrix0[0] <= {5'b0, prob[2:0]};
				matrix0[1] <= {5'b0, prob[5:3]};
				matrix0[2] <= {5'b0, prob[8:6]};
				matrix1[0] <= {5'b0, prob[2:0]};
				matrix1[1] <= {5'b0, prob[5:3]};
				matrix1[2] <= {5'b0, prob[8:6]};
				matrix2[0] <= {5'b0, prob[2:0]};
				matrix2[1] <= {5'b0, prob[5:3]};
				matrix2[2] <= {5'b0, prob[8:6]};
				ready <= 1'b1;
			end
			else begin
				matrix0[0] = {5'b0, prob[8:6]};
				matrix0[1] = {5'b0, prob[5:3]};
				matrix0[2] = {5'b0, prob[2:0]};
				matrix1[0] = {5'b0, prob[8:6]};
				matrix1[1] = {5'b0, prob[5:3]};
				matrix1[2] = {5'b0, prob[2:0]};
				matrix2[0] = {5'b0, prob[8:6]};
				matrix2[1] = {5'b0, prob[5:3]};
				matrix2[2] = {5'b0, prob[2:0]};
				ready = 1'b1;
			end
		end
		
		if (comp) begin
			if (t_tracker < game) begin
				if (t_tracker > 0) begin
					r_tracker <= reward_sum - reward[t_tracker - 1'b1];
				end
				
				t_tracker <= t_tracker + 1'b1;
				case (action[t_tracker]) begin
					2'b0: begin
						matrix0[0] <= matrix0[0] + alpha*r_track*(e^(matrix0[1]) + e^(matrix0[2])/ (e^(matrix0[0]) + e^(matrix0[1]) + e^(matrix0[2])));
						matrix0[1] <= matrix0[0] + alpha*r_track*(e^(matrix0[0]) + e^(matrix0[2])/ (e^(matrix0[0]) + e^(matrix0[1]) + e^(matrix0[2])));
						matrix0[2] <= matrix0[0] + alpha*r_track*(e^(matrix0[1]) + e^(matrix0[0])/ (e^(matrix0[0]) + e^(matrix0[1]) + e^(matrix0[2])));
					end
					2'b1: begin
						matrix1[0] <= matrix1[0] + alpha*r_track*(e^(matrix1[1]) + e^(matrix1[2])/ (e^(matrix1[0]) + e^(matrix1[1]) + e^(matrix1[2])));
						matrix1[1] <= matrix1[0] + alpha*r_track*(e^(matrix1[0]) + e^(matrix1[2])/ (e^(matrix1[0]) + e^(matrix1[1]) + e^(matrix1[2])));
						matrix1[2] <= matrix1[0] + alpha*r_track*(e^(matrix1[1]) + e^(matrix1[0])/ (e^(matrix1[0]) + e^(matrix1[1]) + e^(matrix1[2])));
					end
					2'b10: ;
				end
				
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
			reward[game] = current_reward;
			game = game + 1'b1;
			comp = 1'b1;
			reward_sum = reward_sum + current_reward;
		end
	end
	
endmodule

module reinforce_matrix();
endmodule