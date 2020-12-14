/*
 * File: Bridge.v
 * CPU -- device bridge
*/
module Bridge(
    // ports connected with CPU
    input[31:0]     address,
    input[31:0]     write_data,
    input[2:0]      write_size,
    input[2:0]      read_size,
    output[31:0]    read_data,
    output[7:2]     interrupt_request,
    output          address_accepted,
    output          instruction_accepted,
    // ports connected with devices
    // Timer0
    output[3:0]     timer0_address,
    output[31:0]    timer0_write_data,
    output          timer0_write_enable,
    input[31:0]     timer0_read_data,
    input           timer0_interrupt_request,
    // Timer1
    output[3:0]     timer1_address,
    output[31:0]    timer1_write_data,
    output          timer1_write_enable,
    input[31:0]     timer1_read_data,
    input           timer1_interrupt_request,
    // Outer interruption
    input           outer_interruption
);
    // Instruction is accepted if and only if it is (or seems to be) a lw or sw
    assign instruction_accepted = (
        (write_size === 3'd4) | (write_size === 3'd0 & read_size === 3'd4)
    );
    wire    aligned;
    wire    timer0;
    wire    timer1;
    ValueAlignmentChecker   bridge_Align_Checker(.value(address), .accepted(aligned));
    ValueRangeChecker#(32,32'h7f00,32'h7f0b)bridge_Range_Checker_timer0(
        .value(address), .accepted(timer0)
    );
    ValueRangeChecker#(32,32'h7f10,32'h7f1b)bridge_Range_Checker_timer1(
        .value(address), .accepted(timer1)
    );
    // Address is accepted if and only if it is properly aligned and in proper range
    assign address_accepted = aligned & (timer0 | timer1);
    // write is enabled if and only if write size is not 0 and operation is accepted
    wire write_enable = instruction_accepted & address_accepted & (write_size !== 3'd0);
    MUX2#(32)read_data_MUX(
        .in1(timer0_read_data), .in2(timer1_read_data), .select(timer1),
        .out(read_data)
    );
    assign interrupt_request = {
        3'b000, outer_interruption, timer1_interrupt_request, timer0_interrupt_request
    };
    // Tunnel to timer0
    assign timer0_address = address[3:0];
    assign timer0_write_data = write_data;
    assign timer0_write_enable = write_enable & timer0;
    // Tunnel to timer1
    assign timer1_address = address[3:0];
    assign timer1_write_data = write_data;
    assign timer1_write_enable = write_enable & timer1;
endmodule