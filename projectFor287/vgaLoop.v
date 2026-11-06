module mainVGALoop (
	input                   	rst,
	input                   	clk,
	input                   	active_pixels,
	input                   	entity_mem_done,
	input                   	room_mem_done,
	input                   	tile_mem_done,
	input                   	color_update_done,

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
				VEN = READ_ENTITY_MEM;
		end
		default: VEN = READ_ENTITY_MEM;
	endcase
end


// -------------------------------------- State registers
always @(posedge clk or negedge rst)
begin
	if (!rst) begin
		VGC <= VGA_IDLE;
		VEC <= READ_ENTITY_MEM;
	end
	else begin
		VGC <= VGN;
		VEC <= VEN;
	end
end

endmodule
