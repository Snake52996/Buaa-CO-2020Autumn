/*
 * File: InstructionDetector.v
 * InstructionDetector is used to identify if the given instruction is supported,
 *  i.e. if it can be recognized.
 * Any newly supported instruction should be added into the list in this module.
*/
`include "Utility.macros.v"
module InstructionDetector(
    input[31:0] instruction,
    output      supported
);
    wire[5:0]   opcode  = instruction[`opcode];
    wire[4:0]   rs      = instruction[`rs];
    wire[4:0]   rt      = instruction[`rt];
    wire[5:0]   funct   = instruction[`funct];
    // ALL instructions -- 55 instructions
    assign supported = (
        (
            // SPECIAL instructions -- 26 instructions
            (opcode === 6'b000000) & (
                (funct === 6'b100000) |         // add
                (funct === 6'b100001) |         // addu
                (funct === 6'b100100) |         // and
                (funct === 6'b011010) |         // div
                (funct === 6'b011011) |         // divu
                (funct === 6'b001001) |         // jalr
                (funct === 6'b001000) |         // jr
                (funct === 6'b010000) |         // mfhi
                (funct === 6'b010010) |         // mflo
                (funct === 6'b010001) |         // mthi
                (funct === 6'b010011) |         // mtlo
                (funct === 6'b011000) |         // mult
                (funct === 6'b011001) |         // multu
                (funct === 6'b100111) |         // nor
                (funct === 6'b100101) |         // or
                (funct === 6'b000000) |         // sll
                (funct === 6'b000100) |         // sllv
                (funct === 6'b101010) |         // slt
                (funct === 6'b101011) |         // sltu
                (funct === 6'b000011) |         // sra
                (funct === 6'b000111) |         // srav
                (funct === 6'b000010) |         // srl
                (funct === 6'b000110) |         // srlv
                (funct === 6'b100010) |         // sub
                (funct === 6'b100011) |         // subu
                (funct === 6'b100110)           // xor
            )
        ) | (
            // REGIMM instructions -- 4 instructions
            (opcode === 6'b000001) & (
                (rt === 5'b00001) |             // bgez
                (rt === 5'b10001) |             // bgezal
                (rt === 5'b00000) |             // bltz
                (rt === 5'b10000)               // bltzal
            )
        ) | (
            // COP0 instructions -- 3 instructions
            (opcode === 6'b010000) & (
                (rs === 5'b00000) |             // mfc0
                (rs === 5'b00100) |             // mtc0
                (
                    // COP0/CO instructions -- 1 instruction
                    (instruction[25] === 1'b1) & (
                        (funct === 6'b011000)   // eret
                    )
                )
            )
        ) | (
            // directly detectable instructions -- 22 instructions
            (opcode === 6'b001000) |            // addi
            (opcode === 6'b001001) |            // addiu
            (opcode === 6'b001100) |            // andi
            (opcode === 6'b000100) |            // beq
            (opcode === 6'b000111) |            // bgtz
            (opcode === 6'b000110) |            // blez
            (opcode === 6'b000101) |            // bne
            (opcode === 6'b000010) |            // j
            (opcode === 6'b000011) |            // jal
            (opcode === 6'b100000) |            // lb
            (opcode === 6'b100100) |            // lbu
            (opcode === 6'b100001) |            // lh
            (opcode === 6'b100101) |            // lhu
            (opcode === 6'b001111) |            // lui
            (opcode === 6'b100011) |            // lw
            (opcode === 6'b001101) |            // ori
            (opcode === 6'b101000) |            // sb
            (opcode === 6'b101001) |            // sh
            (opcode === 6'b001010) |            // slti
            (opcode === 6'b001011) |            // sltiu
            (opcode === 6'b101011) |            // sw
            (opcode === 6'b001110)              // xori
        )
    );
endmodule