`timescale 1ns / 1ps
module SLL2(origin, shifted);
input[31:0] origin;
output[31:0] shifted;
	assign shifted = {origin[29:0], {2{1'b0}}};

endmodule
