//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe_aware_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);

    // Task:
    //
    // Implement a module formula_1_pipe_aware_fsm
    // with a Finite State Machine (FSM)
    // that drives the inputs and consumes the outputs
    // of a single pipelined module isqrt.
    //
    // The formula_1_pipe_aware_fsm module is supposed to be instantiated
    // inside the module formula_1_pipe_aware_fsm_top,
    // together with a single instance of isqrt.
    //
    // The resulting structure has to compute the formula
    // defined in the file formula_1_fn.svh.
    //
    // The formula_1_pipe_aware_fsm module
    // should NOT create any instances of isqrt module,
    // it should only use the input and output ports connecting
    // to the instance of isqrt at higher level of the instance hierarchy.
    //
    // All the datapath computations except the square root calculation,
    // should be implemented inside formula_1_pipe_aware_fsm module.
    // So this module is not a state machine only, it is a combination
    // of an FSM with a datapath for additions and the intermediate data
    // registers.
    //
    // Note that the module formula_1_pipe_aware_fsm is NOT pipelined itself.
    // It should be able to accept new arguments a, b and c
    // arriving at every N+3 clock cycles.
    //
    // In order to achieve this latency the FSM is supposed to use the fact
    // that isqrt is a pipelined module.
    //
    // For more details, see the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

    // Состояния FSM
    typedef enum logic [2:0] {
        st_idle,       
        st_send_b,     
        st_send_c,     
        st_aggr_res,        
        st_success      
    } state_t;

    state_t state, next_state;

    logic [31:0] sqrt_a, sqrt_b; 
    logic [1:0] count_res;   

    always_comb begin
        next_state = state;
        isqrt_x_vld = 1'b0;
        isqrt_x = 32'b0;
        res_vld = 1'b0;

        case (state)
            st_idle: begin
                if (arg_vld) 
                begin
                    isqrt_x = a;
                    isqrt_x_vld = 1'b1;
                    next_state = st_send_b;
                end
            end

            st_send_b: 
            begin
                isqrt_x = b;
                isqrt_x_vld = 1'b1;
                next_state = st_send_c;    
            end

            st_send_c: 
            begin
                isqrt_x = c;
                isqrt_x_vld = 1'b1;
                next_state = st_aggr_res;
            end

            st_aggr_res: 
            begin
                if (isqrt_y_vld && count_res == 2) 
                begin
                    next_state = st_success;
                end
            end

            st_success: 
            begin
                res_vld = 1'b1;
                next_state = st_idle;
            end

            default: next_state = st_idle;
        endcase
    end

    always_ff @(posedge clk) 
    begin
        if (rst) begin
            state <= st_idle;
            sqrt_a <= 0;
            sqrt_b <= 0;
            count_res <= 0;
            res <= 0;
        end 
        else begin
            state <= next_state;

            if (isqrt_y_vld) begin
                case (count_res)
                    0: sqrt_a <= {16'b0, isqrt_y};
                    1: sqrt_b <= {16'b0, isqrt_y};
                     // isqrt(a) + isqrt(b) + isqrt(c)
                    2: res <= sqrt_a + sqrt_b + {16'b0, isqrt_y};
                endcase

                count_res <= count_res + 1;
            end

            if (state == st_success) begin
                count_res <= 0;
            end
        end
    end



endmodule
