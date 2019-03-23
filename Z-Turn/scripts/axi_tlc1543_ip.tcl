proc adi_ip_files {ip_name ip_files} {

  global ip_constr_files

  set ip_constr_files ""
  foreach m_file $ip_files {
    if {[file extension $m_file] eq ".xdc"} {
      lappend ip_constr_files $m_file
    }
  }

  set proj_fileset [get_filesets sources_1]
  add_files -norecurse -scan_for_includes -fileset $proj_fileset $ip_files
  set_property "top" "$ip_name" $proj_fileset
}
set ip_name axi_tlc1543

cd ../../ip_repo/$ip_name/
file delete -force tmpprj/
file delete -force ipcfg/
file mkdir tmpprj/
file mkdir ipcfg/
cd tmpprj/

create_project $ip_name . -force
source ../../../scripts/adi_xilinx_msg.tcl

adi_ip_files $ip_name [list \
    "../src/edgedetect.v" \
    "../src/top_1543.v" \
    "../src/TLC1543_v1_0_S00_AXI.v"  \
    "../src/top/TLC1543_v1_0.v"  ]         ; # Should top, Update Feture

ipx::package_project -root_dir ../ipcfg/ -vendor user.com -library user -taxonomy /FlyLower ;#-archive_source_project true
set_property name $ip_name [ipx::current_core]
#set_property display_name $ip_name [ipx::current_core]
set_property vendor_display_name {FlyLower} [ipx::current_core]
set_property company_url {http://www.user.com} [ipx::current_core]

set i_families ""
foreach i_part [get_parts] {
    lappend i_families [get_property FAMILY $i_part]
}
set i_families [lsort -unique $i_families]
set s_families [get_property supported_families [ipx::current_core]]
foreach i_family $i_families {
    set s_families "$s_families $i_family Production"
    set s_families "$s_families $i_family Beta"
}
set_property supported_families $s_families [ipx::current_core]

ipx::remove_all_bus_interface [ipx::current_core]

set i_filegroup [ipx::get_file_groups -of_objects [ipx::current_core] -filter {NAME =~ *synthesis*}]
foreach i_file $ip_constr_files {
    set i_module [file tail $i_file]
    regsub {_constr\.xdc} $i_module {} i_module
    ipx::add_file $i_file $i_filegroup
    ipx::reorder_files -front $i_file $i_filegroup
    set_property SCOPED_TO_REF $i_module [ipx::get_files $i_file -of_objects $i_filegroup]
}

set memory_maps [ipx::get_memory_maps * -of_objects [ipx::current_core]]
  foreach map $memory_maps {
    ipx::remove_memory_map [lindex $map 2] [ipx::current_core ]
  }

  ipx::infer_bus_interface {\
    s00_axi_awvalid \
    s00_axi_awaddr \
    s00_axi_awprot \
    s00_axi_awready \
    s00_axi_wvalid \
    s00_axi_wdata \
    s00_axi_wstrb \
    s00_axi_wready \
    s00_axi_bvalid \
    s00_axi_bresp \
    s00_axi_bready \
    s00_axi_arvalid \
    s00_axi_araddr \
    s00_axi_arprot \
    s00_axi_arready \
    s00_axi_rvalid \
    s00_axi_rdata \
    s00_axi_rresp \
    s00_axi_rready} \
  xilinx.com:interface:aximm_rtl:1.0 [ipx::current_core]

  ipx::infer_bus_interface s00_axi_aclk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
  ipx::infer_bus_interface s00_axi_aresetn xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]

  set raddr_width [expr [get_property SIZE_LEFT [ipx::get_ports -nocase true s00_axi_araddr -of_objects [ipx::current_core]]] + 1]
  set waddr_width [expr [get_property SIZE_LEFT [ipx::get_ports -nocase true s00_axi_awaddr -of_objects [ipx::current_core]]] + 1]

  if {$raddr_width != $waddr_width} {
    puts [format "WARNING: AXI address width mismatch for %s (r=%d, w=%d)" $ip_name $raddr_width, $waddr_width]
    set range 65536
  } else {
    if {$raddr_width >= 16} {
      set range 65536
    } else {
      set range [expr 1 << $raddr_width]
    }
  }

  ipx::add_memory_map {s00_axi} [ipx::current_core]
  set_property slave_memory_map_ref {s00_axi} [ipx::get_bus_interfaces s00_axi -of_objects [ipx::current_core]]
  ipx::add_address_block {s00_axi} [ipx::get_memory_maps s00_axi -of_objects [ipx::current_core]]
  set_property range $range [ipx::get_address_blocks s00_axi\
    -of_objects [ipx::get_memory_maps s00_axi -of_objects [ipx::current_core]]]
  ipx::add_bus_parameter ASSOCIATED_BUSIF [ipx::get_bus_interfaces s00_axi_aclk \
    -of_objects [ipx::current_core]]
  set_property value s00_axi [ipx::get_bus_parameters ASSOCIATED_BUSIF \
    -of_objects [ipx::get_bus_interfaces s00_axi_aclk \
    -of_objects [ipx::current_core]]]
