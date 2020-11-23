/*
 * File: MEM_WB.v
 * Pipeline::MEM_WB_register
*/
module MEM_WB (
    input[31:0]     Inst_in,
    input[31:0]     AO_in,
    input[31:0]     MO_in,
    input[31:0]     DO_in,
    input           clk,
    input           reset,
    input           enable,
    output[31:0]    Inst_out,
    output[31:0]    AO_out,
    output[31:0]    MO_out,
    output[31:0]    DO_out
);
    Register#(32)MEM_WB_Inst(
        .D(Inst_in), .clk(clk), .reset(reset), .enable(enable), .Q(Inst_out)
    );
    Register#(32)MEM_WB_AO(
        .D(AO_in), .clk(clk), .reset(reset), .enable(enable), .Q(AO_out)
    );
    Register#(32)MEM_WB_MO(
        .D(MO_in), .clk(clk), .reset(reset), .enable(enable), .Q(MO_out)
    );
    Register#(32)MEM_WB_DO(
        .D(DO_in), .clk(clk), .reset(reset), .enable(enable), .Q(DO_out)
    );
endmodule