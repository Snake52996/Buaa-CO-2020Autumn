/*
 * File: WriteBack.v
 * Pipeline::WB
*/
`include "Utility.macro.v";
module WriteBack(
    input[31:0]     Inst,
    input[31:0]     AO,
    input[31:0]     MO,
    output          GRF_write_enable,
    output[4:0]     GRF_write_addr,
    output[31:0]    GRF_write_data
);
    // wires for controller signals
    wire[1:0]   GRF_write_addr_select;
    wire        GRF_write_data_select;
    MUX3#(5)GRF_write_addr_MUX(
        .in1(Inst[`rd]), .in2(Inst[`rt]), .in3(5'd31),
        .select(GRF_write_addr_select), .out(GRF_write_addr)
    );
    MUX2#(32)GRF_write_data_MUX(
        .in1(AO), .in2(MO),
        .select(GRF_write_data_select), .out(GRF_write_data)
    );
    WB_CTRL WB_ctrl(
        .Inst(Inst), .GRF_write_enable(GRF_write_enable),
        .GRF_write_addr_select(GRF_write_addr_select),
        .GRF_write_data_select(GRF_write_data_select)
    );
endmodule