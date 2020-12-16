/*
 * File: Utility.ExceptionRegister.v
 * Register that contains several registers for caching information useful when
 *  exception is encountered
*/
module ExceptionRegister(
    input           clk,
    input           reset,
    input           enable,
    input           exception_in,
    input[31:0]     EPC_in,
    input[4:0]      ExcCode_in,
    input           BD_in,
    output          exception_out,
    output[31:0]    EPC_out,
    output[4:0]     ExcCode_out,
    output          BD_out
);
    // An exception has been thrown if and only if exception is 1
    // If exception is 0, other fields may still contains valid value but
    //  are meaningless.
    Register#(1,1'b0)exception(
        .D(exception_in), .clk(clk), .reset(reset), .enable(enable), .Q(exception_out)
    );
    Register#(32,32'h3000)EPC(
        .D(EPC_in), .clk(clk), .reset(reset), .enable(enable), .Q(EPC_out)
    );
    Register#(5,5'd0)ExcCode(
        .D(ExcCode_in), .clk(clk), .reset(reset), .enable(enable), .Q(ExcCode_out)
    );
    Register#(1,1'b0)BD(
        .D(BD_in), .clk(clk), .reset(reset), .enable(enable), .Q(BD_out)
    );
endmodule