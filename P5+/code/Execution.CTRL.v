/*
 * File: Execution.CTRL.v
 * Pipeline::EX::Controller
*/
`include "Utility.macros.v"
module EX_CTRL(
    input[31:0]     Inst,
    input           DO_reliable,
    output          ALU_A_select,
    output[1:0]     ALU_B_select,
    output[1:0]     AO_select,
    output[3:0]     ALU_ctrl,
    output[4:0]     Multiply_ctrl,
    output          overflow_detection,
    output          load_instruction,
    output          store_instruction
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
    // When handling mfhi/mflo instruction, select AO from multiply;
    // When DO is reliable, result of ALU is wether meaningless or recalculating of
    //  the same result. Therefore when reliable, DO is directed directly to AO.
    assign AO_select = (
        (special & Inst[`funct] === 6'b010000) |        // mfhi
        (special & Inst[`funct] === 6'b010010)          // mflo
    ) ? 2'b10/* from Multiply */ :     
    (
        DO_reliable
    ) ? 2'b01/* from DO */ : 2'b00/* from ALU, as default */;
    assign ALU_ctrl =
        (
            (special & Inst[`funct] === 6'b100001) |    // addu
            (special & Inst[`funct] === 6'b100000) |    // add
            Inst[`opcode] === 6'b001001 |               // addiu
            Inst[`opcode] === 6'b001000 |               // addi
            Inst[31:30] === 2'b10                       // load/store
        ) ? 4'b0000/* add */ :
        (
            (special & Inst[`funct] === 6'b100010) |    // sub
            (special & Inst[`funct] === 6'b100011)      // subu
        ) ? 4'b0001/* sub */ :
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
        ) ? 4'b1010 : 4'bxxxx;
    // Available instructions: mult, multu, div, divu, mfhi, mflo, mthi, mtlo
    //  all of which are R-type instructions. For convenience in generating the signal
    //  `ctrl`, field funct of each instruction is listed as follows.
    //   mult -- 011000
    //  multu -- 011001
    //    div -- 011010
    //   divu -- 011011
    //   mfhi -- 010000
    //   mflo -- 010010
    //   mthi -- 010001
    //   mtlo -- 010011
    //  When divided into two groups, it is easy to find the regularity:
    //             Inst[3] -- launch
    //             Inst[0] -- unsigned
    //             Inst[1] -- divide
    //   ~launch & Inst[0] -- move mode
    //             Inst[1] -- targeting LO
    wire Multiply_operations = special & (
        (Inst[`funct] === 6'b011000) |     // mult
        (Inst[`funct] === 6'b011001) |     // multu
        (Inst[`funct] === 6'b011010) |     // div
        (Inst[`funct] === 6'b011011) |     // divu
        (Inst[`funct] === 6'b010000) |     // mfhi
        (Inst[`funct] === 6'b010010) |     // mflo
        (Inst[`funct] === 6'b010001) |     // mthi
        (Inst[`funct] === 6'b010011)       // mtlo
    );
    assign Multiply_ctrl = {5{Multiply_operations}} & {
        Inst[3], Inst[1], Inst[0], (~Inst[3]) & Inst[0], Inst[1]
    };
    LoadStoreInstructionDetector execution_load_store_instruction_detector(
        .instruction(Inst),
        .load(load_instruction),
        .store(store_instruction)
    );
    assign overflow_detection = load_instruction | store_instruction | (
        (special & Inst[`funct] === 6'b100000) |        // add
        (special & Inst[`funct] === 6'b100010) |        // sub
        (Inst[`opcode] === 6'b001000)                   // addi
    );
endmodule