// New file
module mix_columns (
    input  [127:0] in,
    output [127:0] out
);

// ===== GF(2^8) functions =====
function [7:0] xtime(input [7:0] b);
begin
    xtime = {b[6:0],1'b0} ^ (8'h1b & {8{b[7]}});
end
endfunction

function [7:0] mul2(input [7:0] b);
begin
    mul2 = xtime(b);
end
endfunction

function [7:0] mul3(input [7:0] b);
begin
    mul3 = xtime(b) ^ b;
end
endfunction

// ===== Extract bytes =====
wire [7:0] s [0:15];

assign s[0]  = in[127:120];
assign s[1]  = in[119:112];
assign s[2]  = in[111:104];
assign s[3]  = in[103:96];

assign s[4]  = in[95:88];
assign s[5]  = in[87:80];
assign s[6]  = in[79:72];
assign s[7]  = in[71:64];

assign s[8]  = in[63:56];
assign s[9]  = in[55:48];
assign s[10] = in[47:40];
assign s[11] = in[39:32];

assign s[12] = in[31:24];
assign s[13] = in[23:16];
assign s[14] = in[15:8];
assign s[15] = in[7:0];

// ===== MixColumns (COLUMN-WISE) =====
wire [7:0] m [0:15];

// Column 0
assign m[0]  = mul2(s[0]) ^ mul3(s[1]) ^ s[2] ^ s[3];
assign m[1]  = s[0] ^ mul2(s[1]) ^ mul3(s[2]) ^ s[3];
assign m[2]  = s[0] ^ s[1] ^ mul2(s[2]) ^ mul3(s[3]);
assign m[3]  = mul3(s[0]) ^ s[1] ^ s[2] ^ mul2(s[3]);

// Column 1
assign m[4]  = mul2(s[4]) ^ mul3(s[5]) ^ s[6] ^ s[7];
assign m[5]  = s[4] ^ mul2(s[5]) ^ mul3(s[6]) ^ s[7];
assign m[6]  = s[4] ^ s[5] ^ mul2(s[6]) ^ mul3(s[7]);
assign m[7]  = mul3(s[4]) ^ s[5] ^ s[6] ^ mul2(s[7]);

// Column 2
assign m[8]  = mul2(s[8]) ^ mul3(s[9]) ^ s[10] ^ s[11];
assign m[9]  = s[8] ^ mul2(s[9]) ^ mul3(s[10]) ^ s[11];
assign m[10] = s[8] ^ s[9] ^ mul2(s[10]) ^ mul3(s[11]);
assign m[11] = mul3(s[8]) ^ s[9] ^ s[10] ^ mul2(s[11]);

// Column 3
assign m[12] = mul2(s[12]) ^ mul3(s[13]) ^ s[14] ^ s[15];
assign m[13] = s[12] ^ mul2(s[13]) ^ mul3(s[14]) ^ s[15];
assign m[14] = s[12] ^ s[13] ^ mul2(s[14]) ^ mul3(s[15]);
assign m[15] = mul3(s[12]) ^ s[13] ^ s[14] ^ mul2(s[15]);

// ===== Output =====
assign out = {
    m[0], m[1], m[2], m[3],
    m[4], m[5], m[6], m[7],
    m[8], m[9], m[10], m[11],
    m[12], m[13], m[14], m[15]
};

endmodule
