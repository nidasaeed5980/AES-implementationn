module shiftrows(
    input [127:0] state,
    output [127:0] out
);
    // Column‑major ordering:
    // Row0 (bytes at positions 0,4,8,12) – no shift
    // Row1 (bytes at positions 1,5,9,13) – left rotate by 1 byte
    // Row2 (bytes at positions 2,6,10,14) – left rotate by 2 bytes
    // Row3 (bytes at positions 3,7,11,15) – left rotate by 3 bytes

    // Extract bytes in column‑major order
    wire [7:0] s [0:15];
    assign s[0]  = state[127:120];  // row0col0
    assign s[1]  = state[119:112];  // row1col0
    assign s[2]  = state[111:104];  // row2col0
    assign s[3]  = state[103:96];   // row3col0
    assign s[4]  = state[95:88];    // row0col1
    assign s[5]  = state[87:80];    // row1col1
    assign s[6]  = state[79:72];    // row2col1
    assign s[7]  = state[71:64];    // row3col1
    assign s[8]  = state[63:56];    // row0col2
    assign s[9]  = state[55:48];    // row1col2
    assign s[10] = state[47:40];    // row2col2
    assign s[11] = state[39:32];    // row3col2
    assign s[12] = state[31:24];    // row0col3
    assign s[13] = state[23:16];    // row1col3
    assign s[14] = state[15:8];     // row2col3
    assign s[15] = state[7:0];      // row3col3

    // Apply row shifts
    wire [7:0] t [0:15];
    // Row0 (indices 0,4,8,12) – unchanged
    assign t[0]  = s[0];
    assign t[4]  = s[4];
    assign t[8]  = s[8];
    assign t[12] = s[12];
    // Row1 (indices 1,5,9,13) – left rotate by 1 -> 5,9,13,1
    assign t[1]  = s[5];
    assign t[5]  = s[9];
    assign t[9]  = s[13];
    assign t[13] = s[1];
    // Row2 (indices 2,6,10,14) – left rotate by 2 -> 10,14,2,6
    assign t[2]  = s[10];
    assign t[6]  = s[14];
    assign t[10] = s[2];
    assign t[14] = s[6];
    // Row3 (indices 3,7,11,15) – left rotate by 3 -> 15,3,7,11
    assign t[3]  = s[15];
    assign t[7]  = s[3];
    assign t[11] = s[7];
    assign t[15] = s[11];

    // Pack back into 128-bit vector (column‑major)
    assign out = { t[0], t[1], t[2], t[3], t[4], t[5], t[6], t[7],
                   t[8], t[9], t[10], t[11], t[12], t[13], t[14], t[15] };
endmodule
