`timescale 1ns / 1ps
module CTRL_sort(
	addu, subu, ori, lw, sw, beq, lui, jal, jr,
	jump_on_lt, jump_on_le, jump_on_eq, jump_on_ge, jump_on_gt, jump_on_ne, jump_whatever,
	branch_family, jump_family, jump_register_family,
	signed_extend,
	write_to_rt, write_to_rd, write_to_ra,
	write_GRF_from_ALU, write_GRF_from_PC4, write_GRF_from_DM, write_GRF_from_lt,
	ALU_A_from_rs, ALU_A_from_rt, ALU_A_from_immediate,
	ALU_B_from_rs, ALU_B_from_rt, ALU_B_from_immediate, ALU_B_from_shmat, ALU_B_from_0, ALU_B_from_16,
	ALU_add, ALU_sub, ALU_mult, ALU_div, ALU_sll, ALU_srl, ALU_sra, ALU_or, ALU_and, ALU_xor, ALU_nor, ALU_signed, ALU_signed_cmp,
	DM_read, DM_write
);
input addu, subu, ori, lw, sw, beq, lui, jal, jr;
output jump_on_lt, jump_on_le, jump_on_eq, jump_on_ge, jump_on_gt, jump_on_ne, jump_whatever,
	   branch_family, jump_family, jump_register_family,
	   signed_extend,
	   write_to_rt, write_to_rd, write_to_ra,
	   write_GRF_from_ALU, write_GRF_from_PC4, write_GRF_from_DM, write_GRF_from_lt,
	   ALU_A_from_rs, ALU_A_from_rt, ALU_A_from_immediate,
	   ALU_B_from_rs, ALU_B_from_rt, ALU_B_from_immediate, ALU_B_from_shmat, ALU_B_from_0, ALU_B_from_16,
	   ALU_add, ALU_sub, ALU_mult, ALU_div, ALU_sll, ALU_srl, ALU_sra, ALU_or, ALU_and, ALU_xor, ALU_nor, ALU_signed, ALU_signed_cmp,
	   DM_read, DM_write;
	assign jump_on_lt = 0;
	assign jump_on_le = 0;
	assign jump_on_eq = beq;
	assign jump_on_ge = 0;
	assign jump_on_gt = 0;
	assign jump_on_ne = 0;
	assign jump_whatever = jal || jr;
	assign branch_family = beq;
	assign jump_family = jal;
	assign jump_register_family = jr;
	assign signed_extend = lw || sw || beq;
	assign write_to_rt = ori || lw || lui;
	assign write_to_rd = addu || subu;
	assign write_to_ra = jal;
	assign write_GRF_from_ALU = addu || subu || ori || lui;
	assign write_GRF_from_PC4 = jal;
	assign write_GRF_from_DM = lw;
	assign write_GRF_from_lt = 0;
	assign ALU_A_from_rs = addu || subu || ori || lw || sw || beq;
	assign ALU_A_from_rt = 0;
	assign ALU_A_from_immediate = lui;
	assign ALU_B_from_rs = 0;
	assign ALU_B_from_rt = addu || subu || beq;
	assign ALU_B_from_immediate = ori || lw || sw;
	assign ALU_B_from_shmat = 0;
	assign ALU_B_from_0 = 0;
	assign ALU_B_from_16 = lui;
	assign ALU_add = addu || lw || sw;
	assign ALU_sub = subu;
	assign ALU_mult = 0;
	assign ALU_div = 0;
	assign ALU_sll = lui;
	assign ALU_srl = 0;
	assign ALU_sra = 0;
	assign ALU_or = ori;
	assign ALU_and = 0;
	assign ALU_xor = 0;
	assign ALU_nor = 0;
	assign ALU_signed = 0;
	assign ALU_signed_cmp = 0;
	assign DM_read = lw;
	assign DM_write = sw;
endmodule
