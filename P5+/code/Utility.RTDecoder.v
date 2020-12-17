/*
 * File: Utility.RTDecoder.v
 * Module for decoding the URA(Unified Register Address) of given instruction.
 * For detail on URA, refer to Utility.RSDecoder.v
*/
`include "Utility.macros.v"
module RTDecoder(
    input[31:0]     instruction,
    output[6:0]     URA
);
    // For most instructions, RT is directly their rt field in GRF
    // instructions comparing with 0 and mf/mt shall be handled separately
    wire[5:0] opcode = instruction[`opcode];
    wire[5:0] funct = instruction[`funct];
    wire[4:0] rs = instruction[`rs];
    wire[4:0] rt = instruction[`rt];
    assign URA =
    (
        (opcode === 6'b000001 & rt === 5'b00000) |      // bltz
        (opcode === 6'b000001 & rt === 5'b10000) |      // bltzal
        (opcode === 6'b000001 & rt === 5'b00001) |      // bgez
        (opcode === 6'b000001 & rt === 5'b10001) |      // bgezal
        (opcode === 6'b000110) |                        // blez
        (opcode === 6'b000111)                          // bgtz
    ) ? 7'b0000000 : (
        (opcode === 6'b000000 & funct === 6'b010000)    // mfhi
    ) ? 7'b1000000 : (
        (opcode === 6'b000000 & funct === 6'b010010)    // mflo
    ) ? 7'b1000001 : (
        (opcode === 6'b010000 & rs === 5'b00000)        // mfc0
    ) ? {2'b01, instruction[`rd]} : (
        (opcode === 6'b000000 & funct === 6'b010001) |  // mthi
        (opcode === 6'b000000 & funct === 6'b010011)    // mtlo
    ) ? {2'b00, rs} : {2'b00, rt};
endmodule