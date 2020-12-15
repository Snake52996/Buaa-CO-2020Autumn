/*
 * File: Utility.ControlledBuffer.v
 * Buffer with configurable input data width and an `enable` port
 * When enabled, input data is tunneled to output directly, otherwise output will be
 *  floating
*/
module ControlledBuffer#(DATA_WIDTH=32)(
    input[DATA_WIDTH-1:0]       data_in,
    input                       enable,
    output[DATA_WIDTH-1:0]  data_out
);
/*
    always@(*)begin
        if(enable)  data_out = data_in;
        else        data_out = {DATA_WIDTH{1'bz}};
    end
*/
    assign data_out = enable ? data_in : {DATA_WIDTH{1'bz}};
endmodule