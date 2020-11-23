/*
 * File: IM.v
 * Instruction Memory
*/
module IM (
    input[31:0]     PC,
    output[31:0]    Inst
);
    reg[31:0] instruction_memory[0:1023];
    assign Inst = instruction_memory[PC[11:2]];
    initial begin
        $readmemh("code.txt",instruction_memory);
    end
endmodule