module assertion_gen();

`define ADC0EXTMUXSEL0_OE 0
`define ADC0EXTMUXSEL0_OUT 0
`define ADC0EXTMUXSEL1_OE 0
`define ADC0EXTMUXSEL1_OUT 0
`define ADC0EXTMUXSEL2_OE 0
`define ADC0EXTMUXSEL2_OUT 0
`define ADC0EXTMUXSEL3_OE 0
`define ADC0EXTMUXSEL3_OUT 0
`define ADC1EXTMUXSEL0_OE 0
`define ADC1EXTMUXSEL0_OUT 0
`define ADC1EXTMUXSEL1_OE 0
`define CAN0RX_IN 0
`define CAN0RX_OE 0
`define CAN0RX_OUT 0
`define CAN0TX_IN 0
`define CAN0TX_OE 1'b1
`define CAN0TX_OUT ioss_wrapper.io_CAN0_txd
`define CAN10RX_IN 0
`define CAN10RX_OE 0
`define CAN10RX_OUT 0
`define CAN10TX_IN 0
`define CAN10TX_OE 1'b1
`define CAN10TX_OUT ioss_wrapper.io_CAN10_txd
`define CAN11RX_IN 0
`define CAN11RX_OE 0
`define CAN11RX_OUT 0
`define CAN11TX_IN 0
`define CAN11TX_OE 1'b1
`define CAN11TX_OUT ioss_wrapper.io_CAN11_txd
`define CAN1RX_IN 0
`define CAN1RX_OE 0
`define CAN1RX_OUT 0
`define CAN1TX_IN 0
`define CAN1TX_OE 1'b1
`define CAN1TX_OUT ioss_wrapper.io_CAN1_txd
`define CAN2RX_IN 0
`define CAN2RX_OE 0
`define CAN2RX_OUT 0
`define CAN2TX_IN 0
`define CAN2TX_OE 1'b1
`define CAN2TX_OUT ioss_wrapper.io_CAN2_txd
`define CAN3RX_IN 0
`define CAN3RX_OE 0
`define CAN3RX_OUT 0
`define CAN3TX_IN 0
`define CAN3TX_OE 1'b1
`define CAN3TX_OUT ioss_wrapper.io_CAN3_txd
`define CAN4RX_IN 0
`define CAN4RX_OE 0
`define CAN4RX_OUT 0
`define CAN4TX_IN 0
`define CAN4TX_OE 1'b1
`define CAN4TX_OUT ioss_wrapper.io_CAN4_txd
`define CAN5RX_IN 0
`define CAN5RX_OE 0
`define CAN5RX_OUT 0
`define CAN5TX_IN 0
`define CAN5TX_OE 1'b1
`define CAN5TX_OUT ioss_wrapper.io_CAN5_txd
`define CAN6RX_IN 0
`define CAN6RX_OE 0
`define CAN6RX_OUT 0
`define CAN6TX_IN 0
`define CAN6TX_OE 1'b1
`define CAN6TX_OUT ioss_wrapper.io_CAN6_txd
`define CAN7RX_IN 0
`define CAN7RX_OE 0
`define CAN7RX_OUT 0
`define CAN7TX_IN 0
`define CAN7TX_OE 1'b1
`define CAN7TX_OUT ioss_wrapper.io_CAN7_txd
`define CAN8RX_IN 0
`define CAN8RX_OE 0
`define CAN8RX_OUT 0
`define CAN8TX_IN 0
`define CAN8TX_OE 1'b1
`define CAN8TX_OUT ioss_wrapper.io_CAN8_txd
`define CAN9RX_IN 0
`define CAN9RX_OE 0
`define CAN9RX_OUT 0
`define CAN9TX_IN 0
`define CAN9TX_OE 1'b1
`define CAN9TX_OUT ioss_wrapper.io_CAN9_txd
`define CLKOUT1_OE 0
`define CLKOUT1_OUT 0
`define CLKOUT2_OE 0
`define CLKOUT2_OUT 0
`define DP0_0 ioss_wrapper.DP0_0_IO
`define DP0_0_GPIO_OUTPUT_ENABLE ioss_wrapper.gpio_dir_out_mscbus[0]
`define DP0_0_INFUNC_EN 0
`define DP0_0_OUTFUNC_SEL ioss_wrapper.gpio_muxsel_to_out_mscbus[1:0]
`define DP0_0_PINCTRL_0_IE 0
`define DP0_0_PINCTRL_0_OD 1'b0
`define DP0_0_PULLEN ioss_wrapper.gpio_pull_en_out_mscbus[0]
`define DP0_0_PULLSEL ioss_wrapper.gpio_pull_type_out_mscbus[0]
`define DP0_0_pad_y 0
`define DP0_29_pad_y 0
`define DP0_2_GPIO_OUTPUT_ENABLE ioss_wrapper.gpio_dir_out_mscbus[2]
`define DP0_2_INFUNC_EN 0
`define DP0_2_OUTFUNC_SEL ioss_wrapper.gpio_muxsel_to_out_mscbus[5:4]
`define DP0_2_PINCTRL_0_IE 0
`define DP0_2_PINCTRL_0_OD 1'b0
`define DP0_2_PULLEN ioss_wrapper.gpio_pull_en_out_mscbus[2]
`define DP0_2_PULLSEL ioss_wrapper.gpio_pull_type_out_mscbus[2]
`define DP0_2_pad_y 0
// Properties
 property iomux_output_drive(logic funcsel, logic gpioouten, logic oe, logic od, logic func_out, logic pad);
  (funcsel == 1 && gpioouten == 1 && oe == 1 && od == 0) |-> (pad == func_out);
 endproperty
 property iomux_output_open_drain(logic funcsel, logic gpioouten, logic oe, logic od, logic func_out, logic pad, logic pad_gz);
  (funcsel == 1 && gpioouten == 1 && oe == 1 && od == 1) |-> (pad_gz == !func_out && pad == 0);
 endproperty
 property iomux_pull_up(logic pullen, logic pullsel, logic pad_pullup);
  (pullen == 1 && pullsel == `PULL_UP) |-> (pad_pullup == 1);
 endproperty
 property iomux_pull_up_reverse(logic pad_pullup, logic pullen, logic pullsel);
  (pad_pullup == 1) |-> (pullen == 1 && pullsel == `PULL_UP);
 endproperty
 property iomux_pull_down(logic pullen, logic pullsel, logic pad_pd);
  (pullen == 1 && pullsel == `PULL_DOWN) |-> (pad_pd == 0);
 endproperty
 property iomux_pull_down_reverse(logic pad_pd, logic pullen, logic pullsel);
  (pad_pd == 0) |-> (pullen == 1 && pullsel == `PULL_DOWN);
 endproperty
 property iomux_highz_conditions(logic pullen, logic outen, logic pad);
  (pullen == 0 && outen == 0) |-> (pad == 1'bz);
 endproperty
 property iomux_highz_reverse(logic pad, logic pullen, logic outen);
  (pad == 1'bz) |-> (pullen == 0 && outen == 0);
 endproperty
 property iomux_input_path(logic ie, logic outen, logic [31:0] infunc_en, logic [31:0] in_concat, logic [31:0] pad, logic [31:0] default_value);
  (ie == 1 && outen == 0) |-> (in_concat == (infunc_en & {32{pad}}) | ~infunc_en & {default_value});
 endproperty

// Assertions
ap_DP0_0_FUNCSEL_1_output_drive_chk : assert property(iomux_output_drive(
  .funcsel(`DP0_0_OUTFUNC_SEL),
  .gpioouten(`DP0_0_GPIO_OUTPUT_ENABLE),
  .oe(`CAN0TX_OE),
  .od(`DP0_0_PINCTRL_0_OD),
  .func_out(`CAN0TX_OUT),
  .pad(`DP0_0)
));
ap_DP0_0_FUNCSEL_1_open_drain_chk : assert property(iomux_output_open_drain(
  .funcsel(`DP0_0_OUTFUNC_SEL),
  .gpioouten(`DP0_0_GPIO_OUTPUT_ENABLE),
  .oe(`CAN0TX_OE),
  .od(`DP0_0_PINCTRL_0_OD),
  .func_out(`CAN0TX_OUT),
  .pad(`DP0_0),
  .pad_gz(`DP0_0_pad_y)
));
ap_DP0_0_FUNCSEL_1_highz_cond_chk : assert property(iomux_highz_conditions(
  .pullen(`DP0_0_PULLEN),
  .outen(`DP0_0_GPIO_OUTPUT_ENABLE),
  .pad(`DP0_0)
));
ap_DP0_0_FUNCSEL_1_highz_rev_chk : assert property(iomux_highz_reverse(
  .pad(`DP0_0),
  .pullen(`DP0_0_PULLEN),
  .outen(`DP0_0_GPIO_OUTPUT_ENABLE)
));
ap_DP0_0_FUNCSEL_1_input_chk : assert property(iomux_input_path(
  .ie(`DP0_0_PINCTRL_0_IE),
  .outen(`DP0_0_GPIO_OUTPUT_ENABLE),
  .infunc_en(`DP0_0_INFUNC_EN),
  .in_concat(`input_func_concat_DP0_0),
  .pad(`DP0_0),
  .default_value(`default_value)));
