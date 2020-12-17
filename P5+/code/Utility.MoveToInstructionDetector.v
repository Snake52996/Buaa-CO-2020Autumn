/*
 * File: Utility.MoveToInstructionDetector.v
 * Detector that verifies is given instruction is a mt instruction
*/
`include "Utility.macros.v"
module MoveToInstructionDetector(
    input[31:0]     instruction,
    output          move_to
);
    wire[5:0]   opcode  = instruction[`opcode];
    wire[4:0]   rs      = instruction[`rs];
    wire[5:0]   funct   = instruction[`funct];
    assign move_to = (
        (opcode === 6'b000000 & funct === 6'b010001) |  // mthi
        (opcode === 6'b000000 & funct === 6'b010011) |  // mtlo
        (opcode === 6'b010000 & rs === 5'b00100)        // mtc0
    );
endmodule