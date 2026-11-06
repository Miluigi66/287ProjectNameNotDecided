// This is for a Legend of zelda like game on the:
// FPGA on the DE1-SOC: Cyclone V SoC 5CSEMA5F31C6



module gameInitiation	(
  	//////////// ADC //////////
	//output		          		ADC_CONVST,
	//output		          		ADC_DIN,
	//input 		          		ADC_DOUT,
	//output		          		ADC_SCLK,

	//////////// Audio //////////
	//input 		          		AUD_ADCDAT,
	//inout 		          		AUD_ADCLRCK,
	//inout 		          		AUD_BCLK,
	//output		          		AUD_DACDAT,
	//inout 		          		AUD_DACLRCK,
	//output		          		AUD_XCK,

	//////////// CLOCK //////////
	//input 		          		CLOCK2_50,
	//input 		          		CLOCK3_50,
	//input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// SDRAM //////////
	//output		    [12:0]		DRAM_ADDR,
	//output		     [1:0]		DRAM_BA,
	//output		          		DRAM_CAS_N,
	//output		          		DRAM_CKE,
	//output		          		DRAM_CLK,
	//output		          		DRAM_CS_N,
	//inout 		    [15:0]		DRAM_DQ,
	//output		          		DRAM_LDQM,
	//output		          		DRAM_RAS_N,
	//output		          		DRAM_UDQM,
	//output		          		DRAM_WE_N,

	//////////// I2C for Audio and Video-In //////////
	//output		          		FPGA_I2C_SCLK,
	//inout 		          		FPGA_I2C_SDAT,

	//////////// SEG7 //////////
	//output		     [6:0]		HEX0,
	//output		     [6:0]		HEX1,
	//output		     [6:0]		HEX2,
	//output		     [6:0]		HEX3,
	//output		     [6:0]		HEX4,
	//output		     [6:0]		HEX5,

	//////////// IR //////////
	//input 		          		IRDA_RXD,
	//output		          		IRDA_TXD,

	//////////// KEY //////////
	//input 		     [3:0]		KEY,

	//////////// LED //////////
	//output		     [9:0]		LEDR,

	//////////// PS2 //////////
	//inout 		          		PS2_CLK,
	//inout 		          		PS2_CLK2,
	//inout 		          		PS2_DAT,
	//inout 		          		PS2_DAT2,

	//////////// SW //////////
	//input 		     [9:0]		SW,

	//////////// Video-In //////////
	//input 		          		TD_CLK27,
	//input 		     [7:0]		TD_DATA,
	//input 		          		TD_HS,
	//output		          		TD_RESET_N,
	//input 		          		TD_VS,

	//////////// VGA //////////
	//output		          		VGA_BLANK_N,
	//output reg	     [7:0]		VGA_B,
	//output		          		VGA_CLK,
	//output reg	     [7:0]		VGA_G,
	//output		          		VGA_HS,
	//output reg	     [7:0]		VGA_R,
	//output		          		VGA_SYNC_N,
	//output		          		VGA_VS

	//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	//inout 		    [35:0]		GPIO_0,

	//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
	//inout 		    [35:0]		GPIO_1

);


// The only conection between PROCESSING BLOCK and VGA BLOCK is the entiy list
// The PROCESSING BLOCK will read the entity list and up date based on player input and AI algorithm
// The VGA BLOCK will read the entity list and update the screen based on the entity list



// ------------------------------------------------------------------------------ MEMORY BLOCKS

// TODO ADD MEM BLOCKS





// ----------------------------------- Parameters for global state machine PROCESSING BLOCK
`include "gameStates.vh"


// ----------------------------------- Instantiation of State Machine Cores and other modules
// State Machine Cores
wire SMC, SGC, SCC;
// State helper signals
wire load_map_done, entity_list_done, current_entity_is_player, room_collision_done, enemy_collision_done;
// Clock and reset
wire clk;
assign clk = CLOCK_50;
wire rst;
assign rst = ~SW[0];
// Pause signal
wire pause;
assign pause = SW[1];


// -------------------------------------------------------------------------------------- PROCESSING BLOCKS


// TODO:
/*
    1) Implement the main game loop
    2) Add collision detection
    3) Implement game state management based on the state machine defined in gameStates.vh and mainProcessingLoop.v
*/




// ----------------------------------- Instantiation of the main loop
mainProcessingLoop mainProcessingLoop_inst (
    .clock_60hz_tick(clock_60hz_tick),
    .rst(rst),
    .load_map_done(load_map_done),
    .entity_list_done(entity_list_done),
    .current_entity_is_player(current_entity_is_player),
    .room_collision_done(room_collision_done),
    .enemy_collision_done(enemy_collision_done),
    .CLOCK_50(clk),
    .pause(pause),

    .SMC(SMC),
    .SGC(SGC),
    .SCC(SCC)
);

// ----------------------------------- Instantiation of the 60Hz clock tick generator
frame_tick_60Hz frame_tick_60Hz_inst (
    .clk_in(clk),
    .rst_n(rst),
    .tick_60Hz(clock_60hz_tick)
);



// -------------------------------------------------------------------------------------- VGA BLOCKS

// ----------------------------------- Instantiation of the VGA driver
vga_driver vga_driver_inst (
    .clk(clk),
    .rst(rst),
    .VGA_BLANK_N(VGA_BLANK_N),
    .VGA_B(VGA_B),
    .VGA_CLK(VGA_CLK),
    .VGA_G(VGA_G),
    .VGA_HS(VGA_HS),
    .VGA_R(VGA_R),
    .VGA_SYNC_N(VGA_SYNC_N),
    .VGA_VS(VGA_VS)
);



// TODO:
/*    
    The state machines
    How it would look:
        VGA driver -> read entity list -> if entity list is done -> SEE 1
                                       -> if entity list is not done -> SEE 2



        1) If entity list is done:
            read room mem -> read tile mem -> update curent color at the x,y on VGA driver

        2) If entity list is not done:
            read entity mem -> update current color at the x,y on VGA driver
                IF THE ENTITY HAS A THE DESIGNATED BACKGROUND COLOR, THEN go to 1


    The Programing for the state machines
*/




endmodule
