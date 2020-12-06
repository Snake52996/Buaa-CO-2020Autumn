/*
 * File: Multiply.Calculator.v
 * A sub-module of Multiply in which actual calculation is preformed.
 * ctrl reference:
 *      00 -- signed multiply
 *      01 -- unsigned multiply
 *      10 -- signed divide
 *      11 -- unsigned divide
*/
module Calculator(
    input[31:0]     A,
    input[31:0]     B,
    input[1:0]      ctrl,
    output[31:0]    result_HI,
    output[31:0]    result_LO
);
    // temporary variables for multiply
	wire unsigned[63:0] u_ext_A = {{32{1'b0}}, A};
	wire unsigned[63:0] u_ext_B = {{32{1'b0}}, B};
    wire   signed[63:0] s_ext_A = {{32{A[31]}}, A};
    wire   signed[63:0] s_ext_B = {{32{B[31]}}, B};
    // temporary variables for divide
	wire   signed[31:0] s_A = A;
	wire   signed[31:0] s_B = B;
    // All possible calculations
	wire[63:0] unsigned_multiply_result = u_ext_A * u_ext_B;
	wire[63:0] signed_multiply_result = s_ext_A * s_ext_B;
	wire[63:0] unsigned_divide_result = {A % B, A / B};
	wire[63:0] signed_divide_result = {s_A % s_B, s_A / s_B};
    // Determine calculation result
	MUX4#(32)result_HI_MUX(
        .in1(signed_multiply_result[63:32]), .in2(unsigned_multiply_result[63:32]),
        .in3(signed_divide_result[63:32]), .in4(unsigned_divide_result[63:32]),
        .select(ctrl), .out(result_HI)
	);
	MUX4#(32)result_LO_MUX(
		.in1(signed_multiply_result[31:0]), .in2(unsigned_multiply_result[31:0]),
        .in3(signed_divide_result[31:0]), .in4(unsigned_divide_result[31:0]),
        .select(ctrl), .out(result_LO)
	);
endmodule