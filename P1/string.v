`timescale 1ns / 1ps
module string(
	input clk,
	input clr,
	input[7:0] in,
	output out
    );
	reg[1:0] status;
	initial status = 0;
	always@(posedge clr) status <= 0;
	always@(posedge clk)begin
		if(!clr)begin
			case(status)
				0:begin
					if(in >= "0" && in <= "9") status <= 1;
					else status <= 2;
				end
				1:begin
					if(in === "+" || in === "*") status <= 3;
					else status <= 2;
				end
				3:begin
					if(in >= "0" && in <= "9") status <= 1;
					else status <= 2;
				end
				default: status <= status;
			endcase
		end
	end
	assign out = status == 1;

endmodule
