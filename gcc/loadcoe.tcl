set_property -dict [list CONFIG.Coe_File {C:/Users/grayb/Projects/Mini-Risc-V-Uart-Srcs/gcc/test0.coe}] [get_ips mem_cell_0]
generate_target all [get_files  C:/Users/grayb/Projects/RISCV/RISCV.srcs/sources_1/ip/mem_cell_0/mem_cell_0.xci]
catch { config_ip_cache -export [get_ips -all mem_cell_0] }
export_ip_user_files -of_objects [get_files C:/Users/grayb/Projects/RISCV/RISCV.srcs/sources_1/ip/mem_cell_0/mem_cell_0.xci] -no_script -sync -force -quiet
reset_run mem_cell_0_synth_1
launch_runs -jobs 6 mem_cell_0_synth_1

set_property -dict [list CONFIG.Coe_File {C:/Users/grayb/Projects/Mini-Risc-V-Uart-Srcs/gcc/test1.coe}] [get_ips mem_cell_1]
generate_target all [get_files  C:/Users/grayb/Projects/RISCV/RISCV.srcs/sources_1/ip/mem_cell_1/mem_cell_1.xci]
catch { config_ip_cache -export [get_ips -all mem_cell_1] }
export_ip_user_files -of_objects [get_files C:/Users/grayb/Projects/RISCV/RISCV.srcs/sources_1/ip/mem_cell_1/mem_cell_1.xci] -no_script -sync -force -quiet
reset_run mem_cell_1_synth_1
launch_runs -jobs 6 mem_cell_1_synth_1

set_property -dict [list CONFIG.Coe_File {C:/Users/grayb/Projects/Mini-Risc-V-Uart-Srcs/gcc/test2.coe}] [get_ips mem_cell_2]
generate_target all [get_files  C:/Users/grayb/Projects/RISCV/RISCV.srcs/sources_1/ip/mem_cell_2/mem_cell_2.xci]
catch { config_ip_cache -export [get_ips -all mem_cell_2] }
export_ip_user_files -of_objects [get_files C:/Users/grayb/Projects/RISCV/RISCV.srcs/sources_1/ip/mem_cell_2/mem_cell_2.xci] -no_script -sync -force -quiet
reset_run mem_cell_2_synth_1
launch_runs -jobs 6 mem_cell_2_synth_1

set_property -dict [list CONFIG.Coe_File {C:/Users/grayb/Projects/Mini-Risc-V-Uart-Srcs/gcc/test3.coe}] [get_ips mem_cell_3]
generate_target all [get_files  C:/Users/grayb/Projects/RISCV/RISCV.srcs/sources_1/ip/mem_cell_3/mem_cell_3.xci]
catch { config_ip_cache -export [get_ips -all mem_cell_3] }
export_ip_user_files -of_objects [get_files C:/Users/grayb/Projects/RISCV/RISCV.srcs/sources_1/ip/mem_cell_3/mem_cell_3.xci] -no_script -sync -force -quiet
reset_run mem_cell_3_synth_1
launch_runs -jobs 6 mem_cell_3_synth_1