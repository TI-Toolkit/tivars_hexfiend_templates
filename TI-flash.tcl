# TI graphing calculator flash file parser Hex Fiend template
# Version 1.2
# (c) 2021-2026 LogicalJoe
# .hidden = true;

proc uint24l {a {b -1}} {
	if {$b==-1} {
		entry	$a [format "0x%06X" [uint24]] 3 [expr [pos]-3]
	} else {
		entry	$a [format "0x%06X" $b] 3 [expr [pos]-3]
	}
}

# Resolve pointers using the relocation at their code-relative hole.
proc TI68K_ReadPointer {context label} {
	lassign $context code initial initialSize relocations
	set offset [pos]
	set value [hex 4]
	set display $value
	set target -1
	set hole [expr {$offset - $code}]
	if {[dict exists $relocations $hole]} {
		lassign [dict get $relocations $hole] type address
		if {$type == 0} {set target [expr {$code + $address}]}
		if {$type == 2 && $address < $initialSize} {set target [expr {$initial + $address}]}
		append display " ([lindex {{Code offset} {ROM-call-table index} {RAM data offset} Reserved} $type] [format 0x%X $address]"
		if {$target >= 0} {append display [format "; file 0x%X" $target]}
		if {$type == 2 && $target < 0} {append display "; BSS"}
		append display ")"
	} elseif {$value == 0xFF000000} {
		append display " (OO_SYSTEM_FRAME)"
	}
	entry $label $display 4 $offset
	return [list $value $target]
}

proc TI68K_ReadFrame {context target label} {
	set names {Unknown {App flags (OO_APP_FLAGS)} {Display name} {TI-BASIC token name}
		{Event handler} {Default menu} {Menu handle} {TI-BASIC extension count}
		{TI-BASIC extension descriptions} {TI-BASIC extension entry table}
		{Localize callback} {Unlocalize callback} {Can-delete callback} {Can-move callback}
		{Variable-viewer callback} Icon {Extension help callback}
		{New-install notification callback} {About callback} {Event-filter ordering (Titanium AMS 3.10)}}
	goto $target
	section $label {
		sectionvalue [format "File 0x%X" $target]
		TI68K_ReadPointer $context "Parent frame"
		set prototype [lindex [TI68K_ReadPointer $context "Prototype frame"] 1]
		section "Frame control flags" {
			set flags [hex 2]
			sectionvalue $flags
			MaskRead $flags 1 {1 "Read-only frame" 0 "Writable-frame behavior"} 2
			MaskRead $flags 2 {1 "Explicit selector/value pairs" 0 "Compact consecutive values"} 2
			MaskRead $flags 65532 Unknown 2
		}
		set first [uint32 -hex "First attribute selector"]
		set count [uint32 "Attribute count"]
		section -collapsed "Attributes" {
			for {set index 0} {$index < $count} {incr index} {
				set offset [pos]
				if {$flags & 2} {
					set selector [uint32]
				} else {
					set selector [expr {$first + $index}]
				}
				set name "App-defined attribute"
				if {$selector < [llength $names]} {set name [lindex $names $selector]}
				if {$selector >= 0x10000} {set name "App-defined interface attribute"}
				section -collapsed [format "0x%08X: %s" $selector $name] {
					if {$flags & 2} {
						entry Selector [format "0x%08X" $selector] 4 $offset
					} else {
						entry "Selector (implicit)" [format "0x%08X" $selector]
					}
					lassign [TI68K_ReadPointer $context Value] value address
					if {$selector == 1} {
						sectionvalue [format "Flags 0x%08X" $value]
						section "App flags" {
							sectionvalue $value
							MaskRead $value 1 {1 Interactive 0 Noninteractive} 4
							MaskRead $value 2 {1 "Current/Open/New submenu" 0 "No Current/Open/New submenu"} 4
							MaskRead $value 4 {1 "Allow protected Data/Matrix column stores" 0 "Normal protected-column checks"} 4
							MaskRead $value 8 {1 "Request background events" 0 "No background events requested"} 4
							MaskRead $value 16 {1 "Event filter (Titanium AMS 3.10)" 0 "No event filter requested"} 4
							MaskRead $value 4294967264 Unknown 4
						}
					} elseif {$address >= 0 && ($selector in {2 3} || ($selector >= 0x1000 && $selector < 0x10000))} {
						set saved [pos]
						goto $address
						sectionvalue [cstr isolatin1 String]
						goto $saved
					} elseif {$value == 0xFFFFFFFF} {
						sectionvalue [format "File 0x%08X" $address]
					} else {
						sectionvalue [format "0x%08X" $value]
					}
				}
			}
		}
		sectionname [format "%s 0x%08X" $label $first]
	}
	return $prototype
}

