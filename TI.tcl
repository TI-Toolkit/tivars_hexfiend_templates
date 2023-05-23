# TI graphing calculator format HexFiend template
# Version 1.0
# (c) 2021-2023 LogicalJoe


proc size_field {{title Data}} {
	set	s [uint16]
	entry	"$title size" $s\ byte[expr $s-1?"s":""] 2 [expr [pos]-2]
	return	$s
}

variable ThisDirectory [file dirname [file normalize [info script]]]

if {[file exists [file join $ThisDirectory BAZIC.txt]]} {
	source	[file join $ThisDirectory BAZIC.txt]
} else {
	proc BAZIC {datasize} {
		if {$datasize} {
			bytes	$datasize Code
		} else {
			entry	"Code" ""
		}
	}
}

if {[file exists [file join $ThisDirectory AppVar.txt]]} {
	source	[file join $ThisDirectory AppVar.txt]
} else {
	proc ReadAppVar {} {
		set	datasize [size_field]
		if {$datasize} {
			bytes	$datasize "Data"
		} else {
			entry	"Data" ""
		}
	}
}

if {[file exists [file join $ThisDirectory "68KRPN.txt"]]} {
	source	[file join $ThisDirectory "68KRPN.txt"]
} else {
	proc 68KRPN {datasize} {
		if {$datasize} {
			hex	$datasize "Data"
		} else {
			entry	"Data" "empty"
		}
	}
}

if {[file exists [file join $ThisDirectory "BAZIC85.txt"]]} {
	source	[file join $ThisDirectory "BAZIC85.txt"]
} else {
	proc BAZIC85 {datasize} {
		if {$datasize} {
			hex	$datasize "Data"
		} else {
			entry	"Data" "empty"
		}
	}
}

# proc main_guard {body} {
#	if [catch { uplevel 1 $body }] {
#		uplevel	1 { entry "FATAL" "Somthin' hap'ned" }
#	}
# }

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

