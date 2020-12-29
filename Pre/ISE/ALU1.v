module ALU(
	input [3:0] inA,
	input [3:0] inB,
	input [1:0] op,
	input [3:0] ans
    );
	// assume no exception
	assign ans = op === 2'b00 ? inA & inB :
				 op === 2'b01 ? inA | inB :
				 op === 2'b10 ? inA ^ inB : inA + inB;

endmodule
