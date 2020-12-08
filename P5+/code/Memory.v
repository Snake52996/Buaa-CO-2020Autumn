/*
 * File: Memory.v
 * Pipeline::MEM
*/
`include "Utility.macros.v"
module Memory(
    input[31:0]     Inst,
    input[31:0]     AO,
    input[31:0]     rt,
    input           clk,
    input           reset,
    output[31:0]    Inst_out,
    output[31:0]    AO_out,
    output[31:0]    MO,
    output          debug_enable, // for debugging only
    output[31:0]    debug_data,
    output          unaligned_exception
);
    // wires for controller signals. Inline the controller since it is simple.
    wire[2:0]   size;
    wire        unaligned;
    // assignments to outputs
    assign Inst_out = Inst;
    assign AO_out = AO;
    assign debug_enable = (size !== 0);
    // An extra temporary variable is defined for when the address seems unaligned,
    //  the instruction shall be checked to determine if a unaligned_exception shall
    //  be raised.
    assign unaligned_exception = unaligned;
    DM#(14)data_memory(
        .address(AO), .data_in(rt), .clk(clk), .reset(reset),
        .size(size), .data_out(MO), .debug_out(debug_data)
    );
    MEM_CTRL MEM_ctrl(.Inst(Inst), .address(AO), .size(size), .unaligned(unaligned));
endmodule
