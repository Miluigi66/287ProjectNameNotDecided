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
