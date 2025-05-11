# TI graphing calculator file parser HexFiend template
# Version 2.0
# (c) 2021-2025 LogicalJoe
# .types = (
# .73e, 73d, 73g, 73i, 73l, 73m, 73n, 73p, 73s, 73t, 73v, 73w, 73y, 73z,
# .82b, 82d, 82g, 82i, 82l, 82m, 82n, 82p, 82s, 82t, 82w, 82y, 82z,
# .83b, 83c, 83d, 83g, 83i, 83l, 83m, 83n, 83p, 83s, 83t, 83w, 83y, 83z,
# .8xb, 8xc, 8xd, 8xe, 8xg, 8xi, 8xl, 8xm, 8xn, 8xo, 8xp, 8xs, 8xt, 8xv, 8xw, 8xy, 8xz,
# .85b, 85c, 85d, 85g, 85i, 85k, 85l, 85m, 85n, 85p, 85r, 85s, 85t, 85v, 85w, 85y, 85z,
# .86b, 86c, 86d, 86g, 86i, 86k, 86l, 86m, 86n, 86p, 86r, 86s, 86t, 86v, 86w, 86y, 86z,
# .89a, 89c, 89d, 89e, 89f, 89g, 89i, 89l, 89m, 89p, 89r, 89s, 89t, 89x, 89y, 89z,
# .92a, 92b, 92c, 92d, 92e, 92f, 92g, 92i, 92l, 92m, 92p, 92r, 92s, 92t, 92x, 92y,
# .9xa, 9xc, 9xd, 9xe, 9xf, 9xg, 9xi, 9xl, 9xm, 9xp, 9xq, 9xr, 9xs, 9xt, 9xx, 9xy, 9xz,
# .v2a, v2c, v2d, v2e, v2f, v2g, v2i, v2l, v2m, v2p, v2q, v2r, v2s, v2t, v2x, v2y, v2z,
# .8cq, 8xq,
# .73k, 8xk, 8ck, 8ek,
# .73u, 82u, 89u, 8cu, 8eu, 8pu, 8xu, 8yu, 9xu, v2u,
# .b83, b84, tig, tib,
# .8ca, 8cb, 8cg, 8ci, 8xidl);

variable CurDir [file dirname [file normalize [info script]]]

if {[info command hf_min_version_required] ne ""} {
	hf_min_version_required 2.17
} else {
	puts stderr "Template must be used in HexFiend"
	return
}

proc len_field {{title Data}} {
	set	s [uint16]
	entry	"$title length" $s\ byte[expr $s-1?"s":""] 2 [expr [pos]-2]
	return	$s
}

