`timescale 1ns / 1ps
/*
 * ctrl:
 *		00 -- sll
 *		01 -- srl
 *		10 -- sra
*/
module shifter(A, B, ctrl, S);
input[31:0] A;
input[4:0] B;
input[1:0] ctrl;
output[31:0] S;
	wire[31:0] sll_result = A << B;
	wire[31:0] srl_result = A >> B;
	wire[31:0] sra_result = ($signed(A) >>> $signed(B));
	MUX3#(32)shifter_S_MUX(.in1(sll_result), .in2(srl_result), .in3(sra_result), .select(ctrl), .out(S));
endmodule
