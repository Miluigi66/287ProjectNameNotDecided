module mainVGALoop (
	input wire              rst,
	input wire              clk,
	input wire              active_pixels,
	input wire [9:0]        x,
	input wire [9:0]        y,
	input wire [3:0]        map_view_addr,

	// Memory read data
	input wire [2:0]        map_data_dout,
	input wire [5:0]        room_data_dout,
	input wire [23:0]       room_tile_dout,
	output wire [7:0]       entity_sprite_addr,

	// Memory read controls
	output wire             map_data_we,
	output wire [3:0]       map_data_addr,
	output wire [2:0]       map_data_din,
	output wire             room_data_we,
	output wire [10:0]      room_data_addr,
	output wire [5:0]       room_data_din,
	output wire             room_tile_we,
	output wire [7:0]        room_tile_addr,
	output wire [23:0]      room_tile_din,



	input wire [9:0]        playerX,
	input wire [9:0]        playerY,
	input wire [23:0]       entity_sprite_dout,

	output reg [23:0]       vga_color,
	output wire [2:0]       VGC,
	output wire [2:0]       VEC
);

	wire entity_mem_done;
	wire room_mem_done;
	wire tile_mem_done;
	wire color_update_done;
	wire map_data_done;

	// The renderer is currently testing map coordinate (0,0), so the
	// state machine can advance after each synchronous memory read.
	assign entity_mem_done = 1'b1;
	assign room_mem_done = 1'b1;
	assign tile_mem_done = 1'b1;
	assign color_update_done = 1'b1;
	assign map_data_done = 1'b1;

	stateVGALoop stateVGALoop_inst (
		.rst(rst),
		.clk(clk),
		.active_pixels(active_pixels),
		.entity_mem_done(entity_mem_done),
		.room_mem_done(room_mem_done),
		.tile_mem_done(tile_mem_done),
		.color_update_done(color_update_done),
		.map_data_done(map_data_done),
		.VGC(VGC),
		.VEC(VEC)
	);

	// SW[5:2] selects one of the 16 rooms stored in the 4x4 map.
	assign map_data_we = 1'b0;
	assign map_data_addr = map_view_addr;
	assign map_data_din = 3'd0;

	// Room 0 is 40 tiles wide and each tile is 16x16 pixels.
	assign room_data_we = 1'b0;
	assign room_data_addr = active_pixels
		? ((y[9:4] * 11'd40) + x[9:4])
		: 11'd0;
	assign room_data_din = 6'd0;

	// Each room entry selects which separately initialized tile memory
	// supplies the pixel. The address is the pixel within the 16x16 tile.
	assign room_tile_we = 1'b0;
	assign room_tile_addr = active_pixels ? {y[3:0], x[3:0]} : 8'd0;
	assign room_tile_din = 24'd0;


	parameter PLAYERSIZE = 16;
	wire [9:0] player_pixel_x = x - playerX;
	wire [9:0] player_pixel_y = y - playerY;
	assign entity_sprite_addr = {player_pixel_y[3:0], player_pixel_x[3:0]};

	always @(*) begin
		if (!active_pixels)
			vga_color = 24'h000000;
		else if ((x >= playerX) && (player_pixel_x < PLAYERSIZE) &&
				 (y >= playerY) && (player_pixel_y < PLAYERSIZE) &&
				 (entity_sprite_dout != 24'hFF00FF))
			vga_color = entity_sprite_dout;
		else
			vga_color = room_tile_dout;
	end

endmodule


module stateVGALoop (
	input wire              rst,
	input wire              clk,
	input wire              active_pixels,
	input wire              entity_mem_done,
	input wire              room_mem_done,
	input wire              tile_mem_done,
	input wire              color_update_done,
	input wire              map_data_done,
	output reg [2:0]        VGC,
	output reg [2:0]        VEC
);

`include "gameStates.vh"

	reg [2:0] VGN;
	reg [2:0] VEN;

	always @(*) begin
		VGN = VGC;

		case (VGC)
			VGA_IDLE:
				if (active_pixels)
					VGN = VGA_DRAW;
			VGA_DRAW:
				if (color_update_done)
					VGN = VGA_UPDATE;
			VGA_UPDATE:
				if (!active_pixels)
					VGN = VGA_IDLE;
			default:
				VGN = VGA_IDLE;
		endcase
	end

	always @(*) begin
		VEN = VEC;

		case (VEC)
			READ_ENTITY_MEM:
				if (entity_mem_done)
					VEN = READ_MAP_DATA;
			READ_MAP_DATA:
				if (map_data_done)
					VEN = READ_ROOM_MEM;
			READ_ROOM_MEM:
				if (room_mem_done)
					VEN = READ_TILE_MEM;
			READ_TILE_MEM:
				if (tile_mem_done)
					VEN = UPDATE_VGA_COLOR;
			UPDATE_VGA_COLOR:
				if (color_update_done)
					VEN = READ_MAP_DATA;
			default:
				VEN = READ_MAP_DATA;
		endcase
	end

	always @(posedge clk or negedge rst) begin
		if (!rst) begin
			VGC <= VGA_IDLE;
			VEC <= READ_MAP_DATA;
		end
		else begin
			VGC <= VGN;
			VEC <= VEN;
		end
	end

endmodule
