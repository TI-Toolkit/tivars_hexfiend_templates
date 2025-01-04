# TI-ROM verification HexFiend template
# Version 2.0
# (c) 2021-2025 LogicalJoe

set hl 0
switch -- [len] {
	32768 { # TI-81
		set hl2 0
		while {[pos]<[len]-2} {
			set c [uint8]
			#1.6K+
			incr hl2 $c
			#1.5K- (CRC16-CCITT)
			set hl [expr ((4129*(($hl>>12)^($hl>>8)&15))^(528*($hl>>12))^($hl<<8)^$c)&65535]
		}
		entry "Hash 1.5K-:" [format %04X $hl]
		entry "Hash 1.6K+:" [format %04X [expr 65535&-$hl2]]
		entry "Current:" [format %04X [uint16]] 2 [expr [len]-2]
	}
	49152 { # TI-80
		# yes, only part of the ROM
		goto 0x4000
		while {[pos]<45055} {
			incr hl [uint16]
		}
		entry "Checksum:" [format %02X [expr 65535&$hl]]
		goto 49150
		entry "Current:" [format %04X [uint16]] 2 [expr [len]-2]
	}
	131072 - 262144 { # TI-8[2356]
		while {![end]} {
			incr hl [uint8]
		}
		entry "Checksum:" [format %02X [expr 255&$hl]]
		# TI-82 19.006 doubles the checksum so the valid ROM returns 0x80
	}
	default {
		entry "Cannot apply" ""
	}
}
