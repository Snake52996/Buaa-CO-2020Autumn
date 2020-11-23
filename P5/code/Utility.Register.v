/*
 * File: Utility.Register.v
 * Register with clk/reset/enable
*/
module Register#(DATA_SIZE)(
    input[DATA_SIZE-1:0]        D,
    input                       clk,
    input                       reset,
    input                       enable,
    output reg[DATA_SIZE-1:0]   Q
);
    always@(posedge clk)begin
        if(reset)begin
            Q <= DATA_SIZE'd0;
        end else begin
            if(enable)begin
                Q <= D;
            end
        end
    end
endmodule