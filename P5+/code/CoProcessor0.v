/*
 * File: CoProcessor0.v
 * Implements Co-Processor0
 * A separate input port is available for each writable register since multiple registers
 *  may be written in one cycle.
*/
module CoProcessor0(
    input           clk,
    input           reset,
    input[4:0]      read_address,
    input[31:0]     SR_input,
    input           SR_enable,
    input[31:0]     Cause_input,
    input           Cause_enable,
    input[31:0]     EPC_input,
    input           EPC_enable,
    output[31:0]    read_data,
    output[31:0]    SR_output,
    output[31:0]    EPC_output,
    output[31:0]    Cause_output
);
    wire[31:0]  SR_value;
    wire[31:0]  Cause_value;
    wire[31:0]  EPC_value;
    wire[31:0]  PRId_value;
    // values is used to simplify reading operation
    wire[31:0]  values[12:15];
    assign values[12] = SR_value;
    assign values[13] = Cause_value;
    assign values[14] = EPC_value;
    assign values[15] = PRId_value;
    // The initial value is `0000 0000 0000 0000 1111 1100 0000 0001` in binary form,
    //  which enables all interruptions, clears EXL and enables global interruptions.
    Register#(32,32'h0000_fc01)SR(
        .D(SR_input), .clk(clk), .reset(reset),
        .enable(SR_enable), .Q(SR_value)
    );  // 12
    Register#(32,0)Cause(
        .D(Cause_input), .clk(clk), .reset(reset),
        .enable(Cause_enable), .Q(Cause_value)
    );  // 13
    Register#(32,0)EPC(
        .D(EPC_input), .clk(clk), .reset(reset),
        .enable(EPC_enable), .Q(EPC_value)
    );  // 14
    // PRId is read only thus is always disabled
    // The value of PRId is snake42(`10010 01101 00000 01010 00100 0101010` in binary
    //  form)
    Register#(32,32'h9340_a215)PRId(
        .D(32'h9340_a215), .clk(clk), .reset(reset), .enable(1'b0), .Q(PRId_value)
    );  // 15
    assign read_data    = values[read_address];
    assign SR_output    = SR_value;
    assign EPC_output   = EPC_value;
    assign Cause_output = Cause_value;
endmodule