/*
 * File: IM.v
 * Instruction Memory
*/
module IM#(ADDRESS_WIDTH=14,LOW_ADDRESS=32'h3000)(
    input[31:0]     PC,
    output          accepted,
    output[31:0]    Inst
);
    wire aligned;
    wire ranged;
    wire[31:0]  normalized_address = PC - LOW_ADDRESS;
    assign accepted = aligned & ranged;
    ValueAlignmentChecker#(32,2)IM_align_checker(
        .value(PC), .accepted(aligned)
    );
    ValueRangeChecker#(32,32'h3000,32'h4ffc)IM_range_checker(
        .value(PC), .accepted(ranged)
    );
    NOPIssuer IM_nop_issuer(
        .instruction_in(instruction_memory[normalized_address[ADDRESS_WIDTH-1:2]]),
        .enable(accepted),
        .instruction_out(Inst)
    );
    reg[31:0] instruction_memory[0:2**ADDRESS_WIDTH-1];
    initial begin
        $readmemh("code.txt",instruction_memory);
        $readmemh("code_handler.txt", instruction_memory, 1120, 2047);
    end
endmodule
