`timescale 1ns/1ps

module aes_tb;

reg clk;
reg rst;
reg start;

reg [127:0] plaintext;
reg [127:0] key;

wire [127:0] ciphertext;
wire done;

// DUT
aes_top DUT (
    .clk(clk),
    .rst(rst),
    .start(start),
    .plaintext(plaintext),
    .key(key),
    .ciphertext(ciphertext),
    .done(done)
);

// Clock
always #5 clk = ~clk;

initial begin

    // init
    clk = 0;
    rst = 1;
    start = 0;

    plaintext = 128'h00112233445566778899aabbccddeeff;
    key       = 128'h000102030405060708090a0b0c0d0e0f;

    // reset
    #20 rst = 0;

    // start aligned with clock
    @(posedge clk);
    start = 1;

    @(posedge clk);
    start = 0;

    // DEBUG MONITOR (VERY IMPORTANT)
    $monitor("time=%0t | start=%b | done=%b | ciphertext=%h", 
             $time, start, done, ciphertext);

    // safety timeout (prevents hang)
    #2000;

    $display("================================");
    $display("FINAL CIPHERTEXT = %h", ciphertext);
    $display("DONE = %b", done);
    $display("================================");

    $stop;

end

endmodule