/*
 * File: InstructionFetch.v
 * Pipeline::IF
*/
`include "Utility.ExcCodes.v"
module InstructionFetch(
    input[31:0]     jump_addr,
    input           PC_enable,
    input           PC_jump_select,
    input           handle_exception,
    input           clk,
    input           reset,
    input           delay_slot,     // if current instruction locates in a delay slot
    input[31:0]     last_PC,        // PC of last instruction
    output[31:0]    PC,
    output[31:0]    PC4,
    output[31:0]    Inst,
    output          exception,      // if an exception is thrown
    output[31:0]    EPC,
    output[4:0]     ExcCode,
    output          BD    
);
    wire[31:0]  ideal_next_PC;   // next-PC for ideal environment: no exceptions
    wire[31:0]  real_next_PC;    // Reality is harsh.
                                // There are exceptions, and we need them.
    wire        accepted;
    wire[31:0]  temp_EPC;
    Register#(32,12288)IF_PC(
        .D(real_next_PC), .clk(clk), .reset(reset), .enable(PC_enable), .Q(PC)
    );
    Adder _PC4(.A(PC), .B(32'd4), .S(PC4));
    MUX2#(32)ideal_next_PC_MUX(
        .in1(PC4), .in2(jump_addr),
        .select(PC_jump_select), .out(ideal_next_PC)
    );
    MUX2#(32)real_next_PC_MUX(
        .in1(ideal_next_PC), .in2(32'h4180),
        .select(handle_exception), .out(real_next_PC)
    );
	IM instruction_memory(
		.PC(PC), .accepted(accepted), .Inst(Inst)
	);
    assign exception = ~accepted;
    assign temp_EPC = delay_slot ? last_PC : PC;
    assign EPC = {temp_EPC[31:2], 2'b00};
    assign ExcCode = `AdEL;     // Let `ExcCode` be always AdEL since it is the only
                                //  exception may be thrown here. In case no exception
                                //  occurs, `exception` shall be 0 and value of `ExcCode`
                                //  is ignored.
    assign BD = delay_slot;
endmodule