foreach a {BAZIC83 BAZIC85 BAZIC81 BAZIC73} {
	set b [file join $CurDir BAZIC $a.tcl]
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

proc BAZIC {len {magic ""}} {
	if {$magic == "**TI73**"} {
		BAZIC73 $len
	} else {
		BAZIC83 $len
	}
}

foreach a {ReadAppVar 68KRPN Assembly} {
	set b [file join $CurDir $a.tcl]
	if [file exists $b] {
		source	$b
	} else {
		proc $a {len {a}} {
			if $len {
				bytes	$len Data
			} else {
				entry	Data ""
			}
		}
	}
}

if [file exists [file join $CurDir Assembly.tcl]] {
	source	[file join $CurDir Assembly.tcl]
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
	0x15 "TI-82 Advanced Edition Python" \
	0x1B "TI-84 Plus T" \
]

variable Z80typeDict [dict create \
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
	0x19 "Directory" \
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
	0x28 "Unit Certificate" \
	0x29 "Clock" \
	0x3E "Flash License" \
]

set	82typeDict [dict create \
	0x0B "Window setup" \
	0x0C "Recall Window" \
	0x0D "TableSet" \
	0x0F "Backup" \
	0x1F "Group" \
]

variable 73typeDict [dict create \
	0x0D "Categorical list" \
	0x14 "Reduced simple fraction" \
	0x15 "Reduced mixed fraction" \
	0x16 "Simple fraction" \
	0x17 "Mixed fraction" \
	0x18 "Category" \
	0x1A "AppVar" \
	0x1B "Temporary" \
]

# 0x14 is `New Equation` on TI-86
variable 85typeDict [dict create \
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
	0x15 "Full Directory" \
	0x17 "Function window" \
	0x18 "Polar window" \
	0x19 "Param window" \
	0x1A "DifEq window" \
	0x1B "Recall window" \
	0x1D "Backup" \
	0x1E "ScreenShot" \
	0x1F "Group" \
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
	0x19 "Full Directory" \
	0x1A "Filter Directory" \
	0x1B "Local Directory" \
	0x1C "Appvar" \
	0x1D "Backup" \
	0x1E "Snapshot" \
	0x1F "Folder" \
	0x20 "Certificate Memory" \
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
		0x0A "$t CSE+" 0x0B "$t CE 5.0-5.2+" 0x0C "$t CE 5.3+" \
		0x10 Exact 0x11 Python]
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
	section -collapsed Number\ $index
	proc internalNumber {recursed} {
		variable 85typeDict
		section -collapsed [expr $recursed?"Complex":"Real"]
		section -collapsed "Flags" {
			set	Flags [hex 1]
			# TODO: what is the correct typemask?
			set	type [format "0x%02X" [expr $Flags & 31]]
			if {$Flags == 255} {
				sectionvalue $Flags\ (Undefined)
			} else {
				sectionvalue $Flags\ ([entryd "Type" $type 1 $85typeDict])
				FlagRead $Flags 7 Negative\ Float Positive\ Float
			}
		}
		# all flags set means undefined; unclear if exclusive to Diff GDB
		if {$Flags == 255} {
			# garbage from OP1(?)
			set	n [hex 9 Data]\ (Undefined)
		} else {
			set	Sign [expr $Flags & 128?"-":""]
			set	Exp [expr [uint16]-64512]
			entry	Exponent $Exp 2 [expr [pos]-2]
			set	Body [hex 7]
			set	Body [string index $Body 2].[string range $Body 3 15]
			entry	Mantissa $Body 7 [expr [pos]-7]
			set	n $Sign$Body\e$Exp
		}
		sectionvalue $n
		endsection
		if {!$recursed && ($type == 0x01)} {
			set n "$n + [internalNumber 1]i"
		}
		sectionvalue $n
		return $n
	}
	internalNumber 0
	endsection
}

