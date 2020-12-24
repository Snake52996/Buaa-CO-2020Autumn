/*
 * File: Utility.RDWriteDecoder.v
 * To decode if an instruction actually writes to decoded RD
*/
`include "Utility.macros.v"
module RDWriteDecoder(
    input[31:0] instruction,
    output      enable
);
    wire store;
    LoadStoreInstructionDetector RDWriteDecoder_load_detector(
        .instruction(instruction),
        .store(store)
    );
    assign enable = ~(
        store |
        (instruction[`opcode] == 6'b000100) |                              // beq
        (instruction[`opcode] == 6'b000101) |                              // bne
        (instruction[`opcode] == 6'b000001 & ~instruction[20]) |           // bgez/bltz
        (instruction[`opcode] == 6'b000111) |                              // bgtz
        (instruction[`opcode] == 6'b000110) |                              // blez
        (instruction[`opcode] == 6'b000010) |                              // j
        (instruction[`opcode] == 6'b000000 & instruction[`funct] === 6'b001000)   // jr
    );
endmodule
