/*
 * File: Multiply.SourceRegister.v
 * A sub-module of Multiply in which registers for caching inputs of Multiply
 *  is set and managed.
*/
module SourceRegister(
    input[31:0]     src_A,
    input[31:0]     src_B,
    input[3:0]      src_ctrl,
    input           clk,
    input           update,
    input           reset,
    output[31:0]    A,
    output[31:0]    B,
    output[3:0]     real_ctrl
);
    Register#(32,0)A_Register(
        .D(src_A), .clk(clk), .reset(reset), .enable(update), .Q(A)
    );
    Register#(32,0)B_Register(
        .D(src_B), .clk(clk), .reset(reset), .enable(update), .Q(B)
    );
    Register#(4,0)ctrl_Register(
        .D(src_ctrl), .clk(clk), .reset(reset), .enable(update), .Q(real_ctrl)
    );
endmodule