
//Owner - a0507242
// The mux_pinmux rtl i basically the mux structure with number of peripherals, data width ans sel_width as parameters.
// while instantiating this rtl, the sel_width is taken same as input width (number of peripherals)

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
    
    // Generate blocks to slice the input vectors and create structural MUXes
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
                
                // Data MUX implementation
                tiboxv_log_and2 sel_data_and (
                    .a(mux_data_inputs[g][k]),
                    .b(i_sel[g]),
                    .y(w_sel_path_data)
                );
                
                tiboxv_log_and2 zero_data_and (
                    .a(1'b0),
                    .b(w_sel_inv),
                    .y(w_zero_path_data)
                );
                
                tiboxv_log_or2 data_mux_or (
                    .a(w_sel_path_data),
                    .b(w_zero_path_data),
                    .y(mux_out_array[g][k])
                );
                
                // OE MUX implementation
                tiboxv_log_and2 sel_oe_and (
                    .a(mux_oe_inputs[g][k]),
                    .b(i_sel[g]),
                    .y(w_sel_path_oe)
                );
                
                tiboxv_log_and2 zero_oe_and (
                    .a(1'b0),
                    .b(w_sel_inv),
                    .y(w_zero_path_oe)
                );
                
                tiboxv_log_or2 oe_mux_or (
                    .a(w_sel_path_oe),
                    .b(w_zero_path_oe),
                    .y(oe_array[g][k])
                );
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

    // OR gates to combine all outputs
    genvar h, i;
    generate
        for(h = 0; h < DATA_WIDTH; h = h + 1) begin : GEN_OR
            // Wires for each stage of the OR tree
            wire [(NUM_PERIPHERALS+1)/2-1:0] mux_level1;
            wire [(NUM_PERIPHERALS+3)/4-1:0] mux_level2;
            wire [(NUM_PERIPHERALS+1)/2-1:0] oe_level1;
            wire [(NUM_PERIPHERALS+3)/4-1:0] oe_level2;
            
            // First level OR gates for mux outputs
            for(i = 0; i < (NUM_PERIPHERALS+1)/2; i = i + 1) begin : GEN_MUX_L1
                wire first_input = mux_out_array[i*2][h];
                wire second_input = (i*2+1 < NUM_PERIPHERALS) ? mux_out_array[i*2+1][h] : 1'b0;
                
                tiboxv_log_or2 or_mux_l1 (
                    .a(first_input),
                    .b(second_input),
                    .y(mux_level1[i])
                );
            end

            // First level OR gates for OE outputs
            for(i = 0; i < (NUM_PERIPHERALS+1)/2; i = i + 1) begin : GEN_OE_L1
                wire first_input = oe_array[i*2][h];
                wire second_input = (i*2+1 < NUM_PERIPHERALS) ? oe_array[i*2+1][h] : 1'b0;
                
                tiboxv_log_or2 or_oe_l1 (
                    .a(first_input),
                    .b(second_input),
                    .y(oe_level1[i])
                );
            end

            // Second level OR gates if needed (NUM_PERIPHERALS > 2)
            if(NUM_PERIPHERALS > 2) begin : GEN_LEVEL2
                for(i = 0; i < (NUM_PERIPHERALS+3)/4; i = i + 1) begin : GEN_L2
                    wire first_input_mux = mux_level1[i*2];
                    wire second_input_mux = (i*2+1 < (NUM_PERIPHERALS+1)/2) ? mux_level1[i*2+1] : 1'b0;
                    wire first_input_oe = oe_level1[i*2];
                    wire second_input_oe = (i*2+1 < (NUM_PERIPHERALS+1)/2) ? oe_level1[i*2+1] : 1'b0;
                    
                    tiboxv_log_or2 or_mux_l2 (
                        .a(first_input_mux),
                        .b(second_input_mux),
                        .y(mux_level2[i])
                    );
                    
                    tiboxv_log_or2 or_oe_l2 (
                        .a(first_input_oe),
                        .b(second_input_oe),
                        .y(oe_level2[i])
                    );
                end
                
                // Assign final outputs
                assign o_mux_out[h] = mux_level2[0];
                assign o_oe[h] = oe_level2[0];
            end else begin
                // For NUM_PERIPHERALS <= 2, use level1 directly
                assign o_mux_out[h] = mux_level1[0];
                assign o_oe[h] = oe_level1[0];
            end
        end
    endgenerate

endmodule




//
//module mux_pinmux #(
//    parameter NUM_PERIPHERALS = 4,
//    parameter DATA_WIDTH     = 1,
//    parameter SEL_WIDTH     = 5
//)(
//    input      [SEL_WIDTH-1:0]                    i_sel,
//    input      [(NUM_PERIPHERALS*DATA_WIDTH)-1:0] i_peripheral_oe,
//    input      [(NUM_PERIPHERALS*DATA_WIDTH)-1:0] i_peripheral_out,
//    output     [DATA_WIDTH-1:0]                   o_mux_out,
//    output     [DATA_WIDTH-1:0]                   o_oe
//);
//
//    // Arrays to hold sliced input vectors
//    wire [DATA_WIDTH-1:0] mux_data_inputs [NUM_PERIPHERALS-1:0];
//    wire [DATA_WIDTH-1:0] mux_oe_inputs [NUM_PERIPHERALS-1:0];
//    
//    // Intermediate wires for the multiplexer outputs
//    wire [DATA_WIDTH-1:0] mux_out_array [NUM_PERIPHERALS-1:0];
//    wire [DATA_WIDTH-1:0] oe_array [NUM_PERIPHERALS-1:0];
//    
//    // Generate blocks to slice the input vectors into arrays and create structural MUXes
//    genvar g, k;
//    generate
//        // Modified loop condition to not exceed SEL_WIDTH
//        for(g = 0; g < NUM_PERIPHERALS && g < SEL_WIDTH; g = g + 1) begin : GEN_MUX
//            // Slice input vectors into arrays
//            assign mux_data_inputs[g] = i_peripheral_out[((g+1)*DATA_WIDTH)-1 : g*DATA_WIDTH];
//            assign mux_oe_inputs[g] = i_peripheral_oe[((g+1)*DATA_WIDTH)-1 : g*DATA_WIDTH];
//            
//            // For each bit in DATA_WIDTH
//            for(k = 0; k < DATA_WIDTH; k = k + 1) begin : GEN_BIT_MUX
//                // Wires for MUX paths
//                wire w_sel_path_data, w_zero_path_data;
//                wire w_sel_path_oe, w_zero_path_oe;
//                wire w_sel_inv;
//                
//                // Invert select signal
//                tiboxv_log_and2 sel_inv_and (
//                    .a(~i_sel[g]),
//                    .b(1'b1),
//                    .y(w_sel_inv)
//                );
//                
//                // Rest of your existing MUX logic...
//            end
//        end
//        
//        // Handle remaining peripherals if NUM_PERIPHERALS > SEL_WIDTH
//        if (NUM_PERIPHERALS > SEL_WIDTH) begin : EXTRA_PERIPHERALS
//            for(g = SEL_WIDTH; g < NUM_PERIPHERALS; g = g + 1) begin : GEN_EXTRA
//                assign mux_out_array[g] = {DATA_WIDTH{1'b0}};
//                assign oe_array[g] = {DATA_WIDTH{1'b0}};
//            end
//        end
//    endgenerate
//
//    // Rest of your existing OR tree logic...
//
//endmodule
//
//
//
//// module mux_pinmux #(
////     parameter NUM_PERIPHERALS = 4,
////     parameter DATA_WIDTH     = 1,
////    //  parameter sel_width      = num_peripherals
////     parameter  SEL_WIDTH     = 5
//// 
//// )(
////     input      [SEL_WIDTH-1:0]                    i_sel,
////     input      [(NUM_PERIPHERALS*DATA_WIDTH)-1:0] i_peripheral_oe,
////     input      [(NUM_PERIPHERALS*DATA_WIDTH)-1:0] i_peripheral_out,
////     output     [DATA_WIDTH-1:0]                   o_mux_out,
////     output     [DATA_WIDTH-1:0]                   o_oe
//// );
//// 
////     // Arrays to hold sliced input vectors
////     wire [DATA_WIDTH-1:0] mux_data_inputs [NUM_PERIPHERALS-1:0];
////     wire [DATA_WIDTH-1:0] mux_oe_inputs [NUM_PERIPHERALS-1:0];
////     
////     // Intermediate wires for the multiplexer outputs
////     wire [DATA_WIDTH-1:0] mux_out_array [NUM_PERIPHERALS-1:0];
////     wire [DATA_WIDTH-1:0] oe_array [NUM_PERIPHERALS-1:0];
////     
////     // Generate blocks to slice the input vectors into arrays and create structural MUXes
////     genvar g, k;
////     generate
////         for(g = 0; g < NUM_PERIPHERALS; g = g + 1) begin : GEN_MUX
////             // Slice input vectors into arrays
////             assign mux_data_inputs[g] = i_peripheral_out[((g+1)*DATA_WIDTH)-1 : g*DATA_WIDTH];
////             assign mux_oe_inputs[g] = i_peripheral_oe[((g+1)*DATA_WIDTH)-1 : g*DATA_WIDTH];
////             
////             // For each bit in DATA_WIDTH
////             for(k = 0; k < DATA_WIDTH; k = k + 1) begin : GEN_BIT_MUX
////                 // Wires for MUX paths
////                 wire w_sel_path_data, w_zero_path_data;
////                 wire w_sel_path_oe, w_zero_path_oe;
////                 wire w_sel_inv;
////                 
////                 // Invert select signal
////                 tiboxv_log_and2 sel_inv_and (
////                     .a(~i_sel[g]),
////                     .b(1'b1),
////                     .y(w_sel_inv)
////                 );
////                 
////                 // Data MUX implementation
////                 tiboxv_log_and2 sel_data_and (
////                     .a(mux_data_inputs[g][k]),
////                     .b(i_sel[g]),
////                     .y(w_sel_path_data)
////                 );
////                 
////                 tiboxv_log_and2 zero_data_and (
////                     .a(1'b0),
////                     .b(w_sel_inv),
////                     .y(w_zero_path_data)
////                 );
////                 
////                 tiboxv_log_or2 data_mux_or (
////                     .a(w_sel_path_data),
////                     .b(w_zero_path_data),
////                     .y(mux_out_array[g][k])
////                 );
////                 
////                 // OE MUX implementation
////                 tiboxv_log_and2 sel_oe_and (
////                     .a(mux_oe_inputs[g][k]),
////                     .b(i_sel[g]),
////                     .y(w_sel_path_oe)
////                 );
////                 
////                 tiboxv_log_and2 zero_oe_and (
////                     .a(1'b0),
////                     .b(w_sel_inv),
////                     .y(w_zero_path_oe)
////                 );
////                 
////                 tiboxv_log_or2 oe_mux_or (
////                     .a(w_sel_path_oe),
////                     .b(w_zero_path_oe),
////                     .y(oe_array[g][k])
////                 );
////             end
////         end
////     endgenerate
//// 
////     // OR gates to combine all outputs
////     genvar h, i;
////     generate
////         for(h = 0; h < DATA_WIDTH; h = h + 1) begin : GEN_OR
////             // Wires for each stage of the OR tree
////             wire [(NUM_PERIPHERALS+1)/2-1:0] mux_level1;
////             wire [(NUM_PERIPHERALS+3)/4-1:0] mux_level2;
////             wire [(NUM_PERIPHERALS+1)/2-1:0] oe_level1;
////             wire [(NUM_PERIPHERALS+3)/4-1:0] oe_level2;
////             
////             // First level OR gates for mux outputs
////             for(i = 0; i < (NUM_PERIPHERALS+1)/2; i = i + 1) begin : GEN_MUX_L1
////                 wire first_input = mux_out_array[i*2][h];
////                 wire second_input = (i*2+1 < NUM_PERIPHERALS) ? mux_out_array[i*2+1][h] : 1'b0;
////                 
////                 tiboxv_log_or2 or_mux_l1 (
////                     .a(first_input),
////                     .b(second_input),
////                     .y(mux_level1[i])
////                 );
////             end
//// 
////             // First level OR gates for OE outputs
////             for(i = 0; i < (NUM_PERIPHERALS+1)/2; i = i + 1) begin : GEN_OE_L1
////                 wire first_input = oe_array[i*2][h];
////                 wire second_input = (i*2+1 < NUM_PERIPHERALS) ? oe_array[i*2+1][h] : 1'b0;
////                 
////                 tiboxv_log_or2 or_oe_l1 (
////                     .a(first_input),
////                     .b(second_input),
////                     .y(oe_level1[i])
////                 );
////             end
//// 
////             // Second level OR gates if needed (NUM_PERIPHERALS > 2)
////             if(NUM_PERIPHERALS > 2) begin : GEN_LEVEL2
////                 for(i = 0; i < (NUM_PERIPHERALS+3)/4; i = i + 1) begin : GEN_L2
////                     wire first_input_mux = mux_level1[i*2];
////                     wire second_input_mux = (i*2+1 < (NUM_PERIPHERALS+1)/2) ? mux_level1[i*2+1] : 1'b0;
////                     wire first_input_oe = oe_level1[i*2];
////                     wire second_input_oe = (i*2+1 < (NUM_PERIPHERALS+1)/2) ? oe_level1[i*2+1] : 1'b0;
////                     
////                     tiboxv_log_or2 or_mux_l2 (
////                         .a(first_input_mux),
////                         .b(second_input_mux),
////                         .y(mux_level2[i])
////                     );
////                     
////                     tiboxv_log_or2 or_oe_l2 (
////                         .a(first_input_oe),
////                         .b(second_input_oe),
////                         .y(oe_level2[i])
////                     );
////                 end
////                 
////                 // Assign final outputs
////                 assign o_mux_out[h] = mux_level2[0];
////                 assign o_oe[h] = oe_level2[0];
////             end else begin
////                 // For NUM_PERIPHERALS <= 2, use level1 directly
////                 assign o_mux_out[h] = mux_level1[0];
////                 assign o_oe[h] = oe_level1[0];
////             end
////         end
////     endgenerate
//// 
//// endmodule
//// 
//// 
//// //module mux_pinmux #(
//// //    parameter NUM_PERIPHERALS = 4,
//// //    parameter DATA_WIDTH     = 1,
//// //    parameter SEL_WIDTH      = 2
//// //)(
//// //    input      [SEL_WIDTH-1:0]                    i_sel,
//// //    input      [(NUM_PERIPHERALS*DATA_WIDTH)-1:0] i_peripheral_oe,
//// //    input      [(NUM_PERIPHERALS*DATA_WIDTH)-1:0] i_peripheral_out,
//// //    output     [DATA_WIDTH-1:0]                   o_mux_out,
//// //    output     [DATA_WIDTH-1:0]                   o_oe
//// //);
//// //
//// //    // Arrays to hold sliced input vectors
//// //    wire [DATA_WIDTH-1:0] mux_data_inputs [NUM_PERIPHERALS-1:0];
//// //    wire [DATA_WIDTH-1:0] mux_oe_inputs [NUM_PERIPHERALS-1:0];
//// //    
//// //    // Intermediate wires for the multiplexer outputs
//// //    wire [DATA_WIDTH-1:0] mux_out_array [NUM_PERIPHERALS-1:0];
//// //    wire [DATA_WIDTH-1:0] oe_array [NUM_PERIPHERALS-1:0];
//// //    
//// //    // Generate blocks to slice the input vectors into arrays
//// //    genvar g;
//// //    generate
//// //        for(g = 0; g < NUM_PERIPHERALS; g = g + 1) begin : GEN_MUX
//// //            assign mux_data_inputs[g] = i_peripheral_out[((g+1)*DATA_WIDTH)-1 : g*DATA_WIDTH];
//// //            assign mux_oe_inputs[g] = i_peripheral_oe[((g+1)*DATA_WIDTH)-1 : g*DATA_WIDTH];
//// //            
//// //            // Gate each input with its select signal
//// //            assign mux_out_array[g] = i_sel[g] ? mux_data_inputs[g] : {DATA_WIDTH{1'b0}};
//// //            assign oe_array[g] = i_sel[g] ? mux_oe_inputs[g] : {DATA_WIDTH{1'b0}};
//// //        end
//// //    endgenerate
//// //
//// //    // OR gates to combine all outputs
//// //    genvar h;
//// //    generate
//// //        for(h = 0; h < DATA_WIDTH; h = h + 1) begin : GEN_OR
//// //            // For 4 inputs, we need 3 OR gates in a tree structure
//// //            wire [1:0] or_level1_out_mux;  // First level OR outputs for mux
//// //            wire [1:0] or_level1_out_oe;   // First level OR outputs for oe
//// //            
//// //            // First level of OR gates
//// //            tiboxv_log_or2 or_mux_l1_0 (
//// //                .a(mux_out_array[0][h]),
//// //                .b(mux_out_array[1][h]),
//// //                .y(or_level1_out_mux[0])
//// //            );
//// //            
//// //            tiboxv_log_or2 or_mux_l1_1 (
//// //                .a(mux_out_array[2][h]),
//// //                .b(mux_out_array[3][h]),
//// //                .y(or_level1_out_mux[1])
//// //            );
//// //            
//// //            tiboxv_log_or2 or_oe_l1_0 (
//// //                .a(oe_array[0][h]),
//// //                .b(oe_array[1][h]),
//// //                .y(or_level1_out_oe[0])
//// //            );
//// //            
//// //            tiboxv_log_or2 or_oe_l1_1 (
//// //                .a(oe_array[2][h]),
//// //                .b(oe_array[3][h]),
//// //                .y(or_level1_out_oe[1])
//// //            );
//// //            
//// //            // Final level of OR gates
//// //            tiboxv_log_or2 or_mux_final (
//// //                .a(or_level1_out_mux[0]),
//// //                .b(or_level1_out_mux[1]),
//// //                .y(o_mux_out[h])
//// //            );
//// //            
//// //            tiboxv_log_or2 or_oe_final (
//// //                .a(or_level1_out_oe[0]),
//// //                .b(or_level1_out_oe[1]),
//// //                .y(o_oe[h])
//// //            );
//// //        end
//// //    endgenerate
//// //
//// //endmodule
//// //
//// //
//// // // module mux_pinmux #(
//// // //     parameter NUM_PERIPHERALS = 4,
//// // //     parameter DATA_WIDTH     = 1,
//// // //     parameter SEL_WIDTH      = 2
//// // // )(
//// // //     input      [SEL_WIDTH-1:0]                    i_sel,
//// // //     input      [(NUM_PERIPHERALS*DATA_WIDTH)-1:0] i_peripheral_oe,
//// // //     input      [(NUM_PERIPHERALS*DATA_WIDTH)-1:0] i_peripheral_out,
//// // //     output reg [DATA_WIDTH-1:0]                   o_mux_out,
//// // //     output reg [DATA_WIDTH-1:0]                   o_oe
//// // // );
//// // // 
//// // //     // Arrays to hold sliced input vectors
//// // //     wire [DATA_WIDTH-1:0] mux_data_inputs [NUM_PERIPHERALS-1:0];
//// // //     wire [DATA_WIDTH-1:0] mux_oe_inputs [NUM_PERIPHERALS-1:0];
//// // //     
//// // //     // Generate blocks to slice the input vectors into arrays
//// // //     genvar g;
//// // //     generate
//// // //         for(g = 0; g < NUM_PERIPHERALS; g = g + 1) begin : GEN_MUX
//// // //             assign mux_data_inputs[g] = i_peripheral_out[((g+1)*DATA_WIDTH)-1 : g*DATA_WIDTH];
//// // //             assign mux_oe_inputs[g] = i_peripheral_oe[((g+1)*DATA_WIDTH)-1 : g*DATA_WIDTH];
//// // //         end
//// // //     endgenerate
//// // // 
//// // //     // Multiplexing logic
//// // //     integer i;
//// // //     always @(*) begin
//// // //         o_mux_out = {DATA_WIDTH{1'b0}};
//// // //         o_oe = {DATA_WIDTH{1'b0}};
//// // //         for(i = 0; i < NUM_PERIPHERALS; i = i + 1) begin
//// // //             if(i_sel[i]) begin
//// // //                 o_mux_out = mux_data_inputs[i];
//// // //                 o_oe = mux_oe_inputs[i];
//// // //             end
//// // //         end
//// // //     end
//// // // endmodule
