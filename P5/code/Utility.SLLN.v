/*
 * File: Utility.SLLN.v
 * Shift Left Logically N(constant) bits with configurable data width
*/
module SLLN#(DATA_SIZE, N)(
    input[DATA_SIZE-1:0]      origin,
    output[DATA_SIZE-1:0]     result
);
    assign result = {origin[DATA_SIZE-N-1:0], {N{1'b0}}};
endmodule