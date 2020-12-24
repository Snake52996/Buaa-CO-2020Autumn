/*
 * File: TnewOriginalDecoder.v
 * Decoder to determine cycles before data to be store in rd(logically) is generated
 * (i.e. ready for forwarding)
*/
`include "Utility.macros.v"
module TnewOriginalDecoder(
    input[31:0] Inst,
    input[6:0]  RT_URA,
    input[6:0]  EX_RD_URA,
    input[1:0]  EX_Tnew,
    input[6:0]  MEM_RD_URA,
    input[1:0]  MEM_Tnew,
    output[1:0] Tnew
);
    // Situations that Tnew is originally 0 which means the data to be written is already
    // generated when entering EX state is separately handled by DO forwarding logic thus
    // in no situation shall Tnew be originally 0 within our consideration. Instructions
    // that do not writes GRF is also handled separately, therefore every instructions,
    // except loads, has or can be handled as having an original Tnew of value 1.
    wire        load;
    wire        mf;
    wire        mt;
    wire        mf_mt = mf | mt;
    wire[1:0]   relative_Tnew;
    wire        eret;
    EretDetector RDDecoder_eret_detector(
        .instruction(Inst),
        .eret(eret)
    );
    LoadStoreInstructionDetector TnewDecoder_load_store_instruction_detector(
        .instruction(Inst),
        .load(load)
    );
    MoveToInstructionDetector TnewDecoder_move_to_instruction_detector(
        .instruction(Inst),
        .move_to(mt)
    );
    MoveFromInstructionDetector TnewDecoder_move_from_instruction_detector(
        .instruction(Inst),
        .move_from(mf)
    );
    assign relative_Tnew = (
        (EX_RD_URA === RT_URA) &
        (RT_URA !== 7'b0101111) &
        (RT_URA !== 7'b0000000)
    ) ? EX_Tnew : (
        (MEM_RD_URA === RT_URA) &
        (RT_URA !== 7'b0101111) &
        (RT_URA !== 7'b0000000)
    ) ? MEM_Tnew : 2'b00;
    assign Tnew = (
        eret
    ) ? 2'b10 : (
        load   // load instructions
    ) ? 2'b10/* Generate after MEM */: (
        mf_mt
    ) ? relative_Tnew : (
        (Inst[`opcode] === 6'b000001 & Inst[20]) |                      // bgezal/bltzal
        (Inst[`opcode] === 6'b000000 & Inst[`funct] === 6'b001001) |    // jalr
        (Inst[`opcode] === 6'b000011) |                                 // jal
        (Inst[`opcode] === 6'b001111)                                   // lui
    ) ? 2'b00 : 2'b01;
endmodule
