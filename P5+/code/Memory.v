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
    input[31:0]     bridge_read_data,
    input           bridge_accepted,
    output[31:0]    bridge_address,
    output[31:0]    bridge_write_data,
    output[2:0]     bridge_write_size,
    output[2:0]     bridge_read_size,
    output[31:0]    Inst_out,
    output[31:0]    AO_out,
    output[31:0]    MO,
    output          debug_enable, // for debugging only
    output[31:0]    debug_data,
    output          accepted
);
    // wires for controller signals. Inline the controller since it is simple.
    wire[2:0]   read_size;
    wire[2:0]   write_size;
    wire        memory_accepted;
    // assignments to outputs
    assign bridge_address = AO;
    assign bridge_write_data = rt;
    assign bridge_write_size = write_size;
    assign bridge_read_size = read_size;
    assign Inst_out = Inst;
    assign AO_out = AO;
    assign MO = bridge_read_data;
    assign accepted = bridge_accepted | memory_accepted;
    DM#(14,0,32'h2fff)data_memory(
        .address(AO), .data_in(rt), .clk(clk), .reset(reset),
        .read_size(read_size), .write_size(write_size), .accepted(memory_accepted),
        .data_out(MO), .debug_enable(debug_enable), .debug_out(debug_data)
    );
    MEM_CTRL MEM_ctrl(.Inst(Inst), .read_size(read_size), .write_size(write_size));
endmodule
