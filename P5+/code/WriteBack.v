/*
 * File: WriteBack.v
 * Pipeline::WB
*/
`include "Utility.macros.v"
module WriteBack(
    input[31:0]     Inst,
    input[31:0]     AO,
    input[31:0]     MO,
    output          write_enable,
    output[6:0]     write_URA,
    output[31:0]    write_data
);
    // wires for controller signals. Inline controller since it is really simple.
    wire write_data_select = (Inst[31:29] === 3'b100);
    wire signed_extend;
    wire[31:0] real_MO;
    wire[31:0] MO_from_byte;
    wire[31:0] MO_from_half;
    wire[31:0] MO_from_word = MO;
    MUX2#(32)GRF_write_data_MUX(
        .in1(AO), .in2(real_MO),
        .select(write_data_select), .out(write_data)
    );
    RDDecoder URA_decoder(
        .instruction(Inst), .URA_real(write_URA)
    );
    RDWriteDecoder enable_decoder(
        .instruction(Inst), .enable(write_enable)
    );
    EXT#(8,32)byte_ext(
        .origin(MO[7:0]), .sign(~Inst[28]), .target(MO_from_byte)
    );
    EXT#(16,32)half_ext(
        .origin(MO[15:0]), .sign(~Inst[28]), .target(MO_from_half)
    );
    MUX4#(32)real_MO_MUX(
        .in1(MO_from_byte), .in2(MO_from_half),  .in3(32'd0), .in4(MO_from_word),
        .select(Inst[27:26]), .out(real_MO)
    );
endmodule