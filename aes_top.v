module aes_top(
    input         clk,
    input         rst,
    input         start,
    input [127:0] plaintext,
    input [127:0] key,
    output reg [127:0] ciphertext,
    output reg    done,
    output reg [31:0] cycle_count
);

    reg [127:0] state;
    reg [3:0]   round;
    reg         busy;

    wire [1407:0] expanded_keys;
    wire [127:0]  round_key;

    wire [127:0] sub, shift, mix, add;

    keyexpansion KE (.key(key), .w_expanded(expanded_keys));

    function [127:0] get_round_key;
        input [3:0] r;
        integer base;
        reg [31:0] w0, w1, w2, w3;
        begin
            base = 4 * r;
            w0 = expanded_keys[32*base +: 32];
            w1 = expanded_keys[32*(base+1) +: 32];
            w2 = expanded_keys[32*(base+2) +: 32];
            w3 = expanded_keys[32*(base+3) +: 32];
            get_round_key = {w0, w1, w2, w3};
        end
    endfunction

    assign round_key = get_round_key(round);

    subbytes    SB (.state(state), .out(sub));
    shiftrows   SR (.state(sub),   .out(shift));
    mix_columns MC (.in(shift),    .out(mix));
    addroundkey ARK (.state(mix),  .key(round_key), .out(add));

    always @(posedge clk) begin
        if (rst) begin
            state       <= 0;
            round       <= 0;
            busy        <= 0;
            done        <= 0;
            ciphertext  <= 0;
            cycle_count <= 0;
        end else begin

            done <= 0;  // Only change added

            // START
            if (start && !busy) begin
                state <= plaintext ^ key;
                round <= 1;
                busy  <= 1;
                done  <= 0;
                cycle_count <= 0;
            end

            // MAIN ROUNDS
            else if (busy) begin

                cycle_count <= cycle_count + 1;

                if (round < 10) begin
                    state <= add;
                    round <= round + 1;
                end
                else if (round == 10) begin
                    // FINAL ROUND (NO mixcolumns)
                    ciphertext <= shift ^ get_round_key(10);
                    done       <= 1;
                    busy       <= 0;
                    round      <= 0;
                end
            end
        end
    end

endmodule
