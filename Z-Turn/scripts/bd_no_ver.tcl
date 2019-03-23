set fid_i [open system.tcl r]
set fid_o [open system_nover.tcl w]
while {[gets $fid_i line] != -1} {
	if {[string first "set scripts_vivado_version" $line] != -1} {
		set pline "set scripts_vivado_version \[version -short\]"
	} elseif {[string first "set bCheckIPs 1" $line] != -1} {
		set pline "set bCheckIPs 0"
	} elseif {[string first "create_bd_cell" $line] != -1} {
		regsub -all {\:(\d+)\.(\d+)} $line "" pline
	} else {
		set pline $line
	}
	puts $fid_o $pline
}

close $fid_i
close $fid_o