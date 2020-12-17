/*
 * File: Utility.EretDetector.v
 * Module used to detect if given instruction is an etet
*/
`include "Utility.macros.v"
module EretDetector(
    input[31:0] instruction,
    output      eret
);
    assign eret = (
        (instruction[`opcode] === 6'b010000) &
        (instruction[25] === 1'b1) &
        (instruction[`funct] === 6'b011000)
    );
endmodule