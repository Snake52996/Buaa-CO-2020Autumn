/*
 * File: Utility.NOPIssuer.v
 * Issuer of NOP used for handling exceptions. When enabled, input instruction is
 *  tunneled to output directly, otherwise, an `NOP` is tunneled to output regardless
 *  what the origin instruction is.
*/
module NOPIssuer(
    input[31:0]     instruction_in,
    input           enable,
    output[31:0]    instruction_out
);
    assign instruction_out = enable ? instruction_in : 32'd0;
endmodule