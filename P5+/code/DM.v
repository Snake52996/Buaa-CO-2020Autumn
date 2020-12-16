/*
 * File: DM.v
 * Data Memory
 * Memory is byte-addressed in implementation out of concern for supporting unaligned
 *  load word and save word instructions. Input signal size explains the number of
 *  bytes that shall be written inclusively from the input signal address which can
 *  be described formally as `memory[address+size*8..address] <- data_in[size*8..0]`.
 *  Read operations always read 4 bytes i.e. a word, further tuning is handled later.
 *  Noticed that set size to 0 naturally disables writing operations on memory thus
 *  input signal write_enable is removed.
*/
module DM#(ADDRESS_WIDTH=10,LOW=0,HIGH=32'h2fff)(
    input[31:0]     address,
    input[31:0]     data_in,
    input           clk,
    input           reset,
    input[2:0]      read_size,
    input[2:0]      write_size,
    output          accepted,
    output[31:0]    data_out,
    output          debug_enable,
    output[31:0]    debug_out
);
    reg[7:0]    memory[0:2**ADDRESS_WIDTH-1];
    reg[ADDRESS_WIDTH:0]   helper;
    wire[ADDRESS_WIDTH-1:0]  real_address = address[ADDRESS_WIDTH-1:0];
    wire[ADDRESS_WIDTH-3:0]  aligned_address = real_address[ADDRESS_WIDTH-1:2];
    wire[7:0]   input_bytes[0:3];
    wire        selected;
    wire        aligned;
    wire        aligned_to_byte;
    wire        aligned_to_half_word;
    wire        aligned_to_word;
    wire[2:0]   size;
    assign {input_bytes[3], input_bytes[2], input_bytes[1], input_bytes[0]} = data_in;
    assign size = read_size | write_size;
    wire[31:0]  read_data = {
        memory[real_address + 3],
        memory[real_address + 2],
        memory[real_address + 1],
        memory[real_address]
    };
    ControlledBuffer data_memory_read_data_controlled_buffer(
        .data_in(read_data), .enable(selected & (read_size !== 3'd0)), .data_out(data_out)
    );
    ValueAlignmentChecker#(32,0)data_memory_byte_align_checker(
        .value(address), .accepted(aligned_to_byte)
    );
    ControlledBuffer#(1)data_memory_align_to_byte_controlled_buffer(
        .data_in(aligned_to_byte), .enable(size === 3'd1), .data_out(aligned)
    );
    ValueAlignmentChecker#(32,1)data_memory_half_align_checker(
        .value(address), .accepted(aligned_to_half_word)
    );
    ControlledBuffer#(1)data_memory_align_to_half_controlled_buffer(
        .data_in(aligned_to_half_word), .enable(size === 3'd2), .data_out(aligned)
    );
    ValueAlignmentChecker#(32,2)data_memory_word_align_checker(
        .value(address), .accepted(aligned_to_word)
    );
    ControlledBuffer#(1)data_memory_align_to_word_controlled_buffer(
        .data_in(aligned_to_word), .enable(size === 3'd4), .data_out(aligned)
    );
    ValueRangeChecker#(32,LOW,HIGH)data_memory_range_checker(
        .value(address), .accepted(selected)
    );
    assign accepted = selected & aligned;
    assign debug_enable = accepted & (write_size !== 0);
    assign debug_out =
        write_size === 4 ? data_in :
        write_size === 2 ? (
            address[1] ? {data_in[15:0], memory[{aligned_address, 2'b01}], memory[{aligned_address, 2'b00}]} : {memory[{aligned_address, 2'b11}], memory[{aligned_address, 2'b10}], data_in[15:0]}
        ) : write_size === 1 ? (
            address[1:0] === 0 ? {memory[{aligned_address, 2'b11}], memory[{aligned_address, 2'b10}], memory[{aligned_address, 2'b01}], data_in[7:0]} : address[1:0] === 1 ? {memory[{aligned_address, 2'b11}], memory[{aligned_address, 2'b10}], data_in[7:0], memory[{aligned_address, 2'b00}]} : address[1:0] === 2 ? {memory[{aligned_address, 2'b11}], data_in[7:0], memory[{aligned_address, 2'b01}], memory[{aligned_address, 2'b00}]} : {data_in[7:0], memory[{aligned_address, 2'b10}], memory[{aligned_address, 2'b01}], memory[{aligned_address, 2'b00}]}
        ) : 0;
    always@(posedge clk) begin
        if (reset) begin
            for(helper = 0; helper < 2**ADDRESS_WIDTH-1; helper = helper + 1)
                memory[helper] = 8'd0;
        end else if(accepted) begin
            for(helper = 0; helper < write_size; helper = helper + 1)begin
                memory[real_address + helper] = input_bytes[helper];
            end
        end
    end
endmodule
