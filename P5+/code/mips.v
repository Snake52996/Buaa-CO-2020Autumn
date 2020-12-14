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
    wire[31:0]  CP0_read_data,
    wire[31:0]  CP0_EPC,
    wire        CP0_BD,
    wire[4:0]   CP0_address,
    wire[31:0]  CP0_write_data,
    wire        CP0_write_enable,
    wire[31:0]  CP0_cause,
    wire[31:0]  bridge_read_data;
    wire[7:2]   interrupt_request;
    wire        bridge_address_accepted;
    wire        bridge_instruction_accepted;
    wire[31:0]  bridge_address;
    wire[31:0]  bridge_write_data;
    wire[2:0]   bridge_write_size;
    wire[2:0]   bridge_read_size;
    CPU cpu(
        .clk(clk),
        .reset(reset),
        .CP0_read_data(CP0_read_data),
        .CP0_EPC(CP0_EPC),
        .CP0_BD(CP0_BD),
        .CP0_address(CP0_address),
        .CP0_write_data(CP0_write_data),
        .CP0_write_enable(CP0_write_enable),
        .CP0_cause(CP0_cause),
        .bridge_read_data(bridge_read_data),
        .interrupt_request(interrupt_request),
        .bridge_address_accepted(bridge_address_accepted),
        .bridge_instruction_accepted(bridge_instruction_accepted),
        .bridge_address(bridge_address),
        .bridge_write_data(bridge_write_data),
        .bridge_write_size(bridge_write_size),
        .bridge_read_size(bridge_read_size),
        .macroscopic_PC(addr)
    );
    CoOperator0 CP0(
        .clk(clk),
        .reset(reset),
        .address(CP0_address),
        .write_data(CP0_write_data),
        .write_enable(CP0_write_enable),
        .cause_input(CP0_cause),
        .read_data(CP0_read_data),
        .EPC_output(CP0_EPC),
        .BD_output(CP0_BD)
    );
    wire[3:0]   timer0_address;
    wire[31:0]  timer0_write_data;
    wire        timer0_write_enable;
    wire[31:0]  timer0_read_data;
    wire        timer0_interrupt_request;
    wire[3:0]   timer1_address;
    wire[31:0]  timer1_write_data;
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
        .address_accepted(bridge_address_accepted),
        .instruction_accepted(bridge_instruction_accepted),
        .timer0_address(timer0_address),
        .timer0_write_data(timer0_write_data),
        .timer0_write_enable(timer0_write_enable),
        .timer0_read_data(timer0_read_data),
        .timer0_interrupt_request(timer0_interrupt_request),
        .timer1_address(timer1_address),
        .timer1_write_data(timer1_write_data),
        .timer1_write_enable(timer1_write_enable),
        .timer1_read_data(timer1_read_data),
        .timer1_interrupt_request(timer1_interrupt_request),
        .outer_interruption(interrupt)
    );
    TC timer0(
        .clk(clk),
        .reset(reset),
        .Addr(timer0_address),
        .WE(timer0_write_enable),
        .Din(timer0_write_data),
        .Dout(timer0_read_data),
        .IRQ(timer0_interrupt_request)
    );
    TC timer1(
        .clk(clk),
        .reset(reset),
        .Addr(timer1_address),
        .WE(timer1_write_enable),
        .Din(timer1_write_data),
        .Dout(timer1_read_data),
        .IRQ(timer1_interrupt_request)
    );
endmodule