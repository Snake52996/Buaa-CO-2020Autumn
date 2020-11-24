/*
 * File: mips.v
 * Top level model of Pipeline MIPS processor
*/
module mips(
    input clk,
    input reset
);
    //   Forwarding is implemented transparent i.e. is not visible to any pipeline state
    // thus is entirely implemented in this module
    
    //   PC serves only for auto judge hence it is also transparent to any pipeline state
    //   DO serves for increasing pipeline speed by providing possibility that an branch
    // instruction can go through without an stall if there is an slt-family instruction
    // before it which encounters no hazard. The result is always re-calculated in EX state
    // thus it is only used in forwarding at EX state, thus is also not visible to pipeline
    // states after ID.
    InstructionFetch IF(

    );
    always@(posedge clk)begin
        
    end
endmodule