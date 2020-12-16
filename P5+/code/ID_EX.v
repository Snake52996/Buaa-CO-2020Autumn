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
    input           DO_reliable_in,
    input[6:0]      rs_URA_in,
    input[6:0]      rt_URA_in,
    input[6:0]      rd_URA_1_in,
    input[6:0]      rd_URA_2_in,
    input[6:0]      rd_URA_3_in,
    input[1:0]      T_new_in,
    input[31:0]     PC_in,
    input           clk,
    input           reset,
    input           enable,
    output[31:0]    Inst_out,
    output[31:0]    rs_out,
    output[31:0]    rt_out,
    output[31:0]    imm_out,
    output[31:0]    DO_out,
    output          DO_reliable_out,
    output[6:0]     rs_URA_out,
    output[6:0]     rt_URA_out,
    output[6:0]     rd_URA_1_out,
    output[6:0]     rd_URA_2_out,
    output[6:0]     rd_URA_3_out,
    output[1:0]     T_new_out,
    output[31:0]    PC_out
);
    // Registers for next pipeline state
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
    // Registers for transparent forwarding
    Register#(32,0)ID_EX_DO(
        .D(DO_in), .clk(clk), .reset(reset), .enable(enable), .Q(DO_out)
    );
    Register#(1,0)ID_EX_DO_reliable(
        .D(DO_reliable_in), .clk(clk), .reset(reset), .enable(enable), .Q(DO_reliable_out)
    );
    Register#(7,0)ID_EX_rs_addr(
        .D(rs_URA_in), .clk(clk), .reset(reset), .enable(enable), .Q(rs_URA_out)
    );
    Register#(7,0)ID_EX_rt_addr(
        .D(rt_URA_in), .clk(clk), .reset(reset), .enable(enable), .Q(rt_URA_out)
    );
    Register#(7,0)ID_EX_rd_1_addr(
        .D(rd_URA_1_in), .clk(clk), .reset(reset), .enable(enable), .Q(rd_URA_1_out)
    );
    Register#(7,0)ID_EX_rd_2_addr(
        .D(rd_URA_2_in), .clk(clk), .reset(reset), .enable(enable), .Q(rd_URA_2_out)
    );
    Register#(7,0)ID_EX_rd_3_addr(
        .D(rd_URA_3_in), .clk(clk), .reset(reset), .enable(enable), .Q(rd_URA_3_out)
    );
    Register#(2,0)EX_MEM_T_new(
        .D(T_new_in), .clk(clk), .reset(reset), .enable(enable), .Q(T_new_out)
    );
    // Registers for debug only
    Register#(32,0)ID_EX_PC(
        .D(PC_in), .clk(clk), .reset(reset), .enable(enable), .Q(PC_out)
    );
endmodule