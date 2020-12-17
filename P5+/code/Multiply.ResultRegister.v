/*
 * File: Multiply.ResultRegister.v
 * A sub-module of Multiply in which registers for caching results of Multiply
 *  is set and managed.
 * ctrl reference
 *      ctrl[0]: tunnel LO to S?
 *      ctrl[1]: LO update enable
 *      ctrl[2]: HI update enable
*/
module ResultRegister (
    input[31:0]     HI_in,
    input[31:0]     LO_in,
    input           ctrl,
    input           clk,
    input           reset,
    output[31:0]    S,
    output[31:0]    HI,
    output[31:0]    LO
);
    WriteThroughRegister#(32,0)HI_Register(
        .D(HI_in), .clk(clk), .reset(reset), .enable(ctrl), .Q(HI)
    );
    WriteThroughRegister#(32,0)LO_Register(
        .D(LO_in), .clk(clk), .reset(reset), .enable(ctrl), .Q(LO)
    );
    MUX2#(32)S_MUX(
        .in1(HI), .in2(LO), .select(1'b0), .out(S)
    );
endmodule