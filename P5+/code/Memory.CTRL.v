/*
 * File: Memory.v
 * Controller in memory state
*/
`include "Utility.macros.v"
module MEM_CTRL(
    input[31:0]     Inst,
    output[2:0]     read_size,
    output[2:0]     write_size
);
    /*
     * Supporting LB, LBU, LH, LHU, LW, SB, SH, SW.
     * Signed or unsigned extension is handled later thus lb/lbu, lh/lhu
     *  acts exactly the same in this state. Actually, since read operations
     *  always reads 4 bytes, all load instructions acts the same. Yet 
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
    */
    wire        load;
    wire        store;
    wire[2:0]   size = {1'b0, Inst[27:26]} + 3'b1;
    LoadStoreInstructionDetector load_store_instruction_detector(
        .instruction(Inst), .load(load), .store(store)
    );
    assign  read_size = {3{load}} & size;
    assign write_size = {3{store}} & size;
endmodule