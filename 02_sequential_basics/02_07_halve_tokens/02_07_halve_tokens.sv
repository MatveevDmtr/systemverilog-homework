//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module halve_tokens
(
    input  clk,
    input  rst,
    input  a,
    output logic b
);
    // Task:
    // Implement a serial module that reduces amount of incoming '1' tokens by half.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 110_011_101_000_1111
    // b -> 010_001_001_000_0101

    logic prev_one;

    always_ff @ (posedge clk)
        if (rst)
        begin
            prev_one <= '0;
            b <= '0;
        end
        else
        begin
            if (a)
            begin
                prev_one <= (~ prev_one & a);
                b <= prev_one;
            end
            else
                b <= '0;
        end

endmodule
