module pinmux_with_io_ap #(
    parameter O_NUM_PERIPHERALS = 4,
    parameter I_NUM_PERIPHERALS = 4,
    parameter DATA_WIDTH     = 1,
    parameter SEL_WIDTH = 5,
    parameter array_cell_index = 0
)(
    // Clock and Reset
    input                                       i_clk,                    
    input  wire                                i_rst_n,           
    
    // Control Signals
    input      [4:0]                           i_outfunc_sel,           
    input      [31:0]                          i_infunc_en,             
    input                                      i_gpioquten,              
    input                                      i_pinctlx_od,             
    input                                      i_pinctlx_ie,             
    input                                      i_pinctlx_slew,           
    input      [1:0]                           i_pinctlx_dsl,            
    input                                      i_pinctlx_inmode,         
    
    // Debounce Filter Controls
    input      [2:0]                           DEBOUNCEFILTx,
    input      [3:0]                           i_debounce,
    
    // MSC Bus Signals
    input                                      amsel_out_mscbus,
    input                                      ds0_out_mscbus,
    input                                      ds1_out_mscbus,
    input                                      slew_out_mscbus,
    input                                      schmitt_out_mscbus,
    input                                      mode0_out_mscbus,
    input                                      mode1_out_mscbus,
    input                                      inena_out_mscbus,
    input                                      dir_out_mscbus,
    input                                      pull_en_out_mscbus,
    input                                      pull_type_out_mscbus,
    input      [4:0]                           pinmux_muxsel_out_mscbus,
    input      [31:0]                          in_function_en_out_mscbus,
    input      [1:0]                           glitch_filter_debounce_clk_sel_out_mscbus,
    input      [2:0]                           glitch_filter_bypass_out_mscbus,
    input      [7:0]                           pes_en_out_mscbus,
    input                                      pes_in_en_out_mscbus,
    input      [1:0]                           pes_safeval_out_mscbus,
    
    // GPIO Interface
    output                                     async_in_from_pad_mscbus,
    input                                      gpio_out_2_buf_mscbus,
    input                                      gpio_out_en_2_buf_mscbus,
    input                                      pinmuxdata_2_gpio_mscbus,
    input                                      pinmuxen_2_gpio_mscbus,
    output                                     GP_DATA_IN_out_mscbus,
    output                                     data_out_2_pinmux_mscbus,
    input                                      in_termination_en_out_mscbus,
    input                                      lvds_en_ctrl_out_mscbus,
    
    // Peripheral Interface
    input      [(I_NUM_PERIPHERALS*DATA_WIDTH)-1:0] i_peripheral_oe,     
    input      [(I_NUM_PERIPHERALS*DATA_WIDTH)-1:0] i_peripheral_out,    
    output     [(O_NUM_PERIPHERALS*DATA_WIDTH)-1:0] o_peripheral_in,     
    
    // Pad Interface
    inout                                      io_pad
);

    // Internal signals - Output Path
    wire w_mux1_oe_out, w_mux1_out_out;
    wire w_pre_portstop_oe, w_pre_portstop_out;
    wire w_post_portstop_oe, w_post_portstop_out;
