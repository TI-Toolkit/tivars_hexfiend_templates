# TI graphing calculator format HexFiend template
# Version 1.0
# (c) 2021-2023 LogicalJoe

set CurDir [file dirname [file normalize [info script]]]

if {[info command hf_min_version_required] ne ""} {
	hf_min_version_required 2.15
} else {
	puts stderr "Template must be used in HexFiend"
	return
}

proc len_field {{title Data}} {
	set	s [uint16]
	entry	"$title length" $s\ byte[expr $s-1?"s":""] 2 [expr [pos]-2]
	return	$s
}

foreach a {BAZIC BAZIC85 BAZIC81} {
	set b [file join $CurDir BAZIC $a.txt]
	if [file exists $b] {
		source	$b
	} else {
		proc $a {len {a a}} {
			if $len {
				bytes	$len Code
			} else {
				entry	Code ""
			}
		}
	}
}

foreach a {ReadAppVar 68KRPN Assembly} {
	set b [file join $CurDir BAZIC $a.txt]
	if [file exists $b] {
		source	$b
	} else {
		proc $a {len} {
			if $len {
				bytes	$len Data
			} else {
				entry	Data ""
			}
		}
	}
}

if [file exists [file join $CurDir Assembly.txt]] {
	source	[file join $CurDir Assembly.txt]
} else {
	proc isAsm {asm} {
		return [expr {$asm in {0xEF7B 0xEF69 0xBB6D}}]
	}
	proc ReadAsm {asm len} {
		hex	2 "Asm token"
		if {$len-2} {
			bytes	[expr $len-2] Assembly
		} else {
			entry	Assembly ""
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

proc FlagRead {f b {s Unused/Unknown} {u ""}} {
	set a [expr {$f>>$b&1?$s:$u}]
	if {$a!=""} {
		entry Bit\ $b $a 1 [expr [pos]-1]
	}
}

proc whiless {a b} {
	set	c [pos]
	while {[pos]<$c+$a} {
		uplevel	1 $b
	}
}

proc for_n {n b {a 0}} {
	while {[incr a]<=$n} {
		uplevel	1 $b
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
	0x0F "TI-84 Plus CSE" \
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
	0x0E "Undefined" \
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

proc ReadVer {} {
	set	s TI-83\ Plus
	set	t TI-84\ Plus
	set	Vers [dict create \
		0x01 $s 0x02 "$s 1.15+" 0x03 "$s 1.16+" \
		0x04 $t 0x05 "$t 2.30+" 0x06 "$t 2.53MP+" 0x07 "$t 2.55MP+" \
		0x0A "$t CSE+" 0x0B "$t CE 5.0-5.2+" 0x0C "$t CE 5.3+"]
	section -collapsed Version {
		set	v [format 0x%02X [expr [set F [hex 1]]&223]]
		set	r [entryd Version $v 1 $Vers]
		FlagRead $F 5 Requires\ RTC
		sectionvalue $F[expr {$r!=$v||$F&32?" ([expr {$r!=$v?"$r[expr {$F&32?", ":""}]":""}][expr $F&32?"RTC":""])":""}]
	}
}

proc ReadAxes {is86} {
	set	axes "0x00 t 0x10 Q 0x20 Q'"
	for {set a 1} {$a<10} {incr a} {
		lappend	axes 0x1$a Q$a 0x2$a Q'$a
	}
	foreach a "{FldOff x} {FldOff y} [expr {$is86?"{SlpFld y} {DirFld x} {DirFld y}":""}]" {
		entryd	$a\ axis [hex 1] 1 $axes
	}
	if $is86 {
		foreach a {dTime fldRes EStep} {
			read85Numb $a
		}
	}
}

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
		set	Body [hex 7]
		set	Body [string range $Body 2 2].[string range $Body 3 15]
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
		set	type [expr $bitbyte & 63]
		if {$type in {28 29}} {
			move	-1
			readTIRadical $index $recursed
			return
		}
		set	Name TI-F[expr $type>15?"raction":"loat"]
		set	Name $Name[expr $type>29?"Pi":""]
		set	Name [expr $type==14?"Undefined":"$Name"]
		set	Sign [expr $bitbyte & 128?"-":"+"]
		set	Power [expr [uint8]-128]
		set	Body [hex 7]
		set	Body [string range $Body 2 2].[string range $Body 3 15]
		entry	"$Name $index" "$Sign$Body\e$Power" 9 [expr [pos]-9]
		if {!$recursed && $type in {12 27 30 31}} {
			readTIFloat "$index\c" 1
		}
	}

	proc readTIRadical {{index ""} {recursed 0}} {
		set	type [uint8]
		set	Body [hex 8]
		set	Signs [string range $Body 2 2]
		set	N5 [string range $Body 3 5]
		set	N3 [expr $Signs & 2?"-":"+"][string range $Body 6 8]
		set	N1 [expr $Signs & 1?"-":""][string range $Body 9 11]
		set	N4 [string range $Body 12 14]
		set	N2 [string range $Body 15 17]
		entry	"TI-Radical $index" "($N1√$N2$N3√$N4)/$N5" 9 [expr [pos]-9]
		if {!$recursed && $type == 29} {
			readTIRadical "$index\c" 1
		}
	}

	readTIFloat $index 0
}

proc readGDB {} {
	set	datalen [len_field]
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
		16 {
			set	EquSets "Y1 Y2 Y3 Y4 Y5 Y6 Y7 Y8 Y9 Y0"
			if $isn82 { lappend numbs Xres }
		}
		32 {
			set	EquSets "r1 r2 r3 r4 r5 r6"
			lappend numbs thetamin thetamax thetastep
		}
		64 {
			set	EquSets "X1T/Y1T X2T/Y2T X3T/Y3T X4T/Y4T X5T/Y5T X6T/Y6T"
			lappend numbs Tmin Tmax Tstep
		}
		128 {
			set	EquSets "u v[expr $isn82?" w":""]"
			append numbs [expr $isn82?{ PlotStart nMax u(nMin) v(nMin) nMin u(nMin+1) v(nMin+1) w(nMin) PlotStep w(nMin+1)}:{ nMin nMax UnStart VnStart nStart}]
		}
	}
	section "Numbers" {
		foreach index $numbs {
			readZ80Numb $index
		}
	}

	if $isn82 {
		section "Styles" {
			foreach index $EquSets {
				entryd	"$index Style" [uint8] 1 [dict create 0 Thin\ line 1 Thick\ line 2 Shade\ above 3 Shade\ below 4 Trace 5 Animate 6 Thick\ dotted\ line 7 Thin\ dotted\ line]
			}
		}
	}

	section Equations
	foreach index [join [split $EquSets /]\ ] {
		section $index {
			section -collapsed "Flags" {
				set	Flags [hex 1]
				sectionvalue "$Flags - [expr $Flags & 32?"S":"Uns"]elected"
				entryd	"Type" [format "0x%02X" [expr $Flags & 31]] 1 $::Z80typeDict
				FlagRead $Flags 5 Selected Unselected
				FlagRead $Flags 6 "Was used for graph"
				FlagRead $Flags 7 "Link transfer flag"
			}
			BAZIC	[len_field Code]
		}
	}
	endsection

	if {[pos]-$start != $datalen} {
		ascii	3 "Color magic"
		section "84C settings"
		set	oscolors [dict create \
		1 BLUE 2 RED 3 BLACK 4 MAGENTA \
		5 GREEN 6 ORANGE 7 BROWN 8 NAVY \
		9 LTBLUE 10 YELLOW 11 WHITE 12 LTGRAY \
		13 MEDGRAY 14 GRAY 15 DARKGRAY 16 Off]

		foreach index $EquSets {
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
	len_field
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
		set	GDB86 [expr $Flags >> 7]
	}
	set	StyleCount 100
	set	numbs "xMin xMax xScl yMin yMax yScl"
	switch -- $type {
		0x0D {
			set	EquPrfx y
			if $GDB86 { lappend numbs xRes }
		}
		0x0E {
			set	EquPrfx r
			set	numbs "thetaMin thetaMax thetaStep $numbs"
		}
		0x0F {
			set	EquPrfx \[xy]t
			set	numbs "tMin tMax tStep $numbs"
		}
		0x10 {
			set	EquPrfx Q'
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
		section Differential {
			ReadAxes $GDB86
		}
	}

	set	functions [uint8 "Equation count"]
	section Equations
	for_n $functions {
		section Equation
		section -collapsed Flags {
			set	Flags [hex 1]
			set	equid [expr $Flags & 127]
			entry	ID $equid 1 [expr [pos]-1]
			sectionvalue "$EquPrfx$equid - [expr $Flags & 0x80?"S":"Uns"]elected"
			FlagRead $Flags 7 Selected Unselected
		}
		sectionname $EquPrfx$equid
		switch -- $type {
			0x0F {
				foreach a {x y} {
					section ${a}t$equid {
						BAZIC85	[len_field Code] $magic
					}
				}
			}
			0x10 {
				BAZIC85	[len_field Code] $magic
				if $GDB86 {
					hex	1 Unknown
				}
				read85Numb Initial
			}
			default {
				BAZIC85	[len_field Code] $magic
			}
		}
		endsection
	}
	endsection
	if $GDB86 {
		section Styles {
			for {set a 1} {$a < $StyleCount} {incr a} {
				set	b [expr {$a % 2 ? [uint8] : $b << 4}]
				entryd	$EquPrfx$a\ Style [expr $b>>4&15] 1 [dict create 0 Solid\ line 1 Thick\ line 2 Shade\ above 3 Shade\ below 4 Trace 5 Animate 6 Dotted\ line]
			}
		}
	}
}

proc 68KreadBody {datatype {defaultLen 0}} {
	section -collapsed Data
	set	start [pos]
	switch -- $datatype {
		0x00 -
		0x04 -
		0x06 -
		0x0C -
		0x12 -
		0x13 { # RPN-TAG formats
			68KRPN	$defaultLen
		}
		0x0B {
			big_endian
			uint16	"Cursor offset"
			little_endian
			set	delim [hex 1]
			move	-1
			while $delim {
				section -collapsed Line {
					set	LineStart [pos]
					set	delim [hex 1]
					while {$delim != 0 && $delim != 13} {
						set	delim [uint8]
					}
					move	-2
					set	lineLen [expr [pos]-$LineStart]
					goto	$LineStart
					entryd	"Line type" [hex 1] 1 [dict create 0x0C Page\ break 0x20 Normal 0x43 Command 0x50 Print\ object]
					if $lineLen {
						sectionvalue [ascii $lineLen "Line"]
					} else {
						entry	Line ""
					}
					entryd	Deliminator [hex 1] 1 [dict create 0x00 EOF 0x0D Line\ End]
				}
			}
			hex	1 "TEXT_TAG (E0)"
		}
		default { bytes $defaultLen Data }
	}
	endsection
}

proc 85readBody {datatype magic {defaultLen 0}} {
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
			set	Width [uint8 "Width"]
			set	Height [uint8 "Height"]
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
		0x0A { BAZIC85 [len_field Code] $magic }
		0x0C -
		0x12 {
			set	datalen [len_field Code]
			set	assembly 1
			set	firstbyte 1
			if {$datalen > 1} {
				set	assembly [hex 2]
				move	-2
			}
			if $datalen {
				set	firstbyte [uint8]
				move	-1
			}
			if {$datatype == 0x0C} {
				if !$firstbyte {
					section -collapsed Code {
						hex	1 Assembly
						entryd	Shell? [hex 1] 1 [dict create 0x50 Phatos 0xBD SuperNova 0xF9 Usgard 0xFB Rigel 0xFD zshell]
						uint8	Offset
						cstr	ascii Title
						bytes	[expr $datalen-[pos]+$start+2] Assembly
					}
				} elseif $datalen {
					bytes	$datalen Code
				} else {
					entry	Code ""
				}
			} elseif {$assembly == 0x8E28} {
				section -collapsed Code {
					hex	2 "Z80 token"
					bytes	[expr $datalen-2] Assembly
				}
			} elseif !$firstbyte {
				section -collapsed Code {
					hex	1 Untokenized
					if !$assembly {
						hex	1 Locked
					}
					bytes	[expr $datalen-[pos]+$start+2] "Code"
				}
			} else {
				BAZIC85	$datalen $magic
			}
		}
		0x0D -
		0x0E -
		0x0F -
		0x10 { read85GDB $datatype $magic }
		0x11 { bytes [len_field] "Data" }
		0x17 -
		0x18 -
		0x19 -
		0x1A -
		0x1B {
			len_field
			set	numbs "xMin xMax xScl yMin yMax yScl"
			switch -- $datatype {
				0x18 { set numbs "thetaMin thetaMax thetaStep $numbs" }
				0x19 { set numbs "tMin tMax tStep $numbs" }
				0x1A { set numbs "difTol tPlot tMin tMax tStep $numbs" }
				0x1B { set numbs "zthetaMin zthetaMax zthetaStep ztPlot ztMin ztMax ztStep zxMin zxMax zxScl zyMin zyMax zyScl" }
			}

			if {$datatype != 0x1B} {
				hex	1 Reserved
			}

			foreach index $numbs {
				read85Numb $index
			}

			if {$datatype == 0x17} {
				bytes	20 Reserved
			}
			if {$datatype in {0x17 0x1B} && $magic == "**TI86**"} {
				read85Numb xRes
			}
			# Dif windows have a bunch of extra stuffs attached, so that's fun
			if {$datatype == 0x1A} {
				ReadAxes [expr {$magic != "**TI85**"}]
			}
		}
		default { bytes $defaultLen Data }
	}
	endsection
}

proc Z80readBody {datatype {magic "**TI83F*"} {defaultLen 0}} {
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
		0x0D -
		0x26 {
			set	n [uint16 "Indices"]
			for {set a 0} {$n > $a} {incr a} {
				readZ80Numb [expr $a+1]
			}
		}
		0x02 {
			set	Width [uint8 "Width"]
			set	Height [uint8 "Height"]
			for {set a 0} {$a<$Width*$Height} {incr a} {
				readZ80Numb "[expr 1+$a/$Width] [expr 1+$a%$Width]"
			}
		}
		0x03 -
		0x04 -
		0x0B { BAZIC [len_field Code] }
		0x05 -
		0x06 {
			set	datalen [len_field Code]
			set	posset [pos]
			set	assembly 0
			if {$datalen > 1} {
				set	assembly [hex 2]
				move	-2
			}
			if {[isAsm $assembly]} {
				section -collapsed Code {
					sectionvalue "\[expand for code]"
					ReadAsm $assembly $datalen
				}
			} else {
				BAZIC	$datalen
			}
		}
		0x07 { bytes [len_field] "Data" }
		0x08 { readGDB }
		0x0F -
		0x10 -
		0x11 {
			len_field
			set	numbs {Xmin Xmax Xscl Ymin Ymax Yscl thetamin thetamax thetastep Tmin Tmax Tstep}
			if {$magic == "**TI82**"} {
				lappend numbs nMin nMax UnStart VnStart nStart
			} else {
				lappend numbs PlotStart nMax u(nMin) v(nMin) nMin u(nMin+1) v(nMin+1) w(nMin) PlotStep Xres w(nMin+1)
			}
			switch -- $datatype {
				0x0F { uint8 Reserved }
				0x11 { set numbs "TblStart DeltaTbl" }
			}
			foreach index $numbs {
				readZ80Numb $index
			}
		}
		0x15 { ReadAppVar [len_field] }
		0x17 {
			set	datalen [len_field]
			whiless $datalen {
				SysTab	$datalen $magic
			}
		}
		0x1A {
			set	datalen [len_field]
			hex	1 "Magic 0x81"
			bytes	[expr $datalen-1] "Data"
		}
		default { bytes $defaultLen Data }
	}
	endsection
}

proc getNameZ80 {title type length} {
	set	start [pos]
	if {[file exists [file join $::CurDir BAZIC BAZIC.txt]]} {
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
			0x17 -
			0x26 {
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
	section Entry

	# https://wikiti.brandonw.net/index.php?title=83Plus:OS:System_Table
	section "System table entry"
	section -collapsed "Type" {
		set	Flags [hex 1]
		# legacy Z80 equations use bit 5 for selection
		set	type [format "0x%02X" [expr $Flags & (($Flags & 23) == 3?31:63)]]
		set	typename [entryd "Type" $type 1 $::Z80typeDict]
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
	ReadVer
	# unused garbage in groups
	entry	"Structure pointer" [format "0x%04X" [uint16]] 2 [expr [pos]-2]
	# always(?) zero in groups
	hex	1 "Page"
	section -collapsed "Name" {
		set	length [uint8]
		move	-1
		if {$length < 9 && $length} {
			uint8	"Name length"
		} else {
			set	length 3
		}
		set	name [getNameZ80 "Name data" $type $length]
		sectionvalue $name
	}
	endsection

	Z80readBody $type $magic $size
	sectionname $typename\ entry
	sectionvalue [expr {$name==""?"":"$name - "}][expr [pos]-$EntryStart]\ bytes

	endsection
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

if {$magic=="**TIFL**" && [file exists [file join $CurDir TI-Flash.txt]]} {
	source	[file join $CurDir TI-Flash.txt]
} elseif {$magic in {"**TI89**" "**TI92**" "**TI92P*"}} {
	hex	2 "Thing"
	ascii	8 "Folder name"
	ascii	40 "Comment"
	set	numFiles [uint16 "Variable count"]
	section "Variables"
	for_n $numFiles {
		section Entry
		section "Meta" {
			sectionvalue "16 bytes"
			set	bodyOffset [uint32 "Offset to data"]
			set	name [ascii 8 Name]
			set	datatype [hex 1]
			set	typeName [entryd "Type" $datatype 1 $68KtypeDict]
			# are these flags?
			entryd	Attribute [hex 1] 1 [dict create 0x01 Locked 0x02 Archived]
			uint16	"Items in dir"
		}
		sectionname $typeName\ entry
		set	retu [pos]
		goto	$bodyOffset
		section "Body" {
			set	loopStart [pos]
			hex	4 NULLs
			big_endian
			set	Size [uint16 Data\ length]
			little_endian
			68KreadBody $datatype $Size
			sectionvalue [expr $Size+8]\ bytes
			CheckSum $loopStart [pos]
		}
		sectionvalue "$name"
		goto	$retu
		endsection
	}
	endsection
	uint32	"File length"
	hex	2 "Body section magic"
} elseif {$magic in {"**TI73**" "**TI82**" "**TI83**" "**TI83F*" "**TI85**" "**TI86**"}} {
	hex	2 "Descriptor"
	entryd	"Owner Prod ID" [hex 1] 1 $ProdIDs
	ascii	42 "Comment"
	set	filesize [len_field Variables]
	section "Variables"
	whiless $filesize {
		section Entry
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
				len_field "Data 1"
				entry	"Type" "[hex 1] (Backup)" 1 [expr [pos]-1]
				len_field "Data 2"
				len_field "Data 3"
				uint16	-hex "Address of data 2"
			} else {
				len_field
				if {[uint8] > 10 && $magic=="**TI82**"} {
					set	datatype [format "0x%02X" [expr $datatype + 4]]
				}
				if {$magic in {"**TI85**" "**TI86**"}} {
					set	typeName [entryd "Type" $datatype 1 $85typeDict]
					set	namelen [uint8 Name\ length]
					if $namelen {
						set	name [string map {\xC1 θ} [ascii $namelen]]
						entry	Name $name $namelen [expr [pos]-$namelen]
					} else {
						entry	Name ""
					}
				} else {
					set	typeName [entryd "Type" $datatype 1 $Z80typeDict]
					set	name [getNameZ80 Name $datatype 8]
					if {$bodyOffset > 11} {
						ReadVer
						set	a [hex 1]
						entry	Archived $a\ [expr $a?"(A":"(Una"]rchived) 1 [expr [pos]-1]
					}
				}
				# some TI-86 files include [garbage] name padding
				goto	[expr $bodyOffset + $headStart]
			}
		}

		section "Body" {
			if {$typeName=="Backup"} {
				bytes	[len_field "Data 1"] "Data 1"
				bytes	[len_field "Data 2"] "Data 2"
				bytes	[len_field "Data 3"] "Data 3"
			} elseif {$magic in {"**TI85**" "**TI86**"}} {
				85readBody $datatype $magic [len_field]
			} else {
				Z80readBody $datatype $magic [len_field]
			}
		}

		sectionname $typeName\ entry
		sectionvalue [expr {$name==""?"":"$name - "}][expr [pos]-$headStart+2]\ bytes
		endsection
	}
	endsection
	CheckSum 55 [pos]
} elseif {$magic=="**TI81**"} {
	hex	2 "Thing"
	set	size [len_field Code]
	set	name ""
	for_n 8 { # simplified detok
		set	a [uint8]
		set	name $name[format %c [expr $a<86?$a+32:$a==115?952:$a>86?$a-24:20]]
	}
	entry	Name $name 8 [expr [pos]-8]
	BAZIC81 $size
	CheckSum 12 [pos]
} else {
	requires 0 0
}
