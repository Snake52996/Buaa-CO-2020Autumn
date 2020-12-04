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
    wire[31:0] real_B;
    MUX2#(32)real_B_MUX(
        .in1(B), .in2(~B+32'd1), .select(negative), .out(real_B)
    );
    Adder Arithmetic_Adder(
        .A(A), .B(real_B), .S(S), .overflow(overflow)
    );
endmodule