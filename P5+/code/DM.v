/*
 * File: DM.v
 * Data Memory
*/
module DM (
    input[31:0]     address,
    input[31:0]     data_in,
    input           clk,
    input           reset,
    input           read_enable,
    input           write_enable,
    output[31:0]    data_out
);
    reg[31:0] memory[0:2047];
    reg[11:0] reset_helper;
    wire[10:0] real_address = address[12:2];
    assign data_out = 
        read_enable ? memory[real_address] : 32'bxxxxxxxx_xxxxxxxx_xxxxxxxx_xxxxxxxx;
    always@(posedge clk) begin
        if (reset) begin
            for(reset_helper = 0; reset_helper < 12'd2048; reset_helper = reset_helper + 1)
                memory[reset_helper[10:0]] <= 32'd0;
        end else begin
            if (write_enable) begin
                memory[real_address] <= data_in;
            end
        end
    end
endmodule