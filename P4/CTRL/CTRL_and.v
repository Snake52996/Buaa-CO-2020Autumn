`timescale 1ns / 1ps
module CTRL_and(opcode, funct, addu, subu, ori, lw, sw, beq, lui, jal, jr);
input[5:0] opcode, funct;
output addu, subu, ori, lw, sw, beq, lui, jal, jr;
	wire special = opcode == 6'b000000;
	assign addu = special && (funct == 6'b100001);
	assign subu = special && (funct == 6'b100011);
	assign ori  = opcode == 6'b001101;
	assign lw   = opcode == 6'b100011;
	assign sw   = opcode == 6'b101011;
	assign beq  = opcode == 6'b000100;
	assign lui  = opcode == 6'b001111;
	assign jal  = opcode == 6'b000011;
	assign jr   = special && (funct == 6'b001000);
endmodule
