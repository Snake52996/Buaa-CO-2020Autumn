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
    input[2:0]      ctrl,
    input           clk,
    input           reset,
    output[31:0]    S
);
    wire[31:0]  current_HI;
    wire[31:0]  current_LO;
    Register#(32,0)HI(
        .D(HI_in), .clk(clk), .reset(reset), .enable(ctrl[2]), .Q(current_HI)
    );
    Register#(32,0)LO(
        .D(LO_in), .clk(clk), .reset(reset), .enable(ctrl[1]), .Q(current_LO)
    );
    MUX2#(32)S_MUX(
        .in1(current_HI), .in2(current_LO), .select(ctrl[0]), .out(S)
    );
endmodule