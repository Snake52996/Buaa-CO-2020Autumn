`timescale 1ns / 1ps
module CTRL_and(
	opcode, funct, extra,
	add, addi, addiu, addu, sand, andi, beq, bgez, bgezal, bgtz, blez, bltz, bltzal, bne, div, divu, j, jal, jalr, jr, lui,
	lw, mfhi, mflo, mthi, mtlo, mult, multu, snor, sor, ori, sll, sllv, slt, slti, sltiu, sltu, sra, srav, srl, srlv, sub,
	subu, sw, sxor, xori
);
input[5:0] opcode, funct;
input[4:0] extra;
output add, addi, addiu, addu, sand, andi, beq, bgez, bgezal, bgtz, blez, bltz, bltzal, bne, div, divu, j, jal, jalr, jr, lui,
	   lw, mfhi, mflo, mthi, mtlo, mult, multu, snor, sor, ori, sll, sllv, slt, slti, sltiu, sltu, sra, srav, srl, srlv, sub,
	   subu, sw, sxor, xori;
	wire special	= opcode == 6'b000000;
	wire special_b	= opcode == 6'b000001;
	// R-types
	assign add		= special && (funct == 6'b100000);
	assign addu		= special && (funct == 6'b100001);
	assign sand		= special && (funct == 6'b100100);
	assign div		= special && (funct == 6'b011010);
	assign divu		= special && (funct == 6'b011011);
	assign jalr		= special && (funct == 6'b001001);
	assign jr		= special && (funct == 6'b001000);
	assign mfhi		= special && (funct == 6'b010000);
	assign mflo		= special && (funct == 6'b010010);
	assign mthi		= special && (funct == 6'b010001);
	assign mtlo		= special && (funct == 6'b010011);
	assign mult		= special && (funct == 6'b011000);
	assign multu	= special && (funct == 6'b011001);
	assign snor		= special && (funct == 6'b100111);
	assign sor		= special && (funct == 6'b100101);
	assign sll		= special && (funct == 6'b000000);
	assign sllv		= special && (funct == 6'b000100);
	assign slt		= special && (funct == 6'b101010);
	assign sltu		= special && (funct == 6'b101011);
	assign sra		= special && (funct == 6'b000011);
	assign srav		= special && (funct == 6'b000111);
	assign srl		= special && (funct == 6'b000010);
	assign srlv		= special && (funct == 6'b000110);
	assign sub		= special && (funct == 6'b100010);
	assign subu		= special && (funct == 6'b100011);
	assign sxor		= special && (funct == 6'b100110);
	// B-types
	assign bgez		= special_b && (extra == 5'b00001);
	assign bgezal	= special_b && (extra == 5'b10001);
	assign bltz		= special_b && (extra == 5'b00000);
	assign bltzal	= special_b && (extra == 5'b10000);
	// I-types
	assign addi		= opcode == 6'b001000;
	assign addiu	= opcode == 6'b001001;
	assign andi		= opcode == 6'b001100;
	assign beq		= opcode == 6'b000100;
	assign bgtz		= opcode == 6'b000111;
	assign blez		= opcode == 6'b000110;
	assign bne		= opcode == 6'b000101;
	assign lui		= opcode == 6'b001111;
	assign lw		= opcode == 6'b100011;
	assign ori		= opcode == 6'b001101;
	assign slti		= opcode == 6'b001010;
	assign sltiu	= opcode == 6'b001011;
	assign sw		= opcode == 6'b101011;
	assign xori		= opcode == 6'b001110;
	// J-types
	assign j		= opcode == 6'b000010;
	assign jal		= opcode == 6'b000011;
endmodule
