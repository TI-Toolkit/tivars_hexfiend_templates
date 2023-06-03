# TI graphing calculator format HexFiend template
# Version 1.0
# (c) 2021-2023 LogicalJoe

if {[info command hf_min_version_required] ne ""} {
	hf_min_version_required 2.15
} else {
	puts stderr "Template must be used in HexFiend"
	return
}

proc size_field {{title Data}} {
	set	s [uint16]
	entry	"$title size" $s\ byte[expr $s-1?"s":""] 2 [expr [pos]-2]
	return	$s
}

set ThisDirectory [file dirname [file normalize [info script]]]

foreach a {BAZIC BAZIC85} {
	if {[file exists [file join $ThisDirectory $a.txt]]} {
		source	[file join $ThisDirectory $a.txt]
	} else {
		proc $a {size {a a}} {
			if {$size} {
				bytes	$size Code
			} else {
				entry	Code ""
			}
		}
	}
}

if {[file exists [file join $ThisDirectory AppVar.txt]]} {
	source	[file join $ThisDirectory AppVar.txt]
} else {
	proc ReadAppVar {} {
		set	datasize [size_field]
		if {$datasize} {
			bytes	$datasize Data
		} else {
			entry	Data ""
		}
	}
}

if {[file exists [file join $ThisDirectory "68KRPN.txt"]]} {
	source	[file join $ThisDirectory "68KRPN.txt"]
} else {
	proc 68KRPN {datasize} {
		if {$datasize} {
			bytes	$datasize Data
		} else {
			entry	Data ""
		}
	}
}

# entryd label value length dict
proc entryd {a b c d} {
	if [dict exists $d [set f [set e $b]]] {
		set	f $b\ ([set e [dict get $d $b]])
	}
	entry	$a $f $c [expr [pos]-$c]
	return	$e
}

proc FlagRead {Flag bit {setname Unused/Unknown} {resname -1}} {
	if {$Flag>>$bit&1} {
		entry Bit\ $bit $setname 1 [expr [pos]-1]
	} elseif {$resname != -1} {
		entry Bit\ $bit $resname 1 [expr [pos]-1]
	}
}

proc whiless {size body} {
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
		# means undefined? unclear if exclusive to Diff GDB
		if {$bitbyte == 255} {
			set start [pos]
			set string [ascii [uint8]]
			goto [expr $start+9]
			entry	"TI-Float $index" $string\ (undefined) 10 [expr [pos]-10]
			return
		}
		set	Sign [expr $bitbyte & 128?"-":"+"]
		set	Power [expr [uint16]-64512]
		set	First [uint8]
		set	First [expr $First/16].[expr $First%16]
		set	Body $First[format "%012X" [hex 6]]
		entry	"TI-Float $index" "$Sign$Body\e$Power" 10 [expr [pos]-10]

		if {!$recursed && ($bitbyte & 1)} {
			internalNumber "$index\c" 1
		}
	}
	internalNumber $index 0
}

proc readZ80Numb {{index ""}} {
	proc readTIFloat {{index ""} {recursed 0}} {
		set	bitbyte [uint8]
		set	typebyte [expr ($bitbyte & 63) < 16 && ($bitbyte & 2) ?0:($bitbyte & 63)]
		if {$typebyte in {28 29}} {
			move	-1
			readTIRadical $index $recursed
			return
		}
		set	Name TI-F[expr $typebyte>15?"raction":"loat"]
		set	Name $Name[expr $typebyte>29?"Pi":""]
		set	Bits [expr ($bitbyte&2 && !(48&$bitbyte))?" unset":""]
		set	Sign [expr $bitbyte & 128?"-":"+"]
		set	Power [expr [uint8]-128]
		set	First [uint8]
		set	First [expr $First/16].[expr $First%16]
		set	Body $First[format "%012X" [hex 6]]
		entry	"$Name $index" "$Sign$Body\e$Power$Bits" 9 [expr [pos]-9]

		if {!$recursed && $typebyte in {12 27 30 31}} {
			readTIFloat "$index\c" 1
		}
	}

	proc readTIRadical {{index ""} {recursed 0}} {
		set	typebyte [uint8]
		set	Body [format "%016X" [hex 8]]

		set	Signs [string range $Body 0 0]
		set	Sign1 [expr $Signs & 1?"-":""]
		set	Sign2 [expr $Signs & 2?"-":"+"]
		set	N5 [string range $Body 1 3]
		set	N3 $Sign2[string range $Body 4 6]
		set	N1 $Sign1[string range $Body 7 9]
		set	N4 [string range $Body 10 12]
		set	N2 [string range $Body 13 15]
		entry	"TI-Radical $index" "($N1√$N2$N3√$N4)/$N5" 9 [expr [pos]-9]

		if {!$recursed && $typebyte == 29} {
			readTIRadical "$index\c" 1
		}
	}

	readTIFloat $index 0
}

