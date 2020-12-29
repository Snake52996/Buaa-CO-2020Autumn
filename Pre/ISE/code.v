`timescale 1ns / 1ps
`include "counter.v"
module code(
	input Clk,
	input Reset,
	input Slt,
	input En,
	output reg [63:0] Output0,
	output reg [63:0] Output1
    );
	wire c0_enable;
	wire c1_enable;
	wire c0_overflow;
	wire c1_overflow;
	reg c0_discount;
	reg c1_discount;
	assign c0_enable = !Slt && En;
	assign c1_enable = Slt && En;
	counter #(.data_width(1), .max_count(1), .onOverflow(`STAY_AT_CURRENT), .trigger(`RISING_EDGE)) c0 (
		.clock(Clk),
		.enable(c0_enable),
		.reset(Reset),
		.discount(c0_discount),
		.overflow(c0_overflow)
	);
	counter #(.data_width(3), .max_count(4), .onOverflow(`STAY_AT_CURRENT), .trigger(`RISING_EDGE)) c1 (
		.clock(Clk),
		.enable(c1_enable),
		.reset(Reset),
		.discount(c1_discount),
		.overflow(c1_overflow)
	);
	initial begin
		c0_discount = 0;
		c1_discount = 0;
		Output0 = 0;
		Output1 = 0;
	end
	always@(posedge c0_overflow)begin
		Output0 = Output0 + 1;
		c0_discount = ~c0_discount;
	end
	always@(posedge c1_overflow)begin
		Output1 = Output1 + 1;
		c1_discount = ~c1_discount;
	end
	always@(posedge Reset)begin
		Output0 = 0;
		Output1 = 0;
	end
	
endmodule