//    wire w_final_oe;
    wire final_w_pre_portstop_oe;
    
    // Internal signals - Input Path
  //  wire w_raw_input;
  //  wire w_debounced_input;
  //  wire w_filtered_input;
  //  wire w_gpio_in;
    wire w_post_portstop_ie;
    
    // Buffer and IO cell interconnect signals
    wire w_buf_to_iocell;      // Connection between output buffer and IO cell
    wire w_iocell_to_inbuf;    // Connection between IO cell and input buffer

    // First level peripheral muxes for output path
    mux_pinmux #(
        .NUM_PERIPHERALS(I_NUM_PERIPHERALS),
        .DATA_WIDTH(DATA_WIDTH),
        .SEL_WIDTH(5)
    ) mux1_oe (
        .i_sel(i_outfunc_sel),
        .i_peripheral_oe(i_peripheral_oe),
        .i_peripheral_out(),
        .o_mux_out(w_mux1_oe_out),
        .o_oe()
    );

    mux_pinmux #(
        .NUM_PERIPHERALS(I_NUM_PERIPHERALS),
        .DATA_WIDTH(DATA_WIDTH),
        .SEL_WIDTH(5)
    ) mux1_out (
        .i_sel(i_outfunc_sel),
        .i_peripheral_oe(),
        .i_peripheral_out(i_peripheral_out),
        .o_mux_out(w_mux1_out_out),
        .o_oe()
    );

    // OD Muxes
    tiboxv_log_mx2 od_oe_mux (
        .a(w_mux1_oe_out),    // Non-OD path
        .b(~w_mux1_out_out),  // OD path
        .s(i_pinctlx_od),
        .y(w_pre_portstop_oe)
    );

    tiboxv_log_mx2 od_data_mux (
        .a(w_mux1_out_out),   // Non-OD path
        .b(1'b0),             // OD path
        .s(i_pinctlx_od),
        .y(w_pre_portstop_out)
    );

    // Final output enable
   //  tiboxv_log_mx2 final_oe_mux (
   //      .a(1'b0),
   //      .b(w_post_portstop_oe),
   //      .s(i_gpioquten),
   //      .y(w_final_oe)
   //  );

    tiboxv_log_and2 final_oe_mux (
      .a(w_pre_portstop_oe),
      .b(i_gpioquten),
      .y(final_w_pre_portstop_oe)
    );

    // Port Stop Override
    port_stop_override port_stop_override_inst (
        .error0(pes_en_out_mscbus[0]),
        .error1(pes_en_out_mscbus[1]),
        .error2(pes_en_out_mscbus[2]),
        .error3(pes_en_out_mscbus[3]),
        .portstpx_grpsel(pes_en_out_mscbus[7:4]),
        .portstpx_safeval(pes_safeval_out_mscbus),
        .portstp_ie(pes_in_en_out_mscbus),
        .output_enable_in(final_w_pre_portstop_oe),
        .out_in(w_pre_portstop_out),
        .ie_in(i_pinctlx_ie),
        .output_enable_out(w_post_portstop_oe),
        .out_out(w_post_portstop_out),
        .ie_out(w_post_portstop_ie)
    );



    // Output Buffer Implementation
    tiboxv_log_tribuf output_buffer (
        .a(w_post_portstop_out),    // Data input to buffer
        .gz(~w_post_portstop_oe),           // Enable (active low)
        .y(w_buf_to_iocell)         // Output to IO cell
    );

    // IO Cell instantiation
    bq50100dcslhypbdd_h_255u_6x2s io_cell_inst (
        // Main connections
        .pad(io_pad),
        .pad_esd_nores(io_pad),
        .pad_esd_res(io_pad),
        
        // Output path
        .a(w_buf_to_iocell),        // From output buffer
        //.gz(w_final_oe),            // Output enable
        .gz(~w_post_portstop_oe),
        // Input path
        .y(w_iocell_to_inbuf),      // To input buffer
        .inena(w_post_portstop_ie),  // Input enable
        
        // Configuration
        .mode_0(mode0_out_mscbus),
        .mode_1(mode1_out_mscbus),
        .hysten(schmitt_out_mscbus),
        .slewctrl(slew_out_mscbus),
        .drive0(ds0_out_mscbus),
        
        // Fixed connections
        .sleep(1'b0),
        .pgio(1'b1),
        .pgio_ulp(1'b0),
        .pi(1'b0),
        .psel(1'b0),
        
        // Tie-offs
        .tieoff_vss(),
        .tieoff_vdds()
    );

    // Input Buffer Implementation
    tiboxv_log_tribuf input_buffer (
        .a(w_iocell_to_inbuf),      // Data from IO cell
        .gz(~w_post_portstop_ie),   // Input enable (active low)
        .y(w_raw_input)             // To debounce filter
    );

    // Debounce Filter
 //   debounce_filter debounce_inst (
 //       .clk(i_clk),
 //       .rst_n(i_rst_n),
 //       .i_debounce(i_debounce),
 //       .DEBOUNCEFILTx(DEBOUNCEFILTx),
 //       .INDEBOUNCEx(w_filtered_input)
 //   );

    // Debounce Filter
    debounce_filter debounce_inst (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .i_debounce(i_debounce),
        .DEBOUNCEFILTx(DEBOUNCEFILTx),
        .INx(w_raw_input),         // Connect to input buffer output
        .INDEBOUNCEx(w_filtered_input)
    );

    // Peripheral Input Distribution
    genvar i;
    generate
        for (i = 0; i < O_NUM_PERIPHERALS; i = i + 1) begin : PERIPHERAL_IN_ANDS
            wire func_en_match;
            
            // Match function enable with corresponding mux select
            tiboxv_log_and2 func_en_and (
                .a(i_infunc_en[i]),
                .b((pinmux_muxsel_out_mscbus == i[4:0])),
                .y(func_en_match)
            );

            // Gate filtered input with enable
            tiboxv_log_and2 input_and (
                .a(w_filtered_input),
                .b(func_en_match),
                .y(o_peripheral_in[i])
            );
        end
    endgenerate

    // Output assignments
    assign async_in_from_pad_mscbus = w_filtered_input;
    assign GP_DATA_IN_out_mscbus = w_filtered_input;
    assign data_out_2_pinmux_mscbus = w_post_portstop_out;

endmodule

