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
    wire[4:0] w = B[4:0];
    MUX#(32)Shift_S_MUX(
        .in1(A << w), .in2($signed($signed(A) >>> w)), .in3(A >> w),
        .select(ctrl), .out(S)
    );
endmodule