/*
 * File: IF_ID.v
 * Pipeline::IF_ID_register
*/
module IF_ID (
    input[31:0]     Inst_in,
    input[31:0]     PC4_in,
    input[31:0]     PC_in,
    input           clk,
    input           reset,
    input           enable,
    output[31:0]    Inst_out,
    output[31:0]    PC4_out,
    output[31:0]    PC_out
);
    Register#(32,0)IF_ID_Inst(
        .D(Inst_in), .clk(clk), .reset(reset), .enable(enable), .Q(Inst_out)
    );
    Register#(32,0)IF_ID_PC4(
        .D(PC4_in), .clk(clk), .reset(reset), .enable(enable), .Q(PC4_out)
    );
    Register#(32,0)IF_ID_PC(
        .D(PC_in), .clk(clk), .reset(reset), .enable(enable), .Q(PC_out)
    );
endmodule