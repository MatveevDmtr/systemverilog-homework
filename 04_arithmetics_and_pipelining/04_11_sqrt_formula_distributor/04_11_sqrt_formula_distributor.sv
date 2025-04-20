module sqrt_formula_distributor
# (
    parameter formula = 1,
              impl    = 1
)
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output logic        res_vld,
    output logic [31:0] res
);
    // Task:
    //
    // Implement a module that will calculate formula 1 or formula 2
    // based on the parameter values. The module must be pipelined.
    // It should be able to accept new triple of arguments a, b, c arriving
    // at every clock cycle.
    //
    // The idea of the task is to implement hardware task distributor,
    // that will accept triplet of the arguments and assign the task
    // of the calculation formula 1 or formula 2 with these arguments
    // to the free FSM-based internal module.
    //
    // The first step to solve the task is to fill 03_04 and 03_05 files.
    //
    // Note 1:
    // Latency of the module "formula_1_isqrt" should be clarified from the corresponding waveform
    // or simply assumed to be equal 50 clock cycles.
    //
    // Note 2:
    // The task assumes idealized distributor (with 50 internal computational blocks),
    // because in practice engineers rarely use more than 10 modules at ones.
    // Usually people use 3-5 blocks and utilize stall in case of high load.
    //
    // Hint:
    // Instantiate sufficient number of "formula_1_impl_1_top", "formula_1_impl_2_top",
    // or "formula_2_top" modules to achieve desired performance.

    localparam N = 13;
    localparam WIDTH = 32;
    
    logic [WIDTH-1:0] input_a   [N];
    logic [WIDTH-1:0] input_b   [N];
    logic [WIDTH-1:0] input_c   [N];
    logic             input_vld [N];

    logic [WIDTH-1:0] curr_res [N];
    logic             curr_vld [N];

    logic [7:0] idx;

    always_ff @ (posedge clk) 
    begin
        if (rst) begin
            idx <= '0;
        end

        if(idx ==  N - 1)
            idx <= 0;
        else
            idx++;
    end
    
    always_comb 
    begin
        for (int i = 0; i < N; i++)
            input_vld[i] = '0; 

        input_vld[idx] = arg_vld; 
        input_a  [idx] = a;
        input_b  [idx] = b;
        input_c  [idx] = c;  

        res = curr_res[idx];
        res_vld = curr_vld[idx];
    end


    generate
        genvar i;
        if (formula == 1)
            for (i = 0; i < N; i++)
                formula_1_impl_1_top f1(
                    .clk(clk),
                    .rst(rst),
                    .a(input_a[i]),
                    .b(input_b[i]),
                    .c(input_c[i]),
                    .arg_vld(input_vld[i]),
                    .res_vld(curr_vld[i]),
                    .res(curr_res[i]));

        else if (formula == 2)
            for (i = 0; i < N; i++)
                formula_2_top f2(
                    .clk(clk),
                    .rst(rst),
                    .a(input_a[i]),
                    .b(input_b[i]),
                    .c(input_c[i]),
                    .arg_vld(input_vld[i]),
                    .res_vld(curr_vld[i]),
                    .res(curr_res[i]));

    endgenerate



endmodule
