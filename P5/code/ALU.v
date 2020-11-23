/*
 * File: ALU.v
 * Arithmetic and Logic Unit
*/
module ALU (
    input[31:0]         A,
    input[31:0]         B,
    input[3:0]          ctrl,
    output[31:0]        S,
    output              overflow
);
    wire[31:0]  Arithmetic_result;
    wire[31:0]  Logic_result;
    wire[31:0]  Shift_result;
    wire[31:0]  Comparer_result;
    wire        arithmetic_negative;
    wire[1:0]   logic_ctrl;
    wire[1:0]   shift_ctrl;
    wire        comparer_signed_compare;
    wire[2:0]   comparer_compare_select;
    wire[1:0]   ALU_S_select;
    ALUCTRL ALU_CTRL(
        .ctrl_in(ctrl), .arithmetic_negative(arithmetic_negative),
        .logic_ctrl(logic_ctrl), .shift_ctrl(shift_ctrl),
        .comparer_signed_compare(comparer_signed_compare),
        .comparer_compare_select(comparer_compare_select), .ALU_S_select(ALU_S_select)
    )
    Arithmetic arithmetic(
        .A(A), .B(B), .negative(arithmetic_negative),
        .S(Arithmetic_result), .overflow(overflow)
    );
    Logic logic(
        .A(A), .B(B), .ctrl(logic_ctrl), .S(Logic_result)
    );
    Shift shift(
        .A(A), .B(B), .ctrl(shift_ctrl), .S(Shift_result)
    );
    SelectiveComparer comparer(
        .A(A), .B(B), .signed_compare(comparer_signed_compare),
        .compare_select(comparer_compare_select), .S(Comparer_result)
    );
    MUX4#(32)ALU_S_MUX(
        .in1(Arithmetic_result), .in2(Logic_result),
        .in3(Shift_result), .in4(Comparer_result),
        .select(ALU_S_select), .out(S)
    );
endmodule