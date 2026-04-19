module shiftrows(
input [127:0] state,
output [127:0] out
);

// mapping manually (column-major AES format)

assign out[127:120] = state[127:120]; // b0
assign out[119:112] = state[87:80];   // b5
assign out[111:104] = state[47:40];   // b10
assign out[103:96]  = state[7:0];     // b15

assign out[95:88]   = state[95:88];   // b4
assign out[87:80]   = state[55:48];   // b9
assign out[79:72]   = state[15:8];    // b14
assign out[71:64]   = state[103:96];  // b3

assign out[63:56]   = state[63:56];   // b8
assign out[55:48]   = state[23:16];   // b13
assign out[47:40]   = state[111:104]; // b2
assign out[39:32]   = state[71:64];   // b7

assign out[31:24]   = state[31:24];   // b12
assign out[23:16]   = state[119:112]; // b1
assign out[15:8]    = state[79:72];   // b6
assign out[7:0]     = state[39:32];   // b11

endmodule// New file
