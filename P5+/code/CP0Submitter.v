/*
 * File: CP0Submitter.v
 * Module for submitting values to CP0.
 * Both exceptions-handling and normal writing included.
 * Signals controlling the PC-branch to exceptions handler are also generated
*/
`include "Utility.macros.v"
`include "Utility.ExcCodes.v"
module CP0Submitter(
    input[31:0]     Inst,
    input[31:0]     rt,
    input           exception,
    input[31:0]     EPC,
    input[4:0]      ExcCode,
    input           BD,
    input           valid_status,
    input[15:10]    interrupt_request,
    input[31:0]     current_SR,
    input[31:0]     current_Cause,
    output          branch_to_handler,
    output[31:0]    new_SR,
    output          SR_enable,
    output[31:0]    new_Cause,
    output          Cause_enable,
    output[31:0]    new_EPC,
    output          EPC_enable
);
    wire        SR_IE  = current_SR[0];
    wire        SR_EXL = current_SR[1];
    wire[15:10] SR_interrupt_enable = current_SR[15:10];
    wire[15:10] interrupt_enable = SR_interrupt_enable & {6{SR_IE & (~SR_EXL)}};
    wire[15:10] interrupt_vector = interrupt_enable & interrupt_request;
    wire        interrupt = |interrupt_vector;
    wire        submit = (interrupt | exception) & valid_status;
    wire        return;
    wire        mtc0;
    wire[6:0]   rd_URA;
    wire[4:0]   mtc0_address;
    assign mtc0 = (Inst[`opcode] === 6'b010000 & Inst[`rs] === 5'b00100);
    RDDecoder CP0Submitter_rd_decoder(
        .instruction(Inst), .URA_real(rd_URA)
        /* possible targets not used thus not connected */
    );
    assign mtc0_address = rd_URA[4:0];
    assign return = (
        (Inst[`opcode] === 6'b010000) &
        (Inst[25] === 1'b1) &
        (Inst[`funct] === 6'b011000)
    );
    assign branch_to_handler = submit;
    MUX3#(32)new_SR_MUX(
        .in1(rt),
        .in2({current_SR[31:2], 1'b1, SR_IE}),
        .in3({current_SR[31:2], 1'b0, SR_IE}),
        .select({return, submit}),
        .out(new_SR)
    );
    assign SR_enable = submit | return | (mtc0 & mtc0_address === 5'd12);
    MUX2#(32)new_Cause_MUX(
        .in1({current_Cause[31:16], interrupt_request, current_Cause[9:0]}),
        .in2({BD, {15{1'b0}}, interrupt_request, 3'b000, (interrupt ? `Int : ExcCode), 2'b00}),
        .select(submit),
        .out(new_Cause)
    );
    assign Cause_enable = 1'b1;
    MUX2#(32)new_EPC_MUX(
        .in1(rt),
        .in2(EPC),
        .select(submit),
        .out(new_EPC)
    );
    assign EPC_enable = submit | (mtc0 & mtc0_address === 5'd14);
endmodule