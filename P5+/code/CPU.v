/*
 * File: CPU.v
 * General Pipeline MIPS processor
*/
`include "Utility.macros.v"
module CPU(
    input           clk,
    input           reset,
    // connections with CoOperator0
    input[31:0]     CP0_read_data,
    input[31:0]     CP0_SR_output,
    input[31:0]     CP0_EPC_output,
    input[31:0]     CP0_Cause_output,
    output[4:0]     CP0_read_address,
    output[31:0]    CP0_SR_input,
    output          CP0_SR_enable,
    output[31:0]    CP0_Cause_input,
    output          CP0_Cause_enable,
    output[31:0]    CP0_EPC_input,
    output          CP0_EPC_enable,
    // connections with bridge
    input[31:0]     bridge_read_data,
    input[7:2]      interrupt_request,
    input           bridge_accepted,
    output[31:0]    bridge_address,
    output[31:0]    bridge_write_data,
    output[2:0]     bridge_write_size,
    output[2:0]     bridge_read_size,
    // macroscopic PC
    output[31:0]    macroscopic_PC
);
    //   Forwarding is implemented transparently i.e. is not visible to any pipeline state
    // thus is entirely implemented in this module
    
    //   PC serves only for auto judge hence it is also transparent to any pipeline state

    // Giant scale of net variables
    //  GRF-related variables
    wire[4:0]   GRF_read_addr_1;
    wire[4:0]   GRF_read_addr_2;
    wire[4:0]   GRF_write_addr;
    wire[31:0]  GRF_write_data;
    wire        GRF_write_enable;
    wire[31:0]  GRF_read_data_1;
    wire[31:0]  GRF_read_data_2;
    //  IF-state variables
    wire[31:0]  IF_I_jump_target;
    wire        IF_I_PC_enable;
    wire        IF_I_PC_select;
    wire[31:0]  IF_O_PC;
    wire[31:0]  IF_O_PC4;
    wire[31:0]  IF_O_Instruction;
    wire        IF_O_exception;
    wire[31:0]  IF_O_EPC;
    wire[4:0]   IF_O_ExcCode;
    wire        IF_O_BD;
    //  IF/ID-register variables
    wire        IF_ID_enable;
    wire        IF_ID_reset;
    wire[31:0]  IF_ID_O_PC;
    //  ID-state variables
    wire[31:0]  ID_I_Instruction;
    wire[31:0]  ID_I_PC4;
    wire[31:0]  ID_I_rs;
    wire[31:0]  ID_I_rt;
    wire        ID_I_exception;
    wire[31:0]  ID_I_EPC;
    wire[4:0]   ID_I_ExcCode;
    wire        ID_I_BD;
    wire[6:0]   ID_O_rs_URA;
    wire[6:0]   ID_O_rt_URA;
    wire[31:0]  ID_O_Instruction;
    wire[31:0]  ID_O_rs;
    wire[31:0]  ID_O_rt;
    wire[31:0]  ID_O_immediate;
    wire[31:0]  ID_O_DO;
    wire        ID_O_PC_jump;
    wire[31:0]  ID_O_NPC_target;
    wire        ID_O_exception;
    wire[31:0]  ID_O_EPC;
    wire[4:0]   ID_O_ExcCode;
    wire        ID_O_BD;
    //  ID/EX-register variables
    wire        ID_EX_I_DO_reliable;
    wire[6:0]   ID_EX_I_rd_1_URA;
    wire[6:0]   ID_EX_I_rd_2_URA;
    wire[6:0]   ID_EX_I_rd_3_URA;
    wire[1:0]   ID_EX_I_T_new;
    wire        ID_EX_reset;
    wire        ID_EX_enable;
    wire[31:0]  ID_EX_O_rs;
    wire[31:0]  ID_EX_O_rt;
    wire[31:0]  ID_EX_O_DO;
    wire        ID_EX_O_DO_reliable;
    wire[6:0]   ID_EX_O_rs_URA;
    wire[6:0]   ID_EX_O_rt_URA;
    wire[6:0]   ID_EX_O_rd_1_URA;
    wire[6:0]   ID_EX_O_rd_2_URA;
    wire[6:0]   ID_EX_O_rd_3_URA;
    wire[1:0]   ID_EX_O_T_new;
    wire[31:0]  ID_EX_O_PC;
    //  EX-state variables
    wire[31:0]  EX_I_Instruction;
    wire[31:0]  EX_I_rs;
    wire[31:0]  EX_I_rt;
    wire[31:0]  EX_I_immediate;
    wire        EX_I_exception;
    wire[31:0]  EX_I_EPC;
    wire[4:0]   EX_I_ExcCode;
    wire        EX_I_BD;
    wire[31:0]  EX_O_Instruction;
    wire[31:0]  EX_O_rt;
    wire[31:0]  EX_O_AO;
    wire        Multiply_busy;
    wire        EX_O_exception;
    wire[31:0]  EX_O_EPC;
    wire[4:0]   EX_O_ExcCode;
    wire        EX_O_BD;
    //  EX/MEM-register variables
    wire[1:0]   EX_MEM_I_T_new;
    wire        EX_MEM_reset;
    wire        EX_MEM_enable;
    wire[31:0]  EX_MEM_O_rt;
    wire[6:0]   EX_MEM_O_rt_URA;
    wire[6:0]   EX_MEM_O_rd_1_URA;
    wire[6:0]   EX_MEM_O_rd_2_URA;
    wire[6:0]   EX_MEM_O_rd_3_URA;
    wire[1:0]   EX_MEM_O_T_new;
    wire[31:0]  EX_MEM_O_PC;
    //  MEM-state variables
    wire[31:0]  MEM_I_Instruction;
    wire[31:0]  MEM_I_AO;
    wire[31:0]  MEM_I_rt;
    wire        MEM_I_exception;
    wire[31:0]  MEM_I_EPC;
    wire[4:0]   MEM_I_ExcCode;
    wire        MEM_I_BD;
    wire[31:0]  MEM_O_Instruction;
    wire[31:0]  MEM_O_AO;
    wire[31:0]  MEM_O_MO;
    wire        MEM_O_exception;
    wire[31:0]  MEM_O_EPC;
    wire[4:0]   MEM_O_ExcCode;
    wire        MEM_O_BD;
    //  MEM/WB-register variables
    wire        MEM_WB_reset;
    wire        MEM_WB_enable;
    wire[31:0]  MEM_WB_O_PC;
    //  WB-state variables
    wire[31:0]  WB_I_Instruction;
    wire[31:0]  WB_I_AO;
    wire[31:0]  WB_I_MO;
    wire        WB_O_write_enable;
    wire[6:0]   WB_O_write_URA;
    wire[31:0]  WB_O_write_data;
    wire[31:0]  WB_write_data;
	// End of variables

    // Top level control signals
	wire        pause;

    // configuration to pipeline registers
    assign IF_I_PC_enable = ~pause;
    assign IF_ID_enable = ~pause;
    assign IF_ID_reset = reset | ((~pause) & ID_O_nullify_delay_slot) | IF_I_handle_exception;
    assign ID_EX_reset = pause | reset | IF_I_handle_exception;
    assign ID_EX_enable = 1'b1;
    assign EX_MEM_reset = reset | IF_I_handle_exception;
    assign EX_MEM_enable = 1'b1;
    assign MEM_WB_reset = reset | IF_I_handle_exception;
    assign MEM_WB_enable = 1'b1;

    GRF grf(
        .clk(clk),
        .reset(reset),
        .read_addr_1(GRF_read_addr_1),
        .read_addr_2(GRF_read_addr_2),
        .write_addr(GRF_write_addr),
        .write_value(GRF_write_data),
        .write_enable(GRF_write_enable),
        .read_value_1(GRF_read_data_1),
        .read_value_2(GRF_read_data_2)
    );

    // vvvvvvvvvvvvvvvvvvvvvvvv BEGIN OF IF STATE vvvvvvvvvvvvvvvvvvvvvvvv
    InstructionFetch IF(
        .jump_addr(IF_I_jump_target),
        .PC_enable(IF_I_PC_enable),
        .PC_jump_select(IF_I_PC_select),
        .handle_exception(IF_I_handle_exception),
        .clk(clk),
        .reset(reset),
        .delay_slot(IF_I_delay_slot),
        .last_PC(IF_ID_O_PC),
        .PC(IF_O_PC),
        .PC4(IF_O_PC4),
        .Inst(IF_O_Instruction),
        .exception(IF_O_exception),
        .EPC(IF_O_EPC),
        .ExcCode(IF_O_ExcCode),
        .BD(IF_O_BD)
    );
    assign IF_I_jump_target = ID_O_NPC_target;
    assign IF_I_PC_select = ID_O_PC_jump;
    // ^^^^^^^^^^^^^^^^^^^^^^^^^ END OF IF STATE ^^^^^^^^^^^^^^^^^^^^^^^^^

    IF_ID if_id(
        .Inst_in(IF_O_Instruction),
        .PC4_in(IF_O_PC4),
        .PC_in(IF_O_PC),
        .clk(clk),
        .reset(IF_ID_reset),
        .enable(IF_ID_enable),
        .Inst_out(ID_I_Instruction),
        .PC4_out(ID_I_PC4),
        .PC_out(IF_ID_O_PC)
    );
    ExceptionRegister if_id_exception(
        .clk(clk),
        .reset(IF_ID_reset),
        .enable(IF_ID_enable),
        .exception_in(IF_O_exception),
        .EPC_in(IF_O_EPC),
        .ExcCode_in(IF_O_ExcCode),
        .BD_in(IF_O_BD),
        .exception_out(ID_I_exception),
        .EPC_out(ID_I_EPC),
        .ExcCode_out(ID_I_ExcCode),
        .BD_out(ID_I_BD)
    );

    // vvvvvvvvvvvvvvvvvvvvvvvv BEGIN OF ID STATE vvvvvvvvvvvvvvvvvvvvvvvv
    InstructionDecode ID(
        .Inst(ID_I_Instruction),
        .PC4(ID_I_PC4),
        .rs_in(ID_I_rs),
        .rt_in(ID_I_rt),
        .exception_in(ID_I_exception),
        .EPC_in(ID_I_EPC),
        .ExcCode_in(ID_I_ExcCode),
        .BD_in(ID_I_BD),
        .rs_URA(ID_O_rs_URA),
        .rt_URA(ID_O_rt_URA),
        .has_delay_slot(IF_I_delay_slot),
        .nullify_delay_slot(ID_O_nullify_delay_slot),
        .Inst_out(ID_O_Instruction),
        .rs(ID_O_rs),
        .rt(ID_O_rt),
        .immediate(ID_O_immediate),
        .DO(ID_O_DO),
        .PC_jump(ID_O_PC_jump),
        .NPC_target(ID_O_NPC_target),
        .exception_out(ID_O_exception),
        .EPC_out(ID_O_EPC),
        .ExcCode_out(ID_O_ExcCode),
        .BD_out(ID_O_BD)
    );
    wire        ID_RS_used;
    wire        ID_RT_used;
    wire[1:0]   ID_RS_T_use;
    wire[1:0]   ID_RT_T_use;
    wire[6:0]   ID_RD_1_URA;
    wire[6:0]   ID_RD_2_URA;
    wire[6:0]   ID_RD_3_URA;
    wire        ID_RD_write_enable;
    wire[1:0]   ID_T_new;
    wire        multiply_instruction = (
                    (ID_I_Instruction[`opcode] === 6'b000000) & (ID_I_Instruction[5:4] === 2'b01)
                );
    TnewOriginalDecoder T_new_generator(
        .Inst(ID_I_Instruction),
        .RT_URA(ID_O_rt_URA),
        .EX_RD_URA(ID_EX_O_rd_1_URA),
        .EX_Tnew(ID_EX_O_T_new),
        .MEM_RD_URA(EX_MEM_O_rd_1_URA),
        .MEM_Tnew(EX_MEM_O_T_new),
        .Tnew(ID_T_new)
    );
    RSTuseDecoder RS_T_use_generator(
        .Inst(ID_I_Instruction),
        .used(ID_RS_used),
        .Tuse(ID_RS_T_use)
    );
    RTTuseDecoder RT_T_use_generator(
        .Inst(ID_I_Instruction),
        .used(ID_RT_used),
        .Tuse(ID_RT_T_use)
    );
    RDDecoder RD_decoder(
        .instruction(ID_I_Instruction),
        .URA_real(ID_RD_1_URA),
        .URA_possible1(ID_RD_2_URA),
        .URA_possible2(ID_RD_3_URA)
    );
    RDWriteDecoder RD_checker(
        .instruction(ID_I_Instruction), .enable(ID_RD_write_enable)
    );
    assign ID_EX_I_T_new = ID_T_new;
    assign ID_EX_I_DO_reliable = ID_T_new === 2'b00;
    // To avoid unwanted forwarding, set piped rd_addr to 0 if instruction
    //  won't modify GRF.
    assign ID_EX_I_rd_1_URA = ID_RD_1_URA & {7{ID_RD_write_enable}};
    assign ID_EX_I_rd_2_URA = ID_RD_2_URA & {7{ID_RD_write_enable}};
    assign ID_EX_I_rd_3_URA = ID_RD_3_URA & {7{ID_RD_write_enable}};
    assign GRF_read_addr_1 = ID_O_rs_URA[4:0];
    assign GRF_read_addr_2 = ID_O_rt_URA[4:0];
    assign CP0_read_address = (
        ID_O_rs_URA[6:5] === 2'b01
    ) ? ID_O_rs_URA[4:0] : ID_O_rt_URA[4:0];

    // Pausing the pipeline if needed
    assign pause = (
        (
            ID_RS_used & (ID_O_rs_URA !== 7'b0000000 & ID_O_rs_URA !== 7'b0101111) & (
                ((ID_EX_O_rd_1_URA === ID_O_rs_URA) & (ID_RS_T_use < ID_EX_O_T_new)) |
                ((EX_MEM_O_rd_1_URA === ID_O_rs_URA) & (ID_RS_T_use < EX_MEM_O_T_new))
            )
        ) | (
            ID_RT_used & (ID_O_rt_URA !== 7'b0000000 & ID_O_rt_URA !== 7'b0101111) & (
                ((ID_EX_O_rd_1_URA === ID_O_rt_URA) & (ID_RT_T_use < ID_EX_O_T_new)) |
                ((EX_MEM_O_rd_1_URA === ID_O_rt_URA) & (ID_RT_T_use < EX_MEM_O_T_new))
            )
        ) | (
            // For debugging convenience, freeze processor on syscall instructions
            (ID_I_Instruction[`opcode] === 6'b000000) & (ID_I_Instruction[`funct] === 6'b001100)
        ) | (multiply_instruction & Multiply_busy)
    );

    // Forward implementation
    wire[1:0]   ID_rs_select;
    wire[1:0]   ID_rt_select;
    MUX4#(32)ID_rs_MUX(
        .in1(GRF_read_data_1),
        .in2(CP0_read_data),
        .in3(ID_EX_O_DO),
        .in4(MEM_I_AO),
        .select(ID_rs_select),
        .out(ID_I_rs)
    );
    MUX4#(32)ID_rt_MUX(
        .in1(GRF_read_data_2),
        .in2(CP0_read_data),
        .in3(ID_EX_O_DO),
        .in4(MEM_I_AO),
        .select(ID_rt_select),
        .out(ID_I_rt)
    );
    assign ID_rs_select = (
        (ID_O_rs_URA !== 7'b0000000 & ID_O_rs_URA !== 7'b0101111) &
        (ID_EX_O_rd_1_URA === ID_O_rs_URA) &
        (ID_EX_O_T_new === 0)
    ) ? 2'b10 : (
        (ID_O_rs_URA !== 7'b0000000 & ID_O_rs_URA !== 7'b0101111) &
        (EX_MEM_O_rd_1_URA === ID_O_rs_URA) &
        (EX_MEM_O_T_new === 0)
    ) ? 2'b11 : (
        (ID_O_rs_URA[6:5] === 2'b01)
    ) ? 2'b01 : 2'b00;
    assign ID_rt_select =
    (
        (ID_O_rt_URA !== 7'b0000000 & ID_O_rt_URA !== 7'b0101111) &
        (ID_EX_O_rd_1_URA === ID_O_rt_URA) &
        (ID_EX_O_T_new === 0)
    ) ? 2'b10 :
    (
        (ID_O_rt_URA !== 7'b0000000 & ID_O_rt_URA !== 7'b0101111) &
        (EX_MEM_O_rd_1_URA === ID_O_rt_URA) &
        (EX_MEM_O_T_new === 0)
    ) ? 2'b11 : (
        (ID_O_rt_URA[6:5] === 2'b01)
    ) ? 2'b01 : 2'b00;
    // ^^^^^^^^^^^^^^^^^^^^^^^^^ END OF ID STATE ^^^^^^^^^^^^^^^^^^^^^^^^^

    ID_EX id_ex(
        .Inst_in(ID_O_Instruction),
        .rs_in(ID_O_rs),
        .rt_in(ID_O_rt),
        .imm_in(ID_O_immediate),
        .DO_in(ID_O_DO),
        .DO_reliable_in(ID_EX_I_DO_reliable),
        .rs_URA_in(ID_O_rs_URA),
        .rt_URA_in(ID_O_rt_URA),
        .rd_URA_1_in(ID_EX_I_rd_1_URA),
        .rd_URA_2_in(ID_EX_I_rd_2_URA),
        .rd_URA_3_in(ID_EX_I_rd_3_URA),
        .T_new_in(ID_EX_I_T_new),
        .PC_in(IF_ID_O_PC),
        .clk(clk),
        .reset(ID_EX_reset),
        .enable(ID_EX_enable),
        .Inst_out(EX_I_Instruction),
        .rs_out(ID_EX_O_rs),
        .rt_out(ID_EX_O_rt),
        .imm_out(EX_I_immediate),
        .DO_out(ID_EX_O_DO),
        .DO_reliable_out(ID_EX_O_DO_reliable),
        .rs_URA_out(ID_EX_O_rs_URA),
        .rt_URA_out(ID_EX_O_rt_URA),
        .rd_URA_1_out(ID_EX_O_rd_1_URA),
        .rd_URA_2_out(ID_EX_O_rd_2_URA),
        .rd_URA_3_out(ID_EX_O_rd_3_URA),
        .T_new_out(ID_EX_O_T_new),
        .PC_out(ID_EX_O_PC)
    );
    ExceptionRegister id_ex_exception(
        .clk(clk),
        .reset(ID_EX_reset),
        .enable(ID_EX_enable),
        .exception_in(ID_O_exception),
        .EPC_in(ID_O_EPC),
        .ExcCode_in(ID_O_ExcCode),
        .BD_in(ID_O_BD),
        .exception_out(EX_I_exception),
        .EPC_out(EX_I_EPC),
        .ExcCode_out(EX_I_ExcCode),
        .BD_out(EX_I_BD)
    );

    // vvvvvvvvvvvvvvvvvvvvvvvv BEGIN OF EX STATE vvvvvvvvvvvvvvvvvvvvvvvv  
    Execution EX(
        .Inst(EX_I_Instruction),
        .rs(EX_I_rs),
        .rt(EX_I_rt),
        .immediate(EX_I_immediate),
        .DO(ID_EX_O_DO),
        .DO_reliable(ID_EX_O_DO_reliable),
        .clk(clk),
        .reset(reset),
        .exception_in(EX_I_exception),
        .EPC_in(EX_I_EPC),
        .ExcCode_in(EX_I_ExcCode),
        .BD_in(EX_I_BD),
        .Inst_out(EX_O_Instruction),
        .rt_out(EX_O_rt),
        .AO(EX_O_AO),
        .Multiply_busy(Multiply_busy),
        .exception_out(EX_O_exception),
        .EPC_out(EX_O_EPC),
        .ExcCode_out(EX_O_ExcCode),
        .BD_out(EX_O_BD)
    );
    assign EX_MEM_I_T_new = (ID_EX_O_T_new === 2'b00) ? (2'b00) : (ID_EX_O_T_new - 2'b01);
    // Forward implementation
    wire[1:0]   EX_rs_select;
    wire[1:0]   EX_rt_select;
    MUX3#(32)EX_rs_MUX(
        .in1(ID_EX_O_rs),
        .in2(MEM_I_AO),
        .in3(WB_write_data),
        .select(EX_rs_select),
        .out(EX_I_rs)
    );
    MUX3#(32)EX_rt_MUX(
        .in1(ID_EX_O_rt),
        .in2(MEM_I_AO),
        .in3(WB_write_data),
        .select(EX_rt_select),
        .out(EX_I_rt)
    );
    assign EX_rs_select =
    (
        (ID_EX_O_rs_URA !== 7'b0000000 & ID_EX_O_rs_URA !== 7'b0101111) &
        (EX_MEM_O_rd_1_URA === ID_EX_O_rs_URA) &
        (EX_MEM_O_T_new === 0)
    ) ? 2'b01 :
    (
        (ID_EX_O_rs_URA !== 7'b0000000 & ID_EX_O_rs_URA !== 7'b0101111) &
        (WB_write_URA === ID_EX_O_rs_URA)
    ) ? 2'b10 : 2'b00;
    assign EX_rt_select =
    (
        (ID_EX_O_rt_URA !== 7'b0000000 & ID_EX_O_rt_URA !== 7'b0101111) &
        (EX_MEM_O_rd_1_URA === ID_EX_O_rt_URA) &
        (EX_MEM_O_T_new === 0)
    ) ? 2'b01 :
    (
        (ID_EX_O_rt_URA !== 7'b0000000 & ID_EX_O_rt_URA !== 7'b0101111) &
        (WB_write_URA === ID_EX_O_rt_URA)
    ) ? 2'b10 : 2'b00;
    // ^^^^^^^^^^^^^^^^^^^^^^^^^ END OF EX STATE ^^^^^^^^^^^^^^^^^^^^^^^^^
    EX_MEM ex_mem(
        .Inst_in(EX_O_Instruction),
        .AO_in(EX_O_AO),
        .rt_in(EX_O_rt),
        .rt_URA_in(ID_EX_O_rt_URA),
        .rd_URA_1_in(ID_EX_O_rd_1_URA),
        .rd_URA_2_in(ID_EX_O_rd_2_URA),
        .rd_URA_3_in(ID_EX_O_rd_3_URA),
        .T_new_in(EX_MEM_I_T_new),
        .PC_in(ID_EX_O_PC),
        .clk(clk),
        .reset(EX_MEM_reset),
        .enable(EX_MEM_enable),
        .Inst_out(MEM_I_Instruction),
        .AO_out(MEM_I_AO),
        .rt_out(EX_MEM_O_rt),
        .rt_URA_out(EX_MEM_O_rt_URA),
        .rd_URA_1_out(EX_MEM_O_rd_1_URA),
        .rd_URA_2_out(EX_MEM_O_rd_2_URA),
        .rd_URA_3_out(EX_MEM_O_rd_3_URA),
        .T_new_out(EX_MEM_O_T_new),
        .PC_out(EX_MEM_O_PC)
    );
    ExceptionRegister ex_mem_exception(
        .clk(clk),
        .reset(EX_MEM_reset),
        .enable(EX_MEM_enable),
        .exception_in(EX_O_exception),
        .EPC_in(EX_O_EPC),
        .ExcCode_in(EX_O_ExcCode),
        .BD_in(EX_O_BD),
        .exception_out(MEM_I_exception),
        .EPC_out(MEM_I_EPC),
        .ExcCode_out(MEM_I_ExcCode),
        .BD_out(MEM_I_BD)
    );

    // vvvvvvvvvvvvvvvvvvvvvvvv BEGIN OF MEM STATE vvvvvvvvvvvvvvvvvvvvvvvv
    wire        MEM_write_enable;
    wire[31:0]  MEM_write_data;
    wire[31:0]  MEM_write_address = {MEM_I_AO[31:2], 2'b00};
    Memory MEM(
        .Inst(MEM_I_Instruction),
        .AO(MEM_I_AO),
        .rt(MEM_I_rt),
        .clk(clk),
        .reset(reset),
        .bridge_read_data(bridge_read_data),
        .bridge_accepted(bridge_accepted),
        .bridge_address(bridge_address),
        .bridge_write_data(bridge_write_data),
        .bridge_write_size(bridge_write_size),
        .bridge_read_size(bridge_read_size),
        .exception_in(MEM_I_exception),
        .EPC_in(MEM_I_EPC),
        .ExcCode_in(MEM_I_ExcCode),
        .BD_in(MEM_I_BD),
        .Inst_out(MEM_O_Instruction),
        .AO_out(MEM_O_AO),
        .MO(MEM_O_MO),
        .debug_enable(MEM_write_enable),
        .debug_data(MEM_write_data),
        .exception_out(MEM_O_exception),
        .EPC_out(MEM_O_EPC),
        .ExcCode_out(MEM_O_ExcCode),
        .BD_out(MEM_O_BD)
    );
    CP0Submitter CP0_submitter(
        .Inst(MEM_I_Instruction),
        .rt(MEM_I_rt),
        .exception(MEM_O_exception),
        .EPC(MEM_O_EPC),
        .ExcCode(MEM_O_ExcCode),
        .BD(MEM_O_BD),
        .interrupt_request(interrupt_request),
        .current_SR(CP0_SR_output),
        .branch_to_handler(IF_I_handle_exception),
        .new_SR(CP0_SR_input),
        .SR_enable(CP0_SR_enable),
        .new_Cause(CP0_Cause_input),
        .Cause_enable(CP0_Cause_enable),
        .new_EPC(CP0_EPC_input),
        .EPC_enable(CP0_EPC_enable)
    );
    // Forward implementation
    wire   MEM_rt_select;
    MUX2#(32)MEM_rt_MUX(
        .in1(EX_MEM_O_rt),
        .in2(WB_write_data),
        .select(MEM_rt_select),
        .out(MEM_I_rt)
    );
    assign MEM_rt_select = (
        (EX_MEM_O_rt_URA !== 7'b0000000 & EX_MEM_O_rt_URA !== 7'b0101111) &
        (WB_write_URA === EX_MEM_O_rt_URA)
    );
    // ^^^^^^^^^^^^^^^^^^^^^^^^^ END OF MEM STATE ^^^^^^^^^^^^^^^^^^^^^^^^^

    MEM_WB mem_wb(
        .Inst_in(MEM_O_Instruction),
        .AO_in(MEM_O_AO),
        .MO_in(MEM_O_MO),
        .PC_in(EX_MEM_O_PC),
        .clk(clk),
        .reset(MEM_WB_reset),
        .enable(MEM_WB_enable),
        .Inst_out(WB_I_Instruction),
        .AO_out(WB_I_AO),
        .MO_out(WB_I_MO),
        .PC_out(MEM_WB_O_PC)
    );

    // vvvvvvvvvvvvvvvvvvvvvvvv BEGIN OF WB STATE vvvvvvvvvvvvvvvvvvvvvvvv
    WriteBack WB(
        .Inst(WB_I_Instruction),
        .AO(WB_I_AO),
        .MO(WB_I_MO),
        .write_enable(WB_O_write_enable),
        .write_URA(WB_O_write_URA),
        .write_data(WB_O_write_data)
    );
	assign GRF_write_data = WB_O_write_data;
    assign GRF_write_addr = WB_O_write_URA[4:0] & {5{WB_O_write_enable}};
    assign GRF_write_enable = WB_O_write_enable & (WB_O_write_URA[6:5] === 2'b00);
    assign WB_write_data = WB_O_write_data;
    wire[6:0]   WB_write_URA = WB_O_write_URA & {7{WB_O_write_enable}};
    // ^^^^^^^^^^^^^^^^^^^^^^^^^ END OF WB STATE ^^^^^^^^^^^^^^^^^^^^^^^^^

    always@(posedge clk)begin
        // watch signals and output for debugging
        if(!reset)begin
            if(GRF_write_enable)begin
                $display("%d@%h: $%d <= %h", $time, MEM_WB_O_PC, GRF_write_addr, GRF_write_data);
            end
            if(MEM_write_enable)begin
                $display("%d@%h: *%h <= %h", $time, EX_MEM_O_PC, MEM_write_address, MEM_write_data);
            end
        end
    end
endmodule