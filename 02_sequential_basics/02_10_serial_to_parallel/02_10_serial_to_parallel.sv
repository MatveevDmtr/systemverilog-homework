//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_to_parallel
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      serial_valid,
    input                      serial_data,

    output logic               parallel_valid,
    output logic [width - 1:0] parallel_data
);
    // Task:
    // Implement a module that converts serial data to the parallel multibit value.
    //
    // The module should accept one-bit values with valid interface in a serial manner.
    // After accumulating 'width' bits, the module should assert the parallel_valid
    // output and set the data.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.

    logic [3:0] valid_counter;

    logic [width - 1:0] register;

    // This task is an awful timekiller.
    // The description is too poor to understand what is expected.
    // It spoiled my evening. 


    always_ff @(posedge clk or posedge rst) 
    begin
        if (rst) 
        begin
            register <= 1'b0;
            valid_counter <= 1'b0;
            parallel_data <= 1'b0;
            parallel_valid <= 1'b0;
        end 
        else 
        begin
            parallel_valid <= 1'b0; 

            if (serial_valid) 
            begin
                register <= {serial_data, register[width-1:1]};
                valid_counter <= valid_counter + 1'b1;

                if (valid_counter == width - 1) 
                begin
                    parallel_valid <= 1'b1;
                    parallel_data <= {serial_data, register[width-1:1]};
                    valid_counter <= 1'b0;
                end
            end
        end
    end

endmodule
