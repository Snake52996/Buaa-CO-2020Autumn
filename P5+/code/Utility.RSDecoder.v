/*
 * File: Utility.RSDecoder.v
 * Module for decoding the URA(Unified Register Address) of given instruction.
 * A URA is a 7-bits unsigned integer defined as follows:
 *  +URA[6:5] -- Group Selector
 *  |      +-- 00: in General Register File
 *  |      +-- 01: in Co-Processor0
 *  |      +-- 10: in Multiply(multiply/divide module)
 *  |      +-- 11: reserved
 *  +URA[4:0] -- Register Selector
 *             For GRF, all 31 possible values are valid;
 *             For CP0, 12, 13, 14 and 15 are valid
 *             For Multiply, only 0 and 1 are valid where 0 represents for HI, 1 for LO
*/
`include "Utility.macros.v"
module RSDecoder(
    input[31:0]     instruction,
    output[6:0]     URA
);
    // For most instructions, RS is directly their rs field in GRF
    // eret shall be handled separately
    wire[5:0] opcode = instruction[`opcode];
    wire[5:0] funct = instruction[`funct];
    wire[4:0] rs = instruction[`rs];
    wire      eret;
    EretDetector RSDecoder_eret_detector(
        .instruction(instruction),
        .eret(eret)
    );
    assign URA = eret ? 7'b0101110 : {2'b00, rs};
endmodule