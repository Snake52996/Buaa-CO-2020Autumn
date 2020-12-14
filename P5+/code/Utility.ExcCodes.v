/*
 * File: Utility.ExcCodes.v
 * Defines ExcCode mapping their mnemonic and their actual code.
 *  All possible codes are listed though only Int, AdEL, AdES, RI and Ov are required.
*/
`define Int 5'd0
`define Mod 5'd1
`define TLBL 5'd2
`define TLBS 5'd3
`define AdEL 5'd4
`define AdES 5'd5
`define IBE 5'd6
`define DBE 5'd7
`define Syscall 5'd8
`define Bp 5'd9
`define RI 5'd10
`define CpU 5'd11
`define Ov 5'd12
`define TRAP 5'd13
//`define Preserved 5'd14
`define FPE 5'd15
//`define Preserved 5'd16
//`define Preserved 5'd17
`define C2E 5'd18
//`define Preserved 5'd19
//`define Preserved 5'd20
//`define Preserved 5'd21
`define MDMX 5'd22
`define Watch 5'd23
`define MCheck 5'd24
`define Thread 5'd25
`define DSP 5'd26
//`define Preserved 5'd27
//`define Preserved 5'd28
//`define Preserved 5'd29
`define CacheErr 5'd30
//`define Preserved 5'd31