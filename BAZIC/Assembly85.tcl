# TI-85/86 assembly header parser Hex Fiend template include
# Version 1.0
# (c) 2021-2026 LogicalJoe
# .hidden = true;

proc ReadAsm85 {datalen magic datatype} {
	if {$datalen < 2 || !(($magic == "**TI85**" && $datatype == 0x0C) || ($magic == "**TI86**" && $datatype == 0x12))} { return 0 }
	set start [pos]
	set assembly [hex 2]
	goto $start
	if {$magic == "**TI86**"} {
		if {$assembly != 0x8E28} { return 0 }
	} else {
		if {$datalen < 4 || ($assembly >> 8) != 0} { return 0 }
		set shellIDs [dict create \
			0x42 "Summit TI-BASIC ASM Subroutine" \
			0x4E "Summit Non-relocation Prgm" \
			0x50 "PhatOS & Peak Relocation Prgm" \
			0x52 "Summit Relocation Prgm" \
			0x53 "Summit Shell Patch" \
			0x54 "Summit TSR" \
			0x70 "Peak Non-relocation Prgm" \
			0xBD SuperNova \
			0xF8 FutureOS \
			0xF9 Usgard \
			0xFB "Rigel Library" \
			0xFC "Rigel Prgm" \
			0xFD "ZShell 4.0"]
		set shellID [format 0x%02X [expr {$assembly & 255}]]
		if {![dict exists $shellIDs $shellID]} { return 0 }
		set raw [bytes $datalen]
		goto $start
		if {[string first \x00 $raw 3] < 3} { return 0 }
	}
	section -collapsed Code {
		if {$magic == "**TI86**"} {
			hex 2 "Z80 token"
		} else {
			hex 1 Assembly
			entryd ID [hex 1] 1 $shellIDs
			uint8 Entry\ offset
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
