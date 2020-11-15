`timescale 1ns / 1ps
module mips(clk, reset);
input clk;
input reset;
	wire[31:0] insturction, PC, PC4, GRF_read_data1, GRF_read_data2, ALU_A, ALU_B, ALU_S, EXT_output, SLL2_output, DM_addr, 
	           DM_write_data, DM_read_data, GRF_write_data, IFU_addr;
	wire[25:0] jump_addr;
	wire[15:0] immediate;
	wire[5:0]  opcode, funct;
	wire[4:0]  rs, rt, rd, shmat, GRF_read_addr1, GRF_read_addr2, GRF_write_addr;
	wire[2:0]  ALU_B_select, compare_select;
	wire[1:0]  ALU_ctrl, IFU_ctrl, IFU_addr_select, ALU_A_select, GRF_write_addr_select, GRF_write_data_select, jump_ctrl_temp;
	wire       GRF_write_enable, ALU_signed_comp, EXT_signed_ext, DM_read_enable, DM_write_enable,
	           cmp_lt, cmp_le, cmp_eq, cmp_ge, cmp_gt, cmp_ne, cmp_t, compare_result;
	IFU IFU(.clk(clk), .reset(reset), .IFU_addr(IFU_addr), .IFU_jump_ctrl(IFU_ctrl), .instruction(insturction), .PC(PC), .PC4(PC4));
	IS IS(.Instruction(insturction), .opcode(opcode), .rs(rs), .rt(rt), .rd(rd), .shamt(shmat), .funct(funct),
	   .immediate(immediate), .address(jump_addr));
	EXT EXT(.immediate(immediate), .signed_ext(EXT_signed_ext), .ext(EXT_output));
	SLL2 SLL2(.origin(EXT_output), .shifted(SLL2_output));
	GRF GRF(.read_addr1(GRF_read_addr1), .read_addr2(GRF_read_addr2), .data_input(GRF_write_data), .write_addr(GRF_write_addr),
	    .write_enable(GRF_write_enable), .clk(clk), .reset(reset), .data_output1(GRF_read_data1), .data_output2(GRF_read_data2));
	ALU ALU(.A(ALU_A), .B(ALU_B), .ctrl(ALU_ctrl), .signed_comp(ALU_signed_comp), .S(ALU_S),
	    .lt(cmp_lt), .le(cmp_le), .eq(cmp_eq), .ge(cmp_ge), .gt(cmp_gt), .ne(cmp_ne), .t(cmp_t));
	DM DM(.addr(DM_addr), .input_data(DM_write_data), .read_en(DM_read_enable), .write_en(DM_write_enable), .clk(clk), .reset(reset),
	   .output_data(DM_read_data));
	assign GRF_read_addr1 = rs;
	assign GRF_read_addr2 = rt;
	assign DM_addr = ALU_S;
	assign DM_write_data = GRF_read_data2;
	MUX3#(32)IFU_addr_MUX(.in1(SLL2_output), .in2(jump_addr), .in3(GRF_read_data1), .select(IFU_addr_select), .out(IFU_addr));
	MUX3#(32)ALU_A_MUX(.in1(GRF_read_data1), .in2(GRF_read_data2), .in3(EXT_output), .select(ALU_A_select), .out(ALU_A));
	MUX6#(32)ALU_B_MUX(.in1(GRF_read_data1), .in2(GRF_read_data2), .in3(EXT_output), .in4(shmat), .in5(0), .in6(16), 
	          .select(ALU_B_select), .out(ALU_B));
	MUX3#(5)GRF_write_addr_MUX(.in1(rd), .in2(rt), .in3(31), .select(GRF_write_addr_select), .out(GRF_write_addr));
	MUX4#(32)GRF_write_data_MUX(.in1(ALU_S), .in2(PC4), .in3(DM_read_data), .in4({{31{0}}, cmp_lt}), .select(GRF_write_data_select), .out(GRF_write_data));
	MUX7#(1)compare_result_MUX(.in1(cmp_lt), .in2(cmp_le), .in3(cmp_eq), .in4(cmp_ge), .in5(cmp_gt), .in6(cmp_ne), .in7(cmp_t),
	         .select(compare_select), .out(compare_result));
	assign IFU_ctrl = jump_ctrl_temp & {2{compare_result}};
	CTRL CTRL(
		.opcode(opcode), .funct(funct),
		.compare_select(compare_select),
		.jump_ctrl_temp(jump_ctrl_temp),
		.IFU_addr_select(IFU_addr_select),
		.EXT_signed_ext(EXT_signed_ext),
		.write_GRF(GRF_write_enable),
		.GRF_write_addr_select(GRF_write_addr_select),
		.GRF_write_data_select(GRF_write_data_select),
		.ALU_A_select(ALU_A_select),
		.ALU_B_select(ALU_B_select),
		.ALU_ctrl(ALU_ctrl),
		.DM_read_enable(DM_read_enable),
		.DM_write_enable(DM_write_enable),
		.ALU_signed_o(),
		.ALU_signed_cmp_o()
	);
	always@(posedge clk)begin
		if(!reset)begin
			if(GRF_write_enable)begin
				$display("@%h: $%d <= %h", PC, GRF_write_addr, GRF_write_data);
			end else if(DM_write_enable)begin
				$display("@%h: *%h <= %h", PC, DM_addr, DM_write_data);
			end
		end
	end
endmodule
