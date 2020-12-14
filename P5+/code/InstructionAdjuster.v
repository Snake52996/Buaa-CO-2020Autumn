/*
 * File: InstructionAdjuster.v
 * InstructionAdjuster is used to justify instructions which depends on module
 *  InstructionDetector. If the given instruction is supported according the output
 *  of InstructionDetector, it is tunneled to output port directly, otherwise, an `nop`
 *  is tunneled to output port instead.
*/
module InstructionAdjuster(
    input[31:0]     instruction_in,
    output[31:0]    instruction_out
);
    wire supported;
    InstructionDetector instruction_detector(
        .instruction(instruction_in), .supported(supported)
    );
    assign instruction_out = instruction_in & {32{supported}};
endmodule