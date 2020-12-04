/*
 * File: ALU.Logic.v
 * Logical calculating unit
*/
module Logic (
    input[31:0]     A,
    input[31:0]     B,
    input[1:0]      ctrl,
    output[31:0]    S
);
    MUX4#(32)Logic_S_MUX(
        .in1(A & B), .in2(A | B), .in3(~(A | B)), .in4(A ^ B),
        .select(ctrl), .out(S)
    );
endmodule