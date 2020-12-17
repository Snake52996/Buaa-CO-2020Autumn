/*
 * File: Utility.WriteThroughRegister.v
 * Register with clk/reset/enable and writes through, i.e. has inner forwarding
*/
module WriteThroughRegister#(DATA_SIZE=32,INITIAL_VALUE=0)(
    input[DATA_SIZE-1:0]        D,
    input                       clk,
    input                       reset,
    input                       enable,
    output[DATA_SIZE-1:0]       Q
);
    wire[DATA_SIZE-1:0] register_Q;
    Register#(DATA_SIZE,INITIAL_VALUE)inner_register(
        .D(D), .clk(clk), .reset(reset), .enable(enable), .Q(register_Q)
    );
    assign Q = enable ? D : register_Q;
endmodule