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
    input[4:0]      ctrl,
    input           clk,
    input           reset,
    output[31:0]    S,
    output reg[3:0] count_down,
    output          busy
);
    wire[31:0]  calculate_result_HI;
    wire[31:0]  calculate_result_LO;
    assign busy = (count_down !== 0) | ctrl[4];
    Calculator calculator(
        .A(A), .B(B), .ctrl(ctrl[3:2]),
        .result_HI(calculate_result_HI), .result_LO(calculate_result_LO)
    );
    wire[31:0]  HI_in;
    wire[31:0]  LO_in;
    MUX2#(32)HI_in_MUX(
        .in1(calculate_result_HI), .in2(A), .select(ctrl[1]),
        .out(HI_in)
    );
    MUX2#(32)LO_in_MUX(
        .in1(calculate_result_LO), .in2(A), .select(ctrl[1]),
        .out(LO_in)
    );
    ResultRegister result_register(
        .HI_in(HI_in),
        .LO_in(LO_in),
        .ctrl({ctrl[4] | (ctrl[1] & ~ctrl[0]), ctrl[4] | (ctrl[1] & ctrl[0]), ctrl[0]}),
        .clk(clk),
        .reset(reset),
        .S(S)
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