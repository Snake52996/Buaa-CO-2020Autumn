/*
 * File: Multiply.v
 * The module that implements multiply and division operations with in-built
 *  registers(HI, LO). Unlike what presented in the tutorial, the value of
 *  delaying counter is exported as the replacement of signal `Busy` by which
 *  extra (and potentially useful) information is transferred. Meanwhile signal
 *  busy is also preserved as a "syntactic sugar".
 * In connection with the tutorial, the signal `busy` here does not have the same
 *  meaning with `busy` in the tutorial, which is actually directly the condition
 *  of stalling following instructions, i.e. `busy | launch` in tutorial. ctrl[4]
 *  acts exactly the same as `launch` in tutorial.
 *  Instructions that should be handled in this module includes:
 *      mult multu div divu mfhi mflo mthi mtlo
 * ctrl reference
 *      ctrl[0] -- targeting LO?    \__ mfhi/mflo
 *      ctrl[1] -- move mode?       /   mthi/mtlo
 *      ctrl[2] -- unsigned?        \       |------ conflicts with each other
 *      ctrl[3] -- divide?           |- mult(u)/div(u)
 *      ctrl[4] -- launching?       /
*/
module Multiply(
    input[31:0]     A,
    input[31:0]     B,
    input[31:0]     load,
    input[4:0]      ctrl,
    input           clk,
    input           reset,
    input           revoke,
    input           calculate,
    input           load_HI,
    input           load_LO,
    output[31:0]    S,
    output[31:0]    HI,
    output[31:0]    LO, 
    output reg[3:0] count_down,
    output          busy
);
    wire[31:0]  calculate_result_HI;
    wire[31:0]  calculate_result_LO;
    wire[31:0]  real_A;
    wire[31:0]  real_B;
    wire[1:0]   real_ctrl;
    wire        pending;
    wire        divide = real_ctrl[1];
    wire        zero_B = (real_B === 32'd0);
    wire        legal_calculation = ~(divide & zero_B);
    assign busy = (count_down !== 0) | pending;
    SourceRegister source_register(
        .src_A(A),
        .src_B(B),
        .src_ctrl(ctrl[3:2]),
        .src_pending(ctrl[4]),
        .clk(clk),
        .update(ctrl[4]),
        .reset(calculate | reset | revoke),
        .A(real_A),
        .B(real_B),
        .real_ctrl(real_ctrl),
        .pending_out(pending)
    );
    Calculator calculator(
        .A(real_A),
        .B(real_B),
        .ctrl(real_ctrl),
        .result_HI(calculate_result_HI),
        .result_LO(calculate_result_LO)
    );
    wire[31:0]  HI_in;
    wire[31:0]  LO_in;
    MUX3#(32)HI_in_MUX(
        .in1(HI),
        .in2(calculate_result_HI),
        .in3(load),
        .select({load_HI, calculate & legal_calculation}),
        .out(HI_in)
    );
    MUX3#(32)LO_in_MUX(
        .in1(LO),
        .in2(calculate_result_LO),
        .in3(load),
        .select({load_LO, calculate & legal_calculation}),
        .out(LO_in)
    );
    ResultRegister result_register(
        .HI_in(HI_in),
        .LO_in(LO_in),
        .ctrl({load_HI | calculate, load_LO | calculate}),
        .clk(clk),
        .reset(reset),
        .S(S),
        .HI(HI),
        .LO(LO)
    );
    always@(posedge clk)begin
        if(reset)begin
            count_down = 4'd0;
        end else if(ctrl[4])begin
            if(ctrl[3]) count_down = 4'd10;
            else        count_down = 4'd5;
        end else begin
            if(count_down !== 4'd0) count_down = count_down - 1;
        end
    end
endmodule