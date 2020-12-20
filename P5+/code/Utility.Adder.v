/*
 * File: Utility.Adder.v
 * 32-bit adder with overflow detection(wrapped for further optimization(maybe...))
*/
`timescale 1ns / 1ps
module Adder(
	input[31:0]     A,
	input[31:0]     B,
	input			carry_in,
	output[31:0]    S,
    output          overflow
);
    wire extra_sign;
	assign {extra_sign, S} = {A[31], A} + {B[31], B} + carry_in;
    assign overflow = extra_sign ^ S[31];
endmodule