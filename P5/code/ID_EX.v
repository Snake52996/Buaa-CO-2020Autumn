/*
 * File: ID_EX.v
 * Pipeline::ID_EX_register
*/
module ID_EX (
    input[31:0]     Inst_in,
    input[31:0]     rs_in,
    input[31:0]     rt_in,
    input[31:0]     imm_in,
    input[31:0]     DO_in,
    input           clk,
    input           reset,
    input           enable,
    output[31:0]    Inst_out,
    output[31:0]    rs_out,
    output[31:0]    rt_out,
    output[31:0]    imm_out,
    output[31:0]    DO_out
);
    Register#(32,0)ID_EX_Inst(
        .D(Inst_in), .clk(clk), .reset(reset), .enable(enable), .Q(Inst_out)
    );
    Register#(32,0)ID_EX_rs(
        .D(rs_in), .clk(clk), .reset(reset), .enable(enable), .Q(rs_out)
    );
    Register#(32,0)ID_EX_rt(
        .D(rt_in), .clk(clk), .reset(reset), .enable(enable), .Q(rt_out)
    );
    Register#(32,0)ID_EX_imm(
        .D(imm_in), .clk(clk), .reset(reset), .enable(enable), .Q(imm_out)
    );
    Register#(32,0)ID_EX_DO(
        .D(DO_in), .clk(clk), .reset(reset), .enable(enable), .Q(DO_out)
    );
endmodule