/*
 * File: Execution.v
 * Pipeline::EX
*/
`include "Utility.macros.v"
`include "Utility.ExcCodes.v"
module Execution(
    input[31:0]     Inst,
    input[31:0]     rs,
    input[31:0]     rt,
    input[31:0]     immediate,
    input[31:0]     DO,
    input           DO_reliable,
    input           clk,
    input           reset,
    input           exception_in,
    input[31:0]     EPC_in,
    input[4:0]      ExcCode_in,
    input           BD_in,
    input[31:0]     mul_load,
    input           mul_calculate,
    input           mul_load_HI,
    input           mul_load_LO,
    output[31:0]    Inst_out,
    output[31:0]    rt_out,
    output[31:0]    AO,
    output          Multiply_busy,
    output[31:0]    HI,
    output[31:0]    LO,
    output          exception_out,
    output[31:0]    EPC_out,
    output[4:0]     ExcCode_out,
    output          BD_out
);
    // begin of handling exceptions
    wire[4:0]   ExcCode_in_state;
    assign ExcCode_in_state = load_instruction ? `AdEL : store_instruction ? `AdES : `Ov;
    assign exception_out = exception_in | overflow;
    assign EPC_out = EPC_in;
    assign ExcCode_out = exception_in ? ExcCode_in : ExcCode_in_state;
    assign BD_out = BD_in;
    // end of handling exceptions

    // temporary wires ordinarily for MUX
    wire[31:0]  ALU_A;
    wire[31:0]  ALU_B;
    wire[31:0]  ALU_S;
    wire[31:0]  Multiply_S;
    // wires for controller signals
    wire        ALU_A_select;
    wire[1:0]   ALU_B_select;
    wire[3:0]   ALU_ctrl;
    wire[4:0]   Multiply_ctrl;
    wire[1:0]   AO_select;
    wire        overflow_detection;
    wire        load_instruction;
    wire        store_instruction;
    // effective when ALU calculation overflowed
    wire        ALU_overflow;
    // effective when overflow occurs and shall be detected
    wire        overflow = overflow_detection & ALU_overflow;
    // assignments to outputs
    // if an overflow occurs, issue `nop` to next pipeline state
    NOPIssuer execution_NOP_issuer(
        .instruction_in(Inst),
        .enable(~overflow),
        .instruction_out(Inst_out)
    );
    assign Inst_out = Inst;
    assign rt_out = rt;
    MUX2#(32)ALU_A_MUX(
        .in1(rs), .in2(rt), .select(ALU_A_select), .out(ALU_A)
    );
    MUX4#(32)ALU_B_MUX(
        // at port in3, shamt is zero-extended to 32 bits to avoid warnings
        .in1(rt), .in2(rs), .in3({{27{1'b0}}, Inst[`shamt]}), .in4(immediate),
        .select(ALU_B_select), .out(ALU_B)
    );
    MUX4#(32)AO_MUX(
        .in1(ALU_S), .in2(DO), .in3(Multiply_S), .in4(rt),
        .select(AO_select), .out(AO)
    );
    ALU alu(
        .A(ALU_A),
        .B(ALU_B),
        .ctrl(ALU_ctrl),
        .S(ALU_S),
        .overflow(ALU_overflow)
    );
    Multiply multiply(
        .A(ALU_A),
        .B(ALU_B),
        .load(mul_load),
        .ctrl(Multiply_ctrl),
        .clk(clk),
        .reset(reset),
        .calculate(mul_calculate),
        .load_HI(mul_load_HI),
        .load_LO(mul_load_LO),
        .S(Multiply_S),
        .HI(HI),
        .LO(LO),
        .count_down(/*not connected*/),
        .busy(Multiply_busy)
    );
    EX_CTRL EX_ctrl(
        .Inst(Inst),
        .ALU_A_select(ALU_A_select),
        .ALU_B_select(ALU_B_select),
        .AO_select(AO_select),
        .ALU_ctrl(ALU_ctrl),
        .Multiply_ctrl(Multiply_ctrl),
        .DO_reliable(DO_reliable),
        .overflow_detection(overflow_detection),
        .load_instruction(load_instruction),
        .store_instruction(store_instruction)
    );
endmodule