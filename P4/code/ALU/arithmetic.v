`timescale 1ns / 1ps
/*
 * ctrl:
 *		0 -- add
 *		1 -- sub
*/
module arithmetic_AS(A, B, ctrl, S, overflow);
input[31:0] A;
input[31:0] B;
input ctrl;
output [31:0] S;
output overflow;
	wire[31:0] real_B;
	wire[31:0] add_sub_S;
	MUX2#(32)real_B_MUX(.in1(B), .in2(~B+1), .select(ctrl), .out(real_B));
	adder#(32)adder(.A(A), .B(real_B), .S(add_sub_S), .overflow(overflow));
	assign S = add_sub_S;
endmodule
/*
 * ctrl:
 *		000 -- keep LO & HI, set S to LO
 *		001 -- unsigned A * B
 *		010 -- signed A * B
 *		011 -- unsigned A / B
 *		100 -- signed A / B
 *		101 -- load LO from A, keep HI
 *		110 -- load HI from A, keep LO
 *		111 -- keep LO & HI, set S to HI
*/
module arithmetic_MD(A, B, ctrl, clk, reset, S);
input[31:0] A;
input[31:0] B;
input[2:0] ctrl;
input clk, reset;
output[31:0] S;
	reg[31:0] LO, HI;
	wire[31:0] new_LO, new_HI;
	wire[63:0] rA = {{32{1'b0}}, A};
	wire[63:0] rB = {{32{1'b0}}, B};
	wire signed[31:0] sa = A;
	wire signed[31:0] sb = B;
	wire signed[63:0] sA = {{32{A[31]}}, A};;
	wire signed[63:0] sB = {{32{B[31]}}, B};;
	wire[63:0] unsigned_mult = rA * rB;
	wire[63:0] signed_mult = sA * sB;
	wire[63:0] unsigned_div = {A % B, A / B};
	wire[63:0] signed_div = {sa % sb, sa / sb};
	always@(posedge clk)begin
		if(reset)begin
			LO <= 0;
			HI <= 0;
		end else begin
			LO <= new_LO;
			HI <= new_HI;
		end
	end
	MUX8#(32)S_MUX(
		.in1(LO), .in2(unsigned_mult[31:0]), .in3(signed_mult[31:0]), .in4(unsigned_div[31:0]),
		.in5(signed_div[31:0]), .in6(A), .in7(A), .in8(HI), .select(ctrl), .out(S)
	);
	MUX8#(32)new_LO_MUX(
		.in1(LO), .in2(unsigned_mult[31:0]), .in3(signed_mult[31:0]), .in4(unsigned_div[31:0]),
		.in5(signed_div[31:0]), .in6(A), .in7(LO), .in8(LO), .select(ctrl), .out(new_LO)
	);
	MUX8#(32)new_HI_MUX(
		.in1(HI), .in2(unsigned_mult[63:32]), .in3(signed_mult[63:32]), .in4(unsigned_div[63:32]),
		.in5(signed_div[63:32]), .in6(HI), .in7(A), .in8(HI), .select(ctrl), .out(new_HI)
	);
endmodule
