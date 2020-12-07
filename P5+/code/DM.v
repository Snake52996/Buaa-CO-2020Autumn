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
module DM#(ADDRESS_WIDTH=10)(
    input[31:0]     address,
    input[31:0]     data_in,
    input           clk,
    input           reset,
    input[2:0]      size,
    output[31:0]    data_out,
    output[31:0]    debug_out
);
    reg[7:0]    memory[0:2**ADDRESS_WIDTH-1];
    reg[13:0]   helper;
    wire[ADDRESS_WIDTH-1:0]  real_address = address[ADDRESS_WIDTH-1:0];
    wire[ADDRESS_WIDTH-3:0]  aligned_address = real_address[ADDRESS_WIDTH-1:2];
    wire[7:0]   input_bytes[0:3];
    assign {input_bytes[3], input_bytes[2], input_bytes[1], input_bytes[0]} = data_in;
    assign data_out = {
        memory[real_address + 3],
        memory[real_address + 2],
        memory[real_address + 1],
        memory[real_address]
    };
    assign debug_out =
        size === 4 ? data_in :
        size === 2 ? (
            address[1] ? {data_in[15:0], memory[{aligned_address, 2'b01}], memory[{aligned_address, 2'b00}]} : {memory[{aligned_address, 2'b11}], memory[{aligned_address, 2'b10}], data_in[15:0]}
        ) : size === 1 ? (
            address[1:0] === 0 ? {memory[{aligned_address, 2'b11}], memory[{aligned_address, 2'b10}], memory[{aligned_address, 2'b01}], data_in[7:0]} : address[1:0] === 1 ? {memory[{aligned_address, 2'b11}], memory[{aligned_address, 2'b10}], data_in[7:0], memory[{aligned_address, 2'b00}]} : address[1:0] === 2 ? {memory[{aligned_address, 2'b11}], data_in[7:0], memory[{aligned_address, 2'b01}], memory[{aligned_address, 2'b00}]} : {data_in[7:0], memory[{aligned_address, 2'b10}], memory[{aligned_address, 2'b01}], memory[{aligned_address, 2'b00}]}
        ) : 0;
    always@(posedge clk) begin
        if (reset) begin
            for(helper = 0; helper < 2**ADDRESS_WIDTH-1; helper = helper + 1)
                memory[helper] = 8'd0;
        end else begin
            for(helper = 0; helper < size; helper = helper + 1)begin
                memory[real_address + helper] = input_bytes[helper];
            end
        end
    end
endmodule