# ipx::add_address_block_parameter OFFSET_BASE_PARAM [ipx::get_address_blocks s00_axi -of_objects [ipx::get_memory_maps s00_axi -of_objects [ipx::current_core]]]
# set_property value "C_S_AXI_BASEADDR" [ipx::get_address_block_parameter OFFSET_BASE_PARAM [ipx::get_address_blocks s00_axi -of_objects [ipx::get_memory_maps s00_axi -of_objects [ipx::current_core]]]]
# ipx::add_address_block_parameter OFFSET_HIGH_PARAM [ipx::get_address_blocks s00_axi -of_objects [ipx::get_memory_maps s00_axi -of_objects [ipx::current_core]]]
# set_property value "C_S_AXI_HIGHADDR" [ipx::get_address_block_parameter OFFSET_HIGH_PARAM [ipx::get_address_blocks s00_axi -of_objects [ipx::get_memory_maps s00_axi -of_objects [ipx::current_core]]]]

ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "C_S00_AXI_DATA_WIDTH" -component [ipx::current_core]]
ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "C_S00_AXI_ADDR_WIDTH" -component [ipx::current_core]]

ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "SYS_CLOCK_FREQ" -component [ipx::current_core]]
ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "SPI_CLOCK_FREQ" -component [ipx::current_core]]

ipgui::add_page -name {AXI Lite Settings} -component [ipx::current_core] -display_name {AXI Lite Settings}
set group_parent [ipgui::get_pagespec -name "AXI Lite Settings" -component [ipx::current_core]] 
ipgui::add_group -name {General} -component [ipx::current_core] -parent $group_parent -display_name {General} -layout {vertical}
set param_parent [ipgui::get_groupspec -name "General" -component [ipx::current_core]]
ipgui::add_param -name {SYS_CLOCK_FREQ} -component [ipx::current_core] -parent $param_parent
ipgui::add_param -name {SPI_CLOCK_FREQ} -component [ipx::current_core] -parent $param_parent
set_property value_validation_type range_long [ipx::get_user_parameters SYS_CLOCK_FREQ -of_objects [ipx::current_core]]
set_property value_validation_range_minimum 0 [ipx::get_user_parameters SYS_CLOCK_FREQ -of_objects [ipx::current_core]]
set_property value_validation_range_maximum 100000000 [ipx::get_user_parameters SYS_CLOCK_FREQ -of_objects [ipx::current_core]]
set_property value 100000000 [ipx::get_user_parameters SYS_CLOCK_FREQ -of_objects [ipx::current_core]]
set_property value 100000000 [ipx::get_hdl_parameters SYS_CLOCK_FREQ -of_objects [ipx::current_core]]
set_property value 1000000   [ipx::get_user_parameters SPI_CLOCK_FREQ -of_objects [ipx::current_core]]
set_property value 1000000   [ipx::get_hdl_parameters SPI_CLOCK_FREQ -of_objects [ipx::current_core]]

set rev [get_property core_revision [ipx::current_core]]
set_property core_revision [expr $rev+1] [ipx::current_core]

# if 0 {
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project ;#-delete
cd ../../../scripts/
# }

exit