`timescale 1ns / 1ps
parameter DATA_SIZE = 32;
module adder(A, B, S, overflow);
input[DATA_SIZE-1:0] A;
input[DATA_SIZE-1:0] B;
output[DATA_SIZE-1:0] S;
output overflow;
wire[DATA_SIZE:0] eA = {A[DATA_SIZE-1], A};
wire[DATA_SIZE:0] eB = {B[DATA_SIZE-1], B};
wire[DATA_SIZE:0] eS = eA + eB;
assign S = eS[DATA_SIZE-1:0];
assign overflow = eS[DATA_SIZE-1] ^ eS[DATA_SIZE];
endmodule
