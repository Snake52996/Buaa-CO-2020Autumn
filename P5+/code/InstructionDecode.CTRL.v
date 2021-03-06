/*
 * File: InstructionDecode.CTRL.v
 * Pipeline::ID::Controller
*/
`include "Utility.macros.v"
module ID_CTRL(
    input[31:0]     Inst,
    output[1:0]     DO_ID_select,
    output          comp_B_select,
    output          comp_signed_compare,
    output[2:0]     comp_compare_select,
    output          ext_signed_extend,
    output          npc_addr_select,
    output          npc_ctrl,
    output          branch_instruction,
    output          has_delay_slot,
    output          branch_likely,
    output          eret
);
    wire move_from;
    wire move_to;
    MoveFromInstructionDetector ID_CTRL_move_from_instruction_detector(
        .instruction(Inst),
        .move_from(move_from)
    );
    MoveToInstructionDetector ID_CTRL_move_to_instruction_detector(
        .instruction(Inst),
        .move_to(move_to)
    );
    assign DO_ID_select =
        (
            (Inst[`opcode] === 6'b000001 && Inst[`rt] === 5'b10001) ||  // bgezal
            (Inst[`opcode] === 6'b000001 && Inst[`rt] === 5'b10000) ||  // bltzal
            Inst[`opcode] === 6'b000011 ||                              // jal
            (Inst[`opcode] === 6'b000000 && Inst[`funct] === 6'b001001) // jalr
        ) ? 2'b00/* link target */ :
        (
            Inst[`opcode] === 6'b001111 // lui
        ) ? 2'b01/* SLL16 */ :
        (
            (Inst[`opcode] === 6'b000000 && Inst[`funct] === 6'b101010) ||  // slt
            (Inst[`opcode] === 6'b000000 && Inst[`funct] === 6'b101011) ||  // sltu
            Inst[`opcode] === 6'b001010 ||                                  // slti
            Inst[`opcode] === 6'b001011                                     // sltiu
        ) ? 2'b10/* comparer */ :
        (
            move_from | move_to
        ) ? 2'b11/* data from CP0 */ : 2'b00;
    assign comp_B_select = (
        Inst[`opcode] === 6'b001010 ||  // slti
        Inst[`opcode] === 6'b001011     // sltiu
    );
    assign comp_signed_compare = ~( // list only unsigned compare instructions here
        (Inst[`opcode] === 6'b000000 && Inst[`funct] === 6'b101011) ||  // sltu
        Inst[`opcode] === 6'b001011                                     // sltiu
    );
    assign comp_compare_select =
        (
            Inst[`opcode] === 6'b000101 // bne
        ) ? 3'b000 :
        (
            (Inst[`opcode] === 6'b000001 && Inst[`rt] === 5'b00000) ||      // bltz
            (Inst[`opcode] === 6'b000001 && Inst[`rt] === 5'b10000) ||      // bltzal
            (Inst[`opcode] === 6'b000000 && Inst[`funct] === 6'b101011) ||  // sltu
            Inst[`opcode] === 6'b001011 ||                                  // sltiu
            Inst[`opcode] === 6'b001010 ||                                  // slti
            (Inst[`opcode] === 6'b000000 && Inst[`funct] === 6'b101010)     // slt
        ) ? 3'b001 :
        (
            Inst[`opcode] === 6'b000110 // blez
        ) ? 3'b010 :
        (
            Inst[`opcode] === 6'b000100 // beq
        ) ? 3'b011 :
        (
            (Inst[`opcode] === 6'b000001 && Inst[`rt] === 5'b00001) ||  // bgez
            (Inst[`opcode] === 6'b000001 && Inst[`rt] === 5'b10001)     // bgezal
        ) ? 3'b100 :
        (
            Inst[`opcode] === 6'b000111 // bgtz
        ) ? 3'b101 : 3'b110;    // The result of comparer will be used to judge wether a branch takes place
                                // thus in order to deal with unconditional branch instructions correctly,
                                // the default result of the selective comparer shall be set to `true`
    assign ext_signed_extend = (
        Inst[`opcode] === 6'b001001 ||  // addiu
        Inst[`opcode] === 6'b001000 ||  // addi
        Inst[`opcode] === 6'b000100 ||  // beq
        Inst[`opcode] === 6'b000001 ||  // bgez/bgezal/bltz/bltzal
        Inst[`opcode] === 6'b000111 ||  // bgtz
        Inst[`opcode] === 6'b000110 ||  // blez
        Inst[`opcode] === 6'b000101 ||  // bne
        Inst[31:30] === 2'b10 ||        // load/store
        Inst[`opcode] === 6'b001010 ||  // slti
        Inst[`opcode] === 6'b001011     // sltiu
    );
    assign npc_addr_select = (
        (Inst[`opcode] === 6'b000000 && Inst[`funct] === 6'b001000) |   // jr
        (Inst[`opcode] === 6'b000000 && Inst[`funct] === 6'b001001) |   // jalr
        eret                                                            // eret
    );
    assign npc_ctrl = ~(
        Inst[`opcode] == 6'b000010 ||  // j
        Inst[`opcode] == 6'b000011     // jal
    );
    assign branch_instruction = (
        (Inst[`opcode] === 6'b000100) ||                                // beq
        (Inst[`opcode] === 6'b000001) ||                                // bge/ltz
        (Inst[`opcode] === 6'b000111) ||                                // bgtz
        (Inst[`opcode] === 6'b000110) ||                                // blez
        (Inst[`opcode] === 6'b000101) ||                                // bne
        (Inst[`opcode] === 6'b000010) ||                                // j
        (Inst[`opcode] === 6'b000011) ||                                // jal
        (Inst[`opcode] === 6'b000000 && Inst[`funct] === 6'b001000) ||  // jr
        (Inst[`opcode] === 6'b000000 && Inst[`funct] === 6'b001001) ||  // jalr
        eret                                                            // eret
    );
    // an instruction has delay slot if and only if it is a branch instruction
    assign has_delay_slot = branch_instruction;
    // no branch likely instructions is supported currently
    assign branch_likely = 1'b0;
    EretDetector instruction_decode_controller_eret_detector(
        .instruction(Inst),
        .eret(eret)
    );
endmodule