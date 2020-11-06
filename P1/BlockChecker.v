`timescale 1ns / 1ps
module BlockChecker(
	input clk,
	input reset,
	input[7:0] in,
	output result
    );
	function[7:0] lowercseChar;
	input[7:0] char;
		lowercseChar = (char >= "A" && char <= "Z") ? (char - "A" + "a") : char;
	endfunction
	reg[31:0] counter;
	reg[2:0] begin_reg;
	reg[2:0] end_reg;
	reg fatal;
	always@(posedge reset)begin
		counter <= 0;
		begin_reg <= 0;
		end_reg <= 0;
		fatal <= 0;
	end
	task step;begin
		case(begin_reg)
			0:begin
				if(lowercseChar(in) == "b") begin_reg <= 1;
				else if(in == " ") begin_reg <= 0;
				else begin_reg <= 6;
			end
			1:begin
				if(lowercseChar(in) == "e") begin_reg <= 2;
				else if(in == " ") begin_reg <= 0;
				else begin_reg <= 6;
			end
			2:begin
				if(lowercseChar(in) == "g") begin_reg <= 3;
				else if(in == " ") begin_reg <= 0;
				else begin_reg <= 6;
			end
			3:begin
				if(lowercseChar(in) == "i") begin_reg <= 4;
				else if(in == " ") begin_reg <= 0;
				else begin_reg <= 6;
			end
			4:begin
				if(lowercseChar(in) == "n")begin
					begin_reg <= 5;
					counter <= counter + 1;
				end else if(in == " ") begin_reg <= 0;
				else begin_reg <= 6;
			end
			5:begin
				if(lowercseChar(in) == " ") begin_reg <= 0;
				else begin
					begin_reg <= 6;
					counter <= counter - 1;
				end
			end
			6:begin
				if(lowercseChar(in) == " ") begin_reg <= 0;
			end
		endcase
		case(end_reg)
			0:begin
				if(lowercseChar(in) == "e") end_reg <= 1;
				else if(in == " ") end_reg <= 0;
				else end_reg <= 4;
			end
			1:begin
				if(lowercseChar(in) == "n") end_reg <= 2;
				else if(in == " ") end_reg <= 0;
				else end_reg <= 4;
			end
			2:begin
				if(lowercseChar(in) == "d")begin
					end_reg <= 3;
					counter <= counter - 1;
				end
				else if(in == " ") end_reg <= 0;
				else end_reg <= 4;
			end
			3:begin
				if(lowercseChar(in) == " ")begin
					if($signed(counter) < 0) fatal <= 1;
					end_reg <= 0;
				end else begin
					end_reg <= 4;
					counter <= counter + 1;
				end
			end
			4:begin
				if(lowercseChar(in) == " ") end_reg <= 0;
			end
		endcase
	end endtask
	always@(posedge clk)begin
		if(!reset && !fatal) step();
	end
	assign result = (counter == 0 && fatal == 0);
endmodule
