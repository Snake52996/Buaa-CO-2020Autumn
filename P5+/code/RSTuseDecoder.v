/*
 * File: RSTuseDecoder.v
 * Decoder to determine cycles before data in rs is used since ID state
*/
`include "Utility.macros.v"
module RSTuseDecoder(
    input[31:0] Inst,
    output      used,
    output[1:0] Tuse
);
    wire special = (Inst[`opcode] === 6'b000000);
    wire eret;
    EretDetector RSTuseDecoder_eret_detector(
        .instruction(Inst),
        .eret(eret)
    );
    assign used = ~(
        (special & Inst[`funct] === 6'b000000) |                        // sll
        (special & Inst[`funct] === 6'b000011) |                        // sra
        (special & Inst[`funct] === 6'b000010) |                        // srl
        (Inst[`opcode] === 6'b000011) |                                 // jal
        (Inst[`opcode] === 6'b000010) |                                 // j
        (Inst[`opcode] === 6'b001111) |                                 // lui
        (Inst[`opcode] === 6'b010000 & Inst[`rs] === 5'b00100) |        // mtc0
        (Inst[`opcode] === 6'b010000 & Inst[`rs] === 5'b00000) |        // mfc0
        (special & Inst[`funct] === 6'b010000) |                        // mfhi
        (special & Inst[`funct] === 6'b010010) |                        // mflo
        (special & Inst[`funct] === 6'b010001) |                        // mthi
        (special & Inst[`funct] === 6'b010011)                          // mtlo
    );
    // Most commonly, rs is used after 1 cycle. Branches use it immediately.
    assign Tuse =
    (
        (Inst[`opcode] === 6'b000100) |                                 // beq
        (Inst[`opcode] === 6'b000001) |                                 // bge/ltz
        (Inst[`opcode] === 6'b000111) |                                 // bgtz
        (Inst[`opcode] === 6'b000110) |                                 // blez
        (Inst[`opcode] === 6'b000101) |                                 // bne
        (special & Inst[`funct] === 6'b001000) |                        // jr
        (special & Inst[`funct] === 6'b001001) |                        // jalr
        eret
    ) ? 2'b00/* Use immediate */ : 2'b01/* Use in EX, as default */;
endmodule