`timescale 1ns / 1ps
module comparer(A, B, signed_comp, ne, lt, le, eq, ge, gt, t);
input[31:0] A;
input[31:0] B;
input signed_comp;
output ne;
output lt;
output le;
output eq;
output ge;
output gt;
output t;
assign ne = !eq;
assign le = lt | eq;
assign ge = gt | eq;
assign eq = (A === B);
assign lt = (signed_comp) ? ($signed(A) < $signed(B)) : (A < B);
assign gt = (signed_comp) ? ($signed(A) > $signed(B)) : (A > B);
assign t = 1;
endmodule
