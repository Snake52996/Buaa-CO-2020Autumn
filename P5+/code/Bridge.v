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
    output          accepted,
    // ports connected with devices
    // Timer0
    output          timer0_write_enable,
    input[31:0]     timer0_read_data,
    input           timer0_interrupt_request,
    // Timer1
    output          timer1_write_enable,
    input[31:0]     timer1_read_data,
    input           timer1_interrupt_request,
    // Outer interruption
    input           outer_interruption
);
    // Instruction is accepted if and only if it is (or seems to be) a lw or sw,
    //  whose targeted address is properly aligned and locates in proper range,
    //  and it does not attempt to write to address that is read only.
    assign accepted = aligned & (timer0 | timer1) & (
        (read_size === 3'd0 & write_size === 3'd4 & (timer0_writable | timer1_writable)) |
        (write_size === 3'd0 & read_size === 3'd4)
    );
    wire    aligned;
    wire    timer0;
    wire    timer0_writable;
    wire    timer1;
    wire    timer1_writable;
    ValueAlignmentChecker bridge_Align_Checker(.value(address), .accepted(aligned));
    ValueRangeChecker#(32,32'h7f00,32'h7f0b)bridge_Range_Checker_timer0(
        .value(address), .accepted(timer0)
    );
    ValueRangeChecker#(32,32'h7f00,32'h7f07)bridge_Range_Checker_timer0_writable(
        .value(address), .accepted(timer0_writable)
    );
    ValueRangeChecker#(32,32'h7f10,32'h7f1b)bridge_Range_Checker_timer1(
        .value(address), .accepted(timer1)
    );
    ValueRangeChecker#(32,32'h7f10,32'h7f17)bridge_Range_Checker_timer1_writable(
        .value(address), .accepted(timer1_writable)
    );
    // write is enabled if and only if write size is not 0 and operation is accepted
    wire write_enable = accepted & (write_size !== 3'd0);
    // read is enabled if and only if read size is not 0 and operation is accepted
    wire read_enable = accepted & (read_size !== 3'd0);
    assign interrupt_request = {
        3'b000, outer_interruption, timer1_interrupt_request, timer0_interrupt_request
    };
    // Communicate with timer0
    assign timer0_write_enable = write_enable & timer0_writable;
    ControlledBuffer timer0_controlled_buffer(
        .data_in(timer0_read_data), .enable(read_enable & timer0), .data_out(read_data)
    );
    // Communicate with timer1
    assign timer1_write_enable = write_enable & timer1_writable;
    ControlledBuffer timer1_controlled_buffer(
        .data_in(timer1_read_data), .enable(read_enable & timer1), .data_out(read_data)
    );
endmodule