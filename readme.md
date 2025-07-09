# 🚦 IOMUX Formal Verification Automation @ TI

## 📘 Overview

This project automates the **formal verification of IOMUX (Input/Output Multiplexer)** behavior using Python and SystemVerilog, targeting JasperGold (JG). It focuses on verifying:

- **Output path behavior**: push-pull, open-drain, high-Z
- **Pull-up / Pull-down logic**
- **Input path gating via INFUNC_EN**
- **Safe fallback values when disabled**
- **Property-based assertion generation and binding**

Designed for clean integration with RTL and simulation environments, this setup enables **auto-generation** of design-specific assertions across all PADs and peripherals using Excel mappings.

---

## 🗂️ Directory Structure

iomux_formal/
│
├── assertion_gen/
│ ├── generate_assertions.py # Master script for assertion generation
│ ├── define_mapper.py # Maps signal names to wrapper-level ports
│ ├── templates/
│ │ ├── iomux_output_drive.tpl # Template for output driving assertions
│ │ ├── iomux_pull_up.tpl # Template for pull-up assertions
│ │ ├── iomux_pull_down.tpl # Template for pull-down assertions
│ │ └── iomux_highz_conditions.tpl # High-Z detection property
│
├── test/
│ ├── pinmux_with_io.v # RTL DUT
│ ├── ioss_wrapper.v # Top module instantiating IOMUX
│ └── assertion_gen.sv # Generated property + assertion wrapper
│
├── outputs/
│ ├── macros.sv # define macros for PADs and control
│ ├── properties.sv # property/endproperty blocks
│ └── assertion_gen.sv # Full assertion file with binds
│
├── gpio_mapping.xlsx # Mapping file from PADs to control logic
└── README.md # This file


---

## 📦 Input Requirements

### 🧾 gpio_mapping.xlsx

Excel sheet containing PAD-to-control mappings with at least the following columns:

| Signal (PAD) | PULLEN | PULLSEL | GPIO MUX 0 | ... | GPIO MUX 30 |
|--------------|--------|---------|------------|-----|--------------|
| DP0_6        | ...    | ...     | CAN0TX     | ... | ...          |

- `Signal`: Name of pad (e.g. DP0_6)
- `PULLEN` / `PULLSEL`: Names of control signals
- `GPIO MUX n`: Names of peripheral signals selected via `i_outfunc_sel`

---

## 🚀 How to Use

### Step 1: Generate Assertions

```bash
python3 assertion_gen/generate_assertions.py --file gpio_mapping.xlsx
📌 This generates:

macros.sv: define, wire, and assign macros

properties.sv: reusable properties (property ... endproperty)

assertion_gen.sv: full assertion module instantiating those properties

Optional args:

--outdir outputs/ (default is current dir)

--topmodule ioss_wrapper (used for define mapping)

--prefix DP (used to filter only DPxx pads)

Step 2: Integrate into Testbench
Include assertion_gen.sv in your filelist or RTL

Ensure the top-level ports match those referenced in define macros

In JasperGold, use:

tcl
Copy
Edit


analyze -sv -f rtl.f
elaborate ioss_wrapper
property -file assertion_gen.sv
formal compile
formal verify
| Category          | Property File            | Description                                                     |
| ----------------- | ------------------------ | --------------------------------------------------------------- |
| Output Push-Pull  | `iomux_output_drive`     | Ensures PAD matches selected peripheral output when mux enabled |
| Pull-Up Enabled   | `iomux_pull_up`          | Ensures PAD is driven high when pull-up is enabled              |
| Pull-Down Enabled | `iomux_pull_down`        | Ensures PAD is driven low when pull-down is enabled             |
| High-Z Detection  | `iomux_highz_conditions` | Detects unintentional high-Z scenarios                          |
| Input Path Gating | \[Planned]               | Checks INFUNC\_EN disables input path correctly                 |
Design Assumptions
Each PAD connects to a mux (i_outfunc_sel) and is gated via i_gpioctlx_oe or equivalent.

Control logic includes PULLEN, PULLSEL, GPIO override signals, and pad directions.

Wrapper-level top (ioss_wrapper) instantiates pinmux_with_io.

🧪 Testing
Minimal working example is included in test/ directory:

pinmux_with_io.v: IOMUX logic including output muxing and PAD interfacing

ioss_wrapper.v: Instantiates pinmux module and GPIO connections

assertion_gen.sv: Generated assertion logic for select signals

📌 Future Work
Support for input mux assertion generation (via INFUNC_EN)

Add automatic bind file generation per instance

Enable partial assertion generation (e.g., --filter CAN0*)

Integrate vacuous assertion reporting via Jasper TCL

Modularize assertion types for user toggling

👤 Author
