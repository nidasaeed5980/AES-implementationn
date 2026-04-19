module aes_top(
input clk,
input rst,
input start,
input [127:0] plaintext,
input [127:0] key,
output reg [127:0] ciphertext,
output reg done
);

reg [127:0] state;
reg [127:0] round_key;
reg [3:0] round;

// Internal wires
wire [127:0] sub_out;
wire [127:0] shift_out;
wire [127:0] mix_out;
wire [127:0] add_out;
wire [127:0] next_key;
wire [127:0] final_add;

// ===== YOUR MODULES =====

// SubBytes
subbytes SB (
    .state(state),
    .out(sub_out)
);

// ShiftRows
shiftrows SR (
    .state(sub_out),
    .out(shift_out)
);

// MixColumns (NOTE: using wrapper)
mixcolumns_wrapper MC (
    .data(shift_out),
    .out(mix_out)
);

// AddRoundKey
addroundkey ARK (
    .state(mix_out),
    .key(round_key),
    .out(add_out)
);
addroundkey FINAL_ARK (
    .state(shift_out),   // ✅ NO MixColumns
    .key(next_key),
    .out(final_add)
);

// Key Expansion
keyexpansion KE (
    .key(round_key),
    .round(round),
    .round_key(next_key)
);

// ===== CONTROL LOGIC =====

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        state <= 0;
        round_key <= 0;
        round <= 0;
        done <= 0;
        ciphertext <= 0;
    end

    else if (start)
    begin
        case (round)

        // 🔹 Round 0: Initial AddRoundKey
        0:
        begin
            state <= plaintext ^ key;
            round_key <= key;
            round <= 1;
            done <= 0;
        end

        // 🔹 Rounds 1–9
        1,2,3,4,5,6,7,8,9:
        begin
            state <= add_out;
            round_key <= next_key;
            round <= round + 1;
        end

        // 🔹 Final Round (NO MixColumns)
        10:
        begin
            // SubBytes → ShiftRows → AddRoundKey
            state <= final_add;
            ciphertext <= final_add;
            done <= 1;
            round <= 0;
        end

        endcase
    end
end

endmodule