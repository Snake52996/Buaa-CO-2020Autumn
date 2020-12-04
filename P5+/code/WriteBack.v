/*
 * File: WriteBack.v
 * Pipeline::WB
*/
`include "Utility.macros.v"
module WriteBack(
    input[31:0]     Inst,
    input[31:0]     AO,
    input[31:0]     MO,
    output          GRF_write_enable,
    output[4:0]     GRF_write_addr,
    output[31:0]    GRF_write_data
);
    // wires for controller signals. Inline controller since it is really simple.
    wire GRF_write_data_select = (Inst[`opcode] === 6'b100011);
    MUX2#(32)GRF_write_data_MUX(
        .in1(AO), .in2(MO),
        .select(GRF_write_data_select), .out(GRF_write_data)
    );
    GRFWriteAddressDecoder address_decoder(
        .Inst(Inst), .GRF_write_addr(GRF_write_addr)
    );
    GRFWriteEnableDecoder enable_decoder(
        .Inst(Inst), .GRF_write_enable(GRF_write_enable)
    );
endmodule