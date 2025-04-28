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

    localparam N = 50;  // Идеализированный дистрибьютор

    logic [FLEN-1:0] in_a   [N];
    logic [FLEN-1:0] in_b   [N];
    logic [FLEN-1:0] in_c   [N];
    logic            in_vld [N];
    logic [N-1:0]    instance_busy;

    logic [FLEN-1:0] out_res         [N];
    logic            out_vld         [N];
    logic            out_res_negative[N];
    logic            out_err         [N];

    logic [$clog2(N)-1:0] cnt;

    always_ff @(posedge clk) 
    begin
        if (rst) 
        begin
            cnt <= '0;
        end 
        else if (arg_vld) 
        begin
            for (int i = 0; i < N; i++) 
            begin
                logic [$clog2(N)-1:0] next_cnt = (cnt + i) % N;
                if (!instance_busy[next_cnt]) 
                begin
                    cnt <= next_cnt;
                    break;
                end
            end
        end
    end

    always_comb 
    begin
        for (int i = 0; i < N; i++) 
        begin
            in_vld[i] = '0;
            in_a[i]   = '0;
            in_b[i]   = '0;
            in_c[i]   = '0;
        end

        if (arg_vld && !instance_busy[cnt]) 
        begin
            in_a[cnt]   = a;
            in_b[cnt]   = b;
            in_c[cnt]   = c;
            in_vld[cnt] = arg_vld;
        end
    end

    always_comb 
    begin
        res_vld      = out_vld[cnt];
        res          = out_res[cnt];
        res_negative = out_res_negative[cnt];
        err          = out_err[cnt];
        busy         = instance_busy[cnt];
    end

    generate
        genvar i;
        for (i = 0; i < N; i++) 
        begin : gen_discriminants
            float_discriminant inst (
                .clk(clk),
                .rst(rst),
                .arg_vld(in_vld[i]),
                .a(in_a[i]),
                .b(in_b[i]),
                .c(in_c[i]),
                .res_vld(out_vld[i]),
                .res(out_res[i]),
                .res_negative(out_res_negative[i]),
                .err(out_err[i]),
                .busy(instance_busy[i])
            );
        end
    endgenerate


endmodule
