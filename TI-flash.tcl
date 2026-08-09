# TI graphing calculator flash file parser Hex Fiend template
# Version 1.2
# (c) 2021-2025 LogicalJoe
# .hidden = true;

proc uint24l {a {b -1}} {
	if {$b==-1} {
		entry	$a [format "0x%06X" [uint24]] 3 [expr [pos]-3]
	} else {
		entry	$a [format "0x%06X" $b] 3 [expr [pos]-3]
	}
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
		80C	{ set x "Lowest basecode" }
		810	{ set x "Master" }
		811	{ set x "Signing key" }
		812	{ set x "Version" }
		813	{ set x "Build" }
		814	{ set x "Name" }
		817	{ set x "Final" }
		81A	{ set x "Max hardware" }
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

section	"File packaging" {
	entry	"Version" "[format %x [uint8]].[format %x [uint8]]" 2 [expr [pos]-2]
	set	binary [hex 1]
	entryd	"Binary flag" $binary 1 [dict create 0x00 "Binary" 0x01 "Intel"]
	entryd	"Object type" [hex 1] 1 [dict create 0x00 "!Z80" 0x88 "Z80"]
	hex	4 "Date"
	entry	"Name" "[uint8],[ascii 8]" 9 [expr [pos]-9]
	bytes	23 Padding
	set	a 0
	set	b [pos]
	while {[uint8] != 0} {
		move	-1
		incr	a
		entryd	"Owner calc ID $a" [hex 1] 1 [dict create 0x73 "TI-8\[34] Plus" 0x74 "TI-73" 0x88 "TI-92 Plus" 0x98 "TI-89"]
		entryd	"Type $a" [set vartype [hex 1]] 1 $Z80typeDict
	}
	goto	$b
	move	25
	entryd	"Owner prod ID" [hex 1] 1 $ProdIDs
	set	datasize [uint32]
	entry	"Data size" $datasize 4 [expr [pos]-4]
}

proc readExtendedFormat {fieldSize} {
	set	start [pos]
	set	r [ascii 3]
	move	-3
	if {$r=="eZ8"} { # eZ80
		section -collapsed "Data"
		section "Additional structure" {
			ascii	3 "eZ8"
			ascii	9 "Name"
			hex	1 "Flag1"
			hex	1 "Unknown"
			hex	1 "Flag2"
			uint24l	"Unknown"
			uint24l	"Main" [set main [uint24]]
			uint24l	"Initialized location"
			uint24l	"Initialized size"
			uint24l	"Entry"
			uint24l	"Language"
			uint24l	"ExecLib"
			set	copy [uint24]
			set	a [pos]
			goto	[expr $start + $copy]
			set	copys [cstr ascii]
			goto	$a
			entry	Copyright [format "0x%06X $copys" $copy] 3 [expr [pos]-3]
			uint24l	"Reserved"
		}
		section	-collapsed "Relocation table" {
			while {$main - [pos] + $start} {
				uint24l	"Hole"
				set	address [uint24]
				uint24l	[expr $address >> 22?"Data base":"Code base"] [expr $address & 4194303]
			}
		}
		bytes	[expr $fieldSize-$main] "Body"
		endsection
	} elseif {[uint32] == 0x3D537B16} {
		move	-4
		section -collapsed "Data"
		section "Additional structure" {
			hex	4 "68k"
			ascii	9 "Name"
			bytes	25 "Reserved"
			big_endian
			hex	4 Unknown
			set	main [hex 4 Main]
			hex	4 Initialized\ location
			hex	4 Initialized\ size
			hex	4 Reserved
			little_endian
		}
		bytes	[expr $main - [pos] + $start] "Relocation table"
		# there seems to be more formatted data but is inconsistent
		bytes	[expr $fieldSize - [pos] + $start] "Body"
		endsection
	} else {
		move	-4
		hex	$fieldSize "Data"
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
			if {$field_id == 800 || $field_id == 810} {
				set	sizes $field_size_2
				set	a 0
				while {$a < $sizes} {
					incr	a [getsection]
				}
			} elseif {$field_id == 032} { # datestamp
				incr	a [getsection]
			} elseif {$field_id == 817} {
				readExtendedFormat $field_size_2
			} elseif {$field_id == "090"} {
				set a [uint32]
				# can't know timezone this was built in
				# set absoluteTime [expr {[clock scan "1997-01-01" -format "%Y-%m-%d"] + $a}]
				set date [clock format $a -format "%y/%m/%d, %H:%M:%S"]
				entry Data $a\ (+$date) 4 [expr [pos]-4]
			} else {
				hex	$field_size_2 "Data"
			}
		}

		incr	field_size 2
		incr	field_size $field_size_2
	}
	return	$field_size
}


section	"Data" {
	set	start [pos]
	if {$vartype == 0x3E} { # License
		ascii	$datasize "Data"
	} elseif {$binary} {
		set	r [uint8]
		move	-1
		while {$start+$datasize>[pos] && $r==58} {
			readTIHex

# line endings can be 0A or 0D0A, each followed by a 3A
			if {[len]-[pos]>3} {
				set	r [uint8]
				if {$r == 13} {
					set	r [uint8]
				}
				if {$r == 10} {
					set	r [uint8]
				} else {
					set	r 0
				}
				move	-1
			} else {
				set	r 0
			}

		}
		if {78+$datasize-[pos] && [len]<[pos]} {
			ascii	[expr 78+$datasize-[pos]] "Extended data"
		}
	} else {
		while {$start+$datasize>[pos]} {
			getsection
		}
	}
}

#read multiple FLASH headers, only one basecode/application allowed per physical file
if {[len]-[pos] > 78} {
	if {[ascii 8]=="**TIFL**"} {
		move -8
		ascii 8 Magic
		source [info script]
	}
}

if {![end]} {
	bytes	eof "Extra Data"
}