proc TI68K_ReadObjectFrame {context} {
	set saved [pos]
	section "Object Frame" {
		goto [lindex $context 1]
		set target [lindex [TI68K_ReadPointer $context "Initialized-data frame reference"] 1]
		set label "Primary frame"
		while {$target >= 0} {
			set target [TI68K_ReadFrame $context $target $label]
			set label "Prototype frame"
		}
	}
	goto $saved
}

proc Field_Names {value} {
	# 024 CE OSs
	# 035 cert (030000)
	# 0C1
	# 80D
	# 80E CE OS
	return [switch -- $value {
		000	{ set x "Padding" }
		010	{ set x "Certificate revision" }
		020	{ set x "Date signature" }
		022	{ set x "CSE signature" }
		023	{ set x "CE signature" }
		032	{ set x "Date stamp" }
		033	{ set x "Certificate parent" }
		034	{ set x "Exam LED available" }
		037	{ set x "Minimum installable OS" }
		040	{ set x "Calculator ID" }
		041	{ set x "Validation ID" }
		042	{ set x "Model name" }
		043	{ set x "Python co-processor" }
		051	{ set x "About text" }
		071	{ set x "Standard key header" }
		073	{ set x "Standard key signature" }
		081	{ set x "Custom app key header" }
		083	{ set x "Custom app key data" }
		090	{ set x "Date stamp subfield" }
		0A0	{ set x "Calculator ID-related" }
		0A1	{ set x "Calculator ID" }
		0A2	{ set x "Validation key" }
		0B0	{ set x "Default language" }
		0C0	{ set x "Exam mode status" }
		800	{ set x "Master" }
		801	{ set x "Signing key" }
		802	{ set x "Revision" }
		803	{ set x "Build" }
		804	{ set x "Name" }
		805	{ set x "Expiration date" }
		806	{ set x "Overuse count" }
		807	{ set x "Final" }
		808	{ set x "Page count" }
		809	{ set x "Disable TI splash" }
		80A	{ set x "Max hardware revision" }
		80C	{ set x "Fuse/HW compatibility" }
		80D	{ set x "Basecode compatibility" }
		80E	{ set x "Basecode compatibility" }
		810	{ set x "Master" }
		811	{ set x "Signing key" }
		812	{ set x "Version" }
		813	{ set x "Build" }
		814	{ set x "Name" }
		817	{ set x "Final" }
		81A	{ set x "Max hardware revision" }
		81C	{ set x "Unknown" }
		81D	{ set x "Python compatibility generation?" }
		default	{ set x $value }
	}]
}

proc Get_Field_Size {value} {
	return [switch -- $value {
		13	{set	x [hex 1 "Size"]}
		14	{set	x [hex 2 "Size"]}
		15	{set	x [hex 4 "Size"]}
		default	{set	x $value}
	}]
}

# Intel Intellec 8/MDS [Original from /linkguide/ti83+/fformat.html]
#   +--Colon (3A)
#   | +--Number of data bytes               Line feed (0D0A or 0A)--+
#   | |  +--Address                        Checksum (256-C&255)--+  |
#   | |  |    +--Block type (00:data, 01:end, 02:page number)    |  |
#   | |  |    |  +--                  Data                   --+ |  |
#   | |  |    |  |                                             | |  |
#   : 02 0000 02 00 00 <--Page number                            FC CR/LF
#   : 10 4000 00 FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF 00 CR/LF
#   : 10 4010 00 FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF F0 CR/LF
#   : 10 4020 00 FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF E0 CR/LF
#   : 00 0000 01                                                 FF

