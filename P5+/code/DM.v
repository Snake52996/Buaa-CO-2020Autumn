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
module DM (
    input[31:0]     address,
    input[31:0]     data_in,
    input           clk,
    input           reset,
    input[2:0]      size,
    output[31:0]    data_out,
    output[31:0]    debug_out
);
    reg[7:0]    memory[0:8191];
    reg[13:0]   helper;
    wire[12:0]  real_address = address[12:0];
    wire[7:0]   input_bytes[0:3];
    assign {input_bytes[3], input_bytes[2], input_bytes[1], input_bytes[0]} = data_in;
    assign data_out = {
        memory[real_address + 13'd3],
        memory[real_address + 13'd2],
        memory[real_address + 13'd1],
        memory[real_address]
    };
    assign debug_out = {
        memory[{real_address[12:2], 2'b11}],
        memory[{real_address[12:2], 2'b10}],
        memory[{real_address[12:2], 2'b01}],
        memory[{real_address[12:2], 2'b00}]
    };
    always@(posedge clk) begin
        if (reset) begin
            for(helper = 0; helper < 14'd8192; helper = helper + 1)
                memory[helper[12:0]] <= 8'd0;
        end else begin
            for(helper = 0; helper < size; helper = helper + 1)
                memory[real_address + helper[12:0]] <= input_bytes[helper[1:0]];
        end
    end
endmodule