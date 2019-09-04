module Game_Ctrl_Unit
(
	input clk,
	input rst,
	input stop,
	input key1_press,
	input key2_press,
	input key3_press,
	input key4_press,
	
	output reg [2:0]game_status,
	input hit_wall,
	input hit_body,
	output reg die_flash,
	output reg restart		
);
	
	parameter RESTART = 3'b000;
	parameter START = 3'b001;
	parameter PLAY = 3'b010;
	parameter WAIT = 3'b011;
	parameter DIE = 3'b100;
	
	reg [27:0] clk_cnt;
	
	always@(posedge clk or negedge rst)
	begin
		if(!rst) begin
			game_status <= START;
			clk_cnt <= 28'd0;
			die_flash <= 1'b1;
			restart <= 1'b0;
		end
		else begin
			case(game_status)			
				RESTART:begin 
					if(clk_cnt <= 5) begin
						clk_cnt <= clk_cnt + 28'd1;
						restart <= 1'b1;						
					end
					else begin
						game_status <= START;
						clk_cnt <= 28'd0;
						restart <= 1'b0;
					end
				end
				START:begin
					if (key1_press || key2_press || key3_press || key4_press)
                        game_status <= PLAY;
					else 
					    game_status <= START;
				end
				PLAY:begin
					if(hit_wall || hit_body)
					   game_status <= DIE;
					else if(stop)
					   game_status <= WAIT;
					else
					   game_status <= PLAY;
				end
				WAIT:begin
				    if(stop)
				        game_status <= PLAY;
				    else
				        game_status <= WAIT;
				end					
				DIE:begin
					if(clk_cnt <= 28'd200_000_000) begin
						clk_cnt <= clk_cnt + 1'b1;
					   if(clk_cnt == 28'd25_000_000)
					       die_flash <= 1'b0;
					   else if(clk_cnt == 28'd50_000_000)
					       die_flash <= 1'b1;
					   else if(clk_cnt == 28'd75_000_000)
					       die_flash <= 1'b0;
					   else if(clk_cnt == 28'd100_000_000)
					       die_flash <= 1'b1;
					   else if(clk_cnt == 28'd125_000_000)
					       die_flash <= 1'b0;
					   else if(clk_cnt == 28'd150_000_000)
					       die_flash <= 1'b1;
				    end                    
					else begin
							die_flash <= 1'b1;
							clk_cnt <= 28'd0;
							game_status <= RESTART;
					end
				end
				default:begin
				    die_flash <= 1'b1;
                    clk_cnt <= 28'd0;
                    game_status <= RESTART;
				end
			endcase
		end
	end
endmodule
