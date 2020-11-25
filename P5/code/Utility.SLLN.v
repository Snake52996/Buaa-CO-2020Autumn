/*
 * File: Utility.SLLN.v
 * Shift Left Logically N(constant) bits with configurable data width
*/
module SLLN#(DATA_SIZE=32,N=16)(
    input[DATA_SIZE-1:0]      origin,
    output[DATA_SIZE-1:0]     result
);
    wire[N-1:0]             ignored;
    wire[DATA_SIZE-N-1:0]   preserved;
    assign {ignored, preserved} = origin;
    assign result = {preserved, {N{1'b0}}};
endmodule