// This is the memory block for the game the ONLY thing that should be initialized is the entity data to set up a blank list
// The other memory blocks should be pre made and loaded into the FPGA using the .mif files in the project folder 
// to design the mem parts use the python script in the project folder to generate the .mif files for the entity data memory block and the other memory blocks


// ---------------------------------------------------------------------- THE ENTITY DATA MEMORY BLOCK
/* How the bits are laid out for the entity data memory block
    35:30 - Entity ID (6 bits)
    29:20 - X Position (10 bits)
    19:10 - Y Position (10 bits)
    9:8   - Direction (2 bits)
    7:4   - AI State (4 bits)
    3:0   - HP (4 bits)


*/

module entityData #(
    parameter DATA_WIDTH = 36,              // Size of each memory word (36 bits)
    parameter MAX_ENTITIES  = 16,            // Total number of memory slots (16 max entities)
    parameter ADDR_WIDTH = $clog2(MAX_ENTITIES), // Address width based on the number of entities
    parameter MEM_DEPTH = MAX_ENTITIES
)(
    input  wire                    clk,    // Clock signal
    input  wire                    we,     // Write Enable (1 = Write, 0 = Read)
    input  wire [ADDR_WIDTH-1:0]   addr,   // Address bus
    input  wire [DATA_WIDTH-1:0]   din,    // Data Input bus
    output reg  [DATA_WIDTH-1:0]   dout    // Data Output register
);

    reg [DATA_WIDTH-1:0] memory_array [0:MEM_DEPTH-1];

    // Read and Write Logic
    always @(posedge clk) begin
        if (we) begin
            memory_array[addr] <= din;     // Write behavior: store data into the address
        end
        
        dout <= memory_array[addr];        // Read behavior: read data out from the address
    end

endmodule

// ---------------------------------------------------------------------- THE ENTITY SPRITE MEMORY BLOCK JUST HOW TO ADRESS IT
module entitySprite #(
    parameter FILE_NAME  = "mem/default.mif", // Used to say what file to load into the memory block / default is a blank sprite
    parameter DATA_WIDTH = 24,              // VGA color being 24 bits (8 bits per channel)
    parameter SIZE_OF_SPRITE = 256,          // Size of each sprite (16x16 pixels)
    parameter ADDR_WIDTH = $clog2(SIZE_OF_SPRITE), // Address width for sprite pixels
    parameter MEM_DEPTH = SIZE_OF_SPRITE
)(
    input  wire                    clk,    // Clock signal
    input  wire                    we,     // Write Enable (1 = Write, 0 = Read)
    input  wire [ADDR_WIDTH-1:0]   addr,   // Address bus
    input  wire [DATA_WIDTH-1:0]   din,    // Data Input bus
    output reg  [DATA_WIDTH-1:0]   dout    // Data Output register
);
    (* ram_init_file = FILE_NAME *)
    reg [DATA_WIDTH-1:0] memory_array [0:MEM_DEPTH-1];

    // Read and Write Logic
    always @(posedge clk) begin
        if (we) begin
            memory_array[addr] <= din;     // Write behavior: store data into the address
        end
        
        dout <= memory_array[addr];        // Read behavior: read data out from the address
    end

endmodule

// ---------------------------------------------------------------------- THE TILE MEMORY BLOCK JUST HOW TO ADRESS IT
module roomTiles #(
    parameter FILE_NAME  = "mem/default.mif", // Used to say what file to load into the memory block / default is a blank sprite
    parameter DATA_WIDTH = 24,              // VGA color being 24 bits (8 bits per channel)
    parameter SIZE_OF_SPRITE = 256,          // Size of each sprite (16x16 pixels)
    parameter ADDR_WIDTH = $clog2(SIZE_OF_SPRITE), // Address width for tile pixels
    parameter MEM_DEPTH = SIZE_OF_SPRITE
)(
    input  wire                    clk,    // Clock signal
    input  wire                    we,     // Write Enable (1 = Write, 0 = Read)
    input  wire [ADDR_WIDTH-1:0]   addr,   // Address bus
    input  wire [DATA_WIDTH-1:0]   din,    // Data Input bus
    output reg  [DATA_WIDTH-1:0]   dout    // Data Output register
);
    (* ram_init_file = FILE_NAME *)
    reg [DATA_WIDTH-1:0] memory_array [0:MEM_DEPTH-1];

    // Read and Write Logic
    always @(posedge clk) begin
        if (we) begin
            memory_array[addr] <= din;     // Write behavior: store data into the address
        end
        
        dout <= memory_array[addr];        // Read behavior: read data out from the address
    end

endmodule


// ---------------------------------------------------------------------- THE ROOM MEMORY BLOCK JUST HOW TO ADRESS IT
module roomMem #(
    parameter FILE_NAME  = "mem/defultRoom.mif", // Used to say what file to load into the memory block / default is a blank room
    parameter DATA_WIDTH = 6,              // 6 bits of data for tile choice 
    parameter SIZE_OF_ROOM = 1200,          // Size of each room (40 x 30 tiles of 16x16 pixels chunks)
    parameter ADDR_WIDTH = $clog2(SIZE_OF_ROOM), // Address width for room tiles
    parameter MEM_DEPTH = SIZE_OF_ROOM
)(
    input  wire                    clk,    // Clock signal
    input  wire                    we,     // Write Enable (1 = Write, 0 = Read)
    input  wire [ADDR_WIDTH-1:0]   addr,   // Address bus
    input  wire [DATA_WIDTH-1:0]   din,    // Data Input bus
    output reg  [DATA_WIDTH-1:0]   dout    // Data Output register
);
    (* ram_init_file = FILE_NAME *)
    reg [DATA_WIDTH-1:0] memory_array [0:MEM_DEPTH-1];

    // Read and Write Logic
    always @(posedge clk) begin
        if (we) begin
            memory_array[addr] <= din;     // Write behavior: store data into the address
        end
        
        dout <= memory_array[addr];        // Read behavior: read data out from the address
    end

endmodule

// ---------------------------------------------------------------------- THE MAP MEMORY BLOCK JUST HOW TO ADRESS IT
module mapMem #(
    parameter FILE_NAME  = "mem/defultMap.mif", // Used to say what file to load into the memory block / default is a blank map
    parameter DATA_WIDTH = 3,              // 3 bits of data for room choice 
    parameter SIZE_OF_ROOM = 16,          // Size of each map is 4 x 4
    parameter ADDR_WIDTH = $clog2(SIZE_OF_ROOM), // Address width for rooms in the map
    parameter MEM_DEPTH = SIZE_OF_ROOM
)(
    input  wire                    clk,    // Clock signal
    input  wire                    we,     // Write Enable (1 = Write, 0 = Read)
    input  wire [ADDR_WIDTH-1:0]   addr,   // Address bus
    input  wire [DATA_WIDTH-1:0]   din,    // Data Input bus
    output reg  [DATA_WIDTH-1:0]   dout    // Data Output register
);
    (* ram_init_file = FILE_NAME *)
    reg [DATA_WIDTH-1:0] memory_array [0:MEM_DEPTH-1];

    // Read and Write Logic
    always @(posedge clk) begin
        if (we) begin
            memory_array[addr] <= din;     // Write behavior: store data into the address
        end
        
        dout <= memory_array[addr];        // Read behavior: read data out from the address
    end

endmodule
