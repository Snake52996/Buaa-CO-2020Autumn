`timescale 1ns / 1ps
/*
 * ctrl:
 *		00000 -- S <- A + B
 *		00001 -- S <- A - B
 *		00010 -- S <- A | B
 *		00011 -- S <- A << B
 *		00100 -- S, LO <- (A * B)[31:0]; HI <- (A * B)[63:32];
 *		00101 -- S, LO <- ($signed(A) * $signed(B))[31:0]; HI <- ($signed(A) * $signed(B))[63:32];
 *		00110 -- S, LO <- A / B; HI <- A % B;
 *		00111 -- S, LO <- $signed(A) / $signed(B); HI <- $signed(A) % $signed(B);
 *		01000 -- S <- A & B
 *		01001 -- S <- ~(A | B)
 *		01010 -- S <- A ^ B
 *		01011 -- S <- A >> B
 *		01100 -- S <- A >>> B
 *		01101 -- S <- LO
 *		01110 -- S <- HI
 *		01111 -- LO <- A
 *		10000 -- HI <- A
 *
*/
module ALU(A, B, ctrl, signed_comp, clk, reset, S, overflow, zero, ne, lt, le, eq, ge, gt, t);
input[31:0] A, B;
input[4:0] ctrl;
input signed_comp, clk, reset;
output[31:0] S;
output overflow, zero, ne, lt, le, eq, ge, gt, t;
	wire[31:0] arithmetic_AS_result, arithmetic_MD_result, logic_result, shifter_result;
	wire[2:0] arithmetic_MD_ctrl;
	wire[1:0] result_select, logical_ctrl, shifter_ctrl;
	wire arithmetic_AS_ctrl;
	assign zero = (S == 0);
	controller controller(
		.ctrl(ctrl), .result_select(result_select), .arithmetic_AS_ctrl(arithmetic_AS_ctrl), .logical_ctrl(logical_ctrl),
		.shifter_ctrl(shifter_ctrl), .arithmetic_MD_ctrl(arithmetic_MD_ctrl)
	);
	arithmetic_AS arithmetic_AS(
		.A(A), .B(B), .ctrl(arithmetic_AS_ctrl), .S(arithmetic_AS_result), .overflow(overflow)
	);
	arithmetic_MD arithmetic_MD(
		.A(A), .B(B), .ctrl(arithmetic_MD_ctrl), .clk(clk), .reset(reset), .S(arithmetic_MD_result)
	);
	logical logical(.A(A), .B(B), .ctrl(logical_ctrl), .S(logic_result));
	shifter shifter(.A(A), .B(B[4:0]), .ctrl(shifter_ctrl), .S(shifter_result));
	comparer comparer(.A(A), .B(B), .signed_comp(signed_comp), .ne(ne), .lt(lt), .le(le), .eq(eq), .ge(ge), .gt(gt), .t(t));
	MUX4#(32)ALU_S_MUX(
		.in1(arithmetic_AS_result), .in2(logic_result), .in3(shifter_result), .in4(arithmetic_MD_result),
		.select(result_select), .out(S)
	);
endmodule
