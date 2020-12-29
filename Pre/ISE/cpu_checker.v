`timescale 1ns / 1ps
`define S0		0
`define S1		1
`define S20		2
`define S21		3
`define S22		4
`define S23		5
`define S3		6
`define S40		7
`define S41		8
`define S42		9
`define S43		10
`define S44		11
`define S45		12
`define S46		13
`define S47		14
`define S5		15
`define S6		16
`define S7		17
`define S80		18
`define S81		19
`define S82		20
`define S83		21
`define S9		22
`define S100	23
`define S101	24
`define S102	25
`define S103	26
`define S104	27
`define S105	28
`define S106	29
`define S107	30
`define S11		31
`define S120	32
`define S121	33
`define S13		34
`define S140	35
`define S141	36
`define S142	37
`define S143	38
`define S144	39
`define S145	40
`define S146	41
`define S147	42
`define S15		43
module cpu_checker(
	input clk,
	input reset,
	input [7:0] char,
	input [15:0] freq,
	output [1:0] format_type,
	output reg [3:0] error_code
    );
	reg [1:0] result;
	reg [5:0] status;
	reg [31:0] simulation_time;
	reg [31:0] pc;
	reg [31:0] addr;
	reg [31:0] grf;
	
	assign format_type = result & {2{status == `S15}};
	
	task resetAll;begin
		result <= 0;
		status <= `S0;
		error_code <= 0;
	end endtask
	
	function isDigital;
	input [7:0] c;
		isDigital = c >= "0" && c <= "9";
	endfunction
	
	function isHexDigital;
	input [7:0] c;
		isHexDigital = (c >= "a" && c <= "f") || isDigital(c);
	endfunction
	
	// assume c is always a hex digital
	function [3:0] getValue;
	input [7:0] c;
		if(isDigital(c)) getValue = c - "0";
		else getValue = c - "a" + 10;
	endfunction
	
	function [7:0] helper;
	input [31:0] tar;
		if(tar == 0) helper = 8'b11111111;
		else begin: unnamed
		reg [31:0] i;
		i = 0;
		while(tar[0] == 0)begin
			i = i + 1;
			tar = tar >> 1;
		end
		helper = i;
	end endfunction
	
	task setErrorCode;begin
		error_code = 0;
		if(helper(simulation_time) < helper(freq) - 1) error_code = error_code | 4'b0001;
		if(helper(pc) < 2 || pc > 32'h0000_4fff || pc < 32'h0000_3000) error_code = error_code | 4'b0010;
		if(result == 2'b01)begin
			if(grf > 31) error_code = error_code | 4'b1000;
		end else if(result == 2'b10)begin
			if(helper(addr) < 2 || addr > 32'h0000_2fff) error_code = error_code | 4'b0100;
		end
	end endtask
	
	task step;
		if(status == `S0)begin
			if(char == "^") status <= `S1;
		end else if(status == `S1)begin
			if(isDigital(char))begin
				status <= `S20;
				simulation_time <= char - "0";
			end else status <= `S0;
		end else if(status >= `S20 && status < `S23)begin
			if(isDigital(char))begin
				status <= status + 1;
				simulation_time <= (simulation_time << 3) + (simulation_time << 1) + char - "0";
			end else if(char == "@") status <= `S3;
			else status <= `S0;
		end else if(status == `S23)begin
			if(char == "@") status <= `S3;
			else status <= `S0;
		end else if(status == `S3)begin
			if(isHexDigital(char))begin
				status <= `S40;
				pc <= getValue(char);
			end else status <= `S0;
		end else if(status >= `S40 && status < `S47)begin
			if(isHexDigital(char))begin
				status <= status + 1;
				pc <= (pc << 4) + getValue(char);
			end else status <= `S0;
		end else if(status == `S47)begin
			if(char == ":") status <= `S5;
			else status <= `S0;
		end else if(status == `S5)begin
			if(char == "$") status <= `S7;
			else if(char == 8'd42) status <= `S9;
			else if(char != " ") status <= `S0;
		end else if(status == `S7)begin
			result <= 2'b01;
			if(isDigital(char))begin
				status <= `S80;
				grf <= char - "0";
			end else status <= `S0;
		end else if(status >= `S80 && status < `S83)begin
			if(isDigital(char))begin
				status <= status + 1;
				grf <= (grf << 3) + (grf << 1) + char - "0";
			end else if(char == "<") status <= `S120;
			else if(char == " ") status <= `S11;
			else status <= `S0;
		end else if(status == `S83)begin
			if(char == "<") status <= `S120;
			else if(char == " ") status <= `S11;
			else status <= `S0;
		end else if(status == `S9)begin
			result <= 2'b10;
			if(isHexDigital(char))begin
				status <= `S100;
				addr <= getValue(char);
			end else status <= `S0;
		end else if(status >= `S100 && status < `S107)begin
			if(isHexDigital(char))begin
				status <= status + 1;
				addr <= (addr << 4) | getValue(char);
			end else status <= `S0;
		end else if(status == `S107)begin
			if(char == "<") status <= `S120;
			else if(char == " ") status <= `S11;
			else status <= `S0;
		end else if(status == `S11)begin
			if(char == "<") status <= `S120;
			else if(char != " ") status <= `S0;
		end else if(status == `S120)begin
			if(char == "=") status <= `S121;
			else status <= `S0;
		end else if(status == `S121)begin
			if(isHexDigital(char)) status <= `S140;
			else if(char != " ") status <= `S0;
		end else if(status >= `S140 && status < `S147)begin
			if(isHexDigital(char)) status <= status + 1;
			else status <= `S0;
		end else if(status == `S147)begin
			if(char == "#")begin
				status <= `S15;
				setErrorCode();
			end else status <= `S0;
		end else if(status == `S15)begin
			error_code = 0;
			if(char == "^") status <= `S1;
			else status <= `S0;
		end
	endtask
	
	always@(posedge clk)begin
		if(reset) resetAll();
		else step();
	end

endmodule
