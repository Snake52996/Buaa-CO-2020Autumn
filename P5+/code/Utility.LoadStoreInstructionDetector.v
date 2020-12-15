/*
 * File: Utility.LoadStoreInstructionDetector.v
 * Detector that verifies is given instruction is a load instruction or a store one
*/
`include "Utility.macros.v"
module LoadStoreInstructionDetector(
    input[31:0]     instruction,
    output          load,
    output          store
);
    assign load = (
        (instruction[`opcode] === 6'b100000) |            // lb
        (instruction[`opcode] === 6'b100100) |            // lbu
        (instruction[`opcode] === 6'b100001) |            // lh
        (instruction[`opcode] === 6'b100101) |            // lhu
        (instruction[`opcode] === 6'b100011)              // lw
    );
    assign store = (
        (instruction[`opcode] === 6'b101000) |            // sb
        (instruction[`opcode] === 6'b101001) |            // sh
        (instruction[`opcode] === 6'b101011)              // sw
    );
endmodule