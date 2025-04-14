//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module mux_2_1
(
  input        [3:0] d0, d1,
  input              sel,
  output logic [3:0] y
);

  always_comb
    case (sel)
      1'd0: y = d0;
      1'd1: y = d1;
    endcase

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module mux_4_1
(
  input        [3:0] d0, d1, d2, d3,
  input        [1:0] sel,
  output logic [3:0] y
);

  always_comb begin : combBlock
    case (sel)
      2'd3: y = d3;
      2'd2: y = d2;
      2'd1: y = d1;
      2'd0: y = d0;
    endcase
  end


endmodule
