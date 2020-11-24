/*
 * File: EX_MEM.v
 * Pipeline::EX_MEM_register
*/
module EX_MEM (
    input[31:0]     Inst_in,
    input[31:0]     AO_in,
    input[31:0]     rt_in,
    input           clk,
    input           reset,
    input           enable,
    output[31:0]    Inst_out,
    output[31:0]    AO_out,
    output[31:0]    rt_out
);
    Register#(32,0)EX_MEM_Inst(
        .D(Inst_in), .clk(clk), .reset(reset), .enable(enable), .Q(Inst_out)
    );
    Register#(32,0)EX_MEM_AO(
        .D(AO_in), .clk(clk), .reset(reset), .enable(enable), .Q(AO_out)
    );
    Register#(32,0)EX_MEM_rt(
        .D(rt_in), .clk(clk), .reset(reset), .enable(enable), .Q(rt_out)
    );
endmodule