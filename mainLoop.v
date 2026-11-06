module mainLoop	(
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




// ----------------------------------- State registers
//State Main Loop
reg [1:0]SMC;
reg [1:0]SMN;
	
// State Game Loop
reg [1:0]SGC;
reg [1:0]SGN;

// State colision loop
reg [1:0]SCC;
reg [1:0]SCN;





// ----------------------------------- State parameters
parameter
	//State Main Loop
	START = 1'b0,
	BOOT = 1'b0,
	LOAD_MAP = 1'b0,
	GAME_LOOP = 1'b0,
	PAUSE = 1'b0,
	ERROR = = 1'b0;
	// State Game Loop
	
	
	
	
	// State colision loop
	
	


// -------------------------------------- To next state always
always @(*)
begin
	if (rst == 1'b0)
		SMC <= START;
	else
		SMC <= SMN;
end


// -------------------------------- Next state from clock incrments 

always @(posedge clk or negedge rst)
begin

	case(SMC)








end

endmodule


