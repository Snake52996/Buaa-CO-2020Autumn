`timescale 1ns / 1ps
module IS(Instruction, opcode, rs, rt, rd, shamt, funct, immediate, address);
input[31:0] Instruction;
output[5:0] opcode;
output[4:0] rs;
output[4:0] rt;
output[4:0] rd;
output[4:0] shamt;
output[5:0] funct;
output[15:0] immediate;
output[25:0] address;
	assign opcode = Instruction[31:26];
	assign rs = Instruction[25:21];
	assign rt = Instruction[20:16];
	assign rd = Instruction[15:11];
	assign shamt = Instruction[10:6];
	assign funct = Instruction[5:0];
	assign immediate = Instruction[15:0];
	assign address = Instruction[25:0];
endmodule
