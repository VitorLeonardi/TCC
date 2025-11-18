create_clock -name {clk_in} -period 20.000 -waveform {0.000 10.000} [get_ports {clk_in}]

create_generated_clock -name {clk} -source [get_ports {clk_in}] -multiply_by 1 -divide_by 1 [get_nets {pll:pll_inst|altpll:altpll_component|pll_altpll:auto_generated|wire_pll1_clk[0]}]

set_clock_uncertainty 2.0 -from  [get_clocks {clk_in clk}]

# Optional: Input/output delays relative to clk_in (adjust ports as needed; e.g., 50% period for worst-case)
#set_input_delay -clock clk_in 10.000 [get_ports {reset, rin}] 
#set_output_delay -clock clk_in 10.000 [get_ports {rout}]

# Optional: False path for async signals (e.g., reset)
#set_false_path -from [get_ports {reset, rin}]
#set_min_delay 0.1 -from [get_registers *] -to [get_registers *]  