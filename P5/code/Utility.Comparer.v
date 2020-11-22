/*
 * File: Utility.Comparer.v
 * 32-bit comparer supports signed and unsigned integer compare
*/
`timescale 1ns / 1ps
module Comparer(
	input[31:0] A;
	input[31:0] B;
	input		signed_comp;
	output		ne;
	output		lt;
	output		le;
	output		eq;
	output		ge;
	output		gt;
	output		t;
);
	assign ne = !eq;
	assign le = lt | eq;
	assign ge = gt | eq;
	assign eq = (A === B);
	assign lt = (signed_comp) ? ($signed(A) < $signed(B)) : (A < B);
	assign gt = (signed_comp) ? ($signed(A) > $signed(B)) : (A > B);
	assign t = 1;
endmodule
