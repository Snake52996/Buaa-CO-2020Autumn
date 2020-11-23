/*
 * File: Utility.SelectiveComparer.v
 * 32-bit comparer supports signed and unsigned integer compare
 * with selectable output
*/
module SelectiveComparer (
    input[31:0]     A,
	input[31:0]     B,
    input           signed_compare,
    input[2:0]      compare_select,
    output[31:0]    S
);
    wire ne, lt, le, eq, ge, gt, t, temp_result;
    assign S = {{31{1'b0}}, temp_result};
    Comparer comparer(
        .A(A), .B(B), .signed_comp(signed_compare),
        .ne(ne), .lt(lt), .le(le), .eq(eq), .ge(ge), .gt(gt), .t(t)
    );
    MUX7#(1)temp_result_MUX(
        .in1(ne), .in2(lt), .in3(le), .in4(eq), .in5(ge), .in6(gt), .in7(t),
        .select(result_select), .out(temp_result)
    );
endmodule