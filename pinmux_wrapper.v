module pinmux_wrapper (

  // dp0 async input from pad bus
  dp0_async_in_from_pad_mscbus,                  // Bus Miscellanous Busdef

  // dp0 gpio out to buf bus
  dp0_gpio_out_2_buf_mscbus,                     // Bus Miscellanous Busdef

  // dp0 gpio out enable bus
  dp0_gpio_out_en_2_buf_mscbus,                  // Bus Miscellanous Busdef

  // dp0 pinmux data to gpio bus
  dp0_pinmuxdata_2_gpio_mscbus,                  // Bus Miscellanous Busdef

  // dp0 pinmux enable to gpio bus
  dp0_pinmuxen_2_gpio_mscbus,                    // Bus Miscellanous Busdef

  // dp0 GP DATA IN out bus
  dp0_GP_DATA_IN_out_mscbus,                     // Bus Miscellanous Busdef

  // dp0 data out to pinmux bus
  dp0_data_out_2_pinmux_mscbus,                  // Bus Miscellanous Busdef

  // dp0 pinmux muxsel out bus
  dp0_pinmux_muxsel_out_mscbus,                  // Bus Miscellanous Busdef

  // dp0 in function enable out bus
  dp0_in_function_en_out_mscbus,                 // Bus Miscellanous Busdef

  // dp0 analog mode select bus
  dp0_amsel_out_mscbus,                          // Bus Miscellanous Busdef

  // dp0 drive strength 0 bus
  dp0_ds0_out_mscbus,                            // Bus Miscellanous Busdef

  // dp0 drive strength 1 bus
  dp0_ds1_out_mscbus,                            // Bus Miscellanous Busdef

  // dp0 slew control bus
  dp0_slew_out_mscbus,                           // Bus Miscellanous Busdef

  // dp0 schmitt trigger bus
  dp0_schmitt_out_mscbus,                        // Bus Miscellanous Busdef

  // dp0 mode 0 bus
  dp0_mode0_out_mscbus,                          // Bus Miscellanous Busdef

  // dp0 mode 1 bus
  dp0_mode1_out_mscbus,                          // Bus Miscellanous Busdef

  // dp0 input enable bus
  dp0_inena_out_mscbus,                          // Bus Miscellanous Busdef

  // dp0 direction bus
  dp0_dir_out_mscbus,                            // Bus Miscellanous Busdef

  // dp0 pull enable bus
  dp0_pull_en_out_mscbus,                        // Bus Miscellanous Busdef

  // dp0 pull type bus
  dp0_pull_type_out_mscbus,                      // Bus Miscellanous Busdef

  // dp0 glitch filter debounce clock select bus
  dp0_glitch_filter_debounce_clk_sel_out_mscbus, // Bus Miscellanous Busdef

  // dp0 glitch filter bypass bus
  dp0_glitch_filter_bypass_out_mscbus,           // Bus Miscellanous Busdef

  // dp0 PES enable bus
  dp0_pes_en_out_mscbus,                         // Bus Miscellanous Busdef

  // dp0 PES input enable bus
  dp0_pes_in_en_out_mscbus,                      // Bus Miscellanous Busdef

  // dp0 PES safe value bus
  dp0_pes_safeval_out_mscbus,                    // Bus Miscellanous Busdef

  // dp0 LVDS enable control bus
  dp0_lvds_en_ctrl_out_mscbus,                   // Bus Miscellanous Busdef

  // dp0 input termination enable bus
  dp0_in_termination_en_out_mscbus,              // Bus Miscellanous Busdef

// dp0 async input from pad bus
output      [31:0] dp0_async_in_from_pad_mscbus;

// dp0 gpio out to buf bus
input       [31:0] dp0_gpio_out_2_buf_mscbus;

// dp0 gpio out enable bus
input       [31:0] dp0_gpio_out_en_2_buf_mscbus;

// dp0 pinmux data to gpio bus
input       [31:0] dp0_pinmuxdata_2_gpio_mscbus;

// dp0 pinmux enable to gpio bus
input       [31:0] dp0_pinmuxen_2_gpio_mscbus;

// dp0 GP DATA IN out bus
output      [31:0] dp0_GP_DATA_IN_out_mscbus;

// dp0 data out to pinmux bus
output      [31:0] dp0_data_out_2_pinmux_mscbus;

// dp0 pinmux muxsel out bus
input      [159:0] dp0_pinmux_muxsel_out_mscbus;

// dp0 in function enable out bus
input     [1023:0] dp0_in_function_en_out_mscbus;

// dp0 analog mode select bus
input       [31:0] dp0_amsel_out_mscbus;

// dp0 drive strength 0 bus
input       [31:0] dp0_ds0_out_mscbus;

// dp0 drive strength 1 bus
input       [31:0] dp0_ds1_out_mscbus;

// dp0 slew control bus
input       [31:0] dp0_slew_out_mscbus;

// dp0 schmitt trigger bus
input       [31:0] dp0_schmitt_out_mscbus;

// dp0 mode 0 bus
input       [31:0] dp0_mode0_out_mscbus;

// dp0 mode 1 bus
input       [31:0] dp0_mode1_out_mscbus;

// dp0 input enable bus
input       [31:0] dp0_inena_out_mscbus;

// dp0 direction bus
input       [31:0] dp0_dir_out_mscbus;

// dp0 pull enable bus
input       [31:0] dp0_pull_en_out_mscbus;

// dp0 pull type bus
input       [31:0] dp0_pull_type_out_mscbus;

// dp0 glitch filter debounce clock select bus
input       [63:0] dp0_glitch_filter_debounce_clk_sel_out_mscbus;

// dp0 glitch filter bypass bus
input       [31:0] dp0_glitch_filter_bypass_out_mscbus;

// dp0 PES enable bus
input      [255:0] dp0_pes_en_out_mscbus;

// dp0 PES input enable bus
input       [31:0] dp0_pes_in_en_out_mscbus;

// dp0 PES safe value bus
input       [63:0] dp0_pes_safeval_out_mscbus;

// dp0 LVDS enable control bus
input       [31:0] dp0_lvds_en_ctrl_out_mscbus;

//======================================
// Signal Declarations
//======================================
wire      [6:0] DP0_0_in_mux_peripheral_mscbus;
wire      [4:0] DP0_10_in_mux_peripheral_mscbus;
wire      [4:0] DP0_11_in_mux_peripheral_mscbus;
wire      [4:0] DP0_12_in_mux_peripheral_mscbus;
wire      [4:0] DP0_13_in_mux_peripheral_mscbus;
wire            DP0_13_out_demux_peripheral_mscbus;
wire      [5:0] DP0_14_in_mux_peripheral_mscbus;
wire            DP0_14_out_demux_peripheral_mscbus;
wire      [5:0] DP0_15_in_mux_peripheral_mscbus;
wire            DP0_15_out_demux_peripheral_mscbus;
wire      [3:0] DP0_16_in_mux_peripheral_mscbus;
wire      [1:0] DP0_16_out_demux_peripheral_mscbus;
wire      [4:0] DP0_17_in_mux_peripheral_mscbus;
wire            DP0_17_out_demux_peripheral_mscbus;
wire      [4:0] DP0_18_in_mux_peripheral_mscbus;
wire            DP0_18_out_demux_peripheral_mscbus;
wire      [5:0] DP0_19_in_mux_peripheral_mscbus;
wire      [3:0] DP0_1_in_mux_peripheral_mscbus;
wire      [1:0] DP0_1_out_demux_peripheral_mscbus;
wire      [5:0] DP0_20_in_mux_peripheral_mscbus;
wire     [31:0] dp0_GP_DATA_IN_out_mscbus;
wire     [31:0] dp0_amsel_out_mscbus;
wire     [31:0] dp0_async_in_from_pad_mscbus;
wire     [31:0] dp0_data_out_2_pinmux_mscbus;
wire     [31:0] dp0_dir_out_mscbus;
wire     [31:0] dp0_ds0_out_mscbus;
wire     [31:0] dp0_ds1_out_mscbus;
wire     [31:0] dp0_glitch_filter_bypass_out_mscbus;
wire     [63:0] dp0_glitch_filter_debounce_clk_sel_out_mscbus;
wire     [31:0] dp0_gpio_out_2_buf_mscbus;
wire     [31:0] dp0_gpio_out_en_2_buf_mscbus;
wire   [1023:0] dp0_in_function_en_out_mscbus;
wire     [31:0] dp0_in_termination_en_out_mscbus;
wire     [31:0] dp0_inena_out_mscbus;
wire     [31:0] dp0_lvds_en_ctrl_out_mscbus;
wire     [31:0] dp0_mode0_out_mscbus;
wire     [31:0] dp0_mode1_out_mscbus;
wire    [255:0] dp0_pes_en_out_mscbus;
wire     [31:0] dp0_pes_in_en_out_mscbus;
wire     [63:0] dp0_pes_safeval_out_mscbus;
wire    [159:0] dp0_pinmux_muxsel_out_mscbus;
wire     [31:0] dp0_pinmuxdata_2_gpio_mscbus;
wire     [31:0] dp0_pinmuxen_2_gpio_mscbus;
wire     [31:0] dp0_pull_en_out_mscbus;
wire     [31:0] dp0_pull_type_out_mscbus;
pinmux_with_io_dp #(.I_NUM_PERIPHERALS(7), .O_NUM_PERIPHERALS(0), .DATA_WIDTH(1), .SEL_WIDTH(5), .array_cell_index(0)) I_b_DP0_0(
  .i_clk(gpio_clock),
  .i_clk_rc(clk_rc),
  .i_clk_perpll(clk_perpll),
  .i_rst_n(sys_reset_n),
  .amsel_out_mscbus(dp0_amsel_out_mscbus[0]),
  .ds0_out_mscbus(dp0_ds0_out_mscbus[0]),
  .ds1_out_mscbus(dp0_ds1_out_mscbus[0]),
  .slew_out_mscbus(dp0_slew_out_mscbus[0]),
  .schmitt_out_mscbus(dp0_schmitt_out_mscbus[0]),
  .mode0_out_mscbus(dp0_mode0_out_mscbus[0]),
  .mode1_out_mscbus(dp0_mode1_out_mscbus[0]),
  .inena_out_mscbus(dp0_inena_out_mscbus[0]),
  .dir_out_mscbus(dp0_dir_out_mscbus[0]),
  .pull_en_out_mscbus(dp0_pull_en_out_mscbus[0]),
  .pull_type_out_mscbus(dp0_pull_type_out_mscbus[0]),
  .pinmux_muxsel_out_mscbus(dp0_pinmux_muxsel_out_mscbus[4:0]),
  .in_function_en_out_mscbus(dp0_in_function_en_out_mscbus[31:0]),
  .async_in_from_pad_mscbus(dp0_async_in_from_pad_mscbus[0]),
  .gpio_out_2_buf_mscbus(dp0_gpio_out_2_buf_mscbus[0]),
  .gpio_out_en_2_buf_mscbus(dp0_gpio_out_en_2_buf_mscbus[0]),
  .pinmuxdata_2_gpio_mscbus(dp0_pinmuxdata_2_gpio_mscbus[0]),
  .pinmuxen_2_gpio_mscbus(dp0_pinmuxen_2_gpio_mscbus[0]),
  .GP_DATA_IN_out_mscbus(dp0_GP_DATA_IN_out_mscbus[0]),
  .data_out_2_pinmux_mscbus(dp0_data_out_2_pinmux_mscbus[0]),
  .lvds_en_ctrl_out_mscbus(dp0_lvds_en_ctrl_out_mscbus[0]),
  .in_termination_en_out_mscbus(dp0_in_termination_en_out_mscbus[0]),
  .i_peripheral_oe({7{1'b1}}),
  .i_peripheral_out(DP0_0_in_mux_peripheral_mscbus[6:0]),
  .io_pad(DP0_0_IO)
);
pinmux_with_io_dp #(.I_NUM_PERIPHERALS(4), .O_NUM_PERIPHERALS(2), .DATA_WIDTH(1), .SEL_WIDTH(5), .array_cell_index(1)) I_b_DP0_1(
  .i_clk(gpio_clock),
  .i_clk_rc(clk_rc),
  .i_clk_perpll(clk_perpll),
  .i_rst_n(sys_reset_n),
  .amsel_out_mscbus(dp0_amsel_out_mscbus[1]),
  .ds0_out_mscbus(dp0_ds0_out_mscbus[1]),
  .ds1_out_mscbus(dp0_ds1_out_mscbus[1]),
  .slew_out_mscbus(dp0_slew_out_mscbus[1]),
  .schmitt_out_mscbus(dp0_schmitt_out_mscbus[1]),
  .mode0_out_mscbus(dp0_mode0_out_mscbus[1]),
  .mode1_out_mscbus(dp0_mode1_out_mscbus[1]),
  .inena_out_mscbus(dp0_inena_out_mscbus[1]),
  .dir_out_mscbus(dp0_dir_out_mscbus[1]),
  .pull_en_out_mscbus(dp0_pull_en_out_mscbus[1]),
  .pull_type_out_mscbus(dp0_pull_type_out_mscbus[1]),
  .pinmux_muxsel_out_mscbus(dp0_pinmux_muxsel_out_mscbus[9:5]),
  .in_function_en_out_mscbus(dp0_in_function_en_out_mscbus[63:32]),
  .async_in_from_pad_mscbus(dp0_async_in_from_pad_mscbus[1]),
  .gpio_out_2_buf_mscbus(dp0_gpio_out_2_buf_mscbus[1]),
  .gpio_out_en_2_buf_mscbus(dp0_gpio_out_en_2_buf_mscbus[1]),
  .pinmuxdata_2_gpio_mscbus(dp0_pinmuxdata_2_gpio_mscbus[1]),
  .pinmuxen_2_gpio_mscbus(dp0_pinmuxen_2_gpio_mscbus[1]),
  .GP_DATA_IN_out_mscbus(dp0_GP_DATA_IN_out_mscbus[1]),
  .data_out_2_pinmux_mscbus(dp0_data_out_2_pinmux_mscbus[1]),
  .lvds_en_ctrl_out_mscbus(dp0_lvds_en_ctrl_out_mscbus[1]),
  .in_termination_en_out_mscbus(dp0_in_termination_en_out_mscbus[1]),
  .i_peripheral_oe({4{1'b1}}),
  .i_peripheral_out(DP0_1_in_mux_peripheral_mscbus[3:0]),
  .o_peripheral_in(DP0_1_out_demux_peripheral_mscbus[1:0]),
  .io_pad(DP0_1_IO)
);

