`timescale 1ns / 1ps
module controllerAnd(
	ctrl, sadd, ssub, sor, ssll, smultu, smult, sdivu, sdiv, sand, snor, sxor, ssrl, ssra, smflo, smfhi, smtlo, smthi
);
input[4:0] ctrl;
output sadd, ssub, sor, ssll, smultu, smult, sdivu, sdiv, sand, snor, sxor, ssrl, ssra, smflo, smfhi, smtlo, smthi;
	assign sadd = ctrl === 0;
	assign ssub = ctrl === 1;
	assign sor = ctrl === 2;
	assign ssll = ctrl === 3;
	assign smultu = ctrl === 4;
	assign smult = ctrl === 5;
	assign sdivu = ctrl === 6;
	assign sdiv = ctrl === 7;
	assign sand = ctrl === 8;
	assign snor = ctrl === 9;
	assign sxor = ctrl === 10;
	assign ssrl = ctrl === 11;
	assign ssra = ctrl === 12;
	assign smflo = ctrl === 13;
	assign smfhi = ctrl === 14;
	assign smtlo = ctrl === 15;
	assign smthi = ctrl === 16;
endmodule
module controllerOr(
	sadd, ssub, sor, ssll, smultu, smult, sdivu, sdiv, sand, snor, sxor, ssrl, ssra, smflo, smfhi, smtlo, smthi,
	result_select, arithmetic_AS_ctrl, arithmetic_MD_ctrl, logical_ctrl, shifter_ctrl
);
input sadd, ssub, sor, ssll, smultu, smult, sdivu, sdiv, sand, snor, sxor, ssrl, ssra, smflo, smfhi, smtlo, smthi;
output[2:0] arithmetic_MD_ctrl;
output[1:0] result_select, logical_ctrl, shifter_ctrl;
output arithmetic_AS_ctrl;
	assign arithmetic_MD_ctrl = smflo ? 0 :
								smultu ? 1 :
								smult ? 2 :
								sdivu ? 3 :
								sdiv ? 4 :
								smtlo ? 5 :
								smthi ? 6 :
								smfhi ? 7 : 0;
	assign result_select = (sadd || ssub) ? 0 :
						   (sor || sand || snor || sxor) ? 1:
						   (ssll || ssrl || ssra) ? 2 :
						   (smult || smultu || sdiv || sdivu || smflo || smfhi) ? 3 : 0;
	assign logical_ctrl = sor ? 0 :
						  sand ? 1 :
						  snor ? 2 :
						  sxor ? 3 : 0;
	assign shifter_ctrl = ssll ? 0 :
						  ssrl ? 1 :
						  ssra ? 2 : 0;
	assign arithmetic_AS_ctrl = ssub;
endmodule
module controller(ctrl, result_select, arithmetic_AS_ctrl, arithmetic_MD_ctrl, logical_ctrl, shifter_ctrl);
input[4:0] ctrl;
output[2:0] arithmetic_MD_ctrl;
output[1:0] result_select, logical_ctrl, shifter_ctrl;
output arithmetic_AS_ctrl;
	wire sadd, ssub, sor, ssll, smultu, smult, sdivu, sdiv, sand, snor, sxor, ssrl, ssra, smflo, smfhi, smtlo, smthi;
	controllerAnd controllerAnd(
		.ctrl(ctrl), .sadd(sadd), .ssub(ssub), .sor(sor), .ssll(ssll), .smultu(smultu), .smult(smult), .sdivu(sdivu),
		.sdiv(sdiv), .sand(sand), .snor(snor), .sxor(sxor), .ssrl(ssrl), .ssra(ssra), .smflo(smflo), .smfhi(smfhi),
		.smtlo(smtlo), .smthi(smthi)
	);
	controllerOr controllerOr(
		.sadd(sadd), .ssub(ssub), .sor(sor), .ssll(ssll), .smultu(smultu), .smult(smult), .sdivu(sdivu),
		.sdiv(sdiv), .sand(sand), .snor(snor), .sxor(sxor), .ssrl(ssrl), .ssra(ssra), .smflo(smflo), .smfhi(smfhi),
		.smtlo(smtlo), .smthi(smthi), .result_select(result_select), .arithmetic_AS_ctrl(arithmetic_AS_ctrl),
		.logical_ctrl(logical_ctrl), .shifter_ctrl(shifter_ctrl), .arithmetic_MD_ctrl(arithmetic_MD_ctrl)
	);
endmodule
