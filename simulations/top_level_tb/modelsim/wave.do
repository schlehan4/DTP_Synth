onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /synthi_top_tb/GPIO_26
add wave -noupdate /synthi_top_tb/synthi_top_1/midi_controller_top_1/uart_top_1/baud_tick_1/baud_tick
add wave -noupdate /synthi_top_tb/synthi_top_1/midi_controller_top_1/uart_top_1/uart_controller_fsm_1/uart_state
add wave -noupdate /synthi_top_tb/synthi_top_1/midi_controller_top_1/uart_top_1/uart_controller_fsm_1/shift_enable
add wave -noupdate /synthi_top_tb/synthi_top_1/midi_controller_top_1/signal_parallel
add wave -noupdate /synthi_top_tb/synthi_top_1/midi_controller_top_1/GPIO_26
add wave -noupdate /synthi_top_tb/synthi_top_1/midi_controller_top_1/uart_top_1/shiftreg_s2p_1/serdata_sync
add wave -noupdate /synthi_top_tb/DUT/i2s_master_1/clk_12m
add wave -noupdate -radix hexadecimal /synthi_top_tb/synthi_top_1/midi_controller_top_1/uart_top_1/shiftreg_s2p_1/parallel_out
add wave -noupdate /synthi_top_tb/synthi_top_1/midi_controller_top_1/uart_top_1/uart_controller_fsm_1/data_valid_o
add wave -noupdate -radix hexadecimal -childformat {{/synthi_top_tb/synthi_top_1/midi_controller_top_1/uart_top_1/parallel_out(7) -radix hexadecimal} {/synthi_top_tb/synthi_top_1/midi_controller_top_1/uart_top_1/parallel_out(6) -radix hexadecimal} {/synthi_top_tb/synthi_top_1/midi_controller_top_1/uart_top_1/parallel_out(5) -radix hexadecimal} {/synthi_top_tb/synthi_top_1/midi_controller_top_1/uart_top_1/parallel_out(4) -radix hexadecimal} {/synthi_top_tb/synthi_top_1/midi_controller_top_1/uart_top_1/parallel_out(3) -radix hexadecimal} {/synthi_top_tb/synthi_top_1/midi_controller_top_1/uart_top_1/parallel_out(2) -radix hexadecimal} {/synthi_top_tb/synthi_top_1/midi_controller_top_1/uart_top_1/parallel_out(1) -radix hexadecimal} {/synthi_top_tb/synthi_top_1/midi_controller_top_1/uart_top_1/parallel_out(0) -radix hexadecimal}} -subitemconfig {/synthi_top_tb/synthi_top_1/midi_controller_top_1/uart_top_1/parallel_out(7) {-height 15 -radix hexadecimal} /synthi_top_tb/synthi_top_1/midi_controller_top_1/uart_top_1/parallel_out(6) {-height 15 -radix hexadecimal} /synthi_top_tb/synthi_top_1/midi_controller_top_1/uart_top_1/parallel_out(5) {-height 15 -radix hexadecimal} /synthi_top_tb/synthi_top_1/midi_controller_top_1/uart_top_1/parallel_out(4) {-height 15 -radix hexadecimal} /synthi_top_tb/synthi_top_1/midi_controller_top_1/uart_top_1/parallel_out(3) {-height 15 -radix hexadecimal} /synthi_top_tb/synthi_top_1/midi_controller_top_1/uart_top_1/parallel_out(2) {-height 15 -radix hexadecimal} /synthi_top_tb/synthi_top_1/midi_controller_top_1/uart_top_1/parallel_out(1) {-height 15 -radix hexadecimal} /synthi_top_tb/synthi_top_1/midi_controller_top_1/uart_top_1/parallel_out(0) {-height 15 -radix hexadecimal}} /synthi_top_tb/synthi_top_1/midi_controller_top_1/uart_top_1/parallel_out
add wave -noupdate /synthi_top_tb/DUT/i2s_master_1/clk_12m
add wave -noupdate -radix hexadecimal /synthi_top_tb/DUT/i2s_master_1/clk_12m
add wave -noupdate /synthi_top_tb/dacdat_check
add wave -noupdate /synthi_top_tb/synthi_top_1/tone_generator_1/ton_gen_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {26809 ns} 0} {{Cursor 2} {1521470 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 299
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {1661769 ns} {7188749 ns}