proc readZ80Numb {{index ""} {magic "**TI83F*"}} {
	variable 73typeDict
	section -collapsed Number\ $index

	proc readTIFloat {recursed} {
		variable Z80typeDict
		section -collapsed [expr $recursed?"Complex":"Real"]
		section -collapsed "Flags" {
			set	Flags [hex 1]
			set	type [format "0x%02X" [expr $Flags & 63]]
			sectionvalue $Flags\ ([entryd "Type" $type 1 $Z80typeDict])
			FlagRead $Flags 7 Negative\ Float Positive\ Float
		}
		if {$type in {0x1C 0x1D}} {
			set	Body [hex 8 Body]
			set	Signs [string index $Body 2]
			set	N5 [string range $Body 3 5]
			set	N3 [expr $Signs & 2?"-":"+"][string range $Body 6 8]
			set	N1 [expr $Signs & 1?"-":""][string range $Body 9 11]
			set	N4 [string range $Body 12 14]
			set	N2 [string range $Body 15 17]
			set	n "($N1√$N2$N3√$N4)/$N5"
		} else {
			set	Sign [expr $Flags & 128?"-":""]
			set	Exp [expr [uint8]-128]
			entry	Exponent $Exp 1 [expr [pos]-1]
			set	Body [hex 7]
			set	Body [string index $Body 2].[string range $Body 3 15]
			entry	Mantissa $Body 7 [expr [pos]-7]
			if ![regexp {[A-F]} $Body] {
				set Body [format "%.14g" $Body]
			}
			set	n "$Sign$Body[expr $type>29?"π":""][expr $Exp?"\e$Exp":""][expr $type==14?" (Undefined)":""]"
		}
		sectionvalue $n
		endsection
		if {!$recursed && $type in {0x0C 0x1B 0x1D 0x1E 0x1F}} {
			set n "$n + [readTIFloat 1]i"
		}
		sectionvalue $n
		return $n
	}

	set a [hex 1]
	move -1
	if ![hex 9] {
		entry Real DNE 9 [expr [pos]-9]
		sectionvalue DNE
	} elseif {($a&0x7F) in {20 21 22 23 24} && $magic == "**TI73**"} {
		move	-8
		section -collapsed "Flags" {
			set	type [format "0x%02X" [expr $a & 63]]
			sectionvalue $a\ ([entryd "Type" $a 1 $73typeDict])
			FlagRead $a 7 Negative Positive
		}
		set	Body [hex 8 Body]
		set	sign [expr $a & 128?"-":""]
		set	den [string range $Body 12 15]
		switch [expr $a & 127] {
			20 -
			22 {
				set	n "$sign[string range $Body 4 9]/$den"
			}
			21 -
			23 {
				set	n "$sign[string range $Body 3 6].[string index $Body 7]_[string range $Body 8 10].[string index $Body 11]/$den"
			}
			24 {
				sectionname Category\ $index
				move	-7
				set	n [ascii 7]
			}
		}
		sectionvalue $n
	} else {
		move	-9
		readTIFloat 0
	}
	endsection
}

