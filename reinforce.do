# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns backend.v float_adder.v float_div.v float_multi.v ALTFP_EXa.v float_compare.v

# Load simulation using mux as the top level simulation module.
vsim -L lpm_ver -L altera_mf_ver reinforce

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

force {clock} 0, 1 {1 ns} -repeat 2ns
force {start} 1
force {reset} 0
force {user_choice} 00
run 10ns

force {reset} 1
force {start} 0
run 10ns

force {start} 1
run 200ns


force {start} 0
run 10ns

force {start} 1
run 400ns

force {start} 0
run 10ns

force {start} 1
run 600ns

force {start} 0
run 10ns

force {start} 1
run 800ns

force {start} 0
run 10ns

force {start} 1
run 900ns

force {start} 0
run 10ns

force {start} 1
run 900ns

force {start} 0
run 10ns

force {start} 1
run 900ns

force {start} 0
run 10ns

force {start} 1
run 900ns

force {start} 0
run 10ns

force {start} 1
run 900ns