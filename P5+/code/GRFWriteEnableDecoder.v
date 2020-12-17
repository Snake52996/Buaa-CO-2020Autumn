/*
 * File: GRFWriteEnableDecoder.v
 * Decoder for decoding the instruction to determine if data shall be written to GRF
 * This module is packed to avoid code duplication, since the same function is invoked
 * in WB state and in top level(logically in ID state).
 * It is definitely possible to decode in ID state and pipe result till WB state which
 * fulfills all requirements, for explanation on the reason why such designment is
 * not applied, refer to GRFWriteAddressDecoder.v
*/
`include "Utility.macros.v"
module GRFWriteEnableDecoder(
    input[31:0] Inst,
    output      GRF_write_enable
);
    wire eret;
    wire move_to;
    EretDetector GRFWriteEnableDecoder_eret_detector(
        .instruction(Inst),
        .eret(eret)
    );
    MoveToInstructionDetector GRFWriteEnableDecoder_move_to_detector(
        .instruction(Inst),
        .move_to(move_to)
    );
    assign GRF_write_enable = ~(    // list only non-GRF-writing instructions here
        (Inst[31:29] == 3'b101) |                                           // store
        (Inst[`opcode] == 6'b000000 & Inst[5:3] == 3'b011) |                // mult/div
        (Inst[`opcode] == 6'b000000 & Inst[5:2] == 3'b0100 & Inst[0]) |     // mthi/mtlo
        (Inst[`opcode] == 6'b000100) |                                      // beq
        (Inst[`opcode] == 6'b000101) |                                      // bne
        (Inst[`opcode] == 6'b000001 & ~Inst[20]) |                          // bgez/bltz
        (Inst[`opcode] == 6'b000111) |                                      // bgtz
        (Inst[`opcode] == 6'b000110) |                                      // blez
        (Inst[`opcode] == 6'b000010) |                                      // j
        (Inst[`opcode] == 6'b000000 & Inst[`funct] === 6'b001000) |         // jr
        eret |                                                              // eret
        move_to
    );
endmodule