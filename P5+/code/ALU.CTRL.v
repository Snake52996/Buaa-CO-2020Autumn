/*
 * File: ALU.CTRL.v
 * Controller in ALU
*/
module ALUCTRL (
    input[3:0]      ctrl_in,
    output          arithmetic_negative,
    output[1:0]     logic_ctrl,
    output[1:0]     shift_ctrl,
    output          comparer_signed_compare,
    output[2:0]     comparer_compare_select,
    output[1:0]     ALU_S_select
);
    assign arithmetic_negative = (ctrl_in === 4'b0001);
    assign logic_ctrl = (ctrl_in === 4'b0010) ? 2'b00 :
                        (ctrl_in === 4'b0011) ? 2'b01 :
                        (ctrl_in === 4'b0100) ? 2'b10 :
                        (ctrl_in === 4'b0101) ? 2'b11 : 2'b00;
    assign shift_ctrl = (ctrl_in === 4'b0110) ? 2'b00 :
                        (ctrl_in === 4'b0111) ? 2'b01 :
                        (ctrl_in === 4'b1000) ? 2'b10 : 2'b00;
    assign comparer_signed_compare = (ctrl_in === 4'b1010);
    assign comparer_compare_select = 3'b001;
    assign ALU_S_select = (ctrl_in === 4'b0000 || ctrl_in === 4'b0001) ? 2'b00 :
                          (ctrl_in === 4'b0010 || ctrl_in === 4'b0011 || ctrl_in === 4'b0100 || ctrl_in === 4'b0101) ? 2'b01 :
                          (ctrl_in === 4'b0110 || ctrl_in === 4'b0111 || ctrl_in === 4'b1000) ? 2'b10 :
                          (ctrl_in === 4'b1001 || ctrl_in === 4'b1010) ? 2'b11 : 2'b00;
endmodule