set_property -dict [list CONFIG.Coe_File {C:/Users/bserg_000/Documents/Source/ReturnAddressEncryption/Mini-Risc-V-Uart-Srcs/gcc/fib0.coe}] [get_ips imem_cell_0]
generate_target all [get_files  C:/Users/bserg_000/Documents/Source/ReturnAddressEncryption/ReturnAddressEncryption.srcs/sources_1/ip/imem_cell_0/imem_cell_0.xci]
catch { config_ip_cache -export [get_ips -all imem_cell_0] }
export_ip_user_files -of_objects [get_files C:/Users/bserg_000/Documents/Source/ReturnAddressEncryption/ReturnAddressEncryption.srcs/sources_1/ip/imem_cell_0/imem_cell_0.xci] -no_script -sync -force -quiet
reset_run imem_cell_0_synth_1
launch_runs -jobs 6 imem_cell_0_synth_1

set_property -dict [list CONFIG.Coe_File {C:/Users/bserg_000/Documents/Source/ReturnAddressEncryption/Mini-Risc-V-Uart-Srcs/gcc/fib1.coe}] [get_ips imem_cell_1]
generate_target all [get_files  C:/Users/bserg_000/Documents/Source/ReturnAddressEncryption/ReturnAddressEncryption.srcs/sources_1/ip/imem_cell_1/imem_cell_1.xci]
catch { config_ip_cache -export [get_ips -all imem_cell_1] }
export_ip_user_files -of_objects [get_files C:/Users/bserg_000/Documents/Source/ReturnAddressEncryption/ReturnAddressEncryption.srcs/sources_1/ip/imem_cell_1/imem_cell_1.xci] -no_script -sync -force -quiet
reset_run imem_cell_1_synth_1
launch_runs -jobs 6 imem_cell_1_synth_1

set_property -dict [list CONFIG.Coe_File {C:/Users/bserg_000/Documents/Source/ReturnAddressEncryption/Mini-Risc-V-Uart-Srcs/gcc/fib2.coe}] [get_ips imem_cell_2]
generate_target all [get_files  C:/Users/bserg_000/Documents/Source/ReturnAddressEncryption/ReturnAddressEncryption.srcs/sources_1/ip/imem_cell_2/imem_cell_2.xci]
catch { config_ip_cache -export [get_ips -all imem_cell_2] }
export_ip_user_files -of_objects [get_files C:/Users/bserg_000/Documents/Source/ReturnAddressEncryption/ReturnAddressEncryption.srcs/sources_1/ip/imem_cell_2/imem_cell_2.xci] -no_script -sync -force -quiet
reset_run imem_cell_2_synth_1
launch_runs -jobs 6 imem_cell_2_synth_1

set_property -dict [list CONFIG.Coe_File {C:/Users/bserg_000/Documents/Source/ReturnAddressEncryption/Mini-Risc-V-Uart-Srcs/gcc/fib3.coe}] [get_ips imem_cell_3]
generate_target all [get_files  C:/Users/bserg_000/Documents/Source/ReturnAddressEncryption/ReturnAddressEncryption.srcs/sources_1/ip/imem_cell_3/imem_cell_3.xci]
catch { config_ip_cache -export [get_ips -all imem_cell_3] }
export_ip_user_files -of_objects [get_files C:/Users/bserg_000/Documents/Source/ReturnAddressEncryption/ReturnAddressEncryption.srcs/sources_1/ip/imem_cell_3/imem_cell_3.xci] -no_script -sync -force -quiet
reset_run imem_cell_3_synth_1
launch_runs -jobs 6 imem_cell_3_synth_1