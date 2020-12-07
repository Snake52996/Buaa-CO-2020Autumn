/*
 * File: mips.v
 * Top level model of Pipeline MIPS processor
*/
`include "Utility.macros.v"
module mips(
    input clk,
    input reset
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
    //  IF/ID-register variables
    wire        IF_ID_enable;
    wire        IF_ID_reset;
    wire[31:0]  IF_ID_O_PC;
    //  ID-state variables
    wire[31:0]  ID_I_Instruction;
    wire[31:0]  ID_I_PC4;
    wire[31:0]  ID_I_rs;
    wire[31:0]  ID_I_rt;
    wire[4:0]   ID_O_rs_addr;
    wire[4:0]   ID_O_rt_addr;
    wire[31:0]  ID_O_Instruction;
    wire[31:0]  ID_O_rs;
    wire[31:0]  ID_O_rt;
    wire[31:0]  ID_O_immediate;
    wire[31:0]  ID_O_DO;
    wire        ID_O_PC_jump;
    wire[31:0]  ID_O_NPC_target;
    //  ID/EX-register variables
    wire        ID_EX_I_DO_reliable;
    wire[4:0]   ID_EX_I_rd_addr;
    wire[1:0]   ID_EX_I_T_new;
    wire        ID_EX_reset;
    wire        ID_EX_enable;
    wire[31:0]  ID_EX_O_rs;
    wire[31:0]  ID_EX_O_rt;
    wire[31:0]  ID_EX_O_DO;
    wire        ID_EX_O_DO_reliable;
    wire[4:0]   ID_EX_O_rs_addr;
    wire[4:0]   ID_EX_O_rt_addr;
    wire[4:0]   ID_EX_O_rd_addr;
    wire[1:0]   ID_EX_O_T_new;
    wire[31:0]  ID_EX_O_PC;
    //  EX-state variables
    wire[31:0]  EX_I_Instruction;
    wire[31:0]  EX_I_rs;
    wire[31:0]  EX_I_rt;
    wire[31:0]  EX_I_immediate;
    wire[31:0]  EX_O_Instruction;
    wire[31:0]  EX_O_rt;
    wire[31:0]  EX_O_AO;
    wire        Multiply_busy;
    //  EX/MEM-register variables
    wire[1:0]   EX_MEM_I_T_new;
    wire        EX_MEM_reset;
    wire        EX_MEM_enable;
    wire[31:0]  EX_MEM_O_rt;
    wire[4:0]   EX_MEM_O_rt_addr;
	wire[4:0]	EX_MEM_O_rd_addr;
    wire[1:0]   EX_MEM_O_T_new;
    wire[31:0]  EX_MEM_O_PC;
    //  MEM-state variables
    wire[31:0]  MEM_I_Instruction;
    wire[31:0]  MEM_I_AO;
    wire[31:0]  MEM_I_rt;
    wire[31:0]  MEM_O_Instruction;
    wire[31:0]  MEM_O_AO;
    wire[31:0]  MEM_O_MO;
    //  MEM/WB-register variables
    wire        MEM_WB_reset;
    wire        MEM_WB_enable;
    wire[31:0]  MEM_WB_O_PC;
    //  WB-state variables
    wire[31:0]  WB_I_Instruction;
    wire[31:0]  WB_I_AO;
    wire[31:0]  WB_I_MO;
    wire        WB_O_GRF_write_enable;
    wire[4:0]   WB_O_GRF_write_addr;
    wire[31:0]  WB_O_GRF_write_data;
	// End of variables

    // Top level control signals
	wire        pause;

    // pause logic
    assign IF_I_PC_enable = ~pause;
    assign IF_ID_enable = ~pause;
    assign ID_EX_reset = pause | reset;
    // enable registers & link reset
    assign IF_ID_reset = reset;
    assign ID_EX_enable = 1'b1;
    assign EX_MEM_reset = reset;
    assign EX_MEM_enable = 1'b1;
    assign MEM_WB_reset = reset;
    assign MEM_WB_enable = 1'b1;

    GRF grf(
        .clk(clk), .reset(reset),
        .read_addr_1(GRF_read_addr_1), .read_addr_2(GRF_read_addr_2),
        .write_addr(GRF_write_addr), .write_value(GRF_write_data),
        .write_enable(GRF_write_enable),
        .read_value_1(GRF_read_data_1), .read_value_2(GRF_read_data_2)
    );

    // vvvvvvvvvvvvvvvvvvvvvvvv BEGIN OF IF STATE vvvvvvvvvvvvvvvvvvvvvvvv
    InstructionFetch IF(
        .jump_addr(IF_I_jump_target), .PC_enable(IF_I_PC_enable),
        .PC_jump_select(IF_I_PC_select), .clk(clk), .reset(reset),
        .PC(IF_O_PC), .PC4(IF_O_PC4), .Inst(IF_O_Instruction)
    );
    assign IF_I_jump_target = ID_O_NPC_target;
    assign IF_I_PC_select = ID_O_PC_jump;
    // ^^^^^^^^^^^^^^^^^^^^^^^^^ END OF IF STATE ^^^^^^^^^^^^^^^^^^^^^^^^^

    IF_ID if_id(
        .Inst_in(IF_O_Instruction), .PC4_in(IF_O_PC4), .PC_in(IF_O_PC),
        .clk(clk), .reset(IF_ID_reset),
        .enable(IF_ID_enable), .Inst_out(ID_I_Instruction),
        .PC4_out(ID_I_PC4), .PC_out(IF_ID_O_PC)
    );

    // vvvvvvvvvvvvvvvvvvvvvvvv BEGIN OF ID STATE vvvvvvvvvvvvvvvvvvvvvvvv
    InstructionDecode ID(
        .Inst(ID_I_Instruction), .PC4(ID_I_PC4), .GRF_data_1(ID_I_rs),
        .GRF_data_2(ID_I_rt), .GRF_addr_1(ID_O_rs_addr), .GRF_addr_2(ID_O_rt_addr),
        .Inst_out(ID_O_Instruction), .rs(ID_O_rs), .rt(ID_O_rt),
        .immediate(ID_O_immediate), .DO(ID_O_DO), .PC_jump(ID_O_PC_jump),
        .NPC_target(ID_O_NPC_target)
    );
    wire        ID_RS_used;
    wire        ID_RT_used;
    wire[1:0]   ID_RS_T_use;
    wire[1:0]   ID_RT_T_use;
    wire[4:0]   ID_GRF_write_addr;
    wire        ID_GRF_write_enable;
    wire[1:0]   ID_T_new;
    wire        ID_slt_rs_pause;
    wire        ID_slt_rt_pause;
    wire        multiply_instruction = (
                    (ID_I_Instruction[`opcode] === 6'b000000) & (ID_I_Instruction[5:4] === 2'b01)
                );
    TnewOriginalDecoder T_new_generator(.Inst(ID_I_Instruction), .Tnew(ID_T_new));
    RSTuseDecoder RS_T_use_generator(
        .Inst(ID_I_Instruction), .used(ID_RS_used), .Tuse(ID_RS_T_use)
    );
    RTTuseDecoder RT_T_use_generator(
        .Inst(ID_I_Instruction), .used(ID_RT_used), .Tuse(ID_RT_T_use)
    );
    GRFWriteAddressDecoder RD_decoder(
        .Inst(ID_I_Instruction), .GRF_write_addr(ID_GRF_write_addr)
    );
    GRFWriteEnableDecoder RD_checker(
        .Inst(ID_I_Instruction), .GRF_write_enable(ID_GRF_write_enable)
    );
    // DO is reliable(in EX state) if its value is correctly calculated here
    // In case DO is not set, ID_EX_I_DO_reliable shall always be set 0 to
    //  avoid misuse.
    assign ID_slt_rs_pause = (
            (ID_O_rs_addr !== 5'b00000) & (
                ((ID_EX_O_rd_addr === ID_O_rs_addr) & (0 < ID_EX_O_T_new)) |
                ((EX_MEM_O_rd_addr === ID_O_rs_addr) & (0 < EX_MEM_O_T_new))
            )
    );
    assign ID_slt_rt_pause = (
            (ID_O_rt_addr !== 5'b00000) & (
                ((ID_EX_O_rd_addr === ID_O_rt_addr) & (0 < ID_EX_O_T_new)) |
                ((EX_MEM_O_rd_addr === ID_O_rt_addr) & (0 < EX_MEM_O_T_new))
            )
    );
    assign ID_EX_I_DO_reliable = (
        (ID_I_Instruction[`opcode] === 6'b000001 & ID_I_Instruction[20]) |                      // bgezal/bltzal
        (ID_I_Instruction[`opcode] === 6'b000000 & ID_I_Instruction[`funct] === 6'b001001) |    // jalr
        (ID_I_Instruction[`opcode] === 6'b000011) |                                 // jal
        (ID_I_Instruction[`opcode] === 6'b001111) |                                 // lui
        (
            (ID_I_Instruction[`opcode] === 6'b000000) &
            (ID_I_Instruction[`funct] === 6'b101010 | ID_I_Instruction[`funct] === 6'b101011) &
            ((~ID_slt_rs_pause) & (~ID_slt_rt_pause))
        ) |
        (
            ((ID_I_Instruction[`opcode] === 6'b001010) | (ID_I_Instruction[`opcode] === 6'b001011)) &
            (~ID_slt_rs_pause)
        )
    );
    assign ID_EX_I_T_new = (ID_EX_I_DO_reliable === 1'b1) ? 2'b00 : ID_T_new;
    // To avoid unwanted forwarding, set piped rd_addr to 0 if instruction
    //  won't modify GRF.
    assign ID_EX_I_rd_addr = ID_GRF_write_addr & {5{ID_GRF_write_enable}};
    assign GRF_read_addr_1 = ID_O_rs_addr;
    assign GRF_read_addr_2 = ID_O_rt_addr;

    // Pausing the pipeline if needed
    assign pause = (
        (
            ID_RS_used & (ID_O_rs_addr !== 5'b00000) & (
                ((ID_EX_O_rd_addr === ID_O_rs_addr) & (ID_RS_T_use < ID_EX_O_T_new)) |
                ((EX_MEM_O_rd_addr === ID_O_rs_addr) & (ID_RS_T_use < EX_MEM_O_T_new))
            )
        ) | (
            ID_RT_used & (ID_O_rt_addr !== 5'b00000) & (
                ((ID_EX_O_rd_addr === ID_O_rt_addr) & (ID_RT_T_use < ID_EX_O_T_new)) |
                ((EX_MEM_O_rd_addr === ID_O_rt_addr) & (ID_RT_T_use < EX_MEM_O_T_new))
            )
        ) | (
            // For debugging convenience, freeze processor on syscall instructions
            (ID_I_Instruction[`opcode] === 6'b000000) & (ID_I_Instruction[`funct] === 6'b001100)
        ) | (multiply_instruction & Multiply_busy)
    );

    // Forward implementation
    wire[1:0]   ID_rs_select;
    wire[1:0]   ID_rt_select;
    MUX3#(32)ID_rs_MUX(
        .in1(GRF_read_data_1), .in2(ID_EX_O_DO), .in3(MEM_I_AO),
        .select(ID_rs_select), .out(ID_I_rs)
    );
    MUX3#(32)ID_rt_MUX(
        .in1(GRF_read_data_2), .in2(ID_EX_O_DO), .in3(MEM_I_AO),
        .select(ID_rt_select), .out(ID_I_rt)
    );
    assign ID_rs_select =
    (
        (ID_O_rs_addr !== 5'b00000) &
        (ID_EX_O_rd_addr === ID_O_rs_addr) &
        (ID_EX_O_T_new === 0)
    ) ? 2'b01 :
    (
        (ID_O_rs_addr !== 5'b00000) &
        (EX_MEM_O_rd_addr === ID_O_rs_addr) &
        (EX_MEM_O_T_new === 0)
    ) ? 2'b10 : 2'b00;
    assign ID_rt_select =
    (
        (ID_O_rt_addr !== 5'b00000) &
        (ID_EX_O_rd_addr === ID_O_rt_addr) &
        (ID_EX_O_T_new === 0)
    ) ? 2'b01 :
    (
        (ID_O_rt_addr !== 5'b00000) &
        (EX_MEM_O_rd_addr === ID_O_rt_addr) &
        (EX_MEM_O_T_new === 0)
    ) ? 2'b10 : 2'b00;
    // ^^^^^^^^^^^^^^^^^^^^^^^^^ END OF ID STATE ^^^^^^^^^^^^^^^^^^^^^^^^^

    ID_EX id_ex(
        .Inst_in(ID_O_Instruction), .rs_in(ID_O_rs), .rt_in(ID_O_rt),
        .imm_in(ID_O_immediate), .DO_in(ID_O_DO), .DO_reliable_in(ID_EX_I_DO_reliable),
        .rs_addr_in(ID_O_rs_addr), .rt_addr_in(ID_O_rt_addr),
        .rd_addr_in(ID_EX_I_rd_addr), .T_new_in(ID_EX_I_T_new),
        .PC_in(IF_ID_O_PC), .clk(clk), .reset(ID_EX_reset),
        .enable(ID_EX_enable), .Inst_out(EX_I_Instruction), .rs_out(ID_EX_O_rs),
        .rt_out(ID_EX_O_rt), .imm_out(EX_I_immediate), .DO_out(ID_EX_O_DO),
        .DO_reliable_out(ID_EX_O_DO_reliable), .rs_addr_out(ID_EX_O_rs_addr),
        .rt_addr_out(ID_EX_O_rt_addr), .rd_addr_out(ID_EX_O_rd_addr),
        .T_new_out(ID_EX_O_T_new), .PC_out(ID_EX_O_PC)
    );

    // vvvvvvvvvvvvvvvvvvvvvvvv BEGIN OF EX STATE vvvvvvvvvvvvvvvvvvvvvvvv
///*     
    Execution EX(
        .Inst(EX_I_Instruction), .rs(EX_I_rs), .rt(EX_I_rt), .immediate(EX_I_immediate),
        .DO(ID_EX_O_DO), .DO_reliable(ID_EX_O_DO_reliable),
        .clk(clk), .reset(reset),
        .Inst_out(EX_O_Instruction), .rt_out(EX_O_rt), .AO(EX_O_AO),
        .Multiply_busy(Multiply_busy)
    );
    assign EX_MEM_I_T_new = (ID_EX_O_T_new === 2'b00) ? (2'b00) : (ID_EX_O_T_new - 2'b01);
    // Forward implementation
    wire[1:0]   EX_rs_select;
    wire[1:0]   EX_rt_select;
    MUX3#(32)EX_rs_MUX(
        .in1(ID_EX_O_rs), .in2(MEM_I_AO), .in3(WB_O_GRF_write_data),
        .select(EX_rs_select), .out(EX_I_rs)
    );
    MUX3#(32)EX_rt_MUX(
        .in1(ID_EX_O_rt), .in2(MEM_I_AO), .in3(WB_O_GRF_write_data),
        .select(EX_rt_select), .out(EX_I_rt)
    );
    assign EX_rs_select =
    (
        (ID_EX_O_rs_addr !== 5'b00000) &
        (EX_MEM_O_rd_addr === ID_EX_O_rs_addr) &
        (EX_MEM_O_T_new === 0)
    ) ? 2'b01 :
    (
        (ID_EX_O_rs_addr !== 5'b00000) &
        (GRF_write_addr === ID_EX_O_rs_addr)
    ) ? 2'b10 : 2'b00;
    assign EX_rt_select =
    (
        (ID_EX_O_rt_addr !== 5'b00000) &
        (EX_MEM_O_rd_addr === ID_EX_O_rt_addr) &
        (EX_MEM_O_T_new === 0)
    ) ? 2'b01 :
    (
        (ID_EX_O_rt_addr !== 5'b00000) &
        (GRF_write_addr === ID_EX_O_rt_addr)
    ) ? 2'b10 : 2'b00;
    // ^^^^^^^^^^^^^^^^^^^^^^^^^ END OF EX STATE ^^^^^^^^^^^^^^^^^^^^^^^^^
//*/
    EX_MEM ex_mem(
        .Inst_in(EX_O_Instruction), .AO_in(EX_O_AO), .rt_in(EX_O_rt),
        .rt_addr_in(ID_EX_O_rt_addr), .rd_addr_in(ID_EX_O_rd_addr),
        .T_new_in(EX_MEM_I_T_new), .PC_in(ID_EX_O_PC), .clk(clk),
        .reset(EX_MEM_reset), .enable(EX_MEM_enable), .Inst_out(MEM_I_Instruction),
        .AO_out(MEM_I_AO), .rt_out(EX_MEM_O_rt), .rd_addr_out(EX_MEM_O_rd_addr),
        .rt_addr_out(EX_MEM_O_rt_addr), .T_new_out(EX_MEM_O_T_new), .PC_out(EX_MEM_O_PC)
    );

    // vvvvvvvvvvvvvvvvvvvvvvvv BEGIN OF MEM STATE vvvvvvvvvvvvvvvvvvvvvvvv
    wire        MEM_write_enable;
    wire[31:0]  MEM_write_data;
    wire[31:0]  MEM_write_address = {MEM_I_AO[31:2], 2'b00};
    Memory MEM(
        .Inst(MEM_I_Instruction), .AO(MEM_I_AO), .rt(MEM_I_rt), .clk(clk),
        .reset(reset), .Inst_out(MEM_O_Instruction), .AO_out(MEM_O_AO), .MO(MEM_O_MO),
        .debug_enable(MEM_write_enable), .debug_data(MEM_write_data) /* .unaligned_exception() */
    );
    // Forward implementation
    wire   MEM_rt_select;
    MUX2#(32)MEM_rt_MUX(
        .in1(EX_MEM_O_rt), .in2(WB_O_GRF_write_data),
        .select(MEM_rt_select), .out(MEM_I_rt)
    );
    assign MEM_rt_select = (
        (EX_MEM_O_rt_addr !== 5'b00000) &
        (GRF_write_addr === EX_MEM_O_rt_addr)
    );
    // ^^^^^^^^^^^^^^^^^^^^^^^^^ END OF MEM STATE ^^^^^^^^^^^^^^^^^^^^^^^^^

    MEM_WB mem_wb(
        .Inst_in(MEM_O_Instruction), .AO_in(MEM_O_AO), .MO_in(MEM_O_MO),
        .PC_in(EX_MEM_O_PC), .clk(clk), .reset(MEM_WB_reset), .enable(MEM_WB_enable),
        .Inst_out(WB_I_Instruction), .AO_out(WB_I_AO), .MO_out(WB_I_MO),
        .PC_out(MEM_WB_O_PC)
    );

    // vvvvvvvvvvvvvvvvvvvvvvvv BEGIN OF WB STATE vvvvvvvvvvvvvvvvvvvvvvvv
    WriteBack WB(
        .Inst(WB_I_Instruction), .AO(WB_I_AO), .MO(WB_I_MO),
        .GRF_write_enable(WB_O_GRF_write_enable), .GRF_write_addr(WB_O_GRF_write_addr),
        .GRF_write_data(WB_O_GRF_write_data)
    );
	assign GRF_write_data = WB_O_GRF_write_data;
    assign GRF_write_addr = WB_O_GRF_write_addr & {5{WB_O_GRF_write_enable}};
    assign GRF_write_enable = WB_O_GRF_write_enable;
    // ^^^^^^^^^^^^^^^^^^^^^^^^^ END OF WB STATE ^^^^^^^^^^^^^^^^^^^^^^^^^

    always@(posedge clk)begin
        // watch signals and output for debugging
        if(!reset)begin
            if(WB_O_GRF_write_enable)begin
                $display("%d@%h: $%d <= %h", $time, MEM_WB_O_PC, WB_O_GRF_write_addr, WB_O_GRF_write_data);
                //$display("@%h: $%d <= %h", MEM_WB_O_PC, WB_O_GRF_write_addr, WB_O_GRF_write_data);
            end
            if(MEM_write_enable)begin
                $display("%d@%h: *%h <= %h", $time, EX_MEM_O_PC, MEM_write_address, MEM_write_data);
                //$display("@%h: *%h <= %h", EX_MEM_O_PC, MEM_write_address, MEM_write_data);
            end
        end
    end
endmodule