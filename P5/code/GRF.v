/*
 * File: GRF.v
 * defined a General Register File with forwarding
*/
`timescale 1ns / 1ps
module GRF (
    input           clk,
    input           reset,
    input[4:0]      read_addr_1,
    input[4:0]      read_addr_2,
    input[4:0]      write_addr,
    input[31:0]     write_value,
    input           write_enable,
    output[31:0]    read_value_1,
    output[31:0]    read_value_2
);
    reg[31:0] general_registers[0:31];
    reg[6:0] reset_helper;
    MUX2#(32)read_value_1_MUX(
        .in1(general_registers[read_addr_1]), .in2(write_value),
        .select((read_addr_1 === write_addr) && (write_enable) && (write_addr !== 5'd0)), .out(read_value_1)
    );
    MUX2#(32)read_value_2_MUX(
        .in1(general_registers[read_addr_2]), .in2(write_value),
        .select((read_addr_2 === write_addr) && (write_enable) && (write_addr !== 5'd0)), .out(read_value_2)
    );
    always@(posedge clk)begin
        if(reset)begin
            for(reset_helper = 6'd0; reset_helper < 6'd32; reset_helper = reset_helper + 6'd1)begin
                general_registers[reset_helper[4:0]] <= 32'd0;
            end
        end else begin
            if(write_enable && (write_addr !== 5'd0))begin
                general_registers[write_addr] <= write_value;
            end
        end
    end
endmodule