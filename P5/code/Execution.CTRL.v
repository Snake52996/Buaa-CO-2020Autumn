/*
 * File: Execution.CTRL.v
 * Pipeline::EX::Controller
*/
`include "Utility.macro.v"
module EX_CTRL(
    input[31:0]     Inst,
    output          ALU_A_select,
    output[1:0]     ALU_B_select,
    output[3:0]     ALU_ctrl
);
    wire special = (Inst[`opcode] === 6'b000000);
    wire shift = special & (
        Inst[`funct] === 6'b000000 |    // sll
        Inst[`funct] === 6'b000100 |    // sllv
        Inst[`funct] === 6'b000011 |    // sra
        Inst[`funct] === 6'b000111 |    // srav
        Inst[`funct] === 6'b000010 |    // srl
        Inst[`funct] === 6'b000110      // srlv
        // Noted that for shift instructions, last 3 bits explains what exactly it does:
        //  bit 0: arithmetic?
        //  bit 1: right?
        //  bit 2: variable?
        // Interesting and maybe useful...
    );
    wire immediate = ~special;
    assign ALU_A_select = shift;
    // And is used here. Hard to predict, yeah?
    assign ALU_B_select = (shift & Inst[2]) ? 2'b01 :
                          (shift & ~Inst[2]) ? 2'b10 :
                          immediate ? 2'b11 : 2'b00;
    assign ALU_ctrl =
        (
            (special & Inst[`funct] === 6'b100001) |    // addu
            Inst[`opcode] === 6'b001001 |               // addiu
            Inst[`opcode] === 6'b100011 |               // lw
            Inst[`opcode] === 6'b101011                 // sw
        ) ? 4'b0000 :
        (
            (special & Inst[`funct] === 6'b100011)      // sub
        ) ? 4'b0001 :
        (
            (special & Inst[`funct] === 6'b100100) |    // and
            Inst[`opcode] === 6'b001100                 // andi
        ) ? 4'b0010 :
        (
            (special & Inst[`funct] === 6'b100101) |    // or
            Inst[`opcode] === 6'b001101                 // ori
        ) ? 4'b0011 :
        (
            (special & Inst[`funct] === 6'b100111)      // nor
        ) ? 4'b0100 :
        (
            (special & Inst[`funct] === 6'b100110) |    // xor
            Inst[`opcode] === 6'b001110                 // xori
        ) ? 4'b0101 :
        (shift & ~Inst[1]) ? 4'b0110 :                  // sll
        (shift & Inst[1] & Inst[0]) ? 4'b0111 :         // sra
        (shift & Inst[1] & ~Inst[0]) ? 4'b1000 :        // srl
        (
            (special & Inst[`funct] === 6'b101011) |    // sltu
            Inst[`opcode] === 6'b001011                 // sltiu
        ) ? 4'b1001 :
        (
            (special & Inst[`funct] === 6'b101010) |    // slt
            Inst[`opcode] === 6'b001010                 // slti
        ) ? 4'b1001 : 4'b0000;
endmodule