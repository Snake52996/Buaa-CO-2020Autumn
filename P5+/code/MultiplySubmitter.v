/*
 * File: MultiplySubmitter.v
 * module for submitting changes to Multiply in WB.
*/
`include "Utility.macros.v"
module MultiplySubmitter(
    input[31:0]     instruction,
    input[31:0]     AO,
    output          calculate,
    output          load_HI,
    output          load_LO,
    output[31:0]    load_value
);
    wire[5:0] special = instruction[`opcode] === 6'b000000;
    wire[5:0] funct = instruction[`funct];
    assign load_value = AO;
    assign load_HI = special & funct === 6'b010001;
    assign load_LO = special & funct === 6'b010011;
    assign calculate = special & (
        (funct === 6'b011000) |     // mult
        (funct === 6'b011001) |     // multu
        (funct === 6'b011010) |     // div
        (funct === 6'b011011)       // divu
    );
endmodule