/*
 * File: TnewOriginalDecoder.v
 * Decoder to determine cycles before data to be store in rd(logically) is generated
 * (i.e. ready for forwarding)
*/
`include "Utility.macros.v"
module TnewOriginalDecoder(
    input[31:0] Inst,
    output[1:0] Tnew
);
    // Situations that Tnew is originally 0 which means the data to be written is already
    // generated when entering EX state is separately handled by DO forwarding logic thus
    // in no situation shall Tnew be originally 0 within our consideration. Instructions
    // that do not writes GRF is also handled separately, therefore every instructions,
    // except loads, has or can be handled as having an original Tnew of value 1.
    assign Tnew =
    (
        (Inst[31:29] === 6'b100)   // load instructions
    ) ? 2'b10 : 2'b01;
endmodule