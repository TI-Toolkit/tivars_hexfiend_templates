# TI-ROM checksums HexFiend template
# Version 2.1
# (c) 2021-2025 LogicalJoe

proc Checksum {a b {c ""}} {
	entry "Checksum$c:" [format %0$b\X [expr 16**$b-1&$a]]
}
proc Current {b} {
	entry "Current:" [format %0[expr 2*$b]X [uint[expr 8*$b]]] $b [expr [pos]-$b]
}

set hl 0
goto -6
if {[len] in {1048576 2097152} && [uint16]==43605} { # TI-92 (II)
	goto 0
	big_endian
	while {[pos]-[len]+4} {
		incr hl [uint32]
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
			set hl [expr ((4129*(($hl>>12)^($hl>>8)&15))^(528*($hl>>12))^($hl<<8)^$c)&65535]
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
		goto 49150
		Current 2
	}
	65536 { # 68K boot
		big_endian
		while {[pos]-65532} {
			incr hl [uint16]
		}
		Checksum $hl 8
		Current 4
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
