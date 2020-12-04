/*
 * File: ALU.Shift.v
 * "Shiftal" calculating unit
*/
module Shift (
    input[31:0]     A,
    input[31:0]     B,
    input[1:0]      ctrl,
    output[31:0]    S
);
    wire[31:0] w = {{27{1'b0}}, B[4:0]};
    wire signed[31:0] sA = A;
    MUX3#(32)Shift_S_MUX(
        .in1(A << w), .in2(sA >>> w), .in3(A >> w),
        .select(ctrl), .out(S)
    );
endmodule