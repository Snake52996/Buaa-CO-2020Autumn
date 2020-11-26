/*
 * File: GRFWriteAddressDecoder.v
 * Decoder for decoding the instruction to determine to which address of GRF the
 * result shall be written
 * This module is packed to avoid code duplication, since the same function is invoked
 * in WB state and in top level(logically in ID state).
 * It is definitely possible to decode in ID state and pipe result till WB state which
 * fulfills both the requirement to forward data in case needed and to write data to
 * proper register in GRF in WB state, yet such designment violates the principle of a
 * "transparent forwarding", therefore it is not applied.
*/
`include "Utility.macros.v"
module GRFWriteAddressDecoder(
    input[31:0] Inst,
    output[4:0] GRF_write_addr
);
    wire[1:0] GRF_write_addr_select =
        (
            (Inst[`opcode] === 6'b000001 & Inst[20]) |              // bgezal/bltzal
            (Inst[`opcode] === 6'b000011)                           // jal
        ) ? 2'b10 :
        (
            (Inst[`opcode] !== 6'b000000)                           // non-R-type
        ) ? 2'b01 : 2'b00;
    MUX3#(5)GRF_write_addr_MUX(
        .in1(Inst[`rd]), .in2(Inst[`rt]), .in3(5'd31),
        .select(GRF_write_addr_select), .out(GRF_write_addr)
    );
endmodule