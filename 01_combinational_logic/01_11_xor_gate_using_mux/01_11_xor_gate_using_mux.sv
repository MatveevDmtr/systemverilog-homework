//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module mux
(
  input  d0, d1,
  input  sel,
  output y
);

  assign y = sel ? d1 : d0;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module xor_gate_using_mux
(
    input  a,
    input  b,
    output o
);

  // Task:
  // Implement xor gate using instance(s) of mux,
  // constants 0 and 1, and wire connections

  logic not_a;
  logic not_b;
  logic [1:0] ands;

  mux not_a_block(
          .d0(1'b1),
          .d1(1'b0),
          .sel(a),
          .y(not_a)
  );

  mux not_b_block(
          .d0(1'b1),
          .d1(1'b0),
          .sel(b),
          .y(not_b)
  );

  mux and1(
          .d0(1'b0),
          .d1(b),
          .sel(not_a),
          .y(ands[0])
  );

  mux and2(
          .d0(1'b0),
          .d1(a),
          .sel(not_b),
          .y(ands[1])
  );

  mux or1(
          .d0(ands[1]),
          .d1(1'b1),
          .sel(ands[0]),
          .y(o)
  );


endmodule
