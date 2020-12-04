/*
 * File: EX_MEM.v
 * Pipeline::EX_MEM_register
*/
module EX_MEM (
    input[31:0]     Inst_in,
    input[31:0]     AO_in,
    input[31:0]     rt_in,
    input[4:0]      rt_addr_in,
    input[4:0]      rd_addr_in,
    input[1:0]      T_new_in,
    input[31:0]     PC_in,
    input           clk,
    input           reset,
    input           enable,
    output[31:0]    Inst_out,
    output[31:0]    AO_out,
    output[31:0]    rt_out,
    output[4:0]     rt_addr_out,
    output[4:0]     rd_addr_out,
    output[1:0]     T_new_out,
    output[31:0]    PC_out
);
    // Registers for next pipeline state
    Register#(32,0)EX_MEM_Inst(
        .D(Inst_in), .clk(clk), .reset(reset), .enable(enable), .Q(Inst_out)
    );
    Register#(32,0)EX_MEM_AO(
        .D(AO_in), .clk(clk), .reset(reset), .enable(enable), .Q(AO_out)
    );
    Register#(32,0)EX_MEM_rt(
        .D(rt_in), .clk(clk), .reset(reset), .enable(enable), .Q(rt_out)
    );
    // Registers for transparent forwarding
    Register#(5,0)EX_MEM_rt_addr(
        .D(rt_addr_in), .clk(clk), .reset(reset), .enable(enable), .Q(rt_addr_out)
    );
    Register#(5,0)EX_MEM_rd_addr(
        .D(rd_addr_in), .clk(clk), .reset(reset), .enable(enable), .Q(rd_addr_out)
    );
    Register#(2,0)EX_MEM_T_new(
        .D(T_new_in), .clk(clk), .reset(reset), .enable(enable), .Q(T_new_out)
    );
    // Registers for debug only
    Register#(32,0)EX_MEM_PC(
        .D(PC_in), .clk(clk), .reset(reset), .enable(enable), .Q(PC_out)
    );
endmodule