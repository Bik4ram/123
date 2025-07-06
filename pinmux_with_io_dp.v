module pinmux_with_io_dp #(
    parameter O_NUM_PERIPHERALS = 4,
    parameter I_NUM_PERIPHERALS = 4,
    parameter DATA_WIDTH     = 1,
    parameter SEL_WIDTH = 5,
    parameter array_cell_index = 0
)(
    // Clock and Reset
    input                                       i_clk,                    
    input  wire                                i_clk_rc,          
    input  wire                                i_clk_perpll,      
    input  wire                                i_rst_n,           
    
    // Control Signals - Fixed widths
    input      [4:0]                           i_outfunc_sel,           
    input      [31:0]                          i_infunc_en,             
    input                                      i_gpioquten,              
    input                                      i_pinctlx_od,             
    input                                      i_pinctlx_ie,             
    input                                      i_pinctlx_slew,           
    input      [1:0]                           i_pinctlx_dsl,            
    input                                      i_pinctlx_inmode,         
    
    // Single-bit control signals
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
    
    // Multi-bit control signals
    input      [4:0]                           pinmux_muxsel_out_mscbus,
    input      [31:0]                          in_function_en_out_mscbus,
    input      [1:0]                           glitch_filter_debounce_clk_sel_out_mscbus,
    input      [2:0]                           glitch_filter_bypass_out_mscbus,
    input      [7:0]                           pes_en_out_mscbus,
    input                                      pes_in_en_out_mscbus,
    input      [1:0]                           pes_safeval_out_mscbus,
    
    // Single-bit GPIO interface signals
    output                                     async_in_from_pad_mscbus,
    input                                      gpio_out_2_buf_mscbus,
    input                                      gpio_out_en_2_buf_mscbus,
    input                                      pinmuxdata_2_gpio_mscbus,
    input                                      pinmuxen_2_gpio_mscbus,
    output                                     GP_DATA_IN_out_mscbus,
    output                                     data_out_2_pinmux_mscbus,
    
    // Additional control signals
    input                                      lvds_en_ctrl_out_mscbus,
    input                                      in_termination_en_out_mscbus,
    
    // Peripheral Interface
    input      [(I_NUM_PERIPHERALS*DATA_WIDTH)-1:0] i_peripheral_oe,     
    input      [(I_NUM_PERIPHERALS*DATA_WIDTH)-1:0] i_peripheral_out,    
    output     [(O_NUM_PERIPHERALS*DATA_WIDTH)-1:0] o_peripheral_in,     
    
    // Pad Interface
    inout                                      io_pad
);

    // Internal wires
    wire w_mux1_oe_out, w_mux1_out_out;
    wire w_pre_portstop_oe, w_pre_portstop_out;
    wire w_post_portstop_oe, w_post_portstop_out, w_post_portstop_ie;
    wire w_final_oe;
    wire w_not_mux1_out;
    wire w_od_mux_out;
    wire w_input_path;
    wire w_filtered_input;
    wire w_gpio_in;
    wire w_tristate_out;
    wire w_pad_out;
    wire o_gpioinx;

    // First level MUX for OE path
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

    // First level MUX for OUT path
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

    // Inverter for mux1_out using AND gate
    tiboxv_log_and2 not_mux1_out_and (
        .a(~w_mux1_out_out),
        .b(1'b1),
        .y(w_not_mux1_out)
    );

    // OD MUX using structural gates
    wire w_od_path, w_non_od_path;
    
    tiboxv_log_and2 od_path_and (
        .a(w_not_mux1_out),
        .b(i_pinctlx_od),
        .y(w_od_path)
    );

    tiboxv_log_and2 non_od_path_and (
        .a(w_mux1_oe_out),
        .b(~i_pinctlx_od),
        .y(w_non_od_path)
    );

    tiboxv_log_or2 od_mux_or (
        .a(w_od_path),
        .b(w_non_od_path),
        .y(w_pre_portstop_oe)
    );

    // Output data MUX using structural gates
    wire w_od_data_path, w_non_od_data_path;
    
    tiboxv_log_and2 od_data_zero_and (
        .a(1'b0),
        .b(i_pinctlx_od),
        .y(w_od_data_path)
    );

    tiboxv_log_and2 non_od_data_and (
        .a(w_mux1_out_out),
        .b(~i_pinctlx_od),
        .y(w_non_od_data_path)
    );

    tiboxv_log_or2 od_data_mux_or (
        .a(w_od_data_path),
        .b(w_non_od_data_path),
        .y(w_pre_portstop_out)
    );

    // Port Stop Override Logic
    wire [7:0] error_bus;
    assign error_bus = pes_en_out_mscbus[7:0];
    assign w_post_portstop_oe = w_pre_portstop_oe;
    assign w_post_portstop_out = w_pre_portstop_out;
    assign w_post_portstop_ie = i_pinctlx_ie;

    // Final Output Enable using AND gate
    tiboxv_log_and2 final_oe_and (
        .a(w_post_portstop_oe),
        .b(i_gpioquten),
        .y(w_final_oe)
    );

    // Input Path using structural gates
    wire w_ie_path, w_ie_zero;
    
    tiboxv_log_and2 ie_path_and (
        .a(io_pad),
        .b(w_post_portstop_ie),
        .y(w_ie_path)
    );

    tiboxv_log_and2 ie_zero_and (
        .a(1'b0),
        .b(~w_post_portstop_ie),
        .y(w_ie_zero)
    );

    tiboxv_log_or2 input_path_or (
        .a(w_ie_path),
        .b(w_ie_zero),
        .y(w_input_path)
    );

    assign w_filtered_input = w_input_path;

    // Peripheral Input Distribution using AND gates with modified indexing
    genvar i;
    generate
        for (i = 0; i < O_NUM_PERIPHERALS; i = i + 1) begin : PERIPHERAL_IN_ANDS
            wire muxsel_match_0, muxsel_match_1, muxsel_active;
            
            tiboxv_log_and2 muxsel_match_and0 (
                .a(pinmux_muxsel_out_mscbus[i % 5]),
                .b(i_infunc_en[0]),
                .y(muxsel_match_0)
            );
            
            tiboxv_log_and2 muxsel_match_and1 (
                .a(pinmux_muxsel_out_mscbus[(i+1) % 5]),
                .b(i_infunc_en[1]),
                .y(muxsel_match_1)
            );
            
            tiboxv_log_and2 muxsel_active_and (
                .a(muxsel_match_0),
                .b(muxsel_match_1),
                .y(muxsel_active)
            );
            
            tiboxv_log_and2 peripheral_in_and (
                .a(w_filtered_input),
                .b(muxsel_active),
                .y(o_peripheral_in[i])
            );
        end
    endgenerate

    // GPIO Input Path
    tiboxv_log_and2 gpio_in_and (
        .a(w_filtered_input),
        .b(inena_out_mscbus),
        .y(w_gpio_in)
    );

    tiboxv_log_and2 gpio_mode_and (
        .a(w_gpio_in),
        .b(mode1_out_mscbus),
        .y(o_gpioinx)
    );

    // Tristate buffer implementation using structural gates
    wire w_tristate_enable;
    tiboxv_log_and2 tristate_en_and (
        .a(w_final_oe),
        .b(1'b1),
        .y(w_tristate_enable)
    );

    wire w_pad_drive;
    tiboxv_log_and2 pad_drive_and (
        .a(w_post_portstop_out),
        .b(w_tristate_enable),
        .y(w_pad_drive)
    );

    // Final pad connection and signal assignments
    assign io_pad = w_tristate_enable ? w_pad_drive : 1'bz;
    assign async_in_from_pad_mscbus = w_filtered_input;
    assign GP_DATA_IN_out_mscbus = w_filtered_input;
    assign data_out_2_pinmux_mscbus = w_post_portstop_out;

endmodule
