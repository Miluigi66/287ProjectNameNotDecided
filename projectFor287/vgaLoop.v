module mainVGALoop (
	input wire              rst,
	input wire              clk,
	input wire              active_pixels,
	input wire [9:0]        x,
	input wire [9:0]        y,

	// Memory read data
	input wire [2:0]        map_data_dout,
	input wire [5:0]        room_data_dout,
	input wire [23:0]       room_tile_dout,

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

	// Map coordinate (0,0) is stored at address 0 in the 4x4 map.
	assign map_data_we = 1'b0;
	assign map_data_addr = 4'd0;
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

	always @(*) begin
		if (active_pixels)
			vga_color = room_tile_dout;
		else
			vga_color = 24'h000000;
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



/*
module mainVGALoop (
	input                   	rst,
	input                   	clk,
	input                   	active_pixels,
	input                   	entity_mem_done,
	input                   	room_mem_done,
	input                   	tile_mem_done,
	input                   	color_update_done,
	input                   	map_data_done,
	
	// VGA data to send/read (read from x and y and output vga_color)
	input  wire [9:0]			x,
	input  wire [9:0]			y,
	output reg  [23:0]			vga_color,

	// all tile, entity, room, and map memory ONLY select and read signals
	output wire [23:0]			entity_data_dout,
	output wire [9:0]			entity_data_addr,

	output wire [23:0]			entity_sprite_dout,
	output wire [9:0]			entity_sprite_addr,

	output wire [5:0]			room_tile_dout,
	output wire [9:0]			room_tile_addr,

	// State outputs
	output wire [2:0]			VGC,
	output wire [2:0]			VEC
);

	// ----------------------------------- Instantiation of the stateVGALoop
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


	// ----------------------------------- next state of room and map memory address selection
	reg [9:0] room_tile_addr;
	reg [9:0] entity_data_addr;
	reg [9:0] entity_sprite_addr;
	reg [24:0] entity_data_dout;
	reg [24:0] to_draw_vga_color;

	// ----------------------------------- VGA data update logic
	
	always @(*)
	begin
		case (VGC)
			VGA_IDLE: begin
				// Do nothing, wait for active pixels
				//reset all done signals to 0
				entity_mem_done = 1'b0;
				room_mem_done = 1'b0;
				tile_mem_done = 1'b0;
				color_update_done = 1'b0;
				map_data_done = 1'b0;
			end
			VGA_DRAW: begin
				// Read entity memory, room memory, and tile memory to prepare for color update
			end
			VGA_UPDATE: begin
				// Update the VGA color based on the data read from memory
			end
			default: begin
				// Default case, should not happen
			end
		endcase

		case (VEC)
			READ_ENTITY_MEM: begin
				// Read entity memory
				entity_mem_done = 1'b1; 
			end
			READ_MAP_DATA: begin
				// Read map data first so it selects the room before room memory is read
				map_data_done = 1'b1;

				case (map_data_dout)
					3'b000: room_tile_addr = 10'd0; // Room 0
					3'b001: room_tile_addr = 10'd1; // Room 1
					3'b010: room_tile_addr = 10'd2; // Room 2
					3'b011: room_tile_addr = 10'd3; // Room 3
					3'b100: room_tile_addr = 10'd4; // Room 4
					3'b101: room_tile_addr = 10'd5; // Room 5
					3'b110: room_tile_addr = 10'd6; // Room 6
					3'b111: room_tile_addr = 10'd7; // Room 7
					default: room_tile_addr = 10'd0; // Default to Room 0 if invalid data
				endcase

			end
			READ_ROOM_MEM: begin
				// Read room memory
				room_mem_done = 1'b1;

				case (room_data_dout)
					6'b000000: room_tile_addr = 10'd0; // Tile 0
					6'b000001: room_tile_addr = 10'd1; // Tile 1
					6'b000010: room_tile_addr = 10'd2; // Tile 2
					6'b000011: room_tile_addr = 10'd3; // Tile 3
					6'b000100: room_tile_addr = 10'd4; // Tile 4
					6'b000101: room_tile_addr = 10'd5; // Tile 5
					6'b000110: room_tile_addr = 10'd6; // Tile 6
					6'b000111: room_tile_addr = 10'd7; // Tile 7
					6'b001000: room_tile_addr = 10'd8; // Tile 8
					6'b001001: room_tile_addr = 10'd9; // Tile 9
					6'b001010: room_tile_addr = 10'd10; // Tile 10
					6'b001011: room_tile_addr = 10'd11; // Tile 11
					6'b001100: room_tile_addr = 10'd12; // Tile 12
					6'b001101: room_tile_addr = 10'd13; // Tile 13
					6'b001110: room_tile_addr = 10'd14; // Tile 14
					6'b001111: room_tile_addr = 10'd15; // Tile 15
					default: room_tile_addr = 10'd0; // Default to Tile 0 if invalid data
				endcase


			end
			READ_TILE_MEM: begin
				// Read tile memory
				tile_mem_done = 1'b1;

				// Selects the color to draw based on the tile data off the x and y coordinates
				to_draw_vga_color = room_tile_dout[[y[3:0], x[3:0]]]; // 16x16 tiles, using lower 4 bits of x and y for indexing

			end
			UPDATE_VGA_COLOR: begin
				// Update VGA color based on the data read from memory
				vga_color = to_draw_vga_color;

			end
			default: begin
				// Default case, should not happen
				vga_color = 24'h000000; // Default to black
			end
		endcase
	end
	

endmodule



module stateVGALoop (
	input                   	rst,
	input                   	clk,
	input                   	active_pixels,
	input                   	entity_mem_done,
	input                   	room_mem_done,
	input                   	tile_mem_done,
	input                   	color_update_done,
	input                   	map_data_done,

	// State outputs
	output reg [2:0]			VGC,
	output reg [2:0]			VEC
);

// -------------------------------------- Parameters for VGA state machines
`include "gameStates.vh"

// Next-state registers
reg [2:0] VGN;
reg [2:0] VEN;


// -------------------------------------- VGA controller next state
always @(*)
begin
	VGN = VGC;

	case (VGC)
		VGA_IDLE: begin
			if (active_pixels)
				VGN = VGA_DRAW;
		end
		VGA_DRAW: begin
			if (color_update_done)
				VGN = VGA_UPDATE;
		end
		VGA_UPDATE: begin
			if (!active_pixels)
				VGN = VGA_IDLE;
		end
		default: VGN = VGA_IDLE;
	endcase
end


// -------------------------------------- VGA memory/data loop next state
always @(*)
begin
	VEN = VEC;

	case (VEC)
		READ_ENTITY_MEM: begin
			if (entity_mem_done)
				VEN = READ_MAP_DATA;
		end
		READ_MAP_DATA: begin
			if (map_data_done)
				VEN = READ_ROOM_MEM;
		end
		READ_ROOM_MEM: begin
			if (room_mem_done)
				VEN = READ_TILE_MEM;
		end
		READ_TILE_MEM: begin
			if (tile_mem_done)
				VEN = UPDATE_VGA_COLOR;
		end
		UPDATE_VGA_COLOR: begin
			if (color_update_done)
				// TEST MODE: go directly to map data instead of reading entities
				VEN = READ_MAP_DATA;
		end
		default: VEN = READ_MAP_DATA;
	endcase
end


// -------------------------------------- State registers
always @(posedge clk or negedge rst)
begin
	if (!rst) begin
		VGC <= VGA_IDLE;
		// TEST MODE: begin with map data instead of reading the entity list
		VEC <= READ_MAP_DATA;
	end
	else begin
		VGC <= VGN;
		VEC <= VEN;
	end
end

endmodule

*/
