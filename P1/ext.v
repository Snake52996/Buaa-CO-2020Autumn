`timescale 1ns / 1ps
module ext(
	input[15:0] imm,
	input[1:0] EOp,
	output[31:0] ext
    );
	wire[31:0] immm;
	assign immm = imm;
	assign ext =
		(EOp === 0) ? ($signed($signed(immm << 16) >>> 16)) :
		(EOp === 1) ? (immm) :
		(EOp === 2) ? (immm << 16) :
		(EOp === 3) ? ($signed($signed(immm << 16) >>> 14)) : 32'bxxxxxxxx_xxxxxxxx_xxxxxxxx_xxxxxxxx;


endmodule
