`timescale 1ns / 1ps
module GRF(read_addr1, read_addr2, data_input, write_addr, write_enable, clk, reset, data_output1, data_output2);
input[4:0] read_addr1;
input[4:0] read_addr2;
input[31:0] data_input;
input[4:0] write_addr;
input write_enable;
input clk;
input reset;
output[31:0] data_output1;
output[31:0] data_output2;
reg[31:0] GeneralRegisters[0:31];
assign data_output1 = GeneralRegisters[read_addr1];
assign data_output2 = GeneralRegisters[read_addr2];
reg[5:0] helper;
always@(posedge clk)begin
	if(reset)begin
		for(helper = 0; helper < 32; helper = helper + 1) GeneralRegisters[helper] <= 0;
	end else if(write_enable) begin
		if(write_addr !== 0) GeneralRegisters[write_addr] <= data_input;
	end
end
endmodule
