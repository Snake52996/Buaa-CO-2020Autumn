`timescale 1ns / 1ps
module CTRL(
	opcode, funct,
	compare_select,
	jump_ctrl_temp,
	IFU_addr_select,
	EXT_signed_ext,
	write_GRF,
	GRF_write_addr_select,
	GRF_write_data_select,
	ALU_A_select,
	ALU_B_select,
	ALU_ctrl,
	DM_read_enable,
	DM_write_enable,
	ALU_signed_o,
	ALU_signed_cmp_o
);
input[5:0] opcode, funct;
output[2:0] compare_select, ALU_B_select;
output[1:0] jump_ctrl_temp, IFU_addr_select, GRF_write_addr_select, GRF_write_data_select, ALU_A_select, ALU_ctrl;
output      EXT_signed_ext, write_GRF, DM_read_enable, DM_write_enable, ALU_signed_o, ALU_signed_cmp_o;
	wire addu, subu, ori, lw, sw, beq, lui, jal, jr;
	CTRL_and CTRL_and(
		.opcode(opcode), .funct(funct), .addu(addu), .subu(subu),
		.ori(ori), .lw(lw), .sw(sw), .beq(beq), .lui(lui), .jal(jal), .jr(jr)
	);
	wire jump_on_lt, jump_on_le, jump_on_eq, jump_on_ge, jump_on_gt, jump_on_ne, jump_whatever,
	     branch_family, jump_family, jump_register_family,
	     signed_extend,
	     write_to_rt, write_to_rd, write_to_ra,
	     write_GRF_from_ALU, write_GRF_from_PC4, write_GRF_from_DM, write_GRF_from_lt,
	     ALU_A_from_rs, ALU_A_from_rt, ALU_A_from_immediate,
	     ALU_B_from_rs, ALU_B_from_rt, ALU_B_from_immediate, ALU_B_from_shmat, ALU_B_from_0, ALU_B_from_16,
	     ALU_add, ALU_sub, ALU_mult, ALU_div, ALU_sll, ALU_srl, ALU_sra, ALU_or, ALU_and, ALU_xor, ALU_nor, ALU_signed, ALU_signed_cmp,
	     DM_read, DM_write;
	CTRL_sort CTRL_sort(
		.addu(addu), .subu(subu), .ori(ori), .lw(lw), .sw(sw), .beq(beq), .lui(lui), .jal(jal), .jr(jr),
		.jump_on_lt(jump_on_lt), .jump_on_le(jump_on_le), .jump_on_eq(jump_on_eq), .jump_on_ge(jump_on_ge), 
		.jump_on_gt(jump_on_gt), .jump_on_ne(jump_on_ne), .jump_whatever(jump_whatever),
		.branch_family(branch_family), .jump_family(jump_family), .jump_register_family(jump_register_family),
		.signed_extend(signed_extend),
		.write_to_rt(write_to_rt), .write_to_rd(write_to_rd), .write_to_ra(write_to_ra),
		.write_GRF_from_ALU(write_GRF_from_ALU), .write_GRF_from_PC4(write_GRF_from_PC4),
		.write_GRF_from_DM(write_GRF_from_DM), .write_GRF_from_lt(write_GRF_from_lt),
		.ALU_A_from_rs(ALU_A_from_rs), .ALU_A_from_rt(ALU_A_from_rt), .ALU_A_from_immediate(ALU_A_from_immediate),
		.ALU_B_from_rs(ALU_B_from_rs), .ALU_B_from_rt(ALU_B_from_rt), .ALU_B_from_immediate(ALU_B_from_immediate),
		.ALU_B_from_shmat(ALU_B_from_shmat), .ALU_B_from_0(ALU_B_from_0), .ALU_B_from_16(ALU_B_from_16),
		.ALU_add(ALU_add), .ALU_sub(ALU_sub), .ALU_mult(ALU_mult), .ALU_div(ALU_div), .ALU_sll(ALU_sll), .ALU_srl(ALU_srl),
		.ALU_sra(ALU_sra), .ALU_or(ALU_or), .ALU_and(ALU_and), .ALU_xor(ALU_xor), .ALU_nor(ALU_nor), .ALU_signed(ALU_signed),
		.ALU_signed_cmp(ALU_signed_cmp),
		.DM_read(DM_read), .DM_write(DM_write)
	);
	CTRL_generate CTRL_generate(
		.jump_on_lt(jump_on_lt),
		.jump_on_le(jump_on_le),
		.jump_on_eq(jump_on_eq),
		.jump_on_ge(jump_on_ge),
		.jump_on_gt(jump_on_gt),
		.jump_on_ne(jump_on_ne),
		.jump_whatever(jump_whatever),
		.branch_family(branch_family),
		.jump_family(jump_family),
		.jump_register_family(jump_register_family),
		.signed_extend(signed_extend),
		.write_to_rt(write_to_rt),
		.write_to_rd(write_to_rd),
		.write_to_ra(write_to_ra),
		.write_GRF_from_ALU(write_GRF_from_ALU),
		.write_GRF_from_PC4(write_GRF_from_PC4),
		.write_GRF_from_DM(write_GRF_from_DM),
		.write_GRF_from_lt(write_GRF_from_lt),
		.ALU_A_from_rs(ALU_A_from_rs), .ALU_A_from_rt(ALU_A_from_rt), .ALU_A_from_immediate(ALU_A_from_immediate),
		.ALU_B_from_rs(ALU_B_from_rs), .ALU_B_from_rt(ALU_B_from_rt), .ALU_B_from_immediate(ALU_B_from_immediate),
		.ALU_B_from_shmat(ALU_B_from_shmat), .ALU_B_from_0(ALU_B_from_0), .ALU_B_from_16(ALU_B_from_16),
		.ALU_add(ALU_add), .ALU_sub(ALU_sub), .ALU_mult(ALU_mult), .ALU_div(ALU_div), .ALU_sll(ALU_sll), .ALU_srl(ALU_srl),
		.ALU_sra(ALU_sra), .ALU_or(ALU_or), .ALU_and(ALU_and), .ALU_xor(ALU_xor), .ALU_nor(ALU_nor), .ALU_signed(ALU_signed),
		.ALU_signed_cmp(ALU_signed_cmp),
		.DM_read(DM_read), .DM_write(DM_write),
		.compare_select(compare_select),
		.jump_ctrl_temp(jump_ctrl_temp),
		.IFU_addr_select(IFU_addr_select),
		.EXT_signed_ext(EXT_signed_ext),
		.write_GRF(write_GRF),
		.GRF_write_addr_select(GRF_write_addr_select),
		.GRF_write_data_select(GRF_write_data_select),
		.ALU_A_select(ALU_A_select),
		.ALU_B_select(ALU_B_select),
		.ALU_ctrl(ALU_ctrl),
		.DM_read_enable(DM_read_enable),
		.DM_write_enable(DM_write_enable),
		.ALU_signed_o(ALU_signed_o),
		.ALU_signed_cmp_o(ALU_signed_cmp_o)
	);
endmodule
