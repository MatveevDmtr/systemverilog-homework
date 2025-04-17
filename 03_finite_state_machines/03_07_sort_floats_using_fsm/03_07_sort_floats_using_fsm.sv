//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module sort_floats_using_fsm (
    input                          clk,
    input                          rst,

    input                          valid_in,
    input        [0:2][FLEN - 1:0] unsorted,

    output logic                   valid_out,
    output logic [0:2][FLEN - 1:0] sorted,
    output logic                   err,
    output                         busy,

    // f_less_or_equal interface
    output logic      [FLEN - 1:0] f_le_a,
    output logic      [FLEN - 1:0] f_le_b,
    input                          f_le_res,
    input                          f_le_err
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs them in the increasing order using FSM.
    //
    // Requirements:
    // The solution must have latency equal to the three clock cycles.
    // The solution should use the inputs and outputs to the single "f_less_or_equal" module.
    // The solution should NOT create instances of any modules.
    //
    // Notes:
    // res0 must be less or equal to the res1
    // res1 must be less or equal to the res1
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

    typedef enum logic [2:0] {
        st_idle    = 3'd0,
        st_comp1   = 3'd1,
        st_comp2   = 3'd2,
        st_comp3   = 3'd3,
        st_success = 3'd4
    } state_t;

    state_t state, next_state;
    logic [0:2][FLEN - 1:0] temp, next_temp;
    logic next_err, next_valid_out;


    assign busy = (state != st_idle) && (state != st_success);

    always_comb
    begin
        next_state = state;
        next_temp = temp;
        next_err = err;
        next_valid_out = 1'b0;
        f_le_a = '0;
        f_le_b = '0;

        case (state)
        st_idle:
        begin
            if (valid_in)
            begin
                next_state = st_comp1;
                next_temp = unsorted;
                next_err = 1'b0;
            end
        end

        st_comp1:
        begin
            next_state = st_comp2;
            next_err = err | f_le_err;
            {f_le_a, f_le_b} = {temp[0], temp[1]};
            if (~f_le_res) 
                {next_temp[0], next_temp[1]} = {temp[1], temp[0]};
        end

        st_comp2:
        begin
            next_state = st_comp3;
            next_err = err | f_le_err;
            {f_le_a, f_le_b} = {temp[1], temp[2]};
            if (~f_le_res) 
                {next_temp[1], next_temp[2]} = {temp[2], temp[1]};
        end

        st_comp3: 
        begin
            next_state = st_success;
            next_err = err | f_le_err;
            {f_le_a, f_le_b} = {temp[0], temp[1]};
            if (~f_le_res) 
                {next_temp[0], next_temp[1]} = {temp[1], temp[0]};
        end

        st_success:
        begin
            next_valid_out = 1'b1;
            next_state = st_idle;
        end

        default:
        begin
            next_state = st_idle;
        end
        endcase
    end

    always_ff @(posedge clk)
    begin
        if (rst)
        begin
            state     <= st_idle;
            temp      <= '0;
            sorted    <= '0;
            err       <= '0;
            valid_out <= '0;
        end
        else
        begin
            state     <= next_state;
            temp      <= next_temp;
            sorted    <= temp;
            err       <= next_err;
            valid_out <= next_valid_out;
        end
    end

endmodule
