/*
 * File: WriteBack.CTRL.v
 * Pipeline::WB::Controller
*/
`include "Utility.macros.v";
module WB_CTRL(
    input[31:0]     Inst,
    output          GRF_write_enable,
    output[1:0]     GRF_write_addr_select,
    output          GRF_write_data_select
);
    assign GRF_write_enable = ~(    // list only non-GRF-writing instructions here
        (Inst[`opcode] === 6'b101011) |                             // sw
        (Inst[`opcode] === 6'b000100) |                             // beq
        (Inst[`opcode] === 6'b000101) |                             // bne
        (Inst[`opcode] === 6'b000001 & ~Inst[20]) |                 // bgez/bltz
        (Inst[`opcode] === 6'b000111) |                             // bgtz
        (Inst[`opcode] === 6'b000110) |                             // blez
        (Inst[`opcode] === 6'b000010) |                             // j
        (Inst[`opcode] === 6'b000000 & Inst[`funct] === 6'b001000)  // jr
    );
    assign GRF_write_addr_select =
        (
            (Inst[`opcode] === 6'b000001 & Inst[20]) |              // bgezal/bltzal
            (Inst[`opcode] === 6'b000011)                           // jal
        ) ? 2'b10 :
        (
            (Inst[`opcode] !== 6'b000000)                           // non-R-type
        ) ? 2'b01 : 2'b00;
    assign GRF_write_data_select = (Inst[`opcode] === 6'b100011);
endmodule