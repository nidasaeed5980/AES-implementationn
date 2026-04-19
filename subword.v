module subword(
input  [31:0] in,
output [31:0] out
);

wire [7:0] b0, b1, b2, b3;

// SAME sbox module use ho raha hai
sbox s0(.in(in[31:24]), .out(b0));
sbox s1(.in(in[23:16]), .out(b1));
sbox s2(.in(in[15:8]),  .out(b2));
sbox s3(.in(in[7:0]),   .out(b3));

assign out = {b0, b1, b2, b3};

endmodule// New file
