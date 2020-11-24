/*
 * File: Utility.EXT.v
 * extender with configurable data width
*/
module EXT#(ORIGIN_SIZE, TARGET_SIZE)(
    input[ORIGIN_SIZE-1:0]      origin,
    input                       sign,
    output[TARGET_SIZE-1:0]     target
);
    assign target = sign ? {{TARGET_SIZE-ORIGIN_SIZE{origin[ORIGIN_SIZE-1]}}, origin} :
                           {{TARGET_SIZE-ORIGIN_SIZE{1'b0}}, origin};
endmodule