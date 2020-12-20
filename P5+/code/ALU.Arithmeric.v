/*
 * File: ALU.Arithmetic.v
 * Arithmetical calculating unit
*/
module Arithmetic(
    input[31:0]         A,
    input[31:0]         B,
    input               negative,
    output[31:0]        S,
    output              overflow
);
    wire[32:0] temp_A = {A[31], A};
    wire[32:0] temp_B = {B[31], B};
    wire[32:0] temp_S = negative ? (temp_A - temp_B) : (temp_A + temp_B);
    assign overflow = temp_S[32] ^ temp_S[31];
    assign S = temp_S[31:0];
endmodule