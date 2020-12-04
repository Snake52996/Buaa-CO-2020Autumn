/*
 * File: InstructionDecode.v
 * Pipeline::ID
*/
`include "Utility.macros.v"
module InstructionDecode(
    input[31:0]     Inst,
    input[31:0]     PC4,
    input[31:0]     GRF_data_1,
    input[31:0]     GRF_data_2,
    output[4:0]     GRF_addr_1,
    output[4:0]     GRF_addr_2,
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
    wire[31:0] real_offset;
    // wires for controller signals
    wire        GRF_addr_2_select;
    wire[1:0]   DO_ID_select;
    wire        comp_B_select;
    wire        comp_signed_compare;
    wire[2:0]   comp_compare_select;
    wire        ext_signed_extend;
    wire        npc_addr_select;
    wire        npc_ctrl;
    wire        branch_instruction;
    // assignments to outputs
    assign GRF_addr_1 = Inst[`rs];  // GRF_data_1 is always rs
    assign Inst_out = Inst;
    assign rs = GRF_data_1;
    assign rt = GRF_data_2;
    assign immediate = ext_result;
    assign PC_jump = branch_instruction & comp_result[0];
    MUX2#(5)GRF_addr_2_MUX(
        .in1(Inst[`rt]), .in2(5'b00000),
        .select(GRF_addr_2_select), .out(GRF_addr_2)
    );
    MUX3#(32)ID_DO_MUX(
        .in1(link_target), .in2(sll16_result), .in3(comp_result),
        .select(DO_ID_select), .out(DO)
    );
    MUX2#(32)comp_B_MUX(
        .in1(GRF_data_2), .in2(ext_result), .select(comp_B_select), .out(comp_B)
    );
    SelectiveComparer comp(
        .A(GRF_data_1), .B(comp_B), .signed_compare(comp_signed_compare),
        .compare_select(comp_compare_select), .S(comp_result)
    );
    EXT#(16,32)ext(
        .origin(Inst[`immediate]), .sign(ext_signed_extend), .target(ext_result)
    );
    SLLN#(32,2)SLL2(.origin(ext_result), .result(real_offset));
    Adder link_adder(
        .A(PC4), .B(32'd4), .S(link_target) /*No need for overflow*/
    );
    Adder offset_adder(
        .A(PC4), .B(real_offset), .S(offset_target) /*No need for overflow*/
    );
    MUX2#(32)NPC_addr_MUX(
        .in1(offset_target), .in2(GRF_data_1), .select(npc_addr_select), .out(NPC_addr)
    );
    NPC npc(
        .PC4(PC4), .imm(Inst[`address]), .addr(NPC_addr), .ctrl(npc_ctrl),
        .target(NPC_target)
    );
    SLLN#(32,16)sll16(.origin({{16{1'b0}}, Inst[`immediate]}), .result(sll16_result));
    ID_CTRL ID_ctrl(
        .Inst(Inst), .DO_ID_select(DO_ID_select), .comp_B_select(comp_B_select),
        .comp_signed_compare(comp_signed_compare),
        .comp_compare_select(comp_compare_select),
        .ext_signed_extend(ext_signed_extend), .npc_addr_select(npc_addr_select),
        .npc_ctrl(npc_ctrl), .branch_instruction(branch_instruction),
        .GRF_addr_2_select(GRF_addr_2_select)
    );
endmodule