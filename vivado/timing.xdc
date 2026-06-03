# KAN Top - Timing Constraints
# Target: xc7z020clg400-2

# 120 MHz clock constraint (period = 8.333 ns)
create_clock -period 8.333 -name clk -waveform {0.000 4.167} [get_ports clk]
