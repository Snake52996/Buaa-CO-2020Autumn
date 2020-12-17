/*
 * File: RTTuseDecoder.v
 * Decoder to determine cycles before data in rt is used since ID state
*/
`include "Utility.macros.v"
module RTTuseDecoder(
    input[31:0] Inst,
    output      used,
    output[1:0] Tuse
);
    wire special = (Inst[`opcode] === 6'b000000);
    wire eret;
    EretDetector RTTuseDecoder_eret_detector(
        .instruction(Inst),
        .eret(eret)
    );
    // To avoid further trouble that otherwise may ran into, instructions in which rt is
    // always GRF[0] but reads the value 0 is also marked as "used".
    assign used = ~(
        (special & Inst[`funct] === 6'b001001) |                // jalr
        (special & Inst[`funct] === 6'b001000) |                // jr
        (Inst[`opcode] === 6'b001001) |                         // addiu
        (Inst[`opcode] === 6'b001000) |                         // addi
        (Inst[`opcode] === 6'b001100) |                         // andi
        (Inst[`opcode] === 6'b001101) |                         // ori
        (Inst[`opcode] === 6'b001010) |                         // slti
        (Inst[`opcode] === 6'b001011) |                         // sltiu
        (Inst[`opcode] === 6'b001111) |                         // xori
        (Inst[`opcode] === 6'b100011) |                         // lw
        (Inst[`opcode] === 6'b100001) |                         // lh
        (Inst[`opcode] === 6'b100101) |                         // lhu
        (Inst[`opcode] === 6'b100000) |                         // lb
        (Inst[`opcode] === 6'b100100) |                         // lbu
        (Inst[`opcode] === 6'b000011) |                         // jal
        (Inst[`opcode] === 6'b000010) |                         // j
        (Inst[`opcode] === 6'b001111) |                         // lui
        eret                                                    // eret
    );
    // Generally, rt is used 1 cycle later, yet immediately in branch instructions,
    // and 1 more cycle (i.e. 2 cycles) in store instructions and mf/mt
    assign Tuse =
    (
        (Inst[31:29] === 3'b101) |                                  // store instructions
        (Inst[`opcode] === 6'b010000 & Inst[`rs] === 5'b00100) |    // mtc0
        (Inst[`opcode] === 6'b010000 & Inst[`rs] === 5'b00000) |    // mfc0
        (special & Inst[`funct] === 6'b010000) |                    // mfhi
        (special & Inst[`funct] === 6'b010010) |                    // mflo
        (special & Inst[`funct] === 6'b010001) |                    // mthi
        (special & Inst[`funct] === 6'b010011)                      // mtlo
    ) ? 2'b10/* Use in MEM */ :
    (
        (Inst[`opcode] === 6'b000100) |             // beq
        (Inst[`opcode] === 6'b000001) |             // bge/ltz
        (Inst[`opcode] === 6'b000111) |             // bgtz
        (Inst[`opcode] === 6'b000110) |             // blez
        (Inst[`opcode] === 6'b000101)               // bne
    ) ? 2'b00 : 2'b01;  // Thus set 1 cycle as default
endmodule