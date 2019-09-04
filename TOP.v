module TOP
(
    inout PS2_DATA,
    inout PS2_CLK,
    input clk,
	input rst,
	input stop,
	output hsync,
	output vsync,
	output [11:0]color_out,
	output [7:0]seg_out,
	output [3:0]sel
);

	wire left_key_press;
	wire right_key_press;
	wire up_key_press;
	wire down_key_press;
	wire [1:0]snake;
	wire [9:0]x_pos;
	wire [9:0]y_pos;
	wire [5:0]apple_x;
	wire [4:0]apple_y;
	wire [5:0]head_x;
	wire [5:0]head_y;
	
	wire add_cube;
	wire[2:0]game_status;
	wire hit_wall;
	wire hit_body;
	wire die_flash;
	wire restart;
	wire [6:0]cube_num;
	
	reg [3:0] key_num;
	wire [511:0] key_down;
	wire [8:0] last_change;
	wire been_ready;
	reg [27:0] cnt;
	
	wire rst_n;
	wire debounce_stop, stopp;
	debounce db1(debounce_stop,stop,clk);
    One_Pulse op1(stopp,debounce_stop,clk);

	assign rst_n = ~rst;
	KeyboardDecoder key_de (
		.key_down(key_down),
		.last_change(last_change),
		.key_valid(been_ready),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(rst),
		.clk(clk)
	);
	parameter [8:0] KEY_CODES [0:9] = {
				9'b0_0111_0000, // right_0 => 70
				9'b0_0110_1001, // right_1 => 69
				9'b0_0111_0010, // right_2 => 72
				9'b0_0111_1010, // right_3 => 7A
				9'b0_0110_1011, // right_4 => 6B
				9'b0_0111_0011, // right_5 => 73
				9'b0_0111_0100, // right_6 => 74
				9'b0_0110_1100, // right_7 => 6C
				9'b0_0111_0101, // right_8 => 75
				9'b0_0111_1101  // right_9 => 7D
			};
	always @ (*) begin
		case (last_change)
			KEY_CODES[00] : key_num = 4'b0000;
			KEY_CODES[01] : key_num = 4'b0001;
			KEY_CODES[02] : key_num = 4'b0010;
			KEY_CODES[03] : key_num = 4'b0011;
			KEY_CODES[04] : key_num = 4'b0100;
			KEY_CODES[05] : key_num = 4'b0101;
			KEY_CODES[06] : key_num = 4'b0110;
			KEY_CODES[07] : key_num = 4'b0111;
			KEY_CODES[08] : key_num = 4'b1000;
			KEY_CODES[09] : key_num = 4'b1001;
			default       : key_num = 4'b1111;
		endcase
	end

	assign left_key_press = (been_ready&&last_change==KEY_CODES[4])?1'b1:1'b0;
	assign right_key_press = (been_ready&&last_change==KEY_CODES[6])?1'b1:1'b0;
	assign up_key_press = (been_ready&&last_change==KEY_CODES[8])?1'b1:1'b0;
	assign down_key_press = (been_ready&&last_change==KEY_CODES[5])?1'b1:1'b0;
	
    Game_Ctrl_Unit U1 (
        .clk(clk),
	    .rst(rst_n),
	    .stop(stopp),
	    .key1_press(left_key_press),
	    .key2_press(right_key_press),
	    .key3_press(up_key_press),
	    .key4_press(down_key_press),
        .game_status(game_status),
		.hit_wall(hit_wall),
		.hit_body(hit_body),
		.die_flash(die_flash),
		.restart(restart)		
	);
	
	Snake_Eatting_Apple U2 (
        .clk(clk),
		.rst(rst_n),
		.apple_x(apple_x),
		.apple_y(apple_y),
		.head_x(head_x),
		.head_y(head_y),
		.add_cube(add_cube)	
	);
	
	Snake U3 (
	    .clk(clk),
		.rst(rst_n),
		.left_press(left_key_press),
		.right_press(right_key_press),
		.up_press(up_key_press),
		.down_press(down_key_press),
		.snake(snake),
		.x_pos(x_pos),
		.y_pos(y_pos),
		.head_x(head_x),
		.head_y(head_y),
		.add_cube(add_cube),
		.game_status(game_status),
		.cube_num(cube_num),
		.hit_body(hit_body),
		.hit_wall(hit_wall),
		.die_flash(die_flash)
	);

	VGA_top U4 (
		.clk(clk),
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
	
	
	Seg_Display U6 (
		.clk(clk),
		.rst(rst_n),	
		.add_cube(add_cube),
		.game_status(game_status),
		.seg_out(seg_out),
		.sel(sel)	
	);
endmodule

module debounce (output wire debounced,input wire pb,input wire clk);
	reg [3:0] DFF;
	always@(posedge clk)begin
		DFF[3:1]<=DFF[2:0];
		DFF[0]<=pb;
	end
	assign debounced=(DFF==4'b1111)?1'b1:1'b0;
endmodule

module One_Pulse(output reg single_signal,input wire signal,input clk);
	reg delay;
	always@(posedge clk)begin
		single_signal<=signal&&(!delay);
		delay<=signal;
	end
endmodule
