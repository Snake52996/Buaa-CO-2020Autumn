/*
 * File: Execution.v
 * Pipeline::EX
*/
`include "Utility.macros.v"
module Execution(
    input[31:0]     Inst,
    input[31:0]     rs,
    input[31:0]     rt,
    input[31:0]     immediate,
    input[31:0]     DO,
    input           DO_reliable,
    input           clk,
    input           reset,
    output[31:0]    Inst_out,
    output[31:0]    rt_out,
    output[31:0]    AO,
    output          Multiply_busy
);
    // temporary wires ordinarily for MUX
    wire[31:0]  ALU_A;
    wire[31:0]  ALU_B;
    wire[31:0]  ALU_S;
    wire[31:0]  Multiply_S;
    // wires for controller signals
    wire        ALU_A_select;
    wire[1:0]   ALU_B_select;
    wire[3:0]   ALU_ctrl;
    wire[4:0]   Multiply_ctrl;
    wire[1:0]   AO_select;
    // assignments to outputs
    assign Inst_out = Inst;
    assign rt_out = rt;
    MUX2#(32)ALU_A_MUX(
        .in1(rs), .in2(rt), .select(ALU_A_select), .out(ALU_A)
    );
    MUX4#(32)ALU_B_MUX(
        // at port in3, shamt is zero-extended to 32 bits to avoid warnings
        .in1(rt), .in2(rs), .in3({{27{1'b0}}, Inst[`shamt]}), .in4(immediate),
        .select(ALU_B_select), .out(ALU_B)
    );
    MUX3#(32)AO_MUX(
        .in1(ALU_S), .in2(DO), .in3(Multiply_ctrl),
        .select(AO_select), .out(AO)
    );
    ALU alu(
        .A(ALU_A), .B(ALU_B), .ctrl(ALU_ctrl), .S(ALU_S)   /* No need for overflow */
    );
    Multiply multiply(
        .A(ALU_A), .B(ALU_B), .ctrl(Multiply_ctrl),
        .clk(clk), .reset(reset),
        .S(Multiply_S), .count_down(/*not connected*/), .busy(Multiply_busy)
    );
    EX_CTRL EX_ctrl(
        .Inst(Inst), .ALU_A_select(ALU_A_select), .ALU_B_select(ALU_B_select),
        .AO_select(AO_select), .ALU_ctrl(ALU_ctrl), .Multiply_ctrl(Multiply_ctrl)
    );
endmodule