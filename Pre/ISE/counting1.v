`define S0 2'b00
`define S1 2'b01
`define S2 2'b10
`define S3 2'b11
module counting(
	input [1:0] num,
	input clk,
	output ans
    );
	reg [1:0] status;
	initial begin
		status  <= `S0;
	end
	assign ans = status == `S3 ? 1'b1 : 0;
	always@(posedge clk)begin
		case(status)
			`S0:begin
				if(num == 1)  status <= `S1;
			end
			`S1:begin
				if(num == 2) status <= `S2;
				else if(num == 3) status <= `S0;
			end
			`S2:begin
				if(num == 1) status <= `S1;
				else if(num == 2) status <= `S0;
				else status <= `S3;
			end
		endcase
	end
endmodule