proc FlagRead {Flag bit {name Unused/Unknown} {notname -1}} {
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

set	85typeDict [dict create \
	0x00 "Real" \
	0x01 "Complex" \
	0x02 "Real vector" \
	0x03 "Complex vector" \
	0x04 "Real list" \
	0x05 "Complex list" \
	0x06 "Real matrix" \
	0x07 "Complex matrix" \
	0x08 "Real constant" \
	0x09 "Complex constant" \
	0x0A "Equation" \
	0x0C "String" \
	0x0D "Function GDB" \
	0x0E "Polar GDB" \
	0x0F "Parametric GDB" \
	0x10 "Differential GDB" \
	0x11 "Picture" \
	0x12 "Program" \
	0x14 "LCD / PrintScreen" \
	0x17 "Function window" \
	0x18 "Polar window" \
	0x19 "Param window" \
	0x1A "DifEq window" \
	0x1B "Recall window" \
	0x1D "Backup" \
	0x1E "Unknown" \
]

set	68KtypeDict [dict create \
	0x00 "Expression" \
	0x04 "List" \
	0x06 "Matrix" \
	0x0A "Data" \
	0x0B "Text" \
	0x0C "String" \
	0x0D "Graph database" \
	0x0E "Figure" \
	0x10 "Picture" \
	0x12 "Program" \
	0x13 "Function" \
	0x14 "Macro" \
	0x18 "Clock" \
	0x1A "Request Directory" \
	0x1B "Local Directory" \
	0x1C "STDY" \
	0x1D "Backup" \
	0x1F "Directory" \
	0x20 "Get Certificate" \
	0x21 "Assembly program" \
	0x22 "ID-List" \
	0x23 "OS" \
	0x24 "App" \
	0x25 "Certificate" \
]

proc read85Numb {{index ""}} {
	proc internalNumber {index recursed} {
		set	bitbyte [uint8]
		set	Sign [expr $bitbyte & 128?"-":"+"]
		set	Power [expr [uint16]-64512]
		set	First [uint8]
		set	First [expr $First/16].[expr $First%16]
		set	Body $First[format "%012X" [hex 6]]
		entry	"TI-Float $index" "$Sign$Body\e$Power" 10 [expr [pos]-10]

		if {!$recursed && ($bitbyte & 1)} {
			readTIFloat "$index\c" 1
		}
	}
	internalNumber $index 0
}

proc readZ80Numb {{index ""}} {
	proc readTIFloat {{index ""} {recursed 0}} {
		set	bitbyte [uint8]
		set	typebyte [expr ($bitbyte & 127) > 15 ?($bitbyte & 127):($bitbyte & 2)?0:($bitbyte & 12)]

		if {$typebyte == 28 || $typebyte == 29} {
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
		set	Body $First[format "%012X" [hex 6]]
		entry	"TI-F$Name $index" "$Sign$Body\e$Power$Bits" 9 [expr [pos]-9]

		if {!$recursed && (($bitbyte & 0x0E)==0x0C ||
		$typebyte == 27 || $typebyte == 30 || $typebyte == 31)} {
			readTIFloat "$index\c" 1
		}
	}

	proc readTIRadical {{index ""} {recursed 0}} {
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

		if {!$recursed && ($typebyte in {27 29 30 33})} {
			readTIRadical "$index\c" 1
			# should this be readTIFloat?
		}
	}

	readTIFloat $index 0
}

proc readGDB {{magic "**TI83F*"}} {
	global	Z80typeDict
	set	datasize [size_field]
	set	start [pos]
	uint8	Reserved ;# always zero
	set	GraphMode [uint8]
	entryd	"Graph mode flag" $GraphMode 1 [dict create 16 Function 32 Polar 64 Parametric 128 Sequence]
	section "Format flags" {
		set	Flags [hex 1]
		sectionvalue $Flags
		FlagRead $Flags 0 MonoDot MonoConnected
		FlagRead $Flags 1 Simul Sequential
		FlagRead $Flags 2 GridOn GridOff
		FlagRead $Flags 3 PolarGC RectGC
		FlagRead $Flags 4 CoordsOn CoordsOff
		FlagRead $Flags 5 AxesOn AxesOff
		FlagRead $Flags 6 LabelOn LabelOff
		FlagRead $Flags 7 GridLine GridDot
	}
	section "Sequence flags" {
		set	Flags [hex 1]
		sectionvalue $Flags
		entryd	Bits\ 0-4 [expr $Flags & 31] 1 [dict create 0 Time 1 Web 2 VertWeb 4 uv 8 vw 16 uw]
		FlagRead $Flags 5 Unknown
		FlagRead $Flags 6 Unused
		FlagRead $Flags 7 Unused
	}
	section "Extended settings" {
		set	Flags [hex 1]
		sectionvalue $Flags
		FlagRead $Flags 0 ExprOff ExprOn
		set	seqmode [expr ($Flags & 6) >> 1]
		if {$seqmode} {
			entry Bits\ 1&2 "SEQ(n+$seqmode)" 1 [expr [pos] - 1]
		} else {
			entry Bits\ 1&2 "SEQ(n)" 1 [expr [pos] - 1]
		}
		foreach a {3 4 5 6 7} {
			FlagRead $Flags $a Unused
		}
	}

	if {$magic == "**TI82**"} {
		switch -- $GraphMode {
			16	{ set	values { Xmin Xmax Xscl Ymin Ymax Yscl } }
			32	{ set	values { Xmin Xmax Xscl Ymin Ymax Yscl Thetamin Thetamax Thetastep } }
			64	{ set	values { Xmin Xmax Xscl Ymin Ymax Yscl Tmin Tmax Tstep } }
			128	{ set	values { Xmin Xmax Xscl Ymin Ymax Yscl nMin nMax UnStart VnStart nStart } }
		}
	} else {
		switch -- $GraphMode {
			16	{ set	values { Xmin Xmax Xscl Ymin Ymax Yscl Xres } }
			32	{ set	values { Xmin Xmax Xscl Ymin Ymax Yscl Thetamin Thetamax Thetastep } }
			64	{ set	values { Xmin Xmax Xscl Ymin Ymax Yscl Tmin Tmax Tstep } }
			128	{ set	values { Xmin Xmax Xscl Ymin Ymax Yscl PlotStart nMax u(nMin) v(nMin) nMin u(nMin+1) v(nMin+1) w(nMin+1) PlotStep w(nMin) } }
		}
	}
	section "Numbers" {
		foreach index $values {
			readZ80Numb $index
		}
	}

	switch -- $GraphMode {
		16	{ set	equationSets { Y1 Y2 Y3 Y4 Y5 Y6 Y7 Y8 Y9 Y0 } }
		32	{ set	equationSets { r1 r2 r3 r4 r5 r6 } }
		64	{ set	equationSets { X1T/Y1T X2T/Y2T X3T/Y3T X4T/Y4T X5T/Y5T X6T/Y6T } }
		128	{ set	equationSets [expr {"$magic" == "**TI82**"} ?{ u v }:{ u v w }] }
	}
	section "Styles" {
		foreach index $equationSets {
			entryd	"$index Style" [uint8] 1 [dict create 0 Thin\ line 1 Thick\ line 2 Shade\ above 3 Shade\ below 4 Trace 5 Animate 6 Thick\ dotted\ line 7 Thin\ dotted\ line]
		}
	}
	if {$GraphMode == 64} {
		set	equationsAll { X1T Y1T X2T Y2T X3T Y3T X4T Y4T X5T Y5T X6T Y6T }
	} else {
		set	equationsAll $equationSets
	}

	section Equations
	foreach index $equationsAll {
		section $index {
			# see https://wikiti.brandonw.net/index.php?title=83Plus:OS:System_Table#Entry_Parts
			section -collapsed "Flags" {
				set	Flags [hex 1]
				if {($Flags & (1 << 5)) != 0} {
					sectionvalue "$Flags - Selected"
				} else {
					sectionvalue "$Flags - Unselected"
				}
				entryd	"Type" [format "0x%02X" [expr $Flags & 31]] 1 $Z80typeDict
				FlagRead $Flags 5 Selected Unselected
				FlagRead $Flags 6 "Was used for graph"
				FlagRead $Flags 7 "Link transfer flag"
			}
			BAZIC	[size_field Code]
		}
	}
	endsection

	if {[pos]-$start != $datasize} {
		ascii	3 "Color magic"
		section "Colors" {
			set	oscolors [dict create \
			1 BLUE 2 RED 3 BLACK 4 MAGENTA \
			5 GREEN 6 ORANGE 7 BROWN 8 NAVY \
			9 LTBLUE 10 YELLOW 11 WHITE 12 LTGRAY \
			13 MEDGRAY 14 GRAY 15 DARKGRAY 16 Off]

			foreach index $equationSets {
				entryd	"$index color" [uint8] 1 $oscolors
			}
			entryd	"Grid color" [uint8] 1 $oscolors
			entryd	"Axes color" [uint8] 1 $oscolors
			entryd	"Global line style" [uint8] 1 [dict create 0 Thick 1 Dot-Thick 2 Thin 3 Dot-Thin]
			uint8	"Border color"
		}

		section "Extended settings 2" {
			set	Flags [hex 1]
			sectionvalue $Flags
			FlagRead $Flags 0 "Detect Asymptotes Off" "Detect Asymptotes On"
			foreach a {1 2 3 4 5 6 7} {
				FlagRead $Flags $a Unused
			}
		}
	}
}

proc 68KreadBody {datatype {fallbacksize 0}} {
	section -collapsed Data
	set	start [pos]
	switch -- $datatype {
		0x00 -
		0x04 -
		0x06 -
		0x0C -
		0x12 -
		0x13 {
			# RPN-TAG formats
			# bytes	$fallbacksize Data
			68KRPN	$fallbacksize
		}
		0x0B {
			big_endian
			uint16	"Cursor offset"
			little_endian
			set	delim [hex 1]
			move	-1
			while {$delim} {
				section -collapsed Line {
					set	LineStart [pos]
					set	delim [hex 1]
					while {$delim != 0 && $delim != 13} {
						set	delim [uint8]
					}
					move	-2
					set	lineSize [expr [pos]-$LineStart]
					goto	$LineStart
					entryd	"Line type" [hex 1] 1 [dict create 0x0C Page\ Break 0x20 Normal 0x43 Command 0x50 Print\ object]
					if {$lineSize} {
						sectionvalue [ascii $lineSize "Line"]
					} else {
						entry	Line ""
					}
					entryd	Deliminator [hex 1] 1 [dict create 0x00 EOF 0x0D Line\ End]
				}
			}
			hex	1 "TEXT_TAG (E0)"
		}
		default {
			bytes	$fallbacksize Data
		}
	}
	endsection
}

proc 85readBody {datatype magic {fallbacksize 0}} {
	section -collapsed Data
	set	start [pos]

# remaining formats:
#	0x0D "Function GDB"
#	0x0E "Polar GDB"
#	0x0F "Parametric GDB"
#	0x10 "Differential GDB"
#	0x14 "LCD / PrintScreen" (how does one make this file?)

	switch -- $datatype {
		0x00 -
		0x01 -
		0x08 -
		0x09 {
			read85Numb
		}
		0x02 -
		0x03 -
		0x06 -
		0x07 {
			set	Width [expr [uint8 "Width"]]
			set	Height [expr [uint8 "Height"]]
			for {set a 0} {$a<$Width*$Height} {incr a} {
				read85Numb "[expr 1+$a/$Width] [expr 1+$a%$Width]"
			}
		}
		0x04 -
		0x05 {
			set	n [uint16 "Indices"]
			for {set a 0} {$n > $a} {incr a} {
				read85Numb [expr $a+1]
			}
		}
		0x0A -
		0x0C -
		0x12 {
			set	datasize [size_field Code]
			set	posset [pos]
			set	assembly 0
			if {$datasize > 1} {
				set	assembly [hex 2]
				move	-2
				set	firstbyte [uint8]
				move	-1
			}
			if {$assembly == 0x8E27} {
				section -collapsed Code {
					hex	2 Tokenized\ Assembly
					bytes	[expr $datasize-2] Code
				}
			} elseif {$assembly == 0x8E28} {
				section -collapsed Code {
					hex	2 Compiled\ Assembly
					bytes	[expr $datasize-2] Assembly
				}
			} elseif {$assembly == 0x8E29} {
				hex	2 Edit-Lock
				BAZIC85 [expr $datasize-2]
			} elseif {$assembly == 0x0000} { # Untokenized
				section -collapsed Code {
					hex	1 Untokenized
					hex	1 Locked
					bytes	[expr $datasize-2] Code
				}
			} elseif {$firstbyte == 0} { # Untokenized and unlocked
				section -collapsed Code {
					hex	1 Untokenized
					bytes	[expr $datasize-1] "Code"
				}
			} else {
				BAZIC85	$datasize
			}
		}
		0x11 {
			bytes	[size_field] "Data"
		}
		0x17 -
		0x18 -
		0x19 -
		0x1A -
		0x1B {
			size_field
			switch -- $datatype {
				0x17 { set values { xMin xMax xScl yMin yMax yScl } }
				0x18 { set values { thetaMin thetaMax thetaStep xMin xMax xScl yMin yMax yScl } }
				0x19 { set values { tMin tMax tStep xMin xMax xScl yMin yMax yScl } }
				0x1A { set values { difTol tPlot tMin tMax tStep xMin xMax xScl yMin yMax yScl } }
				0x1B { set values { \
					zthetaMin zthetaMax zthetaStep \
					ztPlot ztMin ztMax ztStep \
					zxmin zxMax zxScl \
					zyMin zyMax zyScl }
				}
			}

			if {$datatype != 0x1B} {
				hex	1 Reserved
			}

			foreach index $values {
				read85Numb $index
			}

			if {$datatype in {0x17 0x1B}} {
				bytes 20 Reserved
				if {$magic == "**TI86**"} {
					read85Numb xRes
				}
			}
			# Dif windows have a bunch of extra stuffs attached, so that's fun
			set Axis_bytes [dict create 0x00 t \
			0x10 Q 0x11 Q1 0x12 Q2 0x13 Q3 0x14 Q4 0x15 Q5 0x16 Q6 0x17 Q7 0x18 Q8 0x19 Q9 \
			0x20 Q' 0x21 Q'1 0x22 Q'2 0x23 Q'3 0x24 Q'4 0x25 Q'5 0x26 Q'6 0x27 Q'7 0x28 Q'8 0x29 Q'9]
			if {$datatype == 0x1A} {
				if {$magic == "**TI85**"} {
					entryd	"X axis" [hex 1] 1 $Axis_bytes
					entryd	"Y axis" [hex 1] 1 $Axis_bytes
				} elseif {$magic == "**TI86**"} {
					entryd	"FldOff x axis" [hex 1] 1 $Axis_bytes
					entryd	"FldOff y axis" [hex 1] 1 $Axis_bytes
					entryd	"SlpFld y axis" [hex 1] 1 $Axis_bytes
					entryd	"DirFld x axis" [hex 1] 1 $Axis_bytes
					entryd	"DirFld y axis" [hex 1] 1 $Axis_bytes
					read85Numb dTime
					read85Numb fldRes
					read85Numb EStep
				}
			}
		}
		default {
			bytes	$fallbacksize Data
		}
	}
	endsection
}


proc Z80readBody {datatype {magic "**TI83F*"} {fallbacksize 0}} {
	section -collapsed Data
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
			readZ80Numb
		}
		0x01 -
		0x0D {
			set	n [uint16 "Indices"]
			for {set a 0} {$n > $a} {incr a} {
				readZ80Numb [expr $a+1]
			}
		}
		0x02 -
		0x0E {
			set	Width [expr [uint8 "Width"]]
			set	Height [expr [uint8 "Height"]]
			for {set a 0} {$a<$Width*$Height} {incr a} {
				readZ80Numb "[expr 1+$a/$Width] [expr 1+$a%$Width]"
			}
		}
		0x03 -
		0x04 -
		0x0B {
			set	datasize [size_field Code]
			BAZIC	$datasize
		}
		0x05 -
		0x06 {
			set	datasize [size_field Code]
			set	posset [pos]
			set	assembly 0
			if {$datasize > 1} {
				set	assembly [hex 2]
				move	-2
			}

			if {$assembly == 0xBB6D} { # 8\[43\]P? Z80
				section -collapsed Code {
					hex	2 "Z80 token"
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
					bytes	[expr $datasize+$posset-[pos]] "Assembly"
				}
			} elseif {$assembly == 0xC930} { # `ret / jr nc` for 83 ION
				section -collapsed Code {
					hex	1 "83 ION"
					hex	2 "jr nc"
					cstr	ascii "Description"
					bytes	[expr $datasize+$posset-[pos]] "Assembly"
				}
			} elseif {$assembly == 0x0018} { # `nop / jr` 83 ASHELL
				section -collapsed Code {
					# Wolfenstein 3D
					hex	1 "ASHELL83"
					hex	2 "jr"
					hex	2 "Table version"
					hex	2 "Description pointer"
					hex	2 "Icon pointer"
					hex	2 "For future use"
					bytes	[expr $datasize+$posset-[pos]] "Assembly"
				}
			} elseif {$assembly == 0x3F18} { # `ccf / jr` 83 TI-Explorer
				section -collapsed Code {
					hex	1 "TI-Explorer"
					hex	2 "jr"
					hex	2 "Table version"
					hex	2 "Description pointer"
					hex	2 "Icon pointer"
					hex	1 "ret"
					bytes	[expr $datasize+$posset-[pos]] "Assembly"
				}
			} elseif {$assembly == 0xAF28} { # `xor a / jr z` 83 SOS
				section -collapsed Code {
					hex	1 "83 SOS"
					hex	2 "jr z"
					hex	2 "Libraries"
					hex	2 "Description pointer"
					bytes	[expr $datasize+$posset-[pos]] "Assembly"
				}
			} elseif {$assembly == 0xEF7B} { # CE eZ80
				section -collapsed Code {
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
					bytes	[expr $datasize+$posset-[pos]] "Assembly"
				}
			} elseif {$assembly == 0xD900} { # `Stop;nop` mallard
				section -collapsed Code {
					hex	6 "Mallard"
					uint16	-hex "Start address"
					cstr	ascii "Description"
					bytes	[expr $datasize+$posset-[pos]] "Assembly"
				}
			} elseif {$assembly == 0xD500} { # `Return;nop` crash
				section -collapsed Code {
					hex	3 "Crash"
					cstr	ascii "Description"
					bytes	[expr $datasize+$posset-[pos]] "Assembly"
				}
			} elseif {$assembly == 0xEF69} { # CSE
				section -collapsed Code {
					hex	2 "Assembly"
					bytes	[expr $datasize+$posset-[pos]] "Assembly"
				}
			} else {
				BAZIC	$datasize
			}
		}
		0x07 {
			bytes	[size_field] "Data"
		}
		0x08 {
			readGDB $magic
		}
		0x0F -
		0x10 -
		0x11 {
			set	datasize [size_field]
			if {$magic == "**TI82**"} {
				set	values { \
				Xmin Xmax Xscl Ymin Ymax Yscl \
				Thetamin Thetamax Thetastep \
				Tmin Tmax Tstep \
				nMin nMax UnStart VnStart nStart }
			} else {
				set	values { \
				Xmin Xmax Xscl Ymin Ymax Yscl \
				Thetamin Thetamax Thetastep \
				Tmin Tmax Tstep \
				PlotStart \
				nMax u(nMin) v(nMin) nMin u(nMin+1) v(nMin+1) w(nMin+1) \
				PlotStep Xres \
				w(nMin) }
			}

			if {$datatype == 0x0F} {
				uint8	"Reserved" ;# always zero
			}
			if {$datatype == 0x11} {
				set	values { TblStart DeltaTbl }
			}
			foreach index $values {
				readZ80Numb $index
			}
		}
		0x15 {
			ReadAppVar
		}
		0x17 {
			set	subsize [size_field]
			whiless $subsize {
				SysTab	$subsize $magic
			}
		}
		0x1A {
			set	datasize [size_field]
			hex	1 "Magic 0x81"
			bytes	[expr $datasize-1] "Data"
		}
		default {
			bytes	$fallbacksize "Data"
		}
	}

	endsection
}

