/*
 * File: Utility.ValueRangeChecker.v
 * Check if the given value locates in the given range.
 * LOW and HIGH in parameter are inclusive i.e. the acceptance region is [LOW, HIGH]
 * The default parameter is set to satisfy the requirement of PC in P7
*/
module ValueRangeChecker#(WIDTH=32,LOW=32'h3000,HIGH=32'h4ffc)(
    input[WIDTH-1:0]    value,
    output              accepted
);
    assign accepted = (value >= LOW) & (value <= HIGH);
endmodule