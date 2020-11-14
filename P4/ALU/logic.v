`timescale 1ns / 1ps
module logical(A, B, ctrl, S);
input[31:0] A;
input[31:0] B;
input ctrl;
output[31:0] S;
assign S = A | B;
endmodule
