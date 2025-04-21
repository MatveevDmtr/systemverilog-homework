//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module float_discriminant (
    input                     clk,
    input                     rst,

    input                     arg_vld,
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,
    input        [FLEN - 1:0] c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,

    output logic              busy
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and st_successs their discriminant.
    // The resulting value res should be calculated as a discriminant of the quadratic polynomial.
    // That is, res = b^2 - 4ac == b*b - 4*a*c
    //
    // Note:
    // If any argument is not a valid number, that is NaN or Inf, the "err" flag should be set.
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

    enum logic [3:0]
    {
        st_idle          = 4'd0,
        st_send_b2       = 4'd1,
        st_wait_b2_res   = 4'd2,
        st_send_ac       = 4'd3,
        st_wait_ac_res   = 4'd4,
        st_send_4ac      = 4'd5,
        st_wait_4ac_res  = 4'd6,
        st_send_disc     = 4'd7,
        st_wait_disc_res = 4'd8,
        st_success       = 4'd9
    }
    state, next_state;

    logic [FLEN-1:0] b2, ac, four_ac;
    logic [FLEN-1:0] four;
    logic [FLEN-1:0] inp_mult_a, inp_mult_b;
    logic [FLEN-1:0] inp_sub_a, inp_sub_b;
    logic            mult_up_valid, mult_down_valid, mult_busy, mult_err;
    logic            sub_up_valid,  sub_down_valid,  sub_busy,  sub_err;
    logic [FLEN-1:0] mult_res, sub_res;

    assign four = 64'h4010000000000000;

    f_mult u_mult (
        .clk(clk), .rst(rst),
        .a(inp_mult_a), .b(inp_mult_b), .up_valid(mult_up_valid),
        .res(mult_res), .down_valid(mult_down_valid),
        .busy(mult_busy), .error(mult_err)
    );

    f_sub u_sub (
        .clk(clk), .rst(rst),
        .a(inp_sub_a), .b(inp_sub_b), .up_valid(sub_up_valid),
        .res(sub_res), .down_valid(sub_down_valid),
        .busy(sub_busy), .error(sub_err)
    );

    always_comb
    begin
        next_state = state;

        res_vld       = '0;
        mult_up_valid = '0;
        sub_up_valid  = '0;
        inp_mult_a    = '0;
        inp_mult_b    = '0;
        inp_sub_a     = '0;
        inp_sub_b     = '0;



        case (state)
            st_idle:
                if (arg_vld)
                    next_state = st_send_b2;

            st_send_b2:
            begin
                mult_up_valid = 1;
                inp_mult_a = b;
                inp_mult_b = b;
                next_state = st_wait_b2_res;
            end

            st_wait_b2_res:
                if (mult_down_valid)
                begin
                    b2 = mult_res;
                    next_state = st_send_ac;
                end

            st_send_ac:
            begin
                mult_up_valid = 1;
                inp_mult_a = a;
                inp_mult_b = c;
                next_state = st_wait_ac_res;
            end

            st_wait_ac_res:
                if (mult_down_valid)
                begin
                    ac = mult_res;
                    next_state = st_send_4ac;
                end

            st_send_4ac:
            begin
                mult_up_valid = 1;
                inp_mult_a = four;
                inp_mult_b = ac;
                next_state = st_wait_4ac_res;
            end

            st_wait_4ac_res:
                if (mult_down_valid)
                begin
                    four_ac = mult_res;
                    next_state = st_send_disc;
                end

            st_send_disc:
            begin
                sub_up_valid = 1;
                inp_sub_a = b2;
                inp_sub_b = four_ac;
                next_state = st_wait_disc_res;
            end

            st_wait_disc_res:
                if (sub_down_valid)
                begin
                    res = sub_res;
                    next_state = st_success;
                end

            st_success:
            begin
                res_vld = 1;
                next_state = st_idle;
            end
        endcase


    end

    //------------------------------------------------------------------------
    // Assigning next state

    always_ff @ (posedge clk)
        if (rst)
            state <= st_idle;
        else
            state <= next_state;

    //------------------------------------------------------------------------
    // Accumulating the result

    always_ff @ (posedge clk)
        if (rst)
        begin
            res_vld <= '0;
        end
        else
        begin
            res_vld      <= (state == st_wait_disc_res & sub_down_valid);
            busy         <= (state != st_idle | mult_busy | sub_busy);
            err          <= mult_err | sub_err;
            res_negative <= res[FLEN-1];
        end

endmodule