if {[file exists [file join $ThisDirectory BAZIC.txt]]} {
	proc getNameZ80 {title type length} {
		set	start [pos]
		switch -- $type {
			0x01 -
			0x0D {
				int8
				set	a [hex 1]
				move	-2
				if {$a < 6} {
					set	name [BAZIC_GetToken [hex 1] 0]
				} elseif {$a == 0x40} {
					set	name "IDList"
				} else {
					set	name [string map {[ θ ] |L} [ascii $length]]
				}
			}
			0x05 -
			0x06 -
			0x15 -
			0x17 {
				# crude font "simulation"
				set	name [string map {[ θ} [ascii $length]]
			}
			0x0F -
			0x10 -
			0x11 {
				array set r {0x0F Window 0x10 RclWindow 0x11 TblSet}
				set	name [ascii $length]
				set	name [expr {$name==""?$r($type):"$name ($r($type))"}]
			}
			0x1A {
				# annoyingly, images have their own "tokenizations"
				# first byte should be 03Ch (which I ignore, obviously)
				# should be 0EF50h + [uint8], but I don't have arbitrary detok
				uint8
				set	name Image[expr ([uint8]+1)%10]
			}
			default {
				set	name [BAZIC_GetToken [hex 1] 0]
			}
		}
		goto	$start
		entry	$title $name $length [pos]
		move	$length
		if {$name != "\[none]"} {
			return	$name
		} else {
			return	""
		}
	}
} else {
	proc getNameZ80 {title type length} {
		set	start [pos]
		set	a [hex 1]
		move	-1
		if {$a == 0} {
			set	name "\[none]"
		} else {
			set	name [string map {[ θ ] |L} [ascii $length]]
		}
		goto	$start
		entry	$title $name $length [pos]
		move	$length
		if {$name != "\[none]"} {
			return	$name
		} else {
			return	""
		}
	}
}



proc SysTab {size magic} {
	global	Z80typeDict
	set	EntryStart [pos]
	section "Entry" {
		section "System table entry"
		set	Flags [hex 1]
		section -collapsed "Type" {
			set	subtype [format "0x%02X" [expr $Flags & 63]]
			# legacy Z80 equations use bit 5 for selection
			if {($Flags & 23) == 3} {
				set	subtype [format "0x%02X" [expr $Flags & 31]]
			}
			entryd	"Type" $subtype 1 $Z80typeDict
			set	typename [dictsearch $subtype $Z80typeDict]
			sectionvalue $Flags\ ($typename)
			if {($Flags & 23) == 3} {
				FlagRead $Flags 5 "Selected Z80" "Unselected Z80"
			}
			FlagRead $Flags 6 "Was used for graph"
			# always reset
			FlagRead $Flags 7 "Link transfer flag"
		}
		set	Flags [hex 1]
		section -collapsed Reserved {
			sectionvalue $Flags
			FlagRead $Flags 0 "Selected eZ80" "Unselected eZ80"
			foreach a {1 2 3 4 5 6 7} {
				FlagRead $Flags $a
			}
		}
		hex	1 "Version"
		# unused garbage in groups
		entry	"Structure pointer" [format "0x%02X" [uint16]] 2 [expr [pos]-2]
		# should always(?) be zero in groups
		hex	1 "Page"
		section -collapsed "Name" {
			set	length [uint8]
			move	-1
			if {$length < 9 && $length != 0} {
				uint8	"Name length"
			} else {
				set	length 3
			}
			set	name [getNameZ80 "Name data" $subtype $length]
			if {$name == ""} {
				sectionvalue "\[none]"
			} else {
				sectionvalue $name
			}
		}
		endsection
		Z80readBody $subtype $magic $size
		if {$name == ""} {
			sectionvalue "[expr [pos]-$EntryStart] bytes"
		} else {
			sectionvalue "$name - [expr [pos]-$EntryStart] bytes"
		}
		sectionname $typename\ entry
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
if {[len] < 8} {
	requires 0 0
}
set	magic [ascii 8 Magic]

if {$magic=="**TIFL**" && [file exists [file join $ThisDirectory TI-Flash.tcl]]} {
	move -8
	source	[file join $ThisDirectory TI-Flash.tcl]
	return
} elseif {$magic in {"**TI89**" "**TI92**" "**TI92P*"}} {
	hex	2 "Thing"
	ascii	8 "Folder name"
	ascii	40 "Comment"
	set	numFiles [uint16 "Variable count"]
	section "Variables" {
		for_n $numFiles {
			section Entry {
				section "Meta" {
					sectionvalue "16 bytes"
					set	wheredata [uint32 "Offset to data"]
					set	name [ascii 8 Name]
					set	datatype [hex 1]
					entryd	"Type" $datatype 1 $68KtypeDict
					# are these flags?
					entryd	Attribute [hex 1] 1 [dict create 0x01 Locked 0x02 Archived]
					uint16	"Items in dir"
				}
				sectionname [dictsearch $datatype $68KtypeDict]\ entry
				set retu [pos]
				goto [expr $wheredata]
				section "Body" {
					set	loopStart [pos]
					hex	4 NULLs
					big_endian
					set	Size [uint16 Data\ size]
					little_endian
					68KreadBody $datatype $Size
					sectionvalue [expr $Size+8]\ bytes
					CheckSum $loopStart [pos]
				}
				sectionvalue "$name"
				goto $retu
			}
		}
	}
	uint32	"File Size"
	hex	2 "Body section magic"
} elseif {$magic in {"**TI73**" "**TI82**" "**TI83**" "**TI83F*" "**TI85**" "**TI86**"}} {
	hex	2 "Thing"
	entryd	"Owner Prod ID" [hex 1] 1 $ProdIDs

	ascii	42 "Comment"
	set	filesize [size_field Variables]

	section "Variables" {
		whiless $filesize { # i.e. clibs "group"
			section Entry {
				set	name ""
				set	typeName ""
				set	bodyOffset [uint16 "Body offset"]
				set	headStart [pos]
				uint16
				set	datatype [hex 1]
				move	-3
				section "Meta" {
					if {
					$datatype == 0x0F && $magic == "**TI82**" ||
					$datatype == 0x1D && $magic in {"**TI85**" "**TI86**"} ||
					$datatype == 0x13 && $magic in {"**TI73**" "**TI83**" "**TI83F*"}} {
						# Backup
						set	typeName "Backup"
						size_field "Data 1"
						entry	"Type" "[hex 1] (Backup)" 1 [expr [pos]-1]
						size_field "Data 2"
						size_field "Data 3"
						uint16	-hex "Address of data 2"
					} else {
						size_field

						uint8
						# larger 82 types are slightly offset, maybe make a returning function so the type value remains correct
						if {$magic=="**TI82**" && $datatype > 10} {
							set	datatype [format "0x%02X" [expr $datatype + 4]]
						}
						if {$magic=="**TI85**" || $magic=="**TI86**"} {
							set	typeName [dictsearch $datatype $85typeDict]
							entryd	"Type" $datatype 1 $85typeDict
							set	namelen [uint8 Name\ length]
							if {$namelen} {
								set	Name [string map {[ θ} [ascii $namelen Name]]
							} else {
								entry	Name ""
							}
						} else {
							set	typeName [dictsearch $datatype $Z80typeDict]
							entryd	"Type" $datatype 1 $Z80typeDict
							set	name [getNameZ80 Name $datatype 8]
							if {$bodyOffset == 13} {
								hex	1 Version
								section -collapsed "Flags" {
									set	Flags [hex 1]
									sectionvalue $Flags\ ([expr ($Flags & 128) ?"Archived":"Unarchived"])
									FlagRead $Flags 7 Archived Unarchived
								}
							}
						}

						# for TI-86 file variants: some include [garbage] name padding
						goto	[expr $bodyOffset + $headStart]

					}
				}

				section "Body" {
					if { $typeName == "Backup" } {
						bytes	[size_field "Data 1"] "Data 1"
						bytes	[size_field "Data 2"] "Data 2"
						bytes	[size_field "Data 3"] "Data 3"
					} elseif { $magic=="**TI85**" || $magic=="**TI86**" } {
						set	datasize [size_field]
						85readBody $datatype $magic $datasize
					} else {
						set	datasize [size_field]
						Z80readBody $datatype $magic $datasize
					}
					# sectionvalue "[expr [pos]-$start] bytes"
				}

				sectionname $typeName\ entry

				if {$name == ""} {
					sectionvalue "[expr [pos]-$headStart+2] bytes"
				} else {
					sectionvalue "$name - [expr [pos]-$headStart+2] bytes"
				}
			}
		}
	}
	CheckSum 55 [pos]
} else {
	requires 0 0
}
