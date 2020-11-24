/*
 * File: Memory.v
 * Pipeline::MEM
*/
module Memory(
    input[31:0]     Inst,
    input[31:0]     AO,
    input[31:0]     rt,
    input           clk,
    input           reset,
    output[31:0]    AO_out,
    output[31:0]    MO
);
    // wires for controller signals. Inline the controller since it is simple.
    wire memory_read_enable  = (Inst[`opcode] === 6'b100011);
    wire memory_write_enable = (Inst[`opcode] === 6'b101011);
    // assignments to outputs
    assign AO_out = AO;
    DM data_memory(
        .address(AO), .data_in(rt), .clk(clk), .reset(reset),
        .read_enable(memory_read_enable), .write_enable(memory_write_enable),
        .data_out(MO)
    );
endmodule