proc readGDB {} {
	set	datasize [size_field]
	set	start [pos]
	set	isn82 ![uint8]
	move	-1
	if $isn82 {
		uint8	Reserved
	}
	set	Mode [uint8]
	entryd	"Graph mode flag" $Mode 1 [dict create 16 Function 32 Polar 64 Parametric 128 Sequence]
	section "Format flags" {
		set	Flags [hex 1]
		sectionvalue $Flags
		FlagRead $Flags 0 MonoDot MonoConnected
		FlagRead $Flags 1 Simul Sequential
		FlagRead $Flags 2 GridOn GridOff
		FlagRead $Flags 3 PolarGC RectGC
		FlagRead $Flags 4 CoordOff CoordOn
		FlagRead $Flags 5 AxesOff AxesOn
		FlagRead $Flags 6 LabelOn LabelOff
		FlagRead $Flags 7 GridLine GridDot
	}
	section "Sequence flags" {
		set	Flags [hex 1]
		sectionvalue $Flags
		entryd	Bits\ 0-4 [expr $Flags & 31] 1 [dict create 0 Time 1 Web 2 VertWeb 4 uv 8 vw 16 uw]
		FlagRead $Flags 5 Unknown
		foreach a {6 7} {
			FlagRead $Flags $a Unused
		}
	}
	if $isn82 {
		section "Extended settings" {
			set	Flags [hex 1]
			sectionvalue $Flags
			FlagRead $Flags 0 ExprOff ExprOn
			set	seqmode [expr $Flags >> 1 & 3]
			entry	Bits\ 1&2 "SEQ([expr $seqmode?"n+$seqmode":"n"])" 1 [expr [pos]-1]
			foreach a {3 4 5 6 7} {
				FlagRead $Flags $a Unused
			}
		}
	}

	set	numbs "Xmin Xmax Xscl Ymin Ymax Yscl"
	switch -- $Mode {
		16	{
			set	EquNames "Y1 Y2 Y3 Y4 Y5 Y6 Y7 Y8 Y9 Y0"
			if $isn82 { lappend numbs Xres }
		}
		32	{
			set	EquNames "r1 r2 r3 r4 r5 r6"
			lappend numbs thetamin thetamax thetastep
		}
		64	{
			set	EquNames "X1T/Y1T X2T/Y2T X3T/Y3T X4T/Y4T X5T/Y5T X6T/Y6T"
			lappend numbs Tmin Tmax Tstep
		}
		128	{
			set	EquNames "u v[expr $isn82?" w":""]"
			append numbs [expr $isn82?{ PlotStart nMax u(nMin) v(nMin) nMin u(nMin+1) v(nMin+1) w(nMin+1) PlotStep w(nMin)}:{ nMin nMax UnStart VnStart nStart}]
		}
	}
	section "Numbers" {
		foreach index $numbs {
			readZ80Numb $index
		}
	}

	if $isn82 {
		section "Styles" {
			foreach index $EquNames {
				entryd	"$index Style" [uint8] 1 [dict create 0 Thin\ line 1 Thick\ line 2 Shade\ above 3 Shade\ below 4 Trace 5 Animate 6 Thick\ dotted\ line 7 Thin\ dotted\ line]
			}
		}
	}

	section Equations
	foreach index [join [split $EquNames /]\ ] {
		section $index {
			section -collapsed "Flags" {
				set	Flags [hex 1]
				sectionvalue "$Flags - [expr $Flags & 32?"S":"Uns"]elected"
				entryd	"Type" [format "0x%02X" [expr $Flags & 31]] 1 $::Z80typeDict
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
		section "84C settings"
		set	oscolors [dict create \
		1 BLUE 2 RED 3 BLACK 4 MAGENTA \
		5 GREEN 6 ORANGE 7 BROWN 8 NAVY \
		9 LTBLUE 10 YELLOW 11 WHITE 12 LTGRAY \
		13 MEDGRAY 14 GRAY 15 DARKGRAY 16 Off]

		foreach index $EquNames {
			entryd	"$index color" [uint8] 1 $oscolors
		}
		entryd	"Grid color" [uint8] 1 $oscolors
		entryd	"Axes color" [uint8] 1 $oscolors
		entryd	"Global line style" [uint8] 1 [dict create 0 Thick 1 Dot-Thick 2 Thin 3 Dot-Thin]
		uint8	"Border color"
		section "Extended settings 2" {
			set	Flags [hex 1]
			sectionvalue $Flags
			FlagRead $Flags 0 "Detect Asymptotes Off" "Detect Asymptotes On"
			foreach a {1 2 3 4 5 6 7} {
				FlagRead $Flags $a Unused
			}
		}
		endsection
	}
}

proc read85GDB {type {magic "**TI86**"}} {
	size_field
	section "Format flags" {
		set	Flags [hex 1]
		sectionvalue $Flags
		FlagRead $Flags 0 DrawDot DrawLine
		FlagRead $Flags 1 SimulG SeqG
		FlagRead $Flags 2 GridOn GridOff
		FlagRead $Flags 3 PolarGC RectGC
		FlagRead $Flags 4 CoordsOff CoordsOn
		FlagRead $Flags 5 AxesOff AxesOn
		FlagRead $Flags 6 LabelOn LabelOff
		FlagRead $Flags 7 86GDB 85GDB
		set GDB86 [expr $Flags >> 7]
	}
	set	StyleCount 100
	set	numbs "xMin xMax xScl yMin yMax yScl"
	switch -- $type {
		0x0D {
			set	EquName y
			if $GDB86 { lappend numbs xRes }
		}
		0x0E {
			set	EquName r
			set	numbs "thetaMin thetaMax thetaStep $numbs"
		}
		0x0F {
			set	EquName \[xy]t
			set	numbs "tMin tMax tStep $numbs"
		}
		0x10 {
			set	EquName Q'
			set	StyleCount 10
			if $GDB86 {
				section "Differential flags" {
					set	Flags [hex 1]
					sectionvalue $Flags
					entryd	Bits\ 0-2 [expr $Flags & 7] 1 [dict create 1 SlpFld 2 DirFld 4 FldOff]
					FlagRead $Flags 3 Unknown
					FlagRead $Flags 4 Unknown
					FlagRead $Flags 5 Euler RK
					FlagRead $Flags 6 Unknown
					FlagRead $Flags 7 Unknown
				}
			}
			set	numbs "difTol tPlot tMin tMax tStep $numbs"
		}
	}

	section Numbers {
		foreach index $numbs {
			read85Numb $index
		}
	}

	if {$type == 0x10} {
		section Differential
		set	Axis_dict [dict create 0x00 t 0x10 Q 0x20 Q']
		for {set a 1} {$a<10} {incr a} {
			dict	set Axis_dict 0x1$a Q$a
			dict	set Axis_dict 0x2$a Q'$a
		}
		foreach a {"FldOff x" "FldOff y"} {
			entryd	$a\ axis [hex 1] 1 $Axis_dict
		}
		if $GDB86 {
			foreach a {"SlpFld y" "DirFld x" "DirFld y"} {
				entryd	$a\ axis [hex 1] 1 $Axis_dict
			}
			foreach a {dTime fldRes EStep} {
				read85Numb $a
			}
		}
		endsection
	}

	set	functions [uint8 "Equation count"]
	section Equations
	for_n $functions {
		section Equation
		section -collapsed Flags {
			set	Flags [hex 1]
			set	equid [expr $Flags & 127]
			entry	ID $equid 1 [expr [pos]-1]
			sectionvalue "$EquName$equid - [expr $Flags & 0x80?"S":"Uns"]elected"
			FlagRead $Flags 7 Selected Unselected
		}
		sectionname $EquName$equid
		switch -- $type {
			0x0F { # parametric
				foreach a {x y} {
					section ${a}t$equid {
						BAZIC85	[size_field Code] $magic
					}
				}
			}
			0x10 { # differential
				BAZIC85	[size_field Code] $magic
				if $GDB86 {
					hex	1 Unknown
				}
				read85Numb Initial
			}
			default { # function & polar
				BAZIC85	[size_field Code] $magic
			}
		}
		endsection
	}
	endsection
	if $GDB86 {
		section Styles {
			for {set a 1} {$a < $StyleCount} {incr a} {
				set b [expr {$a % 2 ? [uint8] : $b << 4}]
				entryd	$EquName$a\ Style [expr $b>>4&15] 1 [dict create 0 Solid\ line 1 Thick\ line 2 Shade\ above 3 Shade\ below 4 Trace 5 Animate 6 dotted\ line]
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
		0x13 { # RPN-TAG formats
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
		default { bytes $fallbacksize Data }
	}
	endsection
}

proc 85readBody {datatype magic {fallbacksize 0}} {
	section -collapsed Data
	set	start [pos]

	switch -- $datatype {
		0x00 -
		0x01 -
		0x08 -
		0x09 { read85Numb }
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
			set	assembly 1
			set	firstbyte 1
			if {$datasize > 1} {
				set	assembly [hex 2]
				move	-2
			}
			if {$datasize} {
				set	firstbyte [uint8]
				move	-1
			}
			if {$assembly == 0x8E28} {
				section -collapsed Code {
					hex	2 "Z80 token"
					bytes	[expr $datasize-2] Assembly
				}
			} elseif {$assembly == 0} { # Untokenized and Locked
				section -collapsed Code {
					hex	1 Untokenized
					hex	1 Locked
					bytes	[expr $datasize-2] Code
				}
			} elseif {$firstbyte == 0} { # Untokenized
				section -collapsed Code {
					hex	1 Untokenized
					bytes	[expr $datasize-1] "Code"
				}
			} else {
				BAZIC85	$datasize $magic
			}
		}
		0x0D -
		0x0E -
		0x0F -
		0x10 { read85GDB $datatype $magic }
		0x11 { bytes [size_field] "Data" }
		0x17 -
		0x18 -
		0x19 -
		0x1A -
		0x1B {
			size_field
			set	numbs "xMin xMax xScl yMin yMax yScl"
			switch -- $datatype {
				0x18 { set numbs "thetaMin thetaMax thetaStep $numbs" }
				0x19 { set numbs "tMin tMax tStep $numbs" }
				0x1A { set numbs "difTol tPlot tMin tMax tStep $numbs" }
				0x1B { set numbs "zthetaMin zthetaMax zthetaStep ztPlot ztMin ztMax ztStep zxmin zxMax zxScl zyMin zyMax zyScl" }
			}

			if {$datatype != 0x1B} {
				hex	1 Reserved
			}

			foreach index $numbs {
				read85Numb $index
			}

			if {$datatype == 0x17} {
				bytes 20 Reserved
			}
			if {$datatype in {0x17 0x1B} && $magic == "**TI86**"} {
				read85Numb xRes
			}
			# Dif windows have a bunch of extra stuffs attached, so that's fun
			set Axis_dict [dict create 0x00 t 0x10 Q 0x20 Q']
			for {set a 1} {$a<10} {incr a} {
				dict set Axis_dict 0x1$a Q$a
				dict set Axis_dict 0x2$a Q'$a
			}
			if {$datatype == 0x1A} {
				foreach a {"FldOff x" "FldOff y"} {
					entryd	$a\ axis [hex 1] 1 $Axis_dict
				}
				if {$magic != "**TI85**"} {
					foreach a {"SlpFld y" "DirFld x" "DirFld y"} {
						entryd	$a\ axis [hex 1] 1 $Axis_dict
					}
					foreach a {dTime fldRes EStep} {
						read85Numb $a
					}
				}
			}
		}
		default { bytes $fallbacksize Data }
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
		0x21 { readZ80Numb }
		0x01 -
		0x0D {
			set	n [uint16 "Indices"]
			for {set a 0} {$n > $a} {incr a} {
				readZ80Numb [expr $a+1]
			}
		}
		0x02 {
			set	Width [expr [uint8 "Width"]]
			set	Height [expr [uint8 "Height"]]
			for {set a 0} {$a<$Width*$Height} {incr a} {
				readZ80Numb "[expr 1+$a/$Width] [expr 1+$a%$Width]"
			}
		}
		0x03 -
		0x04 -
		0x0B { BAZIC [size_field Code] }
		0x05 -
		0x06 {
			set	datasize [size_field Code]
			set	posset [pos]
			set	assembly 0
			if {$datasize > 1} {
				set	assembly [hex 2]
				move	-2
			}

			if {$assembly == 0xBB6D} { # mono Z80
				section -collapsed Code {
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
							bytes	30 "Button"
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
					bytes	[expr $datasize+$posset-[pos]] "Assembly"
				}
			} elseif {$assembly == 0xD900} { # `Stop/nop`
				section -collapsed Code {
					hex	6 "Mallard"
					uint16	-hex "Start address"
					cstr	ascii "Description"
					bytes	[expr $datasize+$posset-[pos]] "Assembly"
				}
			} elseif {$assembly == 0xD500} { # `Return/nop` crash
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
		0x07 { bytes [size_field] "Data" }
		0x08 { readGDB }
		0x0F -
		0x10 -
		0x11 {
			size_field
			set	numbs {Xmin Xmax Xscl Ymin Ymax Yscl thetamin thetamax thetastep Tmin Tmax Tstep}
			if {$magic == "**TI82**"} {
				lappend numbs nMin nMax UnStart VnStart nStart
			} else {
				lappend numbs PlotStart nMax u(nMin) v(nMin) nMin u(nMin+1) v(nMin+1) w(nMin+1) PlotStep Xres w(nMin)
			}
			switch -- $datatype {
				0x0F { uint8 Reserved }
				0x11 { set numbs { TblStart DeltaTbl } }
			}
			foreach index $numbs {
				readZ80Numb $index
			}
		}
		0x15 { ReadAppVar }
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
		default { bytes $fallbacksize Data }
	}

	endsection
}


proc getNameZ80 {title type length} {
	set	start [pos]
	if {[file exists [file join $::ThisDirectory BAZIC.txt]]} {
		switch -- $type {
			0x01 -
			0x0D {
				int8
				set	a [hex 1]
				move	-2
				if {$a < 6} {
					set	name [BAZIC_GetToken [hex 1] 0]
				} elseif {$a == 0x40} {
					set	name "|LIDList"
				} else {
					set	name [string map {[ θ ] |L} [ascii $length]]
				}
			}
			0x05 -
			0x06 -
			0x15 -
			0x17 {
				# crude font mapping
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
				# first byte should be 03Ch
				# should be 0EF50h + [uint8], but no arbitrary detok
				int8
				set	name Image[expr ([uint8]+1)%10]
			}
			default { set name [BAZIC_GetToken [hex 1] 0] }
		}
	} else {
		set	name [string map {[ θ ] |L} [ascii $length]]
	}
	goto	$start
	entry	$title $name $length [pos]
	move	$length
	return	$name
}

proc SysTab {size magic} {
	set	EntryStart [pos]
	# https://wikiti.brandonw.net/index.php?title=83Plus:OS:System_Table
	section "Entry" {
		section "System table entry"
		section -collapsed "Type" {
			set	Flags [hex 1]
			set	subtype [format "0x%02X" [expr $Flags & 63]]
			# legacy Z80 equations use bit 5 for selection
			if {($Flags & 23) == 3} {
				set	subtype [format "0x%02X" [expr $Flags & 31]]
			}
			set	typename [entryd "Type" $subtype 1 $::Z80typeDict]
			sectionvalue $Flags\ ($typename)
			if {($Flags & 23) == 3} {
				FlagRead $Flags 5 "Selected Z80" "Unselected Z80"
			}
			FlagRead $Flags 6 "Was used for graph"
			# always reset
			FlagRead $Flags 7 "Link transfer flag"
		}
		section -collapsed Reserved {
			set	Flags [hex 1]
			sectionvalue $Flags
			FlagRead $Flags 0 "Selected eZ80" "Unselected eZ80"
			foreach a {1 2 3 4 5 6 7} {
				FlagRead $Flags $a
			}
		}
		hex	1 "Version"
		# unused garbage in groups
		entry	"Structure pointer" [format "0x%02X" [uint16]] 2 [expr [pos]-2]
		# always(?) zero in groups
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
			sectionvalue [expr {$name == "" ?"\[none]":$name}]
		}
		endsection
		Z80readBody $subtype $magic $size
		sectionname $typename\ entry
		sectionvalue [expr {$name == ""?"":"$name - "}][expr [pos]-$EntryStart]\ bytes
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
					set	typeName [entryd "Type" $datatype 1 $68KtypeDict]
					# are these flags?
					entryd	Attribute [hex 1] 1 [dict create 0x01 Locked 0x02 Archived]
					uint16	"Items in dir"
				}
				sectionname $typeName\ entry
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
		whiless $filesize {
			section Entry {
				set	name ""
				set	typeName ""
				set	bodyOffset [uint16 "Body offset"]
				set	headStart [pos]
				int16
				set	datatype [hex 1]
				move	-3
				section "Meta" {
					if {
					$datatype == 0x0F && $magic == "**TI82**" ||
					$datatype == 0x1D && $magic in {"**TI85**" "**TI86**"} ||
					$datatype == 0x13 && $magic in {"**TI73**" "**TI83**" "**TI83F*"}} {
						set	typeName "Backup"
						size_field "Data 1"
						entry	"Type" "[hex 1] (Backup)" 1 [expr [pos]-1]
						size_field "Data 2"
						size_field "Data 3"
						uint16	-hex "Address of data 2"
					} else {
						size_field

						int8
						if {$magic=="**TI82**" && $datatype > 10} {
							set	datatype [format "0x%02X" [expr $datatype + 4]]
						}
						if {$magic in {"**TI85**" "**TI86**"}} {
							set	typeName [entryd "Type" $datatype 1 $85typeDict]
							set	namelen [uint8 Name\ length]
							if {$namelen} {
								set	name [string map {\xC1 θ} [ascii $namelen]]
								entry	Name $name $namelen [expr [pos]-$namelen]
							} else {
								entry	Name ""
							}
						} else {
							set	typeName [entryd "Type" $datatype 1 $Z80typeDict]
							set	name [getNameZ80 Name $datatype 8]
							if {$bodyOffset > 11} {
								hex	1 Version
								set	a [hex 1]
								entry	Archived $a\ [expr $a?"(A":"(Una"]rchived) 1 [expr [pos]-1]
							}
						}

						# some TI-86 files include [garbage] name padding
						goto	[expr $bodyOffset + $headStart]

					}
				}

				section "Body" {
					if { $typeName == "Backup" } {
						bytes	[size_field "Data 1"] "Data 1"
						bytes	[size_field "Data 2"] "Data 2"
						bytes	[size_field "Data 3"] "Data 3"
					} elseif { $magic in {"**TI85**" "**TI86**"} } {
						85readBody $datatype $magic [size_field]
					} else {
						Z80readBody $datatype $magic [size_field]
					}
				}

				sectionname $typeName\ entry
				sectionvalue [expr {$name == ""?"":"$name - "}][expr [pos]-$headStart+2]\ bytes
			}
		}
	}
	CheckSum 55 [pos]
} else {
	requires 0 0
}
