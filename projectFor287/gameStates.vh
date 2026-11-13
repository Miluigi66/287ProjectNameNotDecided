// ----------------------------------- State parameters for global state machine PROCESSING BLOCK
localparam 
	//State Main Loop
	START = 3'b000, // Goes to boot
	BOOT = 3'b001, // Goes to load map
	LOAD_MAP = 3'b010, // Loads the map and assigns to global reg of what the map is and loops until all enitys on the map are loaded
	GAME_LOOP = 3'b011, // Goes to Game Loop (See below)
	PAUSE = 3'b100, // Goes to pause loop
	ERROR = 3'b101, // Oh no...
	
	// State Game Loop
	READ_ENTITY_LIST = 3'b000, // Keeps going back to read intity list until all intities are read
	UPDATE_ENTITY_LIST = 3'b001, // Updates the singke intity that was read from the list and goes back to read intity list
	PLAYER_INPUT = 3'b010, // IF PLAYER ID: Reads players input then goes to the colision check loop on the 60Hz clock tick then  
	AI_ALGORITHM = 3'b011, // IF NOT PLAYER ID: Runs the AI algorithm for the current intity then goes to colision check loop on the 60Hz clock tick
	COLISION_CHECK = 3'b100, // Goes to colision check loop (See below)

	// State colision loop
	READ_ROOM = 3'b000, // gets the [9:4] of the current enity position and reads the room data for that room
	ROOM_COLISION_CHECK = 3'b001, // Just checks for current enity its on effects of it 
	PLAYER_COLISION_CHECK_VS_ENEMY = 3'b010, // Keeps going back to read intity list until all intities are read VS player (only the player ID can come here)
	CHECK_COLISION_RESULT = 3'b011; // Returns the reg of results for the State game loop to update the part of the intity that was read from the list and goes back to read intity list

// ----------------------------------- State parameters for global state machine VGA BLOCK
localparam 
	// State VGA loop
	VGA_IDLE = 3'b000, // The starting state
	VGA_DRAW = 3'b001, // Draws the current x and y position of the VGA output with the current color data from the VGA memory
	VGA_UPDATE = 3'b010, // Updates the VGA color output with the current color data from the VGA memory

	// VGA entity/data read loop
	READ_ENTITY_MEM = 3'b001, // Reads the current entity data from the entity memory and goes to read room memory if the color is the background color
	READ_ROOM_MEM = 3'b010, // Reads the current room data from the room memory and goes to read tile memory
	READ_TILE_MEM = 3'b011, // Reads the current tile data from the tile memory and goes to update VGA color
	UPDATE_VGA_COLOR = 3'b100, // Updates the VGA color output with the current color data from the VGA memory
	READ_MAP_DATA = 3'b101; // Reads the current map data before reading room memory
