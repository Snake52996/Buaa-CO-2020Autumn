`timescale 1ns / 1ps
parameter DATA_SIZE=32, WORDS=1024;
module memory(addr, input_data, read_en, write_en, clk, reset, output_data);
input[$clog2(WORDS)+1:2] addr;
input[DATA_SIZE-1:0] input_data;
input read_en;
input write_en;
input clk;
input reset;
output[DATA_SIZE-1:0] output_data;
reg[DATA_SIZE-1:0] mem[0:WORDS - 1];
reg[$clog2(WORDS):0] help;
assign output_data = (read_en === 1) ? (mem[addr]) : ({DATA_SIZE{1'bx}});
always@(posedge clk)begin
	if(reset)begin
		for(help = 0; help < WORDS; help = help + 1) mem[help] <= 0;
	end else if(write_en) begin
		mem[addr] <= input_data;
	end
end
endmodule
