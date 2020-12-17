/*
 * File: InstructionDecode.v
 * Pipeline::ID
*/
`include "Utility.macros.v"
`include "Utility.ExcCodes.v"
module InstructionDecode(
    input[31:0]     Inst,
    input[31:0]     PC4,
    input[31:0]     rs_in,
    input[31:0]     rt_in,
    input           exception_in,
    input[31:0]     EPC_in,
    input[4:0]      ExcCode_in,
    input           BD_in,
    output[6:0]     rs_URA,
    output[6:0]     rt_URA,
    output          has_delay_slot,
    output          nullify_delay_slot,
    output[31:0]    Inst_out,
    output[31:0]    rs,
    output[31:0]    rt,
    output[31:0]    immediate,
    output[31:0]    DO,
    output          PC_jump,
    output[31:0]    NPC_target,
    output          exception_out,
    output[31:0]    EPC_out,
    output[4:0]     ExcCode_out,
    output          BD_out
);
    // begin of exception handling
    wire[31:0]  real_instruction;
    wire        instruction_accepted;
    InstructionAdjuster id_instruction_adjuster(
        .instruction_in(Inst),
        .accepted(instruction_accepted),
        .instruction_out(real_instruction)
    );
    assign exception_out = exception_in | (~instruction_accepted);
    assign EPC_out = EPC_in;
    assign ExcCode_out = exception_in ? ExcCode_in : `RI;
    assign BD_out = BD_in;
    // end of exception handling

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
    wire[1:0]   DO_ID_select;
    wire        comp_B_select;
    wire        comp_signed_compare;
    wire[2:0]   comp_compare_select;
    wire        ext_signed_extend;
    wire        npc_addr_select;
    wire        npc_ctrl;
    wire        branch_instruction;
    wire        branch_likely;
    wire        eret;
    // assignments to outputs
    RSDecoder instruction_decode_rs_decoder(.instruction(Inst), .URA(rs_URA));
    RTDecoder instruction_decode_rt_decoder(.instruction(Inst), .URA(rt_URA));
    assign Inst_out = real_instruction;
    assign rs = rs_in;
    assign rt = rt_in;
    assign immediate = ext_result;
    assign PC_jump = branch_instruction & comp_result[0];
    assign nullify_delay_slot = ((branch_likely & (~comp_result[0])) | eret);
    MUX4#(32)ID_DO_MUX(
        .in1(link_target),
        .in2(sll16_result),
        .in3(comp_result),
        .in4(rt),
        .select(DO_ID_select),
        .out(DO)
    );
    MUX2#(32)comp_B_MUX(
        .in1(rt_in),
        .in2(ext_result),
        .select(comp_B_select),
        .out(comp_B)
    );
    SelectiveComparer comp(
        .A(rs_in),
        .B(comp_B),
        .signed_compare(comp_signed_compare),
        .compare_select(comp_compare_select),
        .S(comp_result)
    );
    EXT#(16,32)ext(
        .origin(real_instruction[`immediate]),
        .sign(ext_signed_extend),
        .target(ext_result)
    );
    SLLN#(32,2)SLL2(
        .origin(ext_result),
        .result(real_offset)
    );
    Adder link_adder(
        .A(PC4),
        .B(32'd4),
        .S(link_target)
        /*No need for overflow*/
    );
    Adder offset_adder(
        .A(PC4),
        .B(real_offset),
        .S(offset_target)
        /*No need for overflow*/
    );
    MUX2#(32)NPC_addr_MUX(
        .in1(offset_target),
        .in2(rs_in),
        .select(npc_addr_select),
        .out(NPC_addr)
    );
    NPC npc(
        .PC4(PC4),
        .imm(real_instruction[`address]),
        .addr(NPC_addr),
        .ctrl(npc_ctrl),
        .target(NPC_target)
    );
    SLLN#(32,16)sll16(
        .origin({{16{1'b0}}, real_instruction[`immediate]}),
        .result(sll16_result)
    );
    ID_CTRL ID_ctrl(
        .Inst(real_instruction),
        .DO_ID_select(DO_ID_select),
        .comp_B_select(comp_B_select),
        .comp_signed_compare(comp_signed_compare),
        .comp_compare_select(comp_compare_select),
        .ext_signed_extend(ext_signed_extend),
        .npc_addr_select(npc_addr_select),
        .npc_ctrl(npc_ctrl),
        .branch_instruction(branch_instruction),
        .has_delay_slot(has_delay_slot),
        .branch_likely(branch_likely),
        .eret(eret)
    );
endmodule