/*
 * File: NPC.v
 * Next PC who generates next value of PC(excepts PC+4)
*/
module NPC (
    input[31:0]     PC4,
    input[25:0]     imm,
    input[31:0]     addr,
    input           ctrl,
    output[31:0]    target
);
    wire[31:0] immediate_target = {PC4[31:28], imm[25:0], {2{1'b0}}};
    MUX2#(32)NPC_target_MUX(
        .in1(immediate_target), .in2(addr),
        .select(ctrl), .out(target)
    );
endmodule