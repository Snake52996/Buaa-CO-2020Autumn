/*
 * File: CoOperator0.v
 * Implements Co-Operator0
*/
module CoOperator0(
    input           clk,
    input           reset,
    input[4:0]      address,
    input[31:0]     write_data,
    input           write_enable,
    input[31:0]     cause_input,
    output[31:0]    read_data,
    output[31:0]    EPC_output,
    output          BD_output
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
    // real write address -- the given address justified by `write_enable`
    wire[1:0]   write_address = address[1:0] & {{2{write_enable}}};
    // The initial value is `0000 0000 0000 0000 1111 1100 0000 0001` in binary form,
    //  which enables all interruptions, clears EXL and enables global interruptions.
    Register#(32,32'h0000_fc01)SR(
        .D(write_data), .clk(clk), .reset(reset),
        .enable(write_address === 2'b00), .Q(SR_value)
    );  // 12
    // Cause is never written by software thus `D` port is connected directly to
    //  `cause_input`
    Register#(32,0)Cause(
        .D(cause_input), .clk(clk), .reset(reset),
        .enable(write_address === 2'b01), .Q(Cause_value)
    );  // 13
    Register#(32,0)EPC(
        .D(write_data), .clk(clk), .reset(reset),
        .enable(write_address === 2'b10), .Q(EPC_value)
    );  // 14
    // PRId is read only thus is always disabled
    // The value of PRId is snake42(`10010 01101 00000 01010 00100 0101010` in binary
    //  form)
    Register#(32,32'h9340_a215)PRId(
        .D(32'h9340_a215), .clk(clk), .reset(reset), .enable(1'b0), .Q(PRId_value)
    );  // 15
    assign EPC_output   = EPC_value;
    assign BD_output    = Cause_value[31];
    assign read_data    = values[address];
endmodule