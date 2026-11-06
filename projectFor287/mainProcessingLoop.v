module mainProcessingLoop	(
  	input                   	clock_60hz_tick,
	input                   	rst,
	input                   	load_map_done,
	input                   	entity_list_done,
	input                   	current_entity_is_player,
	input                   	room_collision_done,
	input                   	enemy_collision_done,
	input						clk,
	input						pause,

	// ----------------------------------- State outputs
	// State Main Loop
	output reg [2:0]	SMC,
	// State Game Loop
	output reg [2:0]	SGC,
	// State colision loop
	output reg [2:0]	SCC
);

// -------------------------------------- Parameters for global state machine PROCESSING BLOCK
`include "gameStates.vh"

reg [2:0] SMN; // Next state for main loop
reg [2:0] SGN; // Next state for game loop
reg [2:0] SCN; // Next state for colision loop


// -------------------------------------- Main loop next state
always @(*)
begin
	SMN = SMC;

	case (SMC)
		START:    SMN = BOOT;
		BOOT:     SMN = LOAD_MAP;
		LOAD_MAP: begin
			// Add map loading states here  The main loop remains in
			// LOAD_MAP until the complete map has been loaded.
			// This is just so that the entity list can be loaded and the game can start.
			if (load_map_done)
				SMN = GAME_LOOP;
		end
		GAME_LOOP: begin
			if (pause)
				SMN = PAUSE;
		end
		PAUSE: begin
			if (!pause)
				SMN = GAME_LOOP;
		end
		ERROR:    SMN = ERROR;
		default:  SMN = ERROR;
	endcase
end


// -------------------------------------- Game loop next state
always @(*)
begin
	SGN = SGC;

	case (SGC)
	// Reads the Entity list then takes the data to player input or AI algorithm then goes to colision check loop and then back to read entity list until all entitys are done
		READ_ENTITY_LIST: begin
			if (entity_list_done)
				SGN = READ_ENTITY_LIST;
			else if (current_entity_is_player)
				SGN = PLAYER_INPUT;
			else
				SGN = AI_ALGORITHM;
		end
		PLAYER_INPUT: begin
			if (clock_60hz_tick)
				SGN = COLISION_CHECK;
		end
		AI_ALGORITHM: begin
			if (clock_60hz_tick)
				SGN = COLISION_CHECK;
		end
		COLISION_CHECK: begin
			if (clock_60hz_tick)
				SGN = UPDATE_ENTITY_LIST;
		end
		UPDATE_ENTITY_LIST: begin
			if (clock_60hz_tick)
				SGN = READ_ENTITY_LIST;
		end
		default: SGN = READ_ENTITY_LIST;
	endcase
end


// ------------------------------------ Collision loop next state
always @(*)
begin
	SCN = SCC;

	case (SCC)
		READ_ROOM: begin
			// Room data is read by the logic added for the current map.
			if (room_collision_done)
				SCN = ROOM_COLISION_CHECK;
		end
		ROOM_COLISION_CHECK: begin
			if (current_entity_is_player)
				SCN = PLAYER_COLISION_CHECK_VS_ENEMY;
			else
				SCN = CHECK_COLISION_RESULT;
		end
		PLAYER_COLISION_CHECK_VS_ENEMY: begin
			if (enemy_collision_done)
				SCN = CHECK_COLISION_RESULT;
		end
		CHECK_COLISION_RESULT: SCN = READ_ROOM;
		default:              SCN = READ_ROOM;
	endcase
end


// -------------------------------------- State registers
always @(posedge clk or negedge rst)
begin
	if (!rst) begin
		SMC <= START;
		SGC <= READ_ENTITY_LIST;
		SCC <= READ_ROOM;
	end
	else begin
		SMC <= SMN;
		SGC <= SGN;
		SCC <= SCN;
	end
end

endmodule
