module mux_pinmux #(
    parameter NUM_PERIPHERALS = 4,
    parameter DATA_WIDTH     = 1,
    parameter SEL_WIDTH     = 5
)(
    input      [SEL_WIDTH-1:0]                    i_sel,
    input      [(NUM_PERIPHERALS*DATA_WIDTH)-1:0] i_peripheral_oe,
    input      [(NUM_PERIPHERALS*DATA_WIDTH)-1:0] i_peripheral_out,
    output     [DATA_WIDTH-1:0]                   o_mux_out,
    output     [DATA_WIDTH-1:0]                   o_oe
);

    // Arrays to hold sliced input vectors
    wire [DATA_WIDTH-1:0] mux_data_inputs [NUM_PERIPHERALS-1:0];
    wire [DATA_WIDTH-1:0] mux_oe_inputs [NUM_PERIPHERALS-1:0];
    
    // Intermediate wires for the multiplexer outputs
    wire [DATA_WIDTH-1:0] mux_out_array [NUM_PERIPHERALS-1:0];
    wire [DATA_WIDTH-1:0] oe_array [NUM_PERIPHERALS-1:0];
    
    // Generate blocks to slice the input vectors into arrays and create structural MUXes
    genvar g, k;
    generate
        // Modified loop condition to not exceed SEL_WIDTH
        for(g = 0; g < NUM_PERIPHERALS && g < SEL_WIDTH; g = g + 1) begin : GEN_MUX
            // Slice input vectors into arrays
            assign mux_data_inputs[g] = i_peripheral_out[((g+1)*DATA_WIDTH)-1 : g*DATA_WIDTH];
            assign mux_oe_inputs[g] = i_peripheral_oe[((g+1)*DATA_WIDTH)-1 : g*DATA_WIDTH];
            
            // For each bit in DATA_WIDTH
            for(k = 0; k < DATA_WIDTH; k = k + 1) begin : GEN_BIT_MUX
                // Wires for MUX paths
                wire w_sel_path_data, w_zero_path_data;
                wire w_sel_path_oe, w_zero_path_oe;
                wire w_sel_inv;
                
                // Invert select signal
                tiboxv_log_and2 sel_inv_and (
                    .a(~i_sel[g]),
                    .b(1'b1),
                    .y(w_sel_inv)
                );
                
                // Rest of your existing MUX logic...
            end
        end
        
        // Handle remaining peripherals if NUM_PERIPHERALS > SEL_WIDTH
        if (NUM_PERIPHERALS > SEL_WIDTH) begin : EXTRA_PERIPHERALS
            for(g = SEL_WIDTH; g < NUM_PERIPHERALS; g = g + 1) begin : GEN_EXTRA
                assign mux_out_array[g] = {DATA_WIDTH{1'b0}};
                assign oe_array[g] = {DATA_WIDTH{1'b0}};
            end
        end
    endgenerate

    // Rest of your existing OR tree logic...

endmodule