proc readAsciiHex {size {name ""}} {
	set a [pos]
	set b 0x[ascii [expr 2*$size]]
	if {$name ne ""} {
		entry	$name $b [expr 2*$size] $a
	}
	return $b
}

proc readTIHex {} {
	section "TI-Hex record" {
		uint8
		set	size [readAsciiHex 1 Size]

		set	address [readAsciiHex 2 Address]

		set	type [readAsciiHex 1]
		entryd	"Record type" $type 2 [dict create 0x00 Data 0x01 EOF 0x02 Page]
		if {!$type} {sectioncollapse}

		if {$size != 0} {
			readAsciiHex $size Data
		}
		readAsciiHex 1 Checksum
	}
	return	$type
}

proc readExtendedFormat {fieldSize} {
	set start [pos]
	set r [ascii 3]
	move -3
	if {$r=="eZ8"} { # eZ80
		section -collapsed "Data"
		section "Additional structure" {
			ascii 3 "eZ8"
			ascii 9 "Name"
			section "App flags" {
				set Flags [hex 1]
				sectionvalue $Flags
				MaskRead $Flags 1 {1 "Disable TI splash" 0 "Enable TI splash"}
				MaskRead $Flags 2 {1 "OpenLib" 0 "no OpenLib"}
				MaskRead $Flags 4 {1 "Exclude from applist" 0 "Include in applist"}
				MaskRead $Flags 248 Reserved
			}
			hex 1 "Reserved"
			section "Integration flags" {
				set Flags [hex 1]
				sectionvalue $Flags
				entry Boolean "$Flags ([expr $Flags?"Key 3":"Key 2"])" 1 [expr [pos]-1]
				MaskRead $Flags 1 {1 "Language app" 0 "Not a language app"}
				# Inequalz, Transfrm, Python, and SetDash
				MaskRead $Flags 2 {1 "OS-integrated" 0 "Not OS-integrated"}
				# OS specifically locates PlySmlt2 and then checks flags
				MaskRead $Flags 4 {1 "PlySmlt2, include in résol" 0 "Not PlySmlt2"}
				MaskRead $Flags 56 Something
				MaskRead $Flags 64 {1 "Hub interface" 0 "No Hub interface"}
				MaskRead $Flags 128 Reserved
			}
			uint24l "BSS size"
			uint24l "Main" [set main [uint24]]
			uint24l "Initialized location"
			uint24l "Initialized size"
			uint24l "Entry"
			uint24l "Language"
			uint24l "ExecLib"
			set copy [uint24]
			set a [pos]
			goto [expr $start + $copy]
			set copys [cstr ascii]
			goto $a
			entry Copyright [format "0x%06X $s" $copy $copys] 3 [expr [pos]-3]
			uint24l "Reserved"
		}
		section -collapsed "Relocation table" {
			while {[pos] < $start + $main} {
				uint24l "Hole"
				set address [uint24]
				uint24l [expr $address & 0x800000?"Data base":"Code base"] [expr $address & 0x7FFFFF]
			}
		}
		bytes [expr $fieldSize-$main] "Body"
		endsection
	} elseif {[uint32] == 0x3D537B16} { # 68k
		big_endian
		move -4
		section -collapsed "Data"
		section "Additional structure" {
			hex 4 "68k"
			ascii 8 "Name"
			bytes 24 "Reserved"
			section "Header flags" {
				set Flags [hex 2]
				sectionvalue $Flags
				MaskRead $Flags 1 {1 "OS language localizer" 0 "Not an OS language localizer"} 2
				MaskRead $Flags 65534 Reserved 2
			}
			hex 4 "RAM data size (data + BSS)"
			set main [hex 4 "Offset to code segment"]
			set initial [hex 4 "Offset to initialized data table"]
			set initialSize [hex 4 "Length of initialized data table"]
			set a [hex 4 "Length of optional header"]
			if $a {
				bytes $a "Optional header"
			} else {
				entry "Optional header" ""
			}
		}
		set relocations {}
		set relocation_types [dict create 0 "Code offset" 1 "ROM-call-table index" 2 "RAM data offset" 3 Reserved]
		section -collapsed "Relocation table" {
			while {[pos] < $start + $main} {
				set hole [uint24]
				uint24l "Hole" $hole
				set address [uint24]
				set packed [expr $address >> 22]
				set address [expr $address & 4194303]
				uint24l [dict get $relocation_types $packed] $address
				dict set relocations $hole [list $packed $address]
			}
		}

		TI68K_ReadObjectFrame [list [expr $start + $main] [expr $start + $initial] $initialSize $relocations]
		bytes [expr $fieldSize - [pos] + $start] "Body"
		little_endian
		endsection
	} else {
		move -4
		hex $fieldSize "Data"
	}
}

proc getsection {} {
	set	field [hex 2]
	set	field_id [format "%03X" [expr $field>>4]]
	set	field_size [expr $field & 15]
	section	[Field_Names $field_id] {
		entry	"Field" $field_id 2 [expr [pos]-2]
		set	field_size_2 [Get_Field_Size $field_size]

		if {$field_size_2 != 0} {
			if {$field_id in {800 810 032}} {
				set a 0
				while {$a < $field_size_2} {
					incr a [getsection]
				}
			} elseif {$field_id == 817} {
				readExtendedFormat $field_size_2
			} elseif {$field_id == "090" && $field_size_2 == 4} {
				# 68k and eZ80 are both big-endian
				set a [hex 4]
				set date [clock format [expr $a+852076800] -timezone :UTC -format "%Y-%m-%d %H:%M:%S"]
				entry Data $a\ ($date) 4 [expr [pos]-4]
			} else {
				hex	$field_size_2 "Data"
			}
		}

		incr	field_size 2
		incr	field_size $field_size_2
	}
	return	$field_size
}


section "Flash Header"

entry "Version" "[format %x [uint8]].[format %x [uint8]]" 2 [expr [pos]-2]
set binary [hex 1]
entryd "Binary flag" $binary 1 [dict create 0x00 "Binary" 0x01 "Intel"]
entryd "Object type" [hex 1] 1 [dict create 0x00 "!Z80" 0x88 "Z80"]
hex 4 "Date" ;# supposed to be DDMMYYYY
set namesize [uint8 "Name length"]
entry "Name" "[ascii $namesize]" 31 [expr [pos]-$namesize]
move -$namesize
move 31
set a 0
set b [pos]
while {[uint8] != 0} {
	move -1
	incr a
	entryd "Owner calc ID $a" [hex 1] 1 [dict create 0x73 "TI-8\[34] Plus" 0x74 "TI-73" 0x88 "TI-92 Plus" 0x98 "TI-89"]
	set recordtype [hex 1]
	entryd "Type $a" $recordtype 1 $Z80typeDict
	if {$a == 1} {set vartype $recordtype}
}
goto $b
move 25
entryd "Owner prod ID" [hex 1] 1 $ProdIDs
set datasize [uint32]
entry "Data size" $datasize 4 [expr [pos]-4]

section	"Data" {
	set	start [pos]
	if {$vartype == 0x3E} { # License
		ascii $datasize "Data"
	} elseif {$binary} {
		while {$start+$datasize>[pos]} {
			set r [uint8]
			move -1
			if {$r != 58} {break}
			readTIHex

			if {[pos] >= $start+$datasize} {break}
			set r [uint8]
			if {$r == 13} {
				if {[pos] < $start+$datasize} {
					set r [uint8]
					if {$r != 10} {move -1}
				}
			} elseif {$r != 10} {
				move -1
			} else {
				break
			}
		}
		if {$start+$datasize > [pos]} {
			ascii [expr $start+$datasize-[pos]] "Extended data"
		}
	} else {
		sectionname "Certificate"
		while {$start+$datasize>[pos]} {
			getsection
		}
	}
}

# optional checksum
if {[len]-[pos] == 2} {
	uint16 "Checksum"
} elseif {[len]-[pos] >= 80} {
	move	2
	set	r [ascii 8]
	move	-10
	if {$r=="**TIFL**"} {uint16 "Checksum"}
}

endsection ;# Flash Header

#read multiple FLASH headers, only one basecode/application allowed per physical file
if {[len]-[pos] >= 78} {
	if {[ascii 8]=="**TIFL**"} {
		move -8
		ascii 8 Magic
		source [info script]
	}
}

if {![end]} {
	bytes	eof "Extra Data"
}
