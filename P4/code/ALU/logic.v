`timescale 1ns / 1ps
/*
 * ctrl:
 *		00 -- S <- A | B
 *		01 -- S <- A & B
 *		10 -- S <- ~(A | B)
 *		11 -- S <- A ^ B
*/
module logical(A, B, ctrl, S);
input[31:0] A;
input[31:0] B;
input[1:0] ctrl;
output[31:0] S;
	wire[31:0] or_result = A | B;
	wire[31:0] and_result = A & B;
	wire[31:0] nor_result = ~or_result;
	wire[31:0] xor_result = A ^ B;
	MUX4#(32)logic_S_MUX(
		.in1(or_result), .in2(and_result), .in3(nor_result), .in4(xor_result),
		.select(ctrl), .out(S)
	);
endmodule
