//
//  schoolRISCV - small RISC-V CPU
//
//  Originally based on Sarah L. Harris MIPS CPU
//  & schoolMIPS project.
//
//  Copyright (c) 2017-2020 Stanislav Zhelnio & Aleksandr Romanov.
//
//  Modified in 2024 by Yuri Panchul & Mike Kuskov
//  for systemverilog-homework project.
//

module cpu_cluster
#(
    parameter nCPUs = 3
)
(
    input                        clk,      // clock
    input                        rst,      // reset

    input   [nCPUs - 1:0][31:0]  rstPC,    // program counter for every CPU (set on reset)
    input   [nCPUs - 1:0][ 4:0]  regAddr,  // debug access reg address
    output  [nCPUs - 1:0][31:0]  regData   // debug access reg data
);

    logic [nCPUs - 1:0][31:0] imAddr;      // instruction memory address for every CPU      
    logic [nCPUs - 1:0][31:0] imData;      // instruction memory data for every CPU 
    logic [nCPUs - 1:0]       imDataVld;   // instruction memory data valid for every CPU

    logic [nCPUs - 1:0]       instr_request; // instruction request for every CPU     
    logic [nCPUs - 1:0]       instr_grant;   // instruction grant for every CPU     
    logic [7:0]               arbiter_grant;        
    logic [31:0]              curr_addr;   
    logic [31:0]              curr_data;   


    // All CPUs request new instructions
    genvar i;
    generate
        for (i = 0; i < nCPUs; i++) 
        begin : requests_gen
            assign instr_request[i] = 1'b1;
        end
    endgenerate


    // decision what CPU to use
    round_robin_arbiter_8 rr_arbiter
    (
        .clk    (clk),
        .rst    (rst),
        .req    ({{(8 - nCPUs){1'b0}}, instr_request}),  // 00000***
        .gnt    (arbiter_grant)             
    );

    // actually: resize [7:0] to [nCPUs-1:0]
    // choose 1 CPU to access memory at the moment
    assign instr_grant = arbiter_grant[nCPUs - 1:0]; 


    // choosing right addr to read from
    always_comb 
    begin
        curr_addr = 32'b0;
        for (int i = 0; i < nCPUs; i++) 
        begin
            if (instr_grant[i]) 
            begin
                curr_addr = imAddr[i] << 2; // address = instr_counter * (size_instr=4)  
            end
        end
    end

    instruction_rom #(
        .SIZE(64)
    ) instr_mem (
        .a  (curr_addr[7:2]),  
        .rd (curr_data)        
    );

    // give data to active CPU
    generate
        for (i = 0; i < nCPUs; i++) 
        begin : data_dist
            assign imData[i] = instr_grant[i] ? curr_data : 32'h00000013; // NOP  
        end
    endgenerate

    // rise DataVld for active CPU
    generate
        for (i = 0; i < nCPUs; i++) 
        begin : valid_gen
            assign imDataVld[i] = instr_grant[i];
        end
    endgenerate

    // use CPUs
    generate
        for (i = 0; i < nCPUs; i++) 
        begin : cpu_gen
            sr_cpu cpu (
                .clk        (clk),
                .rst        (rst),
                .rstPC      (rstPC[i]),
                .regAddr    (regAddr[i]),
                .regData    (regData[i]),
                .imAddr     (imAddr[i]),
                .imData     (imData[i]),
                .imDataVld  (imDataVld[i])
            );
        end
    endgenerate

endmodule

