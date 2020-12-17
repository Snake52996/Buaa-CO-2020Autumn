/*
 * File: Multiply.SourceRegister.v
 * A sub-module of Multiply in which registers for caching inputs of Multiply
 *  is set and managed.
 * ctrl reference:
 *  00 -- mult
 *  01 -- multu
 *  10 -- div
 *  11 -- divu
*/
module SourceRegister(
    input[31:0]     src_A,
    input[31:0]     src_B,
    input[1:0]      src_ctrl,
    input           src_pending,
    input           clk,
    input           update,
    input           reset,
    output[31:0]    A,
    output[31:0]    B,
    output[1:0]     real_ctrl,
    output          pending_out
);
    Register#(32,0)A_Register(
        .D(src_A), .clk(clk), .reset(reset), .enable(update), .Q(A)
    );
    Register#(32,0)B_Register(
        .D(src_B), .clk(clk), .reset(reset), .enable(update), .Q(B)
    );
    Register#(2,0)ctrl_Register(
        .D(src_ctrl), .clk(clk), .reset(reset), .enable(update), .Q(real_ctrl)
    );
    WriteThroughRegister#(1,0)pending_Register(
        .D(src_pending), .clk(clk), .reset(reset), .enable(update), .Q(pending_out)
    );
endmodule