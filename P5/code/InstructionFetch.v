/*
 * File: InstructionFetch.v
 * Pipeline::IF
*/
module InstructionFetch (
    input[31:0]     jump_addr,
    input           PC_enable,
    input           PC_jump_select,
    input           clk,
    input           reset,
    output[31:0]    PC,         // JUST FOR OUTPUT
    output[31:0]    PC4,
    output[31:0]    Inst
);
    wire[31:0] current_PC;
    wire[31:0] next_PC;
    Register#(32)_PC(
        .D(next_PC), .clk(clk), .reset(reset), .enable(PC_enable), Q(current_PC)
    );
    Adder _PC4(.A(current_PC), .B(32'd4), .S(PC4));
    MUX2#(32)PC_jump_MUX(
        .in1(PC4), .in2(jump_addr),
        .select(PC_jump_select), .out(next_PC)
    )
endmodule