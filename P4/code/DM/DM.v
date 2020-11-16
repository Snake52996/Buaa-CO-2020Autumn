`timescale 1ns / 1ps
module DM(addr, input_data, read_en, write_en, clk, reset, output_data);
input[31:0] addr;
input[31:0] input_data;
input read_en;
input write_en;
input clk;
input reset;
output[31:0] output_data;
	memory#(32,1024)memory(.addr(addr[11:2]), .input_data(input_data), .read_en(read_en), .write_en(write_en),
	       .clk(clk), .reset(reset), .output_data(output_data));
endmodule
