#!/usr/bin/env python3
import pandas as pd
import argparse
from string import Template
# Argument parsing 
parser = argparse.ArgumentParser(
    description='Generate formal assertions with define, wire, assign, and property blocks.'
)
parser.add_argument('--file', '-f', type=str, required=True, help='CSV file path')
args = parser.parse_args()
# SV text templates 
define_t      = Template('`define ${def_name} (${expr})\n')
wire_decl_t   = Template('wire ${sig};\n')
wire_assign_t = Template('assign ${sig} = `${def_name};\n')
# Collections 
defines, wires, assigns, props, asserts = [], [], [], [], []
pre_defines = set()
input_signals = set()
# default placeholder
pre_defines.add("nan_IN 0")
input_signals.add("nan_IN")
# Property definitions (moved *outside* the per-row loop) 
props.append(" property iomux_output_drive(logic funcsel, logic gpioouten, logic oe, logic od, logic func_out, logic pad);\n")
props.append("  (funcsel == 1 && gpioouten == 1 && oe == 1 && od == 0) |-> (pad == func_out);\n")
props.append(" endproperty\n")
props.append(" property iomux_output_open_drain(logic funcsel, logic gpioouten, logic oe, logic od, logic func_out, logic pad, logic pad_gz);\n")
props.append("  (funcsel == 1 && gpioouten == 1 && oe == 1 && od == 1) |-> (pad_gz == !func_out && pad == 0);\n")
props.append(" endproperty\n")
# Pull-up / pull-down
props.append(" property iomux_pull_up(logic pullen, logic pullsel, logic pad_pullup);\n")
props.append("  (pullen == 1 && pullsel == `PULL_UP) |-> (pad_pullup == 1);\n")
props.append(" endproperty\n")
props.append(" property iomux_pull_up_reverse(logic pad_pullup, logic pullen, logic pullsel);\n")
props.append("  (pad_pullup == 1) |-> (pullen == 1 && pullsel == `PULL_UP);\n")
props.append(" endproperty\n")
props.append(" property iomux_pull_down(logic pullen, logic pullsel, logic pad_pd);\n")
props.append("  (pullen == 1 && pullsel == `PULL_DOWN) |-> (pad_pd == 0);\n")
props.append(" endproperty\n")
props.append(" property iomux_pull_down_reverse(logic pad_pd, logic pullen, logic pullsel);\n")
props.append("  (pad_pd == 0) |-> (pullen == 1 && pullsel == `PULL_DOWN);\n")
props.append(" endproperty\n")
# Input high-Z
props.append(" property iomux_highz_conditions(logic pullen, logic outen, logic pad);\n")
props.append("  (pullen == 0 && outen == 0) |-> (pad == 1'bz);\n")
props.append(" endproperty\n")
props.append(" property iomux_highz_reverse(logic pad, logic pullen, logic outen);\n")
props.append("  (pad == 1'bz) |-> (pullen == 0 && outen == 0);\n")
props.append(" endproperty\n")
# Input path
props.append(" property iomux_input_path(logic ie, logic outen, logic [31:0] infunc_en, logic [31:0] in_concat, logic [31:0] pad, logic [31:0] default_value);\n")
props.append("  (ie == 1 && outen == 0) |-> (in_concat == (infunc_en & {32{pad}}) | ~infunc_en & {default_value});\n")
props.append(" endproperty\n")
#  Read CSV and generate per-pad logic 
df = pd.read_csv(args.file)
for idx, row in df.iterrows():
    pad = row.get("Signal", "").strip()
    if not pad:
        continue
    # build input_func_concat bus
    input_func_list = []
    for mux in range(30):
        func = str(row.get(f"GPIO MUX {mux + 1}", "")).strip()
        if func:
            sig = f"`{func}_IN"
            input_func_list.append(sig)
            input_signals.add(sig)
        else:
            input_func_list.append("1'b0")
    reversed_list = list(reversed(input_func_list))
    reversed_list.append("1'b0")
    wires.append(f"wire [31:0] input_func_concat_{pad};\n")
    assigns.insert(0, "assign nan_IN = 1'b0;\n")
    assigns.append(f"assign input_func_concat_{pad} = {{{', '.join(reversed_list)}}};\n")
    # for each possible GPIO MUX instance
    for mux in range(1, 31):
        mux_col = f"GPIO MUX {mux}"
        type_col = f"Signal Type {mux}"
        func     = str(row.get(mux_col, "")).strip()
        sig_type = str(row.get(type_col, "")).strip().upper()
        if not func:
            continue
        # preserve your original pre-defines logic
        pre_defines.update([
            f"{pad} 0",
            f"{pad}_GPIO_OUTPUT_ENABLE 0",
            f"{pad}_PULLEN 0",
            f"{pad}_PULLSEL 0",
            f"PULL_UP 1",
            f"PULL_DOWN 0"            
        ])
        # only assert calls here  properties already defined
        if "O" in sig_type:
            pre_defines.update([
                f"{pad}_OUTFUNC_SEL 0",
                f"{func}_OE 0",
                f"{func}_OUT 0",
                f"{pad}_pad_y 0",
                f"{pad}_PINCTRL_0_OD 0"

            ])
            asserts.append(
                f"ap_{pad}_FUNCSEL_{mux}_output_drive_chk : assert property(iomux_output_drive(\n"
                f"  .funcsel(`{pad}_OUTFUNC_SEL),\n  .gpioouten(`{pad}_GPIO_OUTPUT_ENABLE),\n"
                f"  .oe(`{func}_OE),\n  .od(`{pad}_PINCTRL_0_OD),\n"
                f"  .func_out(`{func}_OUT),\n  .pad(`{pad})\n"
                f"));\n"
            )
            asserts.append(
                f"ap_{pad}_FUNCSEL_{mux}_open_drain_chk : assert property(iomux_output_open_drain(\n"
                f"  .funcsel(`{pad}_OUTFUNC_SEL),\n  .gpioouten(`{pad}_GPIO_OUTPUT_ENABLE),\n"
                f"  .oe(`{func}_OE),\n  .od(`{pad}_PINCTRL_0_OD),\n"
                f"  .func_out(`{func}_OUT),\n  .pad(`{pad}),\n  .pad_gz(`{pad}_pad_y)\n"
                f"));\n"
            )
        if "I" in sig_type:
            pre_defines.update([
                f"default_value 0",
                f"{func}_IN 0",
                f"input_func_concat_{pad} 0",
                f"{pad}_INFUNC_EN 0",
                f"{pad}_PINCTRL_0_IE 0"
            ])
            asserts.append(
                f"ap_{pad}_FUNCSEL_{mux}_highz_cond_chk : assert property(iomux_highz_conditions(\n"
                f"  .pullen(`{pad}_PULLEN),\n  .outen(`{pad}_GPIO_OUTPUT_ENABLE),\n  .pad(`{pad})\n"
                f"));\n"
            )
            asserts.append(
                f"ap_{pad}_FUNCSEL_{mux}_highz_rev_chk : assert property(iomux_highz_reverse(\n"
                f"  .pad(`{pad}),\n  .pullen(`{pad}_PULLEN),\n  .outen(`{pad}_GPIO_OUTPUT_ENABLE)\n"
                f"));\n"
            )
            asserts.append(
                f"ap_{pad}_FUNCSEL_{mux}_input_chk : assert property(iomux_input_path(\n"
                f"  .ie(`{pad}_PINCTRL_0_IE),\n  .outen(`{pad}_GPIO_OUTPUT_ENABLE),\n"
                f"  .infunc_en(`{pad}_INFUNC_EN),\n  .in_concat(`input_func_concat_{pad}),\n  .pad(`{pad}),\n  .default_value(`default_value)"
                f"));\n"
            )
    # pull-up / pull-down asserts
    asserts.append(
        f"ap_{pad}_FUNCSEL_pull_up_chk : assert property(iomux_pull_up(\n"
        f"  .pullen(`{pad}_PULLEN),\n  .pullsel(`{pad}_PULLSEL),\n  .pad_pullup(`{pad})\n"
        f"));\n"
    )
    asserts.append(
        f"ap_{pad}_FUNCSEL_pull_up_reverse_chk : assert property(iomux_pull_up_reverse(\n"
        f"  .pad_pullup(`{pad}),\n  .pullen(`{pad}_PULLEN),\n  .pullsel(`{pad}_PULLSEL)\n"
        f"));\n"
    )
    asserts.append(
        f"ap_{pad}_FUNCSEL_pull_down_chk : assert property(iomux_pull_down(\n"
        f"  .pullen(`{pad}_PULLEN),\n  .pullsel(`{pad}_PULLSEL),\n  .pad_pd(`{pad})\n"
        f"));\n"
    )
    asserts.append(
        f"ap_{pad}_FUNCSEL_pull_down_reverse_chk : assert property(iomux_pull_down_reverse(\n"
        f"  .pad_pd(`{pad}),\n  .pullen(`{pad}_PULLEN),\n  .pullsel(`{pad}_PULLSEL)\n"
        f"));\n"
    )    # declare all input_signals as wires & assign to 0 by default
    #for sig in sorted(input_signals):
     #   wires.append(wire_decl_t.substitute(sig=sig))
      #  assigns.append(f"assign {sig} = 1'b0;\n")
#  Write out the final SystemVerilog file 
#assigns.insert(0, "assign nan_IN = 1'b0;\n")
output_file = f"{args.file.rsplit('.', 1)[0]}_structured_formal_1_assertions.sv"
with open(output_file, 'w') as f:
    f.write("module assertion_gen();\n\n")
    # pre-defines
    for signal in sorted(pre_defines):
        f.write(f"`define {signal}\n")
    # defines, wires, assigns
    for d in sorted(set(defines)):
        f.write(d)
    for w in sorted(set(wires)):
        f.write(w)
    for a in sorted(set(assigns)):
        f.write(a)
    # properties (one copy each)
    f.write("\n// Properties\n")
    for p in props:
        f.write(p)
    # assertions
    f.write("\n// Assertions\n")
    for a in asserts:
        f.write(a)
    f.write("\nendmodule\n")
    f.write("\nbind assertion_gen pinmux_wrapper bind_inst();")
print(f" Structured formal assertions written to: {output_file}")



