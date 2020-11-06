`timescale 1ns / 1ps
module gray(
	input Clk,
	input Reset,
	input En,
	output[2:0] Output,
	output reg Overflow
    );
	reg[2:0] counter;
	initial begin
		counter = 0;
		Overflow = 0;
	end
	always@(posedge Clk)begin
		if(Reset)begin
			counter <= 0;
			Overflow <= 0;
		end else if(En)begin
			counter <= counter + 1;
			if(counter === 7) Overflow <= 1;
		end
	end
	assign Output =
		(counter === 0) ? (0) :
		(counter === 1) ? (1) :
		(counter === 2) ? (3) :
		(counter === 3) ? (2) :
		(counter === 4) ? (6) :
		(counter === 5) ? (7) :
		(counter === 6) ? (5) :
		(counter === 7) ? (4) : 3'bxxx;
endmodule
