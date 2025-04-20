//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe
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
    // Implement a pipelined module formula_2_pipe that computes the result
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
    // 3. Your solution should save dynamic power by properly connecting
    // the valid bits.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

    logic        sqrt1_vld;
    logic [15:0] sqrt1_res;
    logic        sqrt2_vld;
    logic [15:0] sqrt2_res;

    logic [31:0] delay_a [8];
    logic [31:0] delay_b [4];

    always_ff @(posedge clk) begin
        if (rst) 
        begin
            for (int i = 0; i < 8; i++)
                delay_a[i] <= '0;
            for (int i = 0; i < 4; i++)
                delay_b[i] <= '0;
        end 
        else 
        begin
            if (arg_vld)
            begin
                delay_a[0] <= a;
                delay_b[0] <= b;
            end

            for (int i = 1; i < 8; i++)
                delay_a[i] <= delay_a[i-1];

            for (int i = 1; i < 4; i++)
                delay_b[i] <= delay_b[i-1];
        end
    end

    localparam N_PIPE_STAGES = 4;

    isqrt #(.n_pipe_stages(N_PIPE_STAGES)) sqrt_first (
        .clk(clk),
        .rst(rst),
        .x_vld(arg_vld),
        .x(c),
        .y_vld(sqrt1_vld),
        .y(sqrt1_res)
    );

    isqrt #(.n_pipe_stages(N_PIPE_STAGES)) sqrt_second (
        .clk(clk),
        .rst(rst),
        .x_vld(sqrt1_vld),
        .x(delay_b[3] + {16'b0, sqrt1_res}),
        .y_vld(sqrt2_vld),
        .y(sqrt2_res)
    );

    isqrt #(.n_pipe_stages(N_PIPE_STAGES)) sqrt_final (
        .clk(clk),
        .rst(rst),
        .x_vld(sqrt2_vld),
        .x(delay_a[7] + {16'b0, sqrt2_res}),
        .y_vld(res_vld),
        .y(res[15:0])
    );

    assign res[31:16] = '0;




endmodule
