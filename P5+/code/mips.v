/*
 * File: mips.v
 * Top level module of MIPS Micro-architecture
*/
module mips(
    input           clk,
    input           reset,
    input           interrupt,
    output[31:0]    addr
);
    wire[31:0]  CP0_read_data;
    wire[31:0]  CP0_SR_output;
    wire[31:0]  CP0_EPC_output;
    wire[31:0]  CP0_Cause_output;
    wire[4:0]   CP0_read_address;
    wire[31:0]  CP0_SR_input;
    wire        CP0_SR_enable;
    wire[31:0]  CP0_Cause_input;
    wire        CP0_Cause_enable;
    wire[31:0]  CP0_EPC_input;
    wire        CP0_EPC_enable;
    wire[31:0]  bridge_read_data;
    wire[7:2]   interrupt_request;
    wire        bridge_accepted;
    wire[31:0]  bridge_address;
    wire[31:0]  bridge_write_data;
    wire[2:0]   bridge_write_size;
    wire[2:0]   bridge_read_size;
    CPU cpu(
        .clk(clk),
        .reset(reset),
        .CP0_read_data(CP0_read_data),
        .CP0_SR_output(CP0_SR_output),
        .CP0_EPC_output(CP0_EPC_output),
        .CP0_Cause_output(CP0_Cause_output),
        .CP0_read_address(CP0_read_address),
        .CP0_SR_input(CP0_SR_input),
        .CP0_SR_enable(CP0_SR_enable),
        .CP0_Cause_input(CP0_Cause_input),
        .CP0_Cause_enable(CP0_Cause_enable),
        .CP0_EPC_input(CP0_EPC_input),
        .CP0_EPC_enable(CP0_EPC_enable),
        .bridge_read_data(bridge_read_data),
        .interrupt_request(interrupt_request),
        .bridge_accepted(bridge_accepted),
        .bridge_address(bridge_address),
        .bridge_write_data(bridge_write_data),
        .bridge_write_size(bridge_write_size),
        .bridge_read_size(bridge_read_size),
        .macroscopic_PC(addr)
    );
    CoProcessor0 CP0(
        .clk(clk),
        .reset(reset),
        .read_address(CP0_read_address),
        .SR_input(CP0_SR_input),
        .SR_enable(CP0_SR_enable),
        .Cause_input(CP0_Cause_input),
        .Cause_enable(CP0_Cause_enable),
        .EPC_input(CP0_EPC_input),
        .EPC_enable(CP0_EPC_enable),
        .read_data(CP0_read_data),
        .SR_output(CP0_SR_output),
        .EPC_output(CP0_EPC_output),
        .Cause_output(CP0_Cause_output)
    );
    wire        timer0_write_enable;
    wire[31:0]  timer0_read_data;
    wire        timer0_interrupt_request;
    wire        timer1_write_enable;
    wire[31:0]  timer1_read_data;
    wire        timer1_interrupt_request;
    Bridge bridge(
        .address(bridge_address),
        .write_data(bridge_write_data),
        .write_size(bridge_write_size),
        .read_size(bridge_read_size),
        .read_data(bridge_read_data),
        .interrupt_request(interrupt_request),
        .accepted(bridge_accepted),
        .timer0_write_enable(timer0_write_enable),
        .timer0_read_data(timer0_read_data),
        .timer0_interrupt_request(timer0_interrupt_request),
        .timer1_write_enable(timer1_write_enable),
        .timer1_read_data(timer1_read_data),
        .timer1_interrupt_request(timer1_interrupt_request),
        .outer_interruption(interrupt)
    );
    TC timer0(
        .clk(clk),
        .reset(reset),
        .Addr(bridge_address),
        .WE(timer0_write_enable),
        .Din(bridge_write_data),
        .Dout(timer0_read_data),
        .IRQ(timer0_interrupt_request)
    );
    TC timer1(
        .clk(clk),
        .reset(reset),
        .Addr(bridge_address),
        .WE(timer1_write_enable),
        .Din(bridge_write_data),
        .Dout(timer1_read_data),
        .IRQ(timer1_interrupt_request)
    );
    /*
    TC timer0(
        .clk(clk),
        .reset(reset),
        .Addr(bridge_address),
        .WE(timer0_write_enable),
        .Din(bridge_write_data),
        .PC(addr),
        .Dout(timer0_read_data),
        .IRQ(timer0_interrupt_request)
    );
    TC timer1(
        .clk(clk),
        .reset(reset),
        .Addr(bridge_address),
        .WE(timer1_write_enable),
        .Din(bridge_write_data),
        .PC(addr),
        .Dout(timer1_read_data),
        .IRQ(timer1_interrupt_request)
    );
    */
endmodule