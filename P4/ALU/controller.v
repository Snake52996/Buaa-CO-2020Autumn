`timescale 1ns / 1ps
module controllerAnd(ctrl, sadd, ssub, sor, ssll);
input[1:0] ctrl;
output sadd;
output ssub;
output sor;
output ssll;
	assign sadd = ctrl === 0;
	assign ssub = ctrl === 1;
	assign sor = ctrl === 2;
	assign ssll = ctrl === 3;
endmodule
module controllerOr(sadd, ssub, sor, ssll, result_select, neg_b, l_ctrl, s_ctrl);
input sadd;
input ssub;
input sor;
input ssll;
output[1:0] result_select;
output neg_b;
output l_ctrl;
output s_ctrl;
	assign result_select = (sadd || ssub) ? 0 :
						   (sor) ? 1:
						   (ssll) ? 2 : 0;
	assign neg_b = ssub;
	assign l_ctrl = 0;
	assign s_ctrl = 0;
endmodule
module controller(ctrl, result_select, neg_b, l_ctrl, s_ctrl);
input[1:0] ctrl;
output[1:0] result_select;
output neg_b;
output l_ctrl;
output s_ctrl;
	wire sadd;
	wire ssub;
	wire sor;
	wire ssll;
	controllerAnd controllerAnd(.ctrl(ctrl), .sadd(sadd), .ssub(ssub), .sor(sor), .ssll(ssll));
	controllerOr controllerOr(.sadd(sadd), .ssub(ssub), .sor(sor), .ssll(ssll),
				 .result_select(result_select), .neg_b(neg_b), .l_ctrl(l_ctrl), .s_ctrl(s_ctrl));
endmodule
