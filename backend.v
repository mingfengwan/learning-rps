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
			choice <= choice + 1;
		else 
			choice <= 2'b0;
	end	
endmodule

module markov(clock, reset, combination, choice);
	input clock;
	input reset;
	input [3:0] combination;
	reg [3:0] previous;
	wire [1:0] random_choice;
	real matrix [8:0][1:0][2:0];
	output reg [1:0] choice;
	reg ready = 1'b0;
	reg [4:0] count = 5'b0;
	reg [1:0] count_sub = 2'b0;
	
	random r0(.clock(clock), .choice(random_choice));
	
	always @(posedge clock) begin
		if (!ready) begin
			
			if (count_sub == 2) begin
				count_sub <= 2'b0;
				count <= count + 1;
			end
			else 
				count_sub <= count_sub + 1;
			
			if (count < 9) begin
				matrix[count][1][count_sub] <= 0.333333;
				matrix[count][0][count_sub] <= 0;
			end
			else if (count < 18) begin
				matrix[count - 9][1][count_sub] <= 0.333333;
				matrix[count - 9][0][count_sub] <= 0;
			end
			else
				ready <= 1'b1;
			
		end
	end
	
	always @(combination) begin
		if (reset == 1'b0) begin
			ready = 1'b0;
		end
		
		if (ready & !(^previous === 1'bX)) begin
			matrix[previous][0][combination[1:0]] = matrix[previous][0][combination[1:0]] + 1;
			matrix[previous][1][0] = matrix[previous][0][0] / (matrix[previous][0][0] + matrix[previous][0][1] + matrix[previous][0][2]);
			matrix[previous][1][1] = matrix[previous][0][1] / (matrix[previous][0][0] + matrix[previous][0][1] + matrix[previous][0][2]);
			matrix[previous][1][2] = matrix[previous][0][2] / (matrix[previous][0][0] + matrix[previous][0][1] + matrix[previous][0][2]);
			$display("%b",2/4);
			
			previous = combination;
			
			if (matrix[combination][1][0] == matrix[combination][1][1]) begin
				if (matrix[combination][1][0] < matrix[combination][1][2])
					choice = 2'b10;
				else begin
					if (matrix[combination][1][0] > matrix[combination][1][2]) begin
						choice = {1'b0, choice[0]};
					end
				end
					
			end
				
			else begin
				if (matrix[combination][1][0] > matrix[combination][1][1]) begin
					if (matrix[combination][1][1] > matrix[combination][1][2])
						choice = 2'b0;
					else begin
						if (matrix[combination][1][0] > matrix[combination][1][2])
							choice = 2'b0;
						else
							choice = 2'b10;
					end
				end
				else begin
					if (matrix[combination][1][0] > matrix[combination][1][2])
						choice = 2'b1;
					else begin
						if (matrix[combination][1][1] > matrix[combination][1][2])
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