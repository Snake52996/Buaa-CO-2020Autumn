`timescale 1ns / 1ps
module CTRL_generate(
	jump_on_lt, jump_on_le, jump_on_eq, jump_on_ge, jump_on_gt, jump_on_ne, jump_whatever,
	branch_family, jump_family, jump_register_family,
	signed_extend,
	write_to_rt, write_to_rd, write_to_ra,
	write_GRF_from_ALU, write_GRF_from_PC4, write_GRF_from_DM, write_GRF_from_lt,
	ALU_A_from_rs, ALU_A_from_rt, ALU_A_from_immediate,
	ALU_B_from_rs, ALU_B_from_rt, ALU_B_from_immediate, ALU_B_from_shmat, ALU_B_from_0, ALU_B_from_16,
	ALU_add, ALU_sub, ALU_mult, ALU_div, ALU_sll, ALU_srl, ALU_sra, ALU_or, ALU_and, ALU_xor, ALU_nor, ALU_signed_cal, ALU_signed_cmp,
	ALU_read_LO, ALU_read_HI, ALU_write_LO, ALU_write_HI,
	DM_read, DM_write,
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
	ALU_signed_cmp_o
);
input jump_on_lt, jump_on_le, jump_on_eq, jump_on_ge, jump_on_gt, jump_on_ne, jump_whatever,
	  branch_family, jump_family, jump_register_family,
	  signed_extend,
	  write_to_rt, write_to_rd, write_to_ra,
	  write_GRF_from_ALU, write_GRF_from_PC4, write_GRF_from_DM, write_GRF_from_lt,
	  ALU_A_from_rs, ALU_A_from_rt, ALU_A_from_immediate,
	  ALU_B_from_rs, ALU_B_from_rt, ALU_B_from_immediate, ALU_B_from_shmat, ALU_B_from_0, ALU_B_from_16,
	  ALU_add, ALU_sub, ALU_mult, ALU_div, ALU_sll, ALU_srl, ALU_sra, ALU_or, ALU_and, ALU_xor, ALU_nor, ALU_signed_cal, ALU_signed_cmp,
	  ALU_read_LO, ALU_read_HI, ALU_write_LO, ALU_write_HI,
	  DM_read, DM_write;
output[4:0] ALU_ctrl;
output[2:0] compare_select, ALU_B_select;
output[1:0] jump_ctrl_temp, IFU_addr_select, GRF_write_addr_select, GRF_write_data_select, ALU_A_select;
output      EXT_signed_ext, write_GRF, DM_read_enable, DM_write_enable, ALU_signed_cmp_o;
	assign compare_select = (jump_on_lt) ? 0 :
	                        (jump_on_le) ? 1 :
							(jump_on_eq) ? 2 :
							(jump_on_ge) ? 3 :
							(jump_on_gt) ? 4 :
							(jump_on_ne) ? 5 :
							(jump_whatever) ? 6 : 0;
	assign ALU_B_select = ALU_B_from_rs ? 0 :
						  ALU_B_from_rt ? 1 :
						  ALU_B_from_immediate ? 2 :
						  ALU_B_from_shmat ? 3 :
						  ALU_B_from_0 ? 4 :
						  ALU_B_from_16 ? 5 : 0;
	assign jump_ctrl_temp = branch_family ? 1 :
	                        jump_family ? 2 :
							jump_register_family ? 3 : 0;
	assign IFU_addr_select = branch_family ? 0 :
	                         jump_family ? 1 :
							 jump_register_family ? 2 : 0;
	assign GRF_write_addr_select = write_to_rd ? 0 :
	                               write_to_rt ? 1 :
								   write_to_ra ? 2 : 0;
	assign GRF_write_data_select = write_GRF_from_ALU ? 0 :
	                               write_GRF_from_PC4 ? 1 :
								   write_GRF_from_DM ? 2 :
								   write_GRF_from_lt ? 3 : 0;
	assign ALU_A_select = ALU_A_from_rs ? 0 :
	                      ALU_A_from_rt ? 1 :
						  ALU_A_from_immediate ? 2 : 0;
	assign ALU_ctrl = (ALU_add) ? 0 :
					  (ALU_sub) ? 1	:
					  (ALU_or) ? 2	:
					  (ALU_sll)	? 3	:
					  (ALU_mult && !ALU_signed_cal) ? 4 :
					  (ALU_mult && ALU_signed_cal) ? 5 :
					  (ALU_div && !ALU_signed_cal) ? 6 :
					  (ALU_div && ALU_signed_cal) ? 7 :
					  (ALU_and) ? 8 :
					  (ALU_nor) ? 9 :
					  (ALU_xor) ? 10 :
					  (ALU_srl) ? 11 :
					  (ALU_sra) ? 12 :
					  (ALU_read_LO) ? 13 :
					  (ALU_read_HI) ? 14 :
					  (ALU_write_LO) ? 15 :
					  (ALU_write_HI) ? 16 : 0;
	assign EXT_signed_ext = signed_extend;
	assign write_GRF = write_to_rt || write_to_rd || write_to_ra;
	assign DM_read_enable = DM_read;
	assign DM_write_enable = DM_write;
	assign ALU_signed_cmp_o = ALU_signed_cmp;
endmodule
