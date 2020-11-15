`timescale 1ns / 1ps
module IFU(clk, reset, IFU_addr, IFU_jump_ctrl, instruction, PC, PC4);
input clk;
input reset;
input[31:0] IFU_addr;
input[1:0] IFU_jump_ctrl;
output[31:0] instruction;
output[31:0] PC4;
output reg[31:0] PC;
reg[31:0] InstructionMemory[0:1023];
initial begin
	$readmemh("code.txt",InstructionMemory);
end
wire[31:0] current_full_address = PC - 32'h0000_3000;
wire[9:0] current_address = current_full_address[11:2];
assign instruction = InstructionMemory[current_address];
assign PC4 = PC + 32'h0000_0004;
wire[31:0] next_PC;
wire[31:0] PC_relative_target = PC4 + IFU_addr;
wire[31:0] PC_region_target = {PC4[31:28], IFU_addr[25:0], {2{1'b0}}};
wire[31:0] PC_direct_target = IFU_addr;
MUX4#(32)next_PC_MUX(.in1(PC4), .in2(PC_relative_target), .in3(PC_region_target), .in4(PC_direct_target),
              .select(IFU_jump_ctrl), .out(next_PC));
always@(posedge clk)begin
	if(reset) begin
		PC <= 32'h0000_3000;
	end else begin
		PC <= next_PC;
	end
end
endmodule
