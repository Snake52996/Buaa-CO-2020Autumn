`define RESTART_CONTING 0
`define STAY_AT_CURRENT 1
`define RISING_EDGE 0
`define FALLING_EDGE 1
module counter
#(parameter data_width = 8, max_count = 8'hff, trigger = `RISING_EDGE, onOverflow = `RESTART_CONTING)
(
	input clock,
	input enable,
	input load,
	input discount,
	input reset,
	input [data_width - 1 : 0] data,
	output reg [data_width - 1 : 0] count,
	output reg overflow
    );
	reg [data_width - 1 : 0] start_value;
	reg [data_width - 1 : 0] end_value;
	
	always@(posedge reset)begin
		if(discount === 1)begin
			start_value = max_count;
			end_value = 0;
		end else begin
			start_value = 0;
			end_value = max_count;
		end
		count <= start_value;
		overflow <= 0;
	end
	
	always@(posedge discount)begin
		overflow <= count == 0;
		start_value <= max_count;
		end_value <= 0;
	end
	
	always@(negedge discount)begin
		overflow <= count == max_count;
		start_value <= 0;
		end_value <= max_count;
	end
	
	task checkOverflow;
		if(count == end_value) overflow <= 1;
		else overflow <= 0;
	endtask
	
	task manageOverflow;
		case(onOverflow)
			`RESTART_CONTING:begin
				count <= start_value;
			end
		endcase
	endtask
	
	task regularCount;begin
		if(overflow)begin
			manageOverflow();
			disable regularCount;
		end
		count = count + 1;
		checkOverflow();
	end endtask
	
	task backwardCount;begin
		if(overflow)begin
			manageOverflow();
			disable backwardCount;
		end
		count = count - 1;
		checkOverflow();
	end endtask
	
	task step;begin
		if(enable !== 1 || reset === 1) disable step;
		if(load === 1)begin
			count <= data;
			checkOverflow();
			disable step;
		end
		if(discount === 1) backwardCount();
		else regularCount();
	end endtask
	
	always@(posedge clock)begin
		if(trigger == `RISING_EDGE) step();
	end
	
	always@(negedge clock)begin
		if(trigger == `FALLING_EDGE) step();
	end

endmodule
