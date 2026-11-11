# TI eZ80/Z80 shell header parser Hex Fiend template include
# Version 1.0
# (c) 2021-2026 LogicalJoe
# .hidden = true;

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

proc ReadAsm83 {datalen {magic "**TI83F*"}} {
	if {$datalen < 2} { return 0 }
	set start [pos]
	set assembly [hex 2]
	goto $start
	if {!(($magic == "**TI83F*" && $assembly in {0xBB6D 0xEF69 0xEF7B}) ||
		($magic == "**TI73**" && $assembly == 0xBB6D) ||
		($magic == "**TI83**" && ($assembly in {0xC930 0xAF28} || ($assembly & 255) == 0x18)) ||
		($magic == "**TI82**" && $assembly in {0xD900 0xD500}))} { return 0 }
	section -collapsed Code {
		sectionvalue "\[expand for code]"
		if {$assembly == 0xBB6D || $assembly == 0xEF69} { # mono / CSE Z80
			hex 2 "Z80 token"
		} elseif {$assembly == 0xEF7B} { # CE eZ80
			hex 2 eZ80
		} elseif {$assembly == 0xC930} { # `ret / jr nc` for 83 ION
			hex 1 "83 ION"
			hex 2 "jr nc"
			cstr ascii Description
		} elseif {($assembly & 255) == 0x18} {
			hex 1 [expr {$assembly >> 8 ? "TI-Explorer" : "ASHELL83"}]
			set jr [hex 2 jr]
			hex 2 "Table pointer"
			hex 2 "Description pointer"
			if {$jr == 0x1806} { hex 2 "Icon pointer" }
		} elseif {$assembly == 0xAF28} { # `xor a / jr z` 83 SOS
			hex 1 "83 SOS"
			hex 2 "jr z"
			hex 2 Libraries
			hex 2 "Description pointer"
		} elseif {$assembly == 0xD900} { # ASH / Mallard
			set mallard 0
			if {$datalen >= 6} {
				set mallard [expr {[hex 6] eq "0xD9004475636B"}]
				move -6
			}
			if {$mallard} {
				hex 6 Mallard
				uint16 -hex "Start address"
			} else {
				hex 2 ASH
				hex 1 Unknown
			}
			cstr ascii Description
		} elseif {$assembly == 0xD500} { # Crash
			hex 3 Crash
			cstr ascii Description
		}
		set remaining [expr {$start + $datalen - [pos]}]
		if {$remaining} {
			bytes $remaining Assembly
		} else {
			entry Assembly ""
		}
	}
	return 1
}
