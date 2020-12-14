/*
 * File: Utility.ValueAlignmentChecker.v
 * Check if the given value is properly aligned.
 * To simplify the problem while still fulfills the requirement, supports checking
 *  if the given value aligns to a 2^N base only, where N is defined by parameter.
*/
module ValueAlignmentChecker#(WIDTH=32,N=2)(
    input[WIDTH-1:0]    value,
    output              accepted
);
    assign accepted = ~(|(value & {{WIDTH-N{1'b0}}, {N{1'b1}}}));
endmodule