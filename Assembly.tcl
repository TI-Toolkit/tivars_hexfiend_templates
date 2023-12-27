# TI eZ80/Z80 shell header parser HexFiend template include
# Version 1.0
# (c) 2021-2023 LogicalJoe
# .hidden = true;

proc isAsm {asm} {
	return [expr {$asm in {0xEF7B 0xEF69 0xBB6D 0xC930 0xAF28 0xD900 0xD500}}]
}

proc ReadAsm {assembly datalen} {

set	posset [expr [pos]]

if {$assembly == 0xBB6D} { # mono Z80
	hex	2 "Z80 token"
	set	b1 [uint8]
	if {$b1==201} { # ret
		# http://www.detachedsolutions.com/mirageos/develop/
		# always BB6D for MirageOS
		set	b2 [uint8]
		move	-2
		if {$b2 in {1 3}} {
			hex	1 "MirageOS"
			hex	1 "Type"
			bytes	30 "15x15 Button"
			if {$b2 == 3} {
				uint16	-hex "Quit address"
			}
			cstr	ascii "Description"
		} elseif {$b2 == 2} {
			hex	1 "MirageOS"
			hex	1 "External Interface"
			hex	1 "Interface ID"
			hex	1 "X coord"
			cstr	ascii "Description"
		} elseif {$b2 == 48} {
			hex	1 "ION"
			hex	2 "jr nc"
			cstr	ascii "Description"
		} elseif {$b2 == 84} {
			# https://www.ticalc.org/cgi-bin/zipview?83plus/asm/shells/tsekrnl.zip;tsedev.txt
			move	1
			if {[uint32] == 21320532} {
				move	-5
				hex	1 "RET for TI-OS"
				bytes	4 "TSE header"
				cstr	ascii "Program title"
				uint16	"External data required"
			} else {
				move	-5
			}
		}
	} elseif {$b1==175} {
		set	b2 [uint8]
		move	-2
		if {$b2 == 48} {
			hex	1 "ION & OS"
			hex	2 "jr nc"
			cstr	ascii "Description"
		}
	} else { move -1 }
	bytes	[expr $datalen+$posset-[pos]] "Assembly"
} elseif {$assembly == 0xC930} { # `ret / jr nc` for 83 ION
	hex	1 "83 ION"
	hex	2 "jr nc"
	cstr	ascii "Description"
	bytes	[expr $datalen+$posset-[pos]] "Assembly"
} elseif {($assembly & 255) == 24} {
	hex	1 [expr $assembly>>8?"TI-Explorer":"ASHELL83"]
	set	jr [hex 2 "jr"]
	hex	2 "Table pointer"
	hex	2 "Description pointer"
	if {$jr==0x1806} {
		hex	2 "Icon pointer"
	}
	bytes	[expr $datalen+$posset-[pos]] "Assembly"
} elseif {$assembly == 0xAF28} { # `xor a / jr z` 83 SOS
	hex	1 "83 SOS"
	hex	2 "jr z"
	hex	2 "Libraries"
	hex	2 "Description pointer"
	bytes	[expr $datalen+$posset-[pos]] "Assembly"
} elseif {$assembly == 0xEF7B} { # CE eZ80
	hex	2 "eZ80"
	set	eZtype [uint8]
	move	-1
	if !$eZtype {
		hex	1 "C"
	} elseif {$eZtype == 127} {
		hex	1 "ICE"
	}
	set	jp [uint8]
	move	3
	set	b2 [uint8]
	move	-5
	if {$jp == 195 && $b2 in {1 2}} {
		hex	4 "jp"
		hex	1 "Type"
		if {$b2 == 1} {
			hex	1 "Width"
			hex	1 "Height"
			bytes	256 "Icon"
		}
		cstr	ascii "Description"
	}
	bytes	[expr $datalen+$posset-[pos]] "Assembly"
} elseif {$assembly == 0xD900} { # `Stop/nop`
	hex	6 "Mallard"
	uint16	-hex "Start address"
	cstr	ascii "Description"
	bytes	[expr $datalen+$posset-[pos]] "Assembly"
} elseif {$assembly == 0xD500} { # `Return/nop` crash
	hex	3 "Crash"
	cstr	ascii "Description"
	bytes	[expr $datalen+$posset-[pos]] "Assembly"
} elseif {$assembly == 0xEF69} { # CSE
	hex	2 "Assembly"
	bytes	[expr $datalen+$posset-[pos]] "Assembly"
}

}
