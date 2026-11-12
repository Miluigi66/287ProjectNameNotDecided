# 287ProjectNameNotDecided
A project for 287 that has not been fully decided yet, but VGA will be used




As a simple place to put TODO right now

We still need to implment mem and the python code to help make the mem


NOTe FOR LATER:

module sprite_ram #(
    parameter FILE_NAME = "default.mif",
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 10
)(
    input  wire                  clk,
    input  wire [ADDR_WIDTH-1:0] addr,
    output reg  [DATA_WIDTH-1:0] q
);

    // Apply the synthesis attribute using the string parameter
    (* ram_init_file = FILE_NAME *) reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    always @(posedge clk) begin
        q <= mem[addr];
    end

endmodule
