`timescale 1ns / 1ps
module IFU(clk, reset, IFU_addr, IFU_jump_ctrl, instruction, PC4);
input clk;
input reset;
input[31:0] IFU_addr;
input[1:0] IFU_jump_ctrl;
output[31:0] instruction;
output[31:0] PC4;
reg[31:0] PC;
reg[31:0] InstructionMemory[0:1023];
initial begin
	$readmemh("code.txt",InstructionMemory);
end
assign instruction = InstructionMemory[PC - 32'h0000_3000];
assign PC4 = PC + 32'h0000_0004;
wire[31:0] next_PC;
wire[31:0] PC_relative_target = PC4 + IFU_addr;
wire[31:0] PC_direct_target = IFU_addr;
MUX3 PCSelect(.in1(PC4), .in2(PC_relative_target), .in3(PC_direct_target), .select(IFU_jump_ctrl), .out(next_PC));
always@(posedge clk)begin
	if(reset) begin
		PC <= 32'h0000_3000;
	end else begin
		PC <= next_PC;
	end
end
endmodule
