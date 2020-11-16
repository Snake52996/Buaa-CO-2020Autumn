`timescale 1ns / 1ps
module CTRL_sort(
	add, addi, addiu, addu, sand, andi, beq, bgez, bgezal, bgtz, blez, bltz, bltzal, bne, div, divu, j, jal, jalr, jr, lui,
	lw, mfhi, mflo, mthi, mtlo, mult, multu, snor, sor, ori, sll, sllv, slt, slti, sltiu, sltu, sra, srav, srl, srlv, sub,
	subu, sw, sxor, xori,
	jump_on_lt, jump_on_le, jump_on_eq, jump_on_ge, jump_on_gt, jump_on_ne, jump_whatever,
	branch_family, jump_family, jump_register_family,
	signed_extend,
	write_to_rt, write_to_rd, write_to_ra,
	write_GRF_from_ALU, write_GRF_from_PC4, write_GRF_from_DM, write_GRF_from_lt,
	ALU_A_from_rs, ALU_A_from_rt, ALU_A_from_immediate,
	ALU_B_from_rs, ALU_B_from_rt, ALU_B_from_immediate, ALU_B_from_shmat, ALU_B_from_0, ALU_B_from_16,
	ALU_add, ALU_sub, ALU_mult, ALU_div, ALU_sll, ALU_srl, ALU_sra, ALU_or, ALU_and, ALU_xor, ALU_nor, ALU_signed_cal, ALU_signed_cmp,
	ALU_read_LO, ALU_read_HI, ALU_write_LO, ALU_write_HI,
	DM_read, DM_write
);
input add, addi, addiu, addu, sand, andi, beq, bgez, bgezal, bgtz, blez, bltz, bltzal, bne, div, divu, j, jal, jalr, jr, lui,
	  lw, mfhi, mflo, mthi, mtlo, mult, multu, snor, sor, ori, sll, sllv, slt, slti, sltiu, sltu, sra, srav, srl, srlv, sub,
	  subu, sw, sxor, xori;
output jump_on_lt, jump_on_le, jump_on_eq, jump_on_ge, jump_on_gt, jump_on_ne, jump_whatever,
	   branch_family, jump_family, jump_register_family,
	   signed_extend,
	   write_to_rt, write_to_rd, write_to_ra,
	   write_GRF_from_ALU, write_GRF_from_PC4, write_GRF_from_DM, write_GRF_from_lt,
	   ALU_A_from_rs, ALU_A_from_rt, ALU_A_from_immediate,
	   ALU_B_from_rs, ALU_B_from_rt, ALU_B_from_immediate, ALU_B_from_shmat, ALU_B_from_0, ALU_B_from_16,
	   ALU_add, ALU_sub, ALU_mult, ALU_div, ALU_sll, ALU_srl, ALU_sra, ALU_or, ALU_and, ALU_xor, ALU_nor, ALU_signed_cal, ALU_signed_cmp,
	   ALU_read_LO, ALU_read_HI, ALU_write_LO, ALU_write_HI,
	   DM_read, DM_write;
	assign jump_on_lt = bltz || bltzal;
	assign jump_on_le = blez;
	assign jump_on_eq = beq;
	assign jump_on_ge = bgez || bgezal;
	assign jump_on_gt = bgtz;
	assign jump_on_ne = bne;
	assign jump_whatever = j || jal || jalr || jr;
	assign branch_family = beq || bgez || bgezal || bgtz || blez || bltz || bltzal || bne;
	assign jump_family = j || jal;
	assign jump_register_family = jalr || jr;
	assign signed_extend = addi || addiu || beq || bgez || bgezal || bgtz || blez || bltz || bltzal || bne || lw || slti || sltiu || sw;
	assign write_to_rt = addi || addiu || andi || lui || lw || ori || slti || sltiu || xori;
	assign write_to_rd = add || addu || sand || jalr || mfhi || mflo || snor || sor || sll || sllv || slt || sltu || sra || srav || srl || srlv || sub || subu || sxor;
	assign write_to_ra = bgezal || bltzal || jal;
	assign write_GRF_from_ALU = add || addi || addiu || addu || sand || andi || lui || mfhi || mflo || snor || sor || ori || sll || sllv || sra || srav || srl || srlv || sub || subu || sxor || xori;
	assign write_GRF_from_PC4 = bgezal || bltzal || jal || jalr;
	assign write_GRF_from_DM = lw;
	assign write_GRF_from_lt = slt || slti || sltiu || sltu;
	assign ALU_A_from_rs = add || addi || addiu || addu || sand || andi || beq || bgez || bgezal || bgtz || blez || bltz || bltzal || bne || div || divu || lw || mthi || mtlo || mult || multu || snor || sor || ori || slt || slti || sltiu || sltu || sub || subu || sw || sxor || xori;
	assign ALU_A_from_rt = sll || sllv || sra || srav || srl || srlv;
	assign ALU_A_from_immediate = lui;
	assign ALU_B_from_rs = sllv || srav || srlv;
	assign ALU_B_from_rt = add || addu || sand || beq || bne || div || divu || mult || multu || snor || sor || slt || sltu || sub || subu || sxor;
	assign ALU_B_from_immediate = addi || addiu || andi || lw || ori || slti || sltiu || sw || xori;
	assign ALU_B_from_shmat = sll || sra || srl;
	assign ALU_B_from_0 = bgez || bgezal || bgtz || blez || bltz || bltzal;
	assign ALU_B_from_16 = lui;
	assign ALU_add = add || addi || addiu || addu || lw || sw;
	assign ALU_sub = sub || subu;
	assign ALU_mult = mult || multu;
	assign ALU_div = div || divu;
	assign ALU_sll = lui || sll || sllv;
	assign ALU_srl = srl || srlv;
	assign ALU_sra = sra || srav;
	assign ALU_or = sor || ori;
	assign ALU_and = sand || andi;
	assign ALU_xor = sxor || xori;
	assign ALU_nor = snor;
	assign ALU_signed_cal = mult || div;
	assign ALU_signed_cmp = beq || bgez || bgezal || bgtz || blez || bltz || bltzal || bne || slt || slti;
	assign ALU_read_LO = mflo;
	assign ALU_read_HI = mfhi;
	assign ALU_write_LO = mtlo;
	assign ALU_write_HI = mthi;
	assign DM_read = lw;
	assign DM_write = sw;
endmodule
