/*
 * File: Utility.RDDecoder.v
 * Module for decoding the URA(Unified Register Address) of given instruction.
 * For detail on URA, refer to Utility.RSDecoder.v
 * To deal with instructions with multiple possible RD(mult etc. and lwld etc.),
 *  there are up to 3 RD output ports available.
*/
`include "Utility.macros.v"
module RDDecoder(
    input[31:0]     instruction,
    output[6:0]     URA_real,
    output[6:0]     URA_possible1,
    output[6:0]     URA_possible2
);
    // For most instructions, RS is directly their rs field in GRF
    // move from instructions shall be handled separately
    wire[5:0] opcode = instruction[`opcode];
    wire[5:0] funct = instruction[`funct];
    wire[4:0] rs = instruction[`rs];
    assign URA_real = (
        (opcode === 6'b000001 & instruction[20]) |      // bgezal/bltzal
        (opcode === 6'b000011)                          // jal
    ) ? 7'b0011111/* write to $ra */ : (
        (opcode === 6'b000000 & funct === 6'b011000) |  // mult
        (opcode === 6'b000000 & funct === 6'b011001) |  // multu
        (opcode === 6'b000000 & funct === 6'b011010) |  // div
        (opcode === 6'b000000 & funct === 6'b011011) |  // divu
        (opcode === 6'b000000 & funct === 6'b010001)    // mthi
    ) ? 7'b1000000/* write to HI */ : (
        (opcode === 6'b000000 & funct === 6'b010011)    // mtlo
    ) ? 7'b1000001/* write to LO */ : (
        (opcode === 6'b010000 & rs === 5'b00100)        // mtc0
    ) ? {2'b01, instruction[`rt]} : (
        (opcode === 6'b000000)                          // all R-types
    ) ? {2'b00, instruction[`rd]} : {2'b00, instruction[`rt]}/* non-R-types */;
    // URA_possible1 is used only in mult, multu, div and divu. Such decode is useless
    //  but I like it, so it presents as follows.
    assign URA_possible1 = (
        ((opcode === 6'b000000) & (
            (funct === 6'b011000) |         // mult
            (funct === 6'b011001) |         // multu
            (funct === 6'b011010) |         // div
            (funct === 6'b011011)           // divu
        )) ? 7'b1000001 : 7'b0000000
    );
    // For every currently supported instructions, URA_possible2 is not used,
    //  thus set it to 0
    assign URA_possible2 = 7'b0000000;
endmodule