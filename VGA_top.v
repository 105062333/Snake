module VGA_top(
	input clk,
    input rst,

    input [1:0]snake,
    input [5:0]apple_x,
    input [4:0]apple_y,
    output [9:0]x_pos,
    output [9:0]y_pos,    
    output hsync,
    output vsync,
    output [11:0] color_out
    );
    
    wire clk_n;
    
    clk_unit myclk(
        .clk(clk),
        .rst(rst),
        .clk_n(clk_n)
    );

    VGA_Control VGA
(
		.clk(clk_n),
		.rst(rst),
		.hsync(hsync),
		.vsync(vsync),
		.snake(snake),
        .color_out(color_out),
		.x_pos(x_pos),
		.y_pos(y_pos),
		.apple_x(apple_x),
		.apple_y(apple_y)
	);
endmodule

module VGA_Control
(
	input clk,
	input rst,
	
	input [1:0]snake,
	input [5:0]apple_x,
	input [4:0]apple_y,
	output reg[9:0]x_pos,
	output reg[9:0]y_pos,	
	output reg hsync,
	output reg vsync,
	output reg [11:0] color_out
);

	reg [19:0]clk_cnt;
	reg [9:0]line_cnt;
//	reg clk_25M;
	
	parameter NONE = 2'b00;
	parameter HEAD = 2'b01;
	parameter BODY = 2'b10;
	parameter WALL = 2'b11;
	
	parameter HEAD_COLOR = 12'b0000_1111_1111;
	parameter BODY_COLOR = 12'b0000_1111_0000;
	
	
	reg [3:0]lox;
	reg [3:0]loy;
		
	always@(posedge clk or negedge rst) begin
		if(rst) begin
			clk_cnt <= 0;
			line_cnt <= 0;
			hsync <= 1;
			vsync <= 1;
		end
		else begin
		    x_pos <= clk_cnt - 144;
			y_pos <= line_cnt - 33;	
			if(clk_cnt == 0) begin
			    hsync <= 0;
				clk_cnt <= clk_cnt + 1;
            end
			else if(clk_cnt == 96) begin
				hsync <= 1;
				clk_cnt <= clk_cnt + 1;
            end
			else if(clk_cnt == 799) begin
				clk_cnt <= 0;
				line_cnt <= line_cnt + 1;
			end
			else clk_cnt <= clk_cnt + 1;
			
			if(line_cnt == 0) begin
				vsync <= 0;
            end
			else if(line_cnt == 2) begin
				vsync <= 1;
			end
			else if(line_cnt == 521) begin
				line_cnt <= 0;
				vsync <= 0;
			end
			
			if(x_pos >= 0 && x_pos < 640 && y_pos >= 0 && y_pos < 480) begin
			    lox = x_pos[3:0];
				loy = y_pos[3:0];						
				if(x_pos[9:4] == apple_x && y_pos[9:4] == apple_y)
					case({loy,lox})
						8'b0000_0000:color_out = 12'b0000_0000_0000;
						default:color_out = 12'b0000_0000_1111;
					endcase						
				else if(snake == NONE)
					color_out = 12'b0000_0000_0000;
				else if(snake == WALL)
//					color_out = 3'b101;
                    color_out=12'b1111_0000_0000;
				else if(snake == HEAD || snake == BODY) begin
					case({lox,loy})
						8'b0000_0000:color_out = 12'b0000_0000_0000;
						default:color_out = (snake == HEAD) ?  HEAD_COLOR : BODY_COLOR;
					endcase
				end
			end
		    else
			    color_out = 12'b0000_0000_0000;
		end
    end
endmodule

module clk_unit(
	input clk,
	input rst,
	output reg clk_n
	);

    reg clk_tmp;
    
    always @(posedge clk or posedge rst) begin
            if (rst)
                clk_tmp <= 0;
            else
                clk_tmp <= ~clk_tmp;
        end
        
    always @(posedge clk_tmp or posedge rst) begin
       if (rst)
        clk_n <= 0;
      else
        clk_n <= ~clk_n;
    end
    
endmodule