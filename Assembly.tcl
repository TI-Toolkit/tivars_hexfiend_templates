# TI eZ80/Z80 shell header parser Hex Fiend template include
# Version 1.0
# (c) 2021-2026 LogicalJoe
# .hidden = true;

proc isAsm {asm} {
	return [expr {$asm in {0xEF7B 0xEF69 0xBB6D 0xC930 0xAF28 0xD900 0xD500}}]
}

# http://www.detachedsolutions.com/mirageos/develop/
# https://www.ticalc.org/cgi-bin/zipview?83plus/asm/shells/tsekrnl.zip;tsedev.txt

# 0xBB6D mono Z80
# 0xEF69 CSE Z80
# 0xEF7B CE eZ80

# 0xC930 `ret / jr nc` for 83 ION
# 0x##18 TI-Explorer/ASHELL83
# 0xAF28 `xor a / jr z` 83 SOS
# 0xD900 `Stop/nop`, ASH / Mallard
# 0xD500 `Return/nop` crash

proc ReadAsm {assembly datalen} {

set	posset [expr [pos]]

# TODO: assembly not enough $datalen

if {$assembly == 0xBB6D} { # mono Z80
	hex	2 "Z80 token"
	bytes	[expr $datalen+$posset-[pos]] "Assembly"
} elseif {$assembly == 0xEF69} { # CSE Z80
	hex	2 "Z80 token"
	bytes	[expr $datalen+$posset-[pos]] "Assembly"
} elseif {$assembly == 0xEF7B} { # CE eZ80
	hex	2 "eZ80"
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
} elseif {$assembly == 0xD900} { # `Stop/nop`
	# also ASH, without "Duck"
	if {[hex 6] eq 0xD9004475636B} {
		move -6
		hex 6 "Mallard"
		uint16	-hex "Start address"
		cstr	ascii "Description"
	} else {
		move -6
		hex 2 "ASH"
		hex 1 "Unknown"
		cstr	ascii "Description"
	}
	bytes	[expr $datalen+$posset-[pos]] "Assembly"
} elseif {$assembly == 0xD500} { # `Return/nop` crash
	hex	3 "Crash"
	cstr	ascii "Description"
	bytes	[expr $datalen+$posset-[pos]] "Assembly"
}

}
