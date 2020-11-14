`timescale 1ns / 1ps
module arithmetic(A, B, ctrl, S, overflow);
input[31:0] A;
input[31:0] B;
input ctrl;
output [31:0] S;
output overflow;
wire[31:0] real_B;
wire[31:0] add_sub_S;
MUX2 negMux(.in1(B), .in2(~B+1), .select(ctrl), .out(real_B));
adder adder(.A(A), .B(real_B), .S(add_sub_S), .overflow(overflow));
assign S = add_sub_S;
endmodule
