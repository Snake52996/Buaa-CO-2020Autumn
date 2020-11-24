/*
 * File: InstructionDecode.v
 * Pipeline::ID
*/
`include "Utility.macro.v"
module InstructionDecode(
    input[31:0]     Inst,
    input[31:0]     PC4,
    input[31:0]     GRF_data_1,     // Is actually always rs
    input[31:0]     GRF_data_2,     // Is actually always rt
    output[31:0]    Inst_out,
    output[31:0]    rs,
    output[31:0]    rt,
    output[31:0]    immediate,
    output[31:0]    DO,
    output          PC_jump,
    output[31:0]    NPC_target
);
    // temporary wires ordinarily for MUX
    wire[31:0] comp_B;
    wire[31:0] ext_result;
    wire[31:0] link_target;
    wire[31:0] offset_target;
    wire[31:0] NPC_addr;
    wire[31:0] sll16_result;
    wire[31:0] comp_result;
    // wires for controller signals
    wire[1:0]   DO_ID_select;
    wire        comp_B_select;
    wire        comp_signed_compare;
    wire[2:0]   comp_compare_select;
    wire        ext_signed_extend;
    wire        npc_addr_select;
    wire        npc_ctrl;
    // assignments to outputs
    assign Inst_out = Inst;
    assign rs = GRF_data_1;
    assign rt = GRF_data_2;
    assign immediate = ext_result;
    MUX3#(32)ID_DO_MUX(
        .in1(link_target), .in2(sll16_result), .in3(comp_result)
        .select(DO_ID_select), .out(DO)
    );
    MUX2#(32)comp_B_MUX(
        .in1(GRF_data_2), .in2(ext_result), select(comp_B_select), .out(comp_B)
    );
    SelectiveComparer comp(
        .A(GRF_data_1), .B(comp_B), .signed_compare(comp_signed_compare),
        .compare_select(comp_compare_select), .S(comp_result)
    );
    EXT#(16,32)ext(
        .origin(Inst[`immediate]), .sign(ext_signed_extend), .target(ext_result)
    );
    Adder link_adder(
        .A(PC4), .B(32'd4), .S(link_target) /*No need for overflow*/
    );
    Adder offset_adder(
        .A(PC4), .B(ext_result), .S(offset_target) /*No need for overflow*/
    );
    MUX2#(32)NPC_addr_MUX(
        .in1(offset_target), .in2(GRF_data_1), .select(npc_addr_select), .out(NPC_addr)
    );
    NPC npc(
        .PC4(PC4), .imm(Inst[`address]), .addr(NPC_addr), .ctrl(npc_ctrl),
        .target(NPC_target)
    );
    SLLN#(16,16)sll16(.origin(Inst[`immediate]), .result(sll16_result));
    ID_CTRL ID_ctrl(
        .Inst(Inst), .DO_ID_select(DO_ID_select), .comp_B_select(comp_B_select),
        .comp_signed_compare(comp_signed_compare), .comp_compare_select(comp_compare_select),
        .ext_signed_extend(ext_signed_extend), .npc_addr_select(npc_addr_select), .npc_ctrl(npc_ctrl)
    );
endmodule