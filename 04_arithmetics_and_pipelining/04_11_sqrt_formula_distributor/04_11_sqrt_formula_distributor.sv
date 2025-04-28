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

    // localparam N1 = 13;
    // localparam N2 = 11;
    // localparam WIDTH = 32;
    
    // logic [WIDTH-1:0] input_a   [N1];
    // logic [WIDTH-1:0] input_b   [N1];
    // logic [WIDTH-1:0] input_c   [N1];
    // logic             input_vld [N1];

    // logic [WIDTH-1:0] curr_res [N1];
    // logic             curr_vld [N1];

    // logic [7:0] idx;

    // always_ff @ (posedge clk) 
    // begin
    //     if (rst) begin
    //         idx <= '0;
    //     end

    //     if(idx ==  N1 - 1)
    //         idx <= 0;
    //     else
    //         idx++;
    // end
    
    // always_comb 
    // begin
    //     for (int i = 0; i < N1; i++)
    //         input_vld[i] = '0; 

    //     input_vld[idx] = arg_vld; 
    //     input_a  [idx] = a;
    //     input_b  [idx] = b;
    //     input_c  [idx] = c;  

    //     res = curr_res[idx];
    //     res_vld = curr_vld[idx];
    // end


    // generate
    //     genvar i;
    //     if (formula == 1)
    //     begin
    //         for (i = 0; i < N1; i++)
    //             formula_1_impl_1_top f1(
    //                 .clk(clk),
    //                 .rst(rst),
    //                 .a(input_a[i]),
    //                 .b(input_b[i]),
    //                 .c(input_c[i]),
    //                 .arg_vld(input_vld[i]),
    //                 .res_vld(curr_vld[i]),
    //                 .res(curr_res[i]));
    //     end

    //     else if (formula == 2)
    //     begin
    //         for (i = 0; i < N2; i++)
    //             formula_2_top f2(
    //                 .clk(clk),
    //                 .rst(rst),
    //                 .a(input_a[i]),
    //                 .b(input_b[i]),
    //                 .c(input_c[i]),
    //                 .arg_vld(input_vld[i]),
    //                 .res_vld(curr_vld[i]),
    //                 .res(curr_res[i]));
    //     end
    // endgenerate

    localparam N = 5;
    parameter LATENCY = 50;

    logic [N-1:0] busy;
    logic [N-1:0] vld_in;
    logic [N-1:0] res_vld_arr;
    logic [31:0]  res_arr [N-1:0];
    logic [$clog2(LATENCY+1)-1:0] counters [N-1:0];

    logic [$clog2(N)-1:0] dispatcher;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            dispatcher <= 0;
            vld_in     <= '0;
        end else begin
            vld_in <= '0;
            if (arg_vld) begin
                for (int i = 0; i < N; i++) begin
                    if (!busy[dispatcher]) begin
                        vld_in[dispatcher]   <= 1;
                        busy[dispatcher]     <= 1;
                        counters[dispatcher] <= 1;
                        dispatcher <= (dispatcher + 1) % N;
                        break;
                    end else begin
                        dispatcher <= (dispatcher + 1) % N;
                    end
                end
            end
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < N; i++) begin
                counters[i] <= 0;
            end
        end else begin
            for (int i = 0; i < N; i++) begin
                if (busy[i] && counters[i] < LATENCY)
                    counters[i] <= counters[i] + 1;
            end
        end
    end

    genvar i;
    generate
        for (i = 0; i < N; i++) begin : compute_units
            if (formula == 1 && impl == 1) begin
                formula_1_impl_1_top u_f1_i1 (
                    .clk(clk),
                    .rst(rst),
                    .arg_vld(vld_in[i]),
                    .a(a),
                    .b(b),
                    .c(c),
                    .res_vld(res_vld_arr[i]),
                    .res(res_arr[i])
                );
            end else if (formula == 1 && impl == 2) begin
                formula_1_impl_2_top u_f1_i2 (
                    .clk(clk),
                    .rst(rst),
                    .arg_vld(vld_in[i]),
                    .a(a),
                    .b(b),
                    .c(c),
                    .res_vld(res_vld_arr[i]),
                    .res(res_arr[i])
                );
            end else begin
                formula_2_top u_f2 (
                    .clk(clk),
                    .rst(rst),
                    .arg_vld(vld_in[i]),
                    .a(a),
                    .b(b),
                    .c(c),
                    .res_vld(res_vld_arr[i]),
                    .res(res_arr[i])
                );
            end

            always_ff @(posedge clk or posedge rst) begin
                if (rst) begin
                    busy[i]     <= 0;
                    counters[i] <= 0;
                end else if (res_vld_arr[i]) begin
                    busy[i]     <= 0;
                    counters[i] <= 0;
                end
            end
        end
    endgenerate

    assign res_vld = | res_vld_arr;
    assign res = (res_vld_arr[0] && counters[0] == LATENCY) ? res_arr[0] :
                (res_vld_arr[1] && counters[1] == LATENCY) ? res_arr[1] :
                (res_vld_arr[2] && counters[2] == LATENCY) ? res_arr[2] :
                (res_vld_arr[3] && counters[3] == LATENCY) ? res_arr[3] :
                (res_vld_arr[4] && counters[4] == LATENCY) ? res_arr[4] : 32'b0;


endmodule
