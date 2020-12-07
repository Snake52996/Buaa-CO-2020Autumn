/*
 * File: Memory.v
 * Controller in memory state
*/
`include "Utility.macros.v"
module MEM_CTRL(
    input[31:0]     Inst,
    input[31:0]     address,
    output[2:0]     size,
    output          unaligned
);
    /*
     * Supporting LB, LBU, LH, LHU, LW, SB, SH, SW.
     * Signed or unsigned extension is handled later thus lb/lbu, lh/lhu
     *  acts exactly the same in this state. Actually, since read operations
     *  always reads 4 bytes, all load instructions acts the same.
     * Analyze all these I-type instructions:
     *   lb -- 100000
     *  lbu -- 100100
     *   lh -- 100001
     *  lhu -- 100101
     *   lw -- 100011
     *   sb -- 101000
     *   sh -- 101001
     *   sw -- 101011
     *  obviously fields in opcode represent the meanings as follows:
     *   Inst[27:26] -- extra bytes required from the specified address
     *      Inst[29] -- write?
     * In case the address is not properly aligned, unaligned_exception is activated.
    */
    wire store = (
        (Inst[`opcode] === 6'b101000) |    // sb
        (Inst[`opcode] === 6'b101001) |    // sh
        (Inst[`opcode] === 6'b101011)      // sw
    );
    assign size = {3{store}} & (Inst[28:26] + 3'b1);
    assign unaligned = |(Inst[27:26] & address[1:0]);
endmodule