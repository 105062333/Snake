module Snake_Eatting_Apple
(
	input clk,
	input rst,
	
	input [5:0]head_x,
	input [5:0]head_y,
	
	output reg [5:0]apple_x,
	output reg [4:0]apple_y,

	output reg add_cube
);

	reg [27:0] clk_cnt;
	reg [10:0] random_num;
	
	always@(posedge clk)
		random_num <= random_num + 11'd999;
	
	always@(posedge clk or negedge rst) begin
		if(!rst) begin
			clk_cnt <= 28'd0;
			apple_x <= 6'd24;
			apple_y <= 5'd10;
			add_cube <= 1'b0;
		end
		else begin
			clk_cnt <= clk_cnt + 28'd1;
			if(clk_cnt == 28'd250_000) begin
				clk_cnt <= 28'd0;
				if(apple_x == head_x && apple_y == head_y) begin
					add_cube <= 1'b1;
					apple_x <= (random_num[10:5] > 6'd38) ? (random_num[10:5] - 6'd25) : (random_num[10:5] == 6'd0) ? 6'd1 : random_num[10:5];
					apple_y <= (random_num[4:0] > 5'd28) ? (random_num[4:0] - 5'd3) : (random_num[4:0] == 5'd0) ? 5'd1 : random_num[4:0];
				end
				else
					add_cube <= 1'b0;
			end
		end
	end
endmodule
