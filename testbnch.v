
`timescale 1ns/1ps

module aes_tb;

reg clk;
reg rst;
reg start;

reg [127:0] plaintext;
reg [127:0] key;

wire [127:0] ciphertext;
wire done;
wire [31:0] cycle_count;

integer i;
integer test_count;
integer passed;
integer failed;
integer random_completed;

aes_top DUT (
    .clk(clk),
    .rst(rst),
    .start(start),
    .plaintext(plaintext),
    .key(key),
    .ciphertext(ciphertext),
    .done(done),
    .cycle_count(cycle_count)
);

// Clock: 10 ns period
always #5 clk = ~clk;

// Waveform: dump important signals only
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, aes_tb.clk);
    $dumpvars(0, aes_tb.rst);
    $dumpvars(0, aes_tb.start);
    $dumpvars(0, aes_tb.done);
    $dumpvars(0, aes_tb.plaintext);
    $dumpvars(0, aes_tb.key);
    $dumpvars(0, aes_tb.ciphertext);
    $dumpvars(0, aes_tb.cycle_count);
end

initial begin
    clk = 0;
    rst = 1;
    start = 0;
    plaintext = 0;
    key = 0;

    test_count = 10;
    passed = 0;
    failed = 0;
    random_completed = 0;

    // Apply reset
    repeat (2) @(negedge clk);
    rst = 0;

    // =========================================
    // TEST 1: AES Known Answer Test (KAT)
    // =========================================

    plaintext = 128'h00112233445566778899aabbccddeeff;
    key       = 128'h000102030405060708090a0b0c0d0e0f;

    @(negedge clk);
    start = 1;

    @(negedge clk);
    start = 0;

    wait (done == 1'b1);

    $display("");
    $display("========================================");
    $display("TEST 1: AES KNOWN ANSWER TEST");
    $display("========================================");
    $display("PLAINTEXT          = %032h", plaintext);
    $display("KEY                = %032h", key);
    $display("ACTUAL CIPHERTEXT  = %032h", ciphertext);
    $display("EXPECTED CIPHERTEXT= 69c4e0d86a7b0430d8cdb78070b4c55a");

    if (ciphertext ===
        128'h69c4e0d86a7b0430d8cdb78070b4c55a) begin
        $display("KAT RESULT: PASS");
        passed = passed + 1;
    end
    else begin
        $display("KAT RESULT: FAIL");
        failed = failed + 1;
    end

    // Wait for DUT to become ready
    wait (done == 1'b0);
    @(negedge clk);

    // =========================================
    // TESTS 2-11: TEN RANDOM INPUT CASES
    // =========================================

    for (i = 0; i < test_count; i = i + 1) begin

        // Randomize plaintext and key
        plaintext = {$random, $random, $random, $random};
        key       = {$random, $random, $random, $random};

        // Start encryption
        @(negedge clk);
        start = 1;

        @(negedge clk);
        start = 0;

        // Wait for encryption to finish
        wait (done == 1'b1);

        $display("");
        $display("----------------------------------------");
        $display("RANDOM TEST CASE = %0d", i + 1);
        $display("PLAINTEXT        = %032h", plaintext);
        $display("KEY              = %032h", key);
        $display("CIPHERTEXT       = %032h", ciphertext);
        $display("DONE             = %b", done);
        $display("RESULT           = OUTPUT GENERATED");
        $display("NOTE: Reference comparison not performed.");
        $display("----------------------------------------");

        random_completed = random_completed + 1;

        // Wait for DUT to become ready
        wait (done == 1'b0);
        @(negedge clk);
    end

    // =========================================
    // FINAL SUMMARY
    // =========================================

    $display("");
    $display("========================================");
    $display("           FINAL TEST SUMMARY");
    $display("========================================");
    $display("KAT + RANDOM TESTS = %0d", test_count + 1);
    $display("KAT PASSED         = %0d", passed);
    $display("KAT FAILED         = %0d", failed);
    $display("RANDOM COMPLETED   = %0d", random_completed);
    $display("RANDOM VERIFIED    = 0");
    $display("========================================");

    if (failed == 0 && passed == 1 &&
        random_completed == test_count)
        $display("SIMULATION STATUS: COMPLETED");
    else
        $display("SIMULATION STATUS: CHECK FAILED TESTS");

    $finish;
end

// Safety timeout
initial begin
    #1000000;
    $display("ERROR: Simulation timeout!");
    $finish;
end

endmodule
