`timescale 1ns / 1ps
module MUX2(
	input[DATA_SIZE-1: 0] in1,
	input[DATA_SIZE-1: 0] in2,
	input select,
	output[DATA_SIZE-1: 0] out
);
parameter DATA_SIZE = 32;
	assign out = (select === 0) ? (in1) :
				 (select === 1) ? (in2) : 0;
endmodule
module MUX3(
	input[DATA_SIZE-1: 0] in1,
	input[DATA_SIZE-1: 0] in2,
	input[DATA_SIZE-1: 0] in3,
	input[1:0] select,
	output[DATA_SIZE-1: 0] out
);
parameter DATA_SIZE = 32;
	assign out = (select === 0) ? (in1) :
				 (select === 1) ? (in2) :
				 (select === 2) ? (in3) : 0;
endmodule
module MUX4(
	input[DATA_SIZE-1: 0] in1,
	input[DATA_SIZE-1: 0] in2,
	input[DATA_SIZE-1: 0] in3,
	input[DATA_SIZE-1: 0] in4,
	input[1:0] select,
	output[DATA_SIZE-1: 0] out
);
parameter DATA_SIZE = 32;
	assign out = (select === 0) ? (in1) :
				 (select === 1) ? (in2) :
				 (select === 2) ? (in3) :
				 (select === 3) ? (in4) : 0;
endmodule
module MUX5(
	input[DATA_SIZE-1: 0] in1,
	input[DATA_SIZE-1: 0] in2,
	input[DATA_SIZE-1: 0] in3,
	input[DATA_SIZE-1: 0] in4,
	input[DATA_SIZE-1: 0] in5,
	input[2:0] select,
	output[DATA_SIZE-1: 0] out
);
parameter DATA_SIZE = 32;
	assign out = (select === 0) ? (in1) :
				 (select === 1) ? (in2) :
				 (select === 2) ? (in3) :
				 (select === 3) ? (in4) :
				 (select === 4) ? (in5) : 0;
endmodule
module MUX6(
	input[DATA_SIZE-1: 0] in1,
	input[DATA_SIZE-1: 0] in2,
	input[DATA_SIZE-1: 0] in3,
	input[DATA_SIZE-1: 0] in4,
	input[DATA_SIZE-1: 0] in5,
	input[DATA_SIZE-1: 0] in6,
	input[2:0] select,
	output[DATA_SIZE-1: 0] out
);
parameter DATA_SIZE = 32;
	assign out = (select === 0) ? (in1) :
				 (select === 1) ? (in2) :
				 (select === 2) ? (in3) :
				 (select === 3) ? (in4) :
				 (select === 4) ? (in5) :
				 (select === 5) ? (in6) : 0;
endmodule
module MUX7(
	input[DATA_SIZE-1: 0] in1,
	input[DATA_SIZE-1: 0] in2,
	input[DATA_SIZE-1: 0] in3,
	input[DATA_SIZE-1: 0] in4,
	input[DATA_SIZE-1: 0] in5,
	input[DATA_SIZE-1: 0] in6,
	input[DATA_SIZE-1: 0] in7,
	input[2:0] select,
	output[DATA_SIZE-1: 0] out
);
parameter DATA_SIZE = 32;
	assign out = (select === 0) ? (in1) :
				 (select === 1) ? (in2) :
				 (select === 2) ? (in3) :
				 (select === 3) ? (in4) :
				 (select === 4) ? (in5) :
				 (select === 5) ? (in6) :
				 (select === 6) ? (in7) : 0;
endmodule
module MUX8(
	input[DATA_SIZE-1: 0] in1,
	input[DATA_SIZE-1: 0] in2,
	input[DATA_SIZE-1: 0] in3,
	input[DATA_SIZE-1: 0] in4,
	input[DATA_SIZE-1: 0] in5,
	input[DATA_SIZE-1: 0] in6,
	input[DATA_SIZE-1: 0] in7,
	input[DATA_SIZE-1: 0] in8,
	input[2:0] select,
	output[DATA_SIZE-1: 0] out
);
parameter DATA_SIZE = 32;
	assign out = (select === 0) ? (in1) :
				 (select === 1) ? (in2) :
				 (select === 2) ? (in3) :
				 (select === 3) ? (in4) :
				 (select === 4) ? (in5) :
				 (select === 5) ? (in6) :
				 (select === 6) ? (in7) :
				 (select === 7) ? (in8) : 0;
endmodule
module MUX9(
	input[DATA_SIZE-1: 0] in1,
	input[DATA_SIZE-1: 0] in2,
	input[DATA_SIZE-1: 0] in3,
	input[DATA_SIZE-1: 0] in4,
	input[DATA_SIZE-1: 0] in5,
	input[DATA_SIZE-1: 0] in6,
	input[DATA_SIZE-1: 0] in7,
	input[DATA_SIZE-1: 0] in8,
	input[DATA_SIZE-1: 0] in9,
	input[3:0] select,
	output[DATA_SIZE-1: 0] out
);
parameter DATA_SIZE = 32;
	assign out = (select === 0) ? (in1) :
				 (select === 1) ? (in2) :
				 (select === 2) ? (in3) :
				 (select === 3) ? (in4) :
				 (select === 4) ? (in5) :
				 (select === 5) ? (in6) :
				 (select === 6) ? (in7) :
				 (select === 7) ? (in8) :
				 (select === 8) ? (in9) : 0;
endmodule
module MUX10(
	input[DATA_SIZE-1: 0] in1,
	input[DATA_SIZE-1: 0] in2,
	input[DATA_SIZE-1: 0] in3,
	input[DATA_SIZE-1: 0] in4,
	input[DATA_SIZE-1: 0] in5,
	input[DATA_SIZE-1: 0] in6,
	input[DATA_SIZE-1: 0] in7,
	input[DATA_SIZE-1: 0] in8,
	input[DATA_SIZE-1: 0] in9,
	input[DATA_SIZE-1: 0] in10,
	input[3:0] select,
	output[DATA_SIZE-1: 0] out
);
parameter DATA_SIZE = 32;
	assign out = (select === 0) ? (in1) :
				 (select === 1) ? (in2) :
				 (select === 2) ? (in3) :
				 (select === 3) ? (in4) :
				 (select === 4) ? (in5) :
				 (select === 5) ? (in6) :
				 (select === 6) ? (in7) :
				 (select === 7) ? (in8) :
				 (select === 8) ? (in9) :
				 (select === 9) ? (in10) : 0;
endmodule
