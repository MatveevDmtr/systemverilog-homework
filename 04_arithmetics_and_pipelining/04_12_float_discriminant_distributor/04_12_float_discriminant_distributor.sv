module float_discriminant_distributor (
    input                           clk,
    input                           rst,

    input                           arg_vld,
    input        [FLEN - 1:0]       a,
    input        [FLEN - 1:0]       b,
    input        [FLEN - 1:0]       c,

    output logic                    res_vld,
    output logic [FLEN - 1:0]       res,
    output logic                    res_negative,
    output logic                    err,

    output logic                    busy
);

    // Task:
    //
    // Implement a module that will calculate the discriminant based
    // on the triplet of input number a, b, c. The module must be pipelined.
    // It should be able to accept a new triple of arguments on each clock cycle
    // and also, after some time, provide the result on each clock cycle.
    // The idea of the task is similar to the task 04_11. The main difference is
    // in the underlying module 03_08 instead of formula modules.
    //
    // Note 1:
    // Reuse your file "03_08_float_discriminant.sv" from the Homework 03.
    //
    // Note 2:
    // Latency of the module "float_discriminant" should be clarified from the waveform.

    localparam N = 11;
    localparam WIDTH = 32;
    
    logic [WIDTH-1:0] input_a   [N];
    logic [WIDTH-1:0] input_b   [N];
    logic [WIDTH-1:0] input_c   [N];
    logic             input_vld [N];

    logic [WIDTH-1:0] curr_res     [N];
    logic             curr_vld     [N];
    logic             curr_res_neg [N];
    logic             curr_err     [N];
    logic             curr_busy    [N];

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
        for (i = 0; i < N; i++)
            float_discriminant disc (
                .clk(clk),
                .rst(rst),

                .arg_vld(input_vld[i]),
                .a(input_a[i]),
                .b(input_b[i]),
                .c(input_c[i]),
                
                .res_vld(curr_vld[i]),
                .res    (curr_res[i]),
                .res_negative(curr_res_neg[i]),
                .err    (curr_err[i]),
                
                .busy(curr_busy[i]));
    endgenerate

endmodule
