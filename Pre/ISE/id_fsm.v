localparam S0 = 0, S1 = 1, S2 = 2;
module id_fsm(
	input [7:0] char,
	input clk,
	output out
    );
	reg [1:0] status;
	assign out = status == S2;
	initial begin
		status <= S0;
	end
	always@(posedge clk)begin
		if((char >= "a" && char <= "z") || (char >= "A" && char <= "Z"))begin
			status <= S1;
		end else if(char >= "0" && char <= "9")begin
			if(status == S1) status <= S2;
		end else begin
			status <= S0;
		end
	end
endmodule
