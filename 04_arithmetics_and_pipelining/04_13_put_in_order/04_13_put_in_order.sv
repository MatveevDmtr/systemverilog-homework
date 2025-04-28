module put_in_order
# (
    parameter width    = 16,
              n_inputs = 4
)
(
    input                       clk,
    input                       rst,

    input  [ n_inputs - 1 : 0 ] up_vlds,
    input  [ n_inputs - 1 : 0 ]
           [ width    - 1 : 0 ] up_data,

    output                      down_vld,
    output [ width   - 1 : 0 ]  down_data
);

    // Task:
    //
    // Implement a module that accepts many outputs of the computational blocks
    // and outputs them one by one in order. Input signals "up_vlds" and "up_data"
    // are coming from an array of non-pipelined computational blocks.
    // These external computational blocks have a variable latency.
    //
    // The order of incoming "up_vlds" is not determent, and the task is to
    // output "down_vld" and corresponding data in a round-robin manner,
    // one after another, in order.
    //
    // Comment:
    // The idea of the block is kinda similar to the "parallel_to_serial" block
    // from Homework 2, but here block should also preserve the output order.

    logic[width-1:0]            data_a[n_inputs-1:0];
    logic[width-1:0]            data_b[n_inputs-1:0];
    logic[n_inputs-1:0]         vld_a, vld_b;
    logic[n_inputs-1:0]         vld_next_a;
    
    logic[$clog2(n_inputs)-1:0] cnt;
    assign vld_next_a = vld_a & ~(1 << cnt);

    always_ff @ (posedge clk) begin
        if (rst) 
        begin
            cnt <= 0;
            vld_a <= 0;
            vld_b <= 0;
        end
        else 
        begin
            if (vld_a[cnt])
                cnt <= (cnt >= (n_inputs-1)) ? 0 : cnt + 1;

            vld_b <= (vld_b & ~(1 << cnt)) | (vld_next_a & up_vlds);
            vld_a <= vld_next_a | vld_b | up_vlds;
        end

        for (int i = 0; i < n_inputs; i++) begin
            if (!(vld_next_a[i]))
                if (up_vlds[i])
                    data_a[i] <= up_data[i];
            if (up_vlds[i] && vld_a[i])
                data_b[i] <= up_data[i];
        end
    end

    assign down_vld  = vld_a [cnt];
    assign down_data = data_a[cnt];


endmodule
