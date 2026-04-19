module keyexpansion(
input  [127:0] key,
input  [3:0] round,
output [127:0] round_key
);

// Split into words
wire [31:0] w0, w1, w2, w3;

assign w0 = key[127:96];
assign w1 = key[95:64];
assign w2 = key[63:32];
assign w3 = key[31:0];

// Step 1: RotWord
wire [31:0] rot;
rotword RW(.in(w3), .out(rot));

// Step 2: SubWord
wire [31:0] sub;
subword SW(.in(rot), .out(sub));

// Step 3: Rcon
wire [31:0] rcon_val;
rcon RC(.round(round), .rcon_out(rcon_val));

// g(w3)
wire [31:0] g;
assign g = sub ^ rcon_val;

// Generate new words
wire [31:0] w4, w5, w6, w7;

assign w4 = w0 ^ g;
assign w5 = w1 ^ w4;
assign w6 = w2 ^ w5;
assign w7 = w3 ^ w6;

// Output new round key
assign round_key = {w4, w5, w6, w7};

endmodule// New file
