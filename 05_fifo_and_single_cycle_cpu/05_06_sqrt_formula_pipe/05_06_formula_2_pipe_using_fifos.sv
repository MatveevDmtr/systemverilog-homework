//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe_using_fifos
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output        res_vld,
    output [31:0] res
);
    // Task:
    //
    // Implement a pipelined module formula_2_pipe_using_fifos that computes the result
    // of the formula defined in the file formula_2_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_2_pipe has to be pipelined.
    //
    // It should be able to accept a new set of arguments a, b and c
    // arriving at every clock cycle.
    //
    // It also should be able to produce a new result every clock cycle
    // with a fixed latency after accepting the arguments.
    //
    // 2. Your solution should instantiate exactly 3 instances
    // of a pipelined isqrt module, which computes the integer square root.
    //
    // 3. Your solution should use FIFOs instead of shift registers
    // which were used in 04_10_formula_2_pipe.sv.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

    wire         isqrt_c_y_vld;
    wire [15:0]  isqrt_c_y;

    isqrt isqrt_c (
        .clk    ( clk ),
        .rst    ( rst ),
        .x_vld  ( arg_vld ),
        .x      ( c ),
        .y_vld  ( isqrt_c_y_vld ),
        .y      ( isqrt_c_y )
    );


    wire         fifo_b_pop;
    wire [31:0]  fifo_b_read_data;

    flip_flop_fifo_with_counter
    # (.width (32), .depth (16))
    fifo_b
    (
        .clk        ( clk ),
        .rst        ( rst ),
        .push       ( arg_vld ),
        .pop        ( fifo_b_pop ),
        .write_data ( b ),
        .read_data  ( fifo_b_read_data ),
        .empty      ( ),
        .full       ( )
    );

    assign fifo_b_pop = isqrt_c_y_vld;

    wire [31:0]  isqrt_b_c_x;
    wire         isqrt_b_c_y_vld;
    wire [15:0]  isqrt_b_c_y;

    assign isqrt_b_c_x     = fifo_b_read_data + {16'b0, isqrt_c_y};

    isqrt isqrt_b_c (
        .clk    ( clk ),
        .rst    ( rst ),
        .x_vld  ( isqrt_c_y_vld ),
        .x      ( isqrt_b_c_x ),
        .y_vld  ( isqrt_b_c_y_vld ),
        .y      ( isqrt_b_c_y )
    );


    wire         fifo_a_pop;
    wire [31:0]  fifo_a_read_data;

    flip_flop_fifo_with_counter
    # (.width (32), .depth (32))
    fifo_a
    (
        .clk        ( clk ),
        .rst        ( rst ),
        .push       ( arg_vld ),
        .pop        ( fifo_a_pop ),
        .write_data ( a ),
        .read_data  ( fifo_a_read_data ),
        .empty      ( ),
        .full       ( )
    );

    assign fifo_a_pop = isqrt_b_c_y_vld;

    wire [31:0]  isqrt_a_b_c_x;
    wire         isqrt_a_b_c_y_vld;
    wire [15:0]  isqrt_a_b_c_y;

    assign isqrt_a_b_c_x = fifo_a_read_data + {16'b0, isqrt_b_c_y};

    isqrt isqrt_a_b_c (
        .clk    ( clk ),
        .rst    ( rst ),
        .x_vld  ( isqrt_b_c_y_vld ),
        .x      ( isqrt_a_b_c_x ),
        .y_vld  ( isqrt_a_b_c_y_vld ),
        .y      ( isqrt_a_b_c_y )
    );

    assign res_vld = isqrt_a_b_c_y_vld;
    assign res     = {16'b0, isqrt_a_b_c_y};


endmodule
