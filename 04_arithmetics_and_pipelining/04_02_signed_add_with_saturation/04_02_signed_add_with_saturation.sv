//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module add
(
  input  [3:0] a, b,
  output [3:0] sum
);

  assign sum = a + b;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module signed_add_with_saturation
(
  input  [3:0] a, b,
  output [3:0] sum
);

  // Task:
  //
  // Implement a module that adds two signed numbers with saturation.
  //
  // "Adding with saturation" means:
  //
  // When the result does not fit into 4 bits,
  // and the arguments are positive,
  // the sum should be set to the maximum positive number.
  //
  // When the result does not fit into 4 bits,
  // and the arguments are negative,
  // the sum should be set to the minimum negative number.

    logic [4:0] sum_5_bits;
    logic [3:0] satur_sum;

    assign sum_5_bits = {a[3], a} + {b[3], b};

    always_comb
    begin
        if (sum_5_bits[4] & ~sum_5_bits[3])
            satur_sum <= 4'b1000;
        else if (~sum_5_bits[4] & sum_5_bits[3])
            satur_sum <= 4'b0111;
        else
            satur_sum <= sum_5_bits[3:0];
    end

    assign sum = satur_sum;


endmodule
