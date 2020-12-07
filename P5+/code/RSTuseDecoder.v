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
    assign used = ~(
        (special & Inst[`funct] === 6'b000000) |        // sll
        (special & Inst[`funct] === 6'b000011) |        // sra
        (special & Inst[`funct] === 6'b000010) |        // srl
        (Inst[`opcode] === 6'b000011) |                 // jal
        (Inst[`opcode] === 6'b000010) |                 // j
        (Inst[`opcode] === 6'b001111) |                 // lui
        (special & Inst[5:2] === 4'b0100 & ~Inst[0])    // mflo/mfhi
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
        (special & Inst[`funct] === 6'b001001)                          // jalr
    ) ? 2'b00 : 2'b01;  // Thus set 1 cycle as default
endmodule