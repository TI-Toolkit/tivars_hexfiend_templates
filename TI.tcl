# TI graphing calculator format HexFiend template
# Version 1.0
# (c) 2021-2023 LogicalJoe


if {[file exists TI/BAZIC.txt]} {
	include	TI/BAZIC.txt
} else {
	proc BAZIC {datasize} {
		if {$datasize} {
			hex	$datasize "Data"
		} else {
			entry	"Data" "empty"
		}
	}
}

if {[file exists TI/AppVar.txt]} {
	include	TI/AppVar.txt
} else {
	proc ReadAppVar {} {
		set	datasize [uint16 "Data size"]
		if {$datasize} {
			hex	$datasize "Data"
		} else {
			entry	"Data" "empty"
		}
	}
}

proc main_guard {body} {
	if [catch {
		uplevel	1 $body
	}] {
		uplevel	1 { entry "FATAL" "Somthin' hap'ned" }
	}
}

# entryd label value length dict
# TODO: offset?
proc entryd {a b c d} {
	if [dict exists $d $b] {
		set	e "$b ([dict get $d $b])"
	} else {
		set	e $b
	}
	if {$c} {
		entry	$a $e $c [expr [pos]-$c]
	} else {
		entry	$a $e
	}
	return	$e
}

# dictsearch value dict
proc dictsearch {b d} {
	if [dict exists $d $b] {
		set	e [dict get $d $b]
	} else {
		set	e $b
	}
	return	$e
}

proc FlagRead {Flag bit {name unused/unknown} {notname -1}} {
	if {($Flag & (1 << $bit)) != 0} {
		if {$name != -1} {
			entry Bit\ $bit $name 1 [expr [pos] - 1]
		}
	} elseif {$notname != -1} {
		entry Bit\ $bit $notname 1 [expr [pos] - 1]
	}
}

proc whiless {size body} { # looptil
	set	start [pos]
	while {[pos]<$start+$size} {
		uplevel	1 $body
	}
}

proc for_n {n body} {
	for {set a 0} {$a < $n} {incr a} {
		uplevel	1 $body
	}
}

set	ProdIDs [dict create \
	0x01 "TI-92 Plus" \
	0x02 "TI-73" \
	0x03 "TI-89" \
	0x04 "TI-83 Plus" \
	0x08 "TI-Voyage 200" \
	0x09 "TI-89 Titanium" \
	0x0A "TI-84 Plus" \
	0x0B "TI-82 Advanced" \
	0x0C "TI-Nspire CAS" \
	0x0D "TI-Labcradle" \
	0x0E "TI-Nspire" \
	0x0F "TI-84 Plus CSE / Nspire CX CAS" \
	0x10 "TI-Nspire CX" \
	0x11 "TI-Nspire CM CAS" \
	0x12 "TI-Nspire CM" \
	0x13 "TI-84 Plus CE / TI-83 Premium CE" \
	0x1B "TI-84 Plus T" \
]

set	Z80typeDict [dict create \
	0x00 "Real" \
	0x01 "Real list" \
	0x02 "Matrix" \
	0x03 "Equation" \
	0x04 "String" \
	0x05 "Program" \
	0x06 "Protected program" \
	0x07 "Picture" \
	0x08 "Graph database" \
	0x0B "New equation" \
	0x0C "Complex" \
	0x0D "Complex list" \
	0x0F "Window setup" \
	0x10 "Zoom settings" \
	0x11 "TableSet" \
	0x12 "LCD / PrintScreen" \
	0x13 "Backup" \
	0x15 "AppVar" \
	0x16 "Temporary" \
	0x17 "Group" \
	0x18 "Real Fraction" \
	0x1A "Image" \
	0x1B "Complex Fraction" \
	0x1C "Real radical" \
	0x1D "Complex radical" \
	0x1E "Complex pi" \
	0x1F "Complex pi fraction" \
	0x20 "Real pi" \
	0x21 "Real pi fraction" \
	0x23 "OS" \
	0x24 "Flash app" \
	0x25 "Certificate" \
	0x26 "ID-List" \
	0x27 "Certificate Memory" \
	0x29 "Clock" \
	0x3E "Flash License" \
]

set	68KtypeDict [dict create \
	0x00 "Expression" \
	0x04 "List" \
	0x06 "Matrix" \
	0x0A "Data" \
	0x0B "Text" \
	0x0C "String" \
	0x0D "Graph database" \
	0x0E "Fig" \
	0x10 "Picture" \
	0x12 "Program" \
	0x13 "Function" \
	0x14 "Mac" \
	0x18 "Clock" \
	0x1A "Request Directory" \
	0x1B "Local Directory" \
	0x1C "STDY" \
	0x1D "Backup" \
	0x1F "Directory" \
	0x20 "Get Certificate" \
	0x21 "Assembly program" \
	0x22 "ID-List" \
]

array set Type {
	Real	0
	RList	1
	Matrix	2
	Equ	3
	Str	4
	Prgm	5
	PPrgm	6
	Pic	7
	GDB	8
	NEqu	11
	Cplx	12
	CList	13
	CMatrix	14
	Window	15
	Zoom	16
	TSet	17
	AppVar	21
	TPrgm	22
	Group	23
	Frac	24
	Dir	25
	Image	26
	CFrac	27
	RRad	28
	CRad	29
	CPi	30
	CPiFrac	31
	RPi	32
	RPiFrac	33
	AMS	35
	App	36
}


proc readTINumb {{index ""}} {
	proc readTIFloat {{index ""} {recursed 0}} {
		global	Type
		set	bitbyte [uint8]
		set	typebyte [expr ($bitbyte & 127) > 15 ?($bitbyte & 127):($bitbyte & 2)?0:($bitbyte & 12)]

		if {$typebyte == $Type(RRad) || $typebyte == $Type(CRad)} {
			move	-1
			readTIRadical $index $recursed
			return
		}

		set	Name [expr $typebyte > 15 ?"raction":"loat"]
		set	Name $Name[expr $typebyte>29?"Pi":""]
		set	Bits [expr ($bitbyte&2 && !(48&$bitbyte))?" unset":""]
		set	Sign [expr $bitbyte & 128?"-":"+"]
		set	Power [expr [uint8]-128]
		set	First [uint8]
		set	First [expr $First/16].[expr $First%16]
		big_endian
		set	Body $First[format "%012X" [hex 6]]
		little_endian
		entry	"TI-F$Name $index" "$Sign$Body\e$Power$Bits" 9 [expr [pos]-9]

		if {!$recursed && (($bitbyte & 0x0E)==0x0C ||
		$typebyte == $Type(CFrac) || $typebyte == $Type(CPi) || $typebyte == $Type(CPiFrac))} {
			readTIFloat "$index\c" 1
		}
	}

	proc readTIRadical {{index ""} {recursed 0}} {
		global	Type
		set	typebyte [uint8]
		big_endian
		set	Body [format "%016X" [hex 8]]
		little_endian

		set	Signs [string range $Body 0 0]
		set	Sign1 [expr $Signs & 1?"-":""]
		set	Sign2 [expr $Signs & 2?"-":"+"]
		set	N5 [string range $Body 1 3]
		set	N3 $Sign2[string range $Body 4 6]
		set	N1 $Sign1[string range $Body 7 9]
		set	N4 [string range $Body 10 12]
		set	N2 [string range $Body 13 15]
		entry	"TI-Radical $index" "($N1√$N2$N3√$N4)/$N5" 9 [expr [pos]-9]

		if {!$recursed && ($typebyte == $Type(CFrac) ||
		$typebyte == $Type(CRad) || $typebyte == $Type(CPi) || $typebyte == $Type(CPiFrac))} {
			readTIRadical "$index\c" 1
			# should this be readTIFloat?
		}
	}

	readTIFloat $index 0
}

proc readGDB {} {
	set	datasize [uint16 "Data size"]
	set	start [pos]
	uint8	"Unused"
	set	GraphMode [uint8]
	entryd	"Graph mode" $GraphMode 1 [dict create 16 Function 32 Polar 64 Parametric 128 Sequence]
	section "Mode settings" {
		set	Flags [hex 1]
		sectionvalue $Flags
		FlagRead $Flags 0 Dot Connected
		FlagRead $Flags 1 Simul Sequential
		FlagRead $Flags 2 GridOn GridOff
		FlagRead $Flags 3 PolarGC RectGC
		FlagRead $Flags 4 CoordsOn CoordsOff
		FlagRead $Flags 5 AxesOn AxesOff
		FlagRead $Flags 6 LabelOn LabelOff
		FlagRead $Flags 7 GridLine GridDot
	}
	section "Sequence settings" {
		set	Flags [hex 1]
		sectionvalue $Flags
		if {($Flags & (1 << 0)) != 0} {
			FlagRead $Flags 0 "Web"
		} elseif {($Flags & (1 << 2)) != 0} {
			FlagRead $Flags 2 "uv"
		} elseif {($Flags & (1 << 3)) != 0} {
			FlagRead $Flags 3 "vw"
		} else {
			FlagRead $Flags 4 "uw" "Time"
		}
		FlagRead $Flags 5
		FlagRead $Flags 6
		FlagRead $Flags 7
	}
	section "Extended settings" {
		set	Flags [hex 1]
		sectionvalue $Flags
		FlagRead $Flags 0 ExprOff ExprOn
		set	seqmode [expr ($Flags & 6) >> 1]
		if {$seqmode} {
			entry Bits\ 1&2 "SEQ(n+[expr $seqmode])" 1 [expr [pos] - 1]
		} else {
			entry Bits\ 1&2 "SEQ(n)" 1 [expr [pos] - 1]
		}
		FlagRead $Flags 3
		FlagRead $Flags 4
		FlagRead $Flags 5
		FlagRead $Flags 6
		FlagRead $Flags 7
	}

	switch -- $GraphMode {
		16	{ set	values { Xmin Xmax Xscl Ymin Ymax Yscl Xres } }
		32	{ set	values { Xmin Xmax Xscl Ymin Ymax Yscl Thetamin Thetamax Thetastep } }
		64	{ set	values { Xmin Xmax Xscl Ymin Ymax Yscl Tmin Tmax Tstep } }
		128	{ set	values { Xmin Xmax Xscl Ymin Ymax Yscl PlotStart nMax u(1) v(1) nMin u(2) v(2) w(2) PlotStep w(1) } }
	}
	section "Numbers" {
		foreach index $values {
			readTINumb $index
		}
	}

	switch -- $GraphMode {
		16	{ set	values { Y1 Y2 Y3 Y4 Y5 Y6 Y7 Y8 Y9 Y0 } }
		32	{ set	values { r1 r2 r3 r4 r5 r6 } }
		64	{ set	values { X1T/Y1T X2T/Y2T X3T/Y3T X4T/Y4T X5T/Y5T X6T/Y6T } }
		128	{ set	values { u v w } }
	}
	section "Styles" {
		foreach index $values {
			entryd	"$index Style" [uint8] 1 [dict create 0 Thin\ line 1 Thick\ line 2 Shade\ above 3 Shade\ below 4 Trace 5 Animate 6 Thick\ dotted\ line 7 Thin\ dotted\ line]
		}
	}
	if {$GraphMode == 64} {
		set	valuesAll { X1T Y1T X2T Y2T X3T Y3T X4T Y4T X5T Y5T X6T Y6T }
	} else {
		set	valuesAll $values
	}

	section "Functions"
	foreach index $valuesAll {
		section $index {
			section -collapsed "Activation flag" {
				set	Flags [hex 1]
				if {($Flags & (1 << 5)) != 0} {
					sectionvalue "$Flags - Selected"
				} else {
					sectionvalue "$Flags - Unselected"
				}
				FlagRead $Flags 2
				FlagRead $Flags 3 Ungraphed Graphed
				FlagRead $Flags 4
				FlagRead $Flags 5 Selected Unselected
				FlagRead $Flags 6 "Seq-Unknown"
				FlagRead $Flags 7
			}
			BAZIC	[uint16 "Size"]
		}
	}
	endsection

	if {[pos]-$start != $datasize} {
		ascii	3 "Color indicator"
		section "Colors" {
			set	oscolors [dict create \
			1 BLUE 2 RED 3 BLACK 4 MAGENTA \
			5 GREEN 6 ORANGE 7 BROWN 8 NAVY \
			9 LTBLUE 10 YELLOW 11 WHITE 12 LTGRAY \
			13 MEDGRAY 14 GRAY 15 DARKGRAY 16 Off]

			foreach index $values {
				entryd	"$index color" [uint8] 1 $oscolors
			}
			entryd	"Grid color" [uint8] 1 $oscolors
			entryd	"Axes color" [uint8] 1 $oscolors
			entryd	"Line style" [uint8] 1 [dict create 0 Thick 1 Dot-Thick 2 Thin 3 Dot-Thin]
			uint8	"Border color"
		}

		section "Extended settings 2" {
			set	Flags [hex 1]
			sectionvalue $Flags
			FlagRead $Flags 0 "Detect Asymptotes On" "Detect Asymptotes Off"
			FlagRead $Flags 1
			FlagRead $Flags 2
			FlagRead $Flags 3
			FlagRead $Flags 4
			FlagRead $Flags 5
			FlagRead $Flags 6
			# FlagRead $Flags 7 Always\ set
		}
	}
}


proc Z80readBody {datatype {fallbacksize 0}} {
	global	Type
	section	-collapsed Data
	set	start [pos]

	switch -- $datatype {
		0x00 -
		0x0C -
		0x18 -
		0x1B -
		0x1C -
		0x1D -
		0x1E -
		0x1F -
		0x20 -
		0x21 {
			readTINumb
		}
		0x01 -
		0x0D {
			set	n [uint16 "Indices"]
			for {set a 0} {$n > $a} {incr a} {
				readTINumb [expr $a+1]
			}
		}
		0x02 -
		0x0E {
			set	Width [expr [uint8 "Width"]]
			set	Height [expr [uint8 "Height"]]
			for {set a 0} {$a<$Width*$Height} {incr a} {
				readTINumb "[expr 1+$a/$Width] [expr 1+$a%$Width]"
			}
		}
		0x03 -
		0x04 {
			set	datasize [uint16 "Code size"]
			BAZIC	$datasize
		}
		0x05 -
		0x06 {
			set	datasize [uint16 "Code size"]
			set	posset [pos]
			set	assembly 0
			if {$datasize > 1} {
				set	assembly [hex 2]
				move	-2
				set	AllData [hex $datasize]
				goto	$posset
			}

			if {$assembly == 0xBB6D} { # 8\[43\]P? Z80
				section -collapsed Code {
					sectionvalue $AllData
					hex	2 "Assembly"
					set	b1 [uint8]
					if {$b1==201} { # ret
						# http://www.detachedsolutions.com/mirageos/develop/
						# always BB6D for MirageOS
						set	b2 [uint8]
						move	-2
						if {$b2 == 1 || $b2 == 3} {
							hex	1 "MirageOS"
							hex	1 "Type $b2"
							hex	30 "Button"
							if {$b2 == 3} {
								hex	2 "Quit address"
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
						}
					} elseif {$b1==175} {
						set	b2 [uint8]
						move	-2
						if {$b2 == 48} {
							hex	1 "ION & OS"
							hex	2 "jr nc"
							cstr	ascii "Description"
						}
					}
					hex	[expr $datasize+$posset-[pos]] "Data"
				}
			} elseif {$assembly == 0xC930} { # `ret / jr nc` for 83 ION
				section -collapsed Code {
					sectionvalue $AllData
					hex	1 "83 ION"
					hex	2 "jr nc"
					cstr	ascii "Description"
					hex	[expr $datasize+$posset-[pos]] "Data"
				}
			} elseif {$assembly == 0x0018} { # `nop / jr` 83 ASHELL
				section -collapsed Code {
					sectionvalue $AllData
					# Wolfenstein 3D
					hex	1 "ASHELL83"
					hex	2 "jr"
					hex	2 "Table version"
					hex	2 "Description pointer"
					hex	2 "Icon pointer"
					hex	2 "For future use"
					hex	[expr $datasize+$posset-[pos]] "Data"
				}
			} elseif {$assembly == 0x3F18} { # `ccf / jr` 83 TI-Explorer
				section -collapsed Code {
					sectionvalue $AllData
					hex	1 "TI-Explorer"
					hex	2 "jr"
					hex	2 "Table version"
					hex	2 "Description pointer"
					hex	2 "Icon pointer"
					hex	1 "ret"
					hex	[expr $datasize+$posset-[pos]] "Data"
				}
			} elseif {$assembly == 0xAF28} { # `xor a / jr z` 83 SOS
				section -collapsed Code {
					sectionvalue $AllData
					hex	1 "83 SOS"
					hex	2 "jr z"
					hex	2 "Libraries"
					hex	2 "Description pointer"
					hex	[expr $datasize+$posset-[pos]] "Data"
				}
			} elseif {$assembly == 0xEF7B} { # CE eZ80
				section -collapsed Code {
					sectionvalue $AllData
					hex	2 "eZ80"
					set	eZtype [uint8]
					move	-1
					if {$eZtype == 0} {
						hex	1 "C"
					} elseif {$eZtype == 127} {
						hex	1 "ICE"
					}
					set	jp [uint8]
					move	3
					set	b2 [uint8]
					move	-5
					if {$jp == 195} { # the next byte has to be a jp for more header data
						if {$b2 == 1} {
							hex	4 "jp"
							hex	1 "Type 1"
							hex	1 "Width"
							hex	1 "Height"
							hex	256 "Icon"
							cstr	ascii "Description"
						} elseif {$b2 == 2} {
							hex	4 "jp"
							hex	1 "Type 2"
							cstr	ascii "Description"
						}
					}
					hex	[expr $datasize+$posset-[pos]] "Data"
				}
			} elseif {$assembly == 0xD900} { # `Stop;nop` mallard
				section -collapsed Code {
					sectionvalue $AllData
					hex	6 "Mallard"
					uint16	-hex "Start address"
					cstr	ascii "Description"
					hex	[expr $datasize+$posset-[pos]] "Data"
				}
			} elseif {$assembly == 0xD500} { # `Return;nop` crash
				section -collapsed Code {
					sectionvalue $AllData
					hex	3 "Crash"
					cstr	ascii "Description"
					hex	[expr $datasize+$posset-[pos]] "Data"
				}
			} elseif {$assembly == 0xEF69} { # CSE
				section -collapsed Code {
					sectionvalue $AllData
					hex	2 "Assembly"
					hex	[expr $datasize+$posset-[pos]] "Data"
				}
			} else {
				BAZIC	$datasize
			}
		}
		0x07 {
			set	datasize [uint16 "Data size"]
			hex	$datasize "Data"
		}
		0x08 {
			readGDB
		}
		0x0F -
		0x10 -
		0x11 {
			set	datasize [uint16 "Data size"]
			set	values { \
			Xmin Xmax Xscl Ymin Ymax Yscl θmin θmax \
			θstep Tmin Tmax Tstep PlotStart nMax u(1) v(1) \
			nMin u(2) v(2) w(2) PlotStep Xres w(1) }

			if {$datatype == $Type(Window)} {
				uint8	"Null"
			}
			if {$datatype == $Type(TSet)} {
				set	values { TblStrt DeltaTbl }
			}
			foreach index $values {
				readTINumb $index
			}
		}
		0x15 {
			ReadAppVar
		}
		0x17 {
			set	subsize [uint16 "Data size"]
			whiless $subsize {
				SysTab	$subsize
			}
		}
		0x1A {
			set	datasize [uint16 "Data size"]
			hex	1 "Magic 0x81"
			incr	datasize -1
			hex	$datasize "Data"
		}
		default {
			hex	$fallbacksize "Data"
		}
	}

	sectionvalue [expr [pos]-$start]\ bytes
	endsection
}

proc SysTab {size} {
	global	Z80typeDict
	set	EntryStart [pos]
	section -collapsed "System table entry" {
		set	subtype [hex 1]
		set	typename [entryd "Type" $subtype 1 $Z80typeDict]
		hex	1 "Reserved"
		hex	1 "Version"
		hex	2 "Structure pointer"
		entryd	"Archive status" [uint8] 1 [dict create 0 "Unarchived" 128 "Archived"]
		set	length [uint8]
		move	-1
		if {$length < 9 && $length != 0} {
			uint8	"Name length"
			ascii	$length "Name data"
		} else {
			hex	3 "Name data"
		}
		Z80readBody $subtype $size
		sectionvalue "$typename - [expr [pos]-$EntryStart] bytes"
	}
}

proc CheckSum {loopStart loopEnd} {
	set	check [pos]
	goto	$loopStart
	set	sum 0
	whiless	[expr $loopEnd-$loopStart] {
		incr	sum [uint8]
	}
	goto	$check
	entry	"Checksum" [format "0x%04X (0x%04X)" [uint16] [expr $sum & 65535]] 2 [expr [pos]-2]
}

little_endian
set	a [ascii 8]
if {$a!="**TI73**" && $a!="**TI82**" && $a!="**TI83**" && $a!="**TI83F*" && \
    $a!="**TI89**" && $a!="**TI92**" && $a!="**TI92P*" && \
    $a!="**TI85**" && $a!="**TI86**"} {
	requires 0 0
}
goto	0
ascii	8 "Magic"

main_guard {

if {$a=="**TI85**" || $a=="**TI86**"} {
	hex	3 "Export version"
	ascii	42 "Comment"
	set	filesize [uint16 "Data size"]

	section "Variables" {
		whiless $filesize { # e.i. clibs group
			section "Entry" {
				set	headsize [uint16 Body\ offset]
				set	headstart [pos]
				uint16
				set	datatype [hex 1]
				move	-3
				section "Meta" {
					if {$datatype == 0x1D} {
						uint16	"Data 1 size"
						entry	"Type" "[hex 1] (Backup)" 1 [expr [pos]-1]
						uint16	"Data 2 size"
						uint16	"Data 3 size"
						hex	2 "Address of data 2"
					} else {
						uint16	"Data size"
						hex	1 Type
						ascii	[uint8 Name\ length] Name
						# for TI-86 file variants: some include [garbage] name padding
						goto	[expr $headsize + $headstart]
					}
				}
				section "Body" {
					if {$datatype == 0x1D} {
						hex	[uint16 "Data 1 size"] "Data 1"
						hex	[uint16 "Data 2 size"] "Data 2"
						hex	[uint16 "Data 3 size"] "Data 3"
					} else {
						set	datasize [uint16 "Data size"]
						hex	$datasize Data
					}
				}
			}
		}
	}
	CheckSum 55 [pos]
} elseif {$a=="**TI89**" || $a=="**TI92**" || $a=="**TI92P*"} {
	hex	2 "Export version"
	ascii	8 "Folder name"
	ascii	40 "Comment"
	set	numFiles [uint16 "Variable count"]
	section "Variables" {
		for_n $numFiles {
			section Entry {
				section "Header" {
					sectionvalue "16 bytes"
					set	wheredata [uint32 "Offset to data"]
					set	name [ascii 8 "Name"]
					set	datatype [hex 1]
					entryd	"Type" $datatype 1 $68KtypeDict
					uint8	"Attribute"
					hex	2 "Unused"
				}
				sectionname [dictsearch $datatype $68KtypeDict]\ entry
				set retu [pos]
				goto [expr $wheredata-2]
				section "Body" {
					hex	2 "Signature"
					set	loopStart [pos]
					section -collapsed "Data" {
						hex	4 NULLs
						big_endian
						set	Size [uint16 Size]
						little_endian
						move	-6
						sectionvalue [hex [expr $Size+6]]
						move	-$Size
						hex	$Size "Data"
					}
					sectionvalue [expr $Size+10]\ bytes
					CheckSum $loopStart [pos]
				}
				sectionvalue "$name - [expr $Size+10] bytes"
				goto $retu
			}
		}
	}
	uint32	"File Size"
} else {
	hex	2 "Unread"
	entryd	"Owner Prod ID" [hex 1] 1 $ProdIDs

	ascii	42 "Comment"
	set	filesize [uint16 "Data size"]

	section "Variables" {
		whiless $filesize { # e.i. clibs "group"
			sectionvalue $filesize\ bytes
			section Entry {
				set	name ""
				set	bodysize 0
				set	variablestart [pos]
				set	headersize [uint16 "Body offset"]
				uint16
				set	datatype [hex 1]
				move	-3
				section "Meta" {
					sectionvalue $headersize\ bytes
					if { $datatype == 0x13 && $a!="**TI82**" || $datatype == 0x0F && $a=="**TI82**" } { ;# Backup
						uint16	"Data 1 size"
						uint8
						entry	"Type" "$datatype (Backup)" 1 [expr [pos]-1]
						if {$a=="**TI82**"} {
							set	datatype 0x13
						}
						uint16	"Data 2 size"
						uint16	"Data 3 size"
						hex	2 "Address?"
					} else {
						uint16	"Data size"

						uint8
						# larger 82 types are slightly offset, maybe make a returning function so the type value remains correct
						if {$a=="**TI82**" && $datatype > 10} {
							set	datatype [format "0x%02X" [expr $datatype + 4]]
						}
						entryd	"Type" $datatype 1 $Z80typeDict
						# TODO: file name decoder
						set	name [string map {[ θ} [ascii 8]]
						set	name [string map {] |L} $name]
						entry	"Name" $name 8 [expr [pos]-8]

						if {$headersize == 13} {
							hex	1 Version
							section -collapsed "Flags" {
								set	Flags [hex 1]
								sectionvalue $Flags\ ([expr ($Flags & 128) ?"Archived":"Unarchived"])
								FlagRead $Flags 7 Archived Unarchived
							}
						}
					}
				}

				section	"Body" {
					# set	start [pos]
					if { $datatype == 0x13 } {
						hex	[uint16 "Data 1 size"] "Data 1"
						hex	[uint16 "Data 2 size"] "Data 2"
						hex	[uint16 "Data 3 size"] "Data 3"
					} else {
						set	datasize [uint16 "Data size"]
						Z80readBody $datatype $datasize
					}
					# sectionvalue "[expr [pos]-$start] bytes"
				}

				sectionname [dictsearch $datatype $Z80typeDict]\ entry

				if {$name == ""} {
					sectionvalue "[expr [pos]-$variablestart] bytes"
				} else {
					sectionvalue "$name - [expr [pos]-$variablestart] bytes"
				}
			}
		}
	}
	CheckSum 55 [pos]
}

}