proc readGDB {} {
	variable Z80typeDict
	set	datalen [len_field]
	set	start [pos]
	set	isn82 ![int8]
	move	-1
	if $isn82 {
		uint8	Reserved
	}
	set	Mode [hex 1]
	entry	"Graph mode" "$Mode ([expr $Mode&16?"Function":$Mode&32?"Polar":$Mode&64?"Parametric":"Sequential"])" 1 [expr [pos]-1]
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
	if {$Mode & 0x10} {
		set EquSets "Y1 Y2 Y3 Y4 Y5 Y6 Y7 Y8 Y9 Y0"
		if $isn82 { lappend numbs Xres }
	} elseif {$Mode & 0x20} {
		set EquSets "r1 r2 r3 r4 r5 r6"
		lappend numbs thetamin thetamax thetastep
	} elseif {$Mode & 0x40} {
		set EquSets "X1T/Y1T X2T/Y2T X3T/Y3T X4T/Y4T X5T/Y5T X6T/Y6T"
		lappend numbs Tmin Tmax Tstep
	} else {
		set EquSets "u v[expr $isn82?" w":""]"
		append numbs [expr $isn82?{ PlotStart nMax u(nMin) v(nMin) nMin u(nMin+1) v(nMin+1) w(nMin) PlotStep w(nMin+1)}:{ nMin nMax UnStart VnStart nStart}]
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
				entryd	"Type" [format "0x%02X" [expr $Flags & 31]] 1 $Z80typeDict
				FlagRead $Flags 5 Selected Unselected
				FlagRead $Flags 6 "Was used for graph"
				FlagRead $Flags 7 "Link transfer flag"
			}
			BAZIC83	[len_field Code]
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

proc 68KreadBody {datatype varName {defaultLen 0}} {
	section -collapsed Data
	switch -- $datatype {
		0x00 -
		0x04 -
		0x06 -
		0x0B -
		0x0C -
		0x0D -
		0x10 -
		0x12 -
		0x13 -
		0x1C -
		0x21 {
			68KRPN	$defaultLen $varName
		}
		default { bytes $defaultLen Data }
	}
	little_endian
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
		0x0C {
			set	datalen [len_field Code]
			set	firstbyte 1
			if $datalen {
				set	firstbyte [uint8]
				move	-1
			}
			if {!$firstbyte && $magic == "**TI85**"} {
				section -collapsed Code {
					hex	1 Assembly
					entryd	ID [hex 1] 1 [dict create \
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
					uint8	Entry\ offset
					cstr	ascii Desc
					bytes	[expr $datalen-[pos]+$start+2] Assembly
				}
			} elseif $datalen {
				str	$datalen ascii Code
			} else {
				entry	Code ""
			}
		}
		0x12 {
			set	datalen [len_field Code]
			set	firstword 1
			set	firstbyte 1
			if {$datalen > 1} {
				set	firstword [hex 2]
				move	-2
			}
			if $datalen {
				set	firstbyte [uint8]
				move	-1
			}
			if {$firstword == 0x8E28} {
				section -collapsed Code {
					hex	2 "Z80 token"
					bytes	[expr $datalen-2] Assembly
				}
			} elseif !$firstbyte {
				section -collapsed Code {
					hex	1 Untokenized
					incr	datalen -1
					if !$firstword {
						hex	1 Locked
						incr	datalen -1
					}

					# model line character sets should become a function with the different encodings
					set	start [pos]
					set	linenumber 0
					if $datalen {
						set	sections [split [str $datalen isolatin1] \xD6]
						foreach line $sections {
							incr	linenumber
							if {$line==""} {
								entry	"Line $linenumber" ""
							} else {
								entry	"Line $linenumber" "[string map {"\x19" ">=" "\x1C" "->"} $line]" [string length $line] $start
							}
							incr	start [expr [string length $line]+1]
						}
					} else {
						entry	"Line 1" ""
					}

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

	if { $magic == "**TI73**" } {
		switch -- $datatype {
			0x14 - 0x15 - 0x16 - 0x17 { set datatype 0x00 }
			0x1A { set datatype 0x15 }
			0x18 - 0x1B { set datatype 255 }
		}
	}
	if { $magic == "**TI82**" } {
		if {$datatype>0x0A && $datatype<0x0E} {
			incr datatype 4
		}
	}

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
		0x21 { readZ80Numb "" $magic }
		0x01 -
		0x0D -
		0x26 {
			set	n [uint16 "Indices"]
			for {set a 0} {$n > $a} {incr a} {
				readZ80Numb [expr $a+1] $magic
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
		0x0B { BAZIC [len_field Code] $magic }
		0x05 -
		0x06 {
			set	datalen [len_field Code]
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
				BAZIC	$datalen $magic
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
	if $defaultLen {
		goto [expr $start+$defaultLen]
	}
}

proc getNameZ80 {title type length {magic ""}} {
	variable CurDir
	set	start [pos]
	set bint BAZIC83
	if {$magic == "**TI73**"} {
		set bint BAZIC73
		if {$type==0x1A} {
			set type 0x15
		}
	}
	if {$magic == "**TI82**"} {
		if {$type>0x0A && $type<0x0E} {
			incr type 4
		}
	}
	if {[file exists [file join $CurDir BAZIC $bint.tcl]]} {
		switch -- $type {
			0x01 -
			0x0D {
				int8
				set	a [hex 1]
				move	-2
				if {$a < 6} {
					set	name [$bint\_GetToken [hex 1]]
				} elseif {($a == 0x40) && $magic in {"**TI73**" "**TI83F*"}} {
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
				# first name byte should be 03Ch
				# then should be 0EF50h + [uint8], but no arbitrary detok
				int8
				set	name Image[expr ([uint8]+1)%10]
			}
			default { set name [$bint\_GetToken [hex 1]] }
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
	variable Z80typeDict
	set	EntryStart [pos]
	section Entry

	# https://wikiti.brandonw.net/index.php?title=83Plus:OS:System_Table
	section "System table entry"
	section -collapsed "Type" {
		set	Flags [hex 1]
		# legacy Z80 equations use bit 5 for selection
		set	type [format "0x%02X" [expr $Flags & (($Flags & 23) == 3?31:63)]]
		set	typename [entryd "Type" $type 1 $Z80typeDict]
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
	# should be zero in groups to signify RAM
	hex	1 "Page"
	section -collapsed "Name" {
		if {$type in {0x01 0x05 0x06 0x0D 0x15 0x17}} {
			set	length [uint8 "Name length"]
		} else {
			set	length 3
		}
		if {$type in {0x01 0x0D}} {
			incr length -1
		}
		set	name [getNameZ80 "Name data" $type $length]
		if {$type in {0x01 0x0D}} {
			hex 1 Formula\ index
		}
		sectionvalue $name
	}
	endsection

	Z80readBody $type $magic
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

if {$magic=="**TIFL**" && [file exists [file join $CurDir TI-Flash.tcl]]} {
	source	[file join $CurDir TI-Flash.tcl]
} elseif {$magic in {"**TI89**" "**TI92**" "**TI92P*"}} {
	hex	2 "Thing"
	ascii	8 "Directory"
	ascii	40 "Comment"
	set	numFiles [uint16 "Variable count"]
	section "Variables"
	for_n $numFiles {
		section Entry
		section "Meta" {
			sectionvalue "16 bytes"
			set	bodyOffset [uint32 "Offset to data"]
			move	8
			set	datatype [hex 1]
			move	-9
			set	name [ascii 8 [expr $datatype==0x1D?"Rom version":"Name"]]
			set	typeName [entryd "Type" [hex 1] 1 $68KtypeDict]
			# Backup attributes are allegedly only used by TiLP in TI-89 "backup groups"
			# https://github.com/debrouxl/tilibs/blob/master/libtifiles/trunk/src/tifiles.h#L69-L72
			entryd	Attribute [hex 1] 1 [dict create 0x01 Locked 0x02 Protected 0x03 Archived 0x1D "Backup none" 0x26 "Backup Locked" 0x27 "Backup Archived"]
			uint16	"Items in dir"
		}
		sectionname $typeName\ entry
		if {$datatype!=0x1F} {
			set	retu [pos]
			goto	$bodyOffset
			section "Body" {
				set	loopStart [pos]
				if {$datatype == 0x1D} {
					bytes	39266 Data
				} else {
					hex	4 Something
					big_endian
					set	Size [uint16 Data\ length]
					little_endian
					68KreadBody $datatype $name $Size
					sectionvalue [expr $Size+8]\ bytes
				}
				CheckSum $loopStart [pos]
			}
			sectionvalue "$name"
			goto	$retu
		}
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
				if {$magic == "**TI86**"} {
					len_field "Data 4"
				}
			} else {
				len_field
				set	a $Z80typeDict
				if {[dict exists $82typeDict [hex 1]] && $magic=="**TI82**"} {
					set	a $82typeDict
				}
				if {[dict exists $73typeDict $datatype] && $magic=="**TI73**"} {
					set	a $73typeDict
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
					set	typeName [entryd "Type" $datatype 1 $a]
					set	name [getNameZ80 Name $datatype 8 $magic]
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
				bytes	[len_field "Data 1"] "Data 1 \[RAM?\]"
				bytes	[len_field "Data 2"] "Data 2 \[VAT\]"
				bytes	[len_field "Data 3"] "Data 3 \[symTable\]"
				if {$magic == "**TI86**"} {
					bytes	[len_field "Data 4"] "Data 4"
				}
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
	# simplified detok
	for_n 8 {
		set	a [uint8]
		set	name $name[format %c [expr $a<86?$a+32:$a==115?952:$a>86?$a-24:20]]
	}
	entry	Name $name 8 [expr [pos]-8]
	BAZIC81 $size
	CheckSum 12 [pos]
} elseif {[string range $magic 0 3]=="PK\x03\x04"} {
	# Bundles include a _CHECKSUM file with the sum of CRC32 of all files (lowercase, not zero-padded, ends with CRLF)
	# and a METADATA file with various info
	move	-8
	include archives/zip.tcl
} else {
	requires 0 0
}
