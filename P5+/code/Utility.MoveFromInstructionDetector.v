/*
 * File: Utility.MoveFromInstructionDetector.v
 * Detector that verifies is given instruction is a mf instruction
*/
`include "Utility.macros.v"
module MoveFromInstructionDetector(
    input[31:0]     instruction,
    output          move_from
);
    wire[5:0]   opcode  = instruction[`opcode];
    wire[4:0]   rs      = instruction[`rs];
    wire[5:0]   funct   = instruction[`funct];
    assign move_from = (
        (opcode === 6'b000000 & funct === 6'b010000) |  // mfhi
        (opcode === 6'b000000 & funct === 6'b010010) |  // mflo
        (opcode === 6'b010000 & rs === 5'b00000)        // mfc0
    );
endmodule