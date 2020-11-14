`timescale 1ns / 1ps
module ALU(A, B, ctrl, signed_comp, S, overflow, ne, lt, le, eq, ge, gt, t);
input[31:0] A;
input[31:0] B;
input[1:0] ctrl;
input signed_comp;
output[31:0] S;
output overflow;
output ne;
output lt;
output le;
output eq;
output ge;
output gt;
output t;
	wire[31:0] arithmetic_result;
	wire[31:0] logic_result;
	wire[31:0] shifter_result;
	wire[1:0] result_select;
	wire neg_b;
	wire l_ctrl;
	wire s_ctrl;
	controller(.ctrl(ctrl), .result_select(result_select), .neg_b(neg_b), .l_ctrl(l_ctrl), .s_ctrl(s_ctrl));
	arithmetic(.A(A), .B(B), .ctrl(neg_b), .S(arithmetic_result), .overflow(overflow));
	logical(.A(A), .B(B), .ctrl(l_ctrl), .S(logic_result));
	shifter(.A(A), .B(B), .ctrl(s_ctrl), .S(shifter_result));
	comparer(.A(A), .B(B), .signed_comp(signed_comp), .ne(ne), .lt(lt), .le(le), .eq(eq), .ge(ge), .gt(gt), .t(t));
	MUX3(.in1(arithmetic_result), .in2(logic_result), .in3(shifter_result), .select(result_select), .out(S));
endmodule
