/*
 * File: IM.v
 * Instruction Memory
*/
module IM#(ADDRESS_WIDTH=14) (
    input[31:0]     PC,
    output[31:0]    Inst
);
    reg[31:0] instruction_memory[0:2**ADDRESS_WIDTH-1];
    assign Inst = instruction_memory[PC[ADDRESS_WIDTH-1:2]];
    initial begin
        $readmemh("code.txt",instruction_memory);
    end
endmodule
