# TI-ROM checksums HexFiend template
# Version 2.3
# (c) 2021-2025 LogicalJoe

proc Checksum {a b {c ""}} {
	entry "Checksum$c:" [format %0$b\X [expr 16**$b-1&$a]]
}
proc Current b {
	entry "Current:" [format %0[expr 2*$b]X [uint[expr 8*$b]]] $b [expr [pos]-$b]
}

set hl 0
# TI-92 (II) & 68K boot
if {[len] in {65536 1048576 2097152 4194304} && ![hex 2]} {
	big_endian
	set a [hex 6]
	goto 0
	if !($a&0xFF000000FF) {
		for {set i 0} {$i<256} {incr i} {
			set k $i
			foreach j {0 1 2 3 4 5 6 7} {
				set k [expr $k/2^$k%2*0xEDB88320]
			}
			lappend t $k
		}
		set a 0xFFFFFFFF
		while {[pos]-[len]+4} {
			set a [expr $a>>8^[lindex $t [expr [uint8]^$a&255]]]
		}
		set hl ~$a
	} elseif $a&255 {
		while {[pos]-65532} {
			incr hl [uint16]
		}
	} else {
		while {[pos]-[len]+4} {
			incr hl [uint32]
		}
	}
	Checksum $hl 8
	Current 4
	return
}
goto 0
switch [len] {
	32768 { # TI-81
		set hl2 0
		while {[pos]-32766} {
			set c [uint8]
			#1.6K+
			incr hl2 $c
			#1.5K- (CRC16-CCITT)
			set hl [expr 4129*($hl>>12^$hl>>8&15)^$hl/4096*528^$hl%256<<8^$c]
		}
		Checksum $hl 4 " 1.5K-"
		Checksum -$hl2 4 " 1.6K+"
		Current 2
	}
	49152 { # TI-80
		goto 16384
		while {[pos]-45056} {
			incr hl [uint16]
		}
		Checksum $hl 4
		goto -2
		Current 2
	}
	131072 - 262144 { # TI-8[2356]
		while {![end]} {
			incr hl [uint8]
		}
		Checksum $hl 2
		# valid TI-82 19.006 ROMs return 0x80
	}
	default {
		entry "Unable to apply" ""
	}
}
