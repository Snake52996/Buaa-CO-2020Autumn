/*
 * File: Memory.v
 * Pipeline::MEM
*/
`include "Utility.macros.v"
`include "Utility.ExcCodes.v"
module Memory(
    input[31:0]     Inst,
    input[31:0]     AO,
    input[31:0]     rt,
    input           clk,
    input           reset,
    input[31:0]     bridge_read_data,
    input           bridge_accepted,
    input           exception_in,
    input[31:0]     EPC_in,
    input[4:0]      ExcCode_in,
    input           BD_in,
    output[31:0]    bridge_address,
    output[31:0]    bridge_write_data,
    output[2:0]     bridge_write_size,
    output[2:0]     bridge_read_size,
    output[31:0]    Inst_out,
    output[31:0]    AO_out,
    output[31:0]    MO,
    output          debug_enable, // for debugging only
    output[31:0]    debug_data,
    output          exception_out,
    output[31:0]    EPC_out,
    output[4:0]     ExcCode_out,
    output          BD_out
);
    // begin of handling exceptions
    wire        load_instruction;
    wire        store_instruction;
    LoadStoreInstructionDetector memory_load_store_instruction_detector(
        .instruction(Inst),
        .load(load_instruction),
        .store(store_instruction)
    );
    assign exception_out = exception_in | exception;
    assign EPC_out = EPC_in;
    assign ExcCode_out = exception_in ? ExcCode_in : load_instruction ? `AdEL : `AdES;
    assign BD_out = BD_in;
    // end of handling exceptions
    // wires for controller signals. Inline the controller since it is simple.
    wire[2:0]   read_size;
    wire[2:0]   write_size;
    wire        memory_accepted;
    wire        exception = (load_instruction | store_instruction) & (~accepted);
    wire        accepted = bridge_accepted | memory_accepted;
    // assignments to outputs
    assign bridge_address = AO;
    assign bridge_write_data = rt;
    assign bridge_write_size = write_size;
    assign bridge_read_size = read_size;
    assign Inst_out = Inst;
    assign AO_out = AO;
    assign MO = bridge_read_data;
    DM#(14,0,32'h2fff)data_memory(
        .address(AO),
        .data_in(rt),
        .clk(clk),
        .reset(reset),
        .read_size(read_size),
        .write_size(write_size),
        .accepted(memory_accepted),
        .data_out(MO),
        .debug_enable(debug_enable),
        .debug_out(debug_data)
    );
    MEM_CTRL MEM_ctrl(
        .Inst(Inst),
        .read_size(read_size),
        .write_size(write_size)
    );
endmodule
