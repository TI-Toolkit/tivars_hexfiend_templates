# TI-73 TI-BASIC Detokenizer HexFiend template include
# Version 1.0
# (c) 2021-2024 LogicalJoe
# .hidden = true;


proc BAZIC73_GetToken {term} {
# 25 26 2D 74 75 76 77 92 93 are just invalid tokens
set	BAZIC_00 [dict create \
	0x01 ">DMS" \
	0x02 "|>" \
	0x03 "\[downarrow]" \
	0x04 "->" \
	0x05 "Boxplot" \
	0x06 "\[" \
	0x07 "]" \
	0x08 "{" \
	0x09 "}" \
	0x0A "^^r" \
	0x0B "^^o" \
	0x0C "^^-1" \
	0x0D "^^2" \
	0x0E "^^T" \
	0x0F "^^3" \
	0x10 "(" \
	0x11 ")" \
	0x12 "round(" \
	0x13 "pxl-Test(" \
	0x14 "augment(" \
	0x15 "rowSwap(" \
	0x16 "row+(" \
	0x17 "*row(" \
	0x18 "*row+(" \
	0x19 "max(" \
	0x1A "min(" \
	0x1B "R>Pr(" \
	0x1C "R>Ptheta(" \
	0x1D "P>Rx(" \
	0x1E "P>Ry(" \
	0x1F "median(" \
	0x20 "randM(" \
	0x21 "mean(" \
	0x22 "mode(" \
	0x23 "solve(" \
	0x24 "seq(" \
	0x27 "=" \
	0x28 "EOFrac" \
	0x29 " " \
	0x2A "\"" \
	0x2B "," \
	0x2C "\[r]" \
	0x2E "!" \
	0x2F "%" \
	0x30 "0" \
	0x31 "1" \
	0x32 "2" \
	0x33 "3" \
	0x34 "4" \
	0x35 "5" \
	0x36 "6" \
	0x37 "7" \
	0x38 "8" \
	0x39 "9" \
	0x3A "." \
	0x3B "|E" \
	0x3C " or " \
	0x3D " xor " \
	0x3E ":" \
	0x3F "\n" \
	0x40 " and " \
	0x41 "A" \
	0x42 "B" \
	0x43 "C" \
	0x44 "D" \
	0x45 "E" \
	0x46 "F" \
	0x47 "G" \
	0x48 "H" \
	0x49 "I" \
	0x4A "J" \
	0x4B "K" \
	0x4C "L" \
	0x4D "M" \
	0x4E "N" \
	0x4F "O" \
	0x50 "P" \
	0x51 "Q" \
	0x52 "R" \
	0x53 "S" \
	0x54 "T" \
	0x55 "U" \
	0x56 "V" \
	0x57 "W" \
	0x58 "X" \
	0x59 "Y" \
	0x5A "Z" \
	0x5B "theta" \
	0x5F "prgm" \
	0x64 "Radian" \
	0x65 "Degree" \
	0x66 "Normal" \
	0x67 "Sci" \
	0x68 "Float" \
	0x69 "Fix " \
	0x6A "=" \
	0x6B "<" \
	0x6C ">" \
	0x6D "<=" \
	0x6E ">=" \
	0x6F "!=" \
	0x70 "+" \
	0x71 "-" \
	0x72 "Ans" \
	0x78 "PersonIcon" \
	0x79 "TreeIcon" \
	0x7A "DollarIcon" \
	0x7B "FaceIcon" \
	0x7C "PieIcon" \
	0x7D "DiamondIcon" \
	0x7E "StarIcon" \
	0x7F "plotsquare" \
	0x80 "plotcross" \
	0x81 "plotdot" \
	0x82 "*" \
	0x83 "/" \
	0x84 " Int/ " \
	0x85 "Trace" \
	0x86 "ClrDraw" \
	0x87 "ZStandard" \
	0x88 "ZTrig" \
	0x89 "ZBox" \
	0x8A "Zoom In" \
	0x8B "Zoom Out" \
	0x8C "ZSquare" \
	0x8D "ZInteger" \
	0x8E "ZPrevious" \
	0x8F "ZDecimal" \
	0x90 "ZoomStat" \
	0x91 "ZQuadrant1" \
	0x94 "Text(" \
	0x95 " nPr " \
	0x96 " nCr " \
	0x97 "FnOn " \
	0x98 "FnOff " \
	0x99 "StorePic " \
	0x9A "RecallPic " \
	0x9B "Line(" \
	0x9C "Vertical " \
	0x9D "Pt-On(" \
	0x9E "Pt-Off(" \
	0x9F "Pt-Change(" \
	0xA0 "Pxl-On(" \
	0xA1 "Pxl-Off(" \
	0xA2 "Pxl-Change(" \
	0xA3 "Shade(" \
	0xA4 "Circle(" \
	0xA5 "Horizontal " \
	0xA7 "Tangent(" \
	0xA8 "Manual-Fit " \
	0xA9 "DrawF " \
	0xAB "rand" \
	0xAC "pi" \
	0xAD "getKey" \
	0xAE "'" \
	0xAF "?" \
	0xB0 "~" \
	0xB1 "int(" \
	0xB2 "abs(" \
	0xB3 "det(" \
	0xB4 "identity(" \
	0xB5 "dim(" \
	0xB6 "sum(" \
	0xB7 "prod(" \
	0xB9 "iPart(" \
	0xBA "fPart(" \
	0xBC "sqrt(" \
	0xBD "cuberoot(" \
	0xBE "ln(" \
	0xBF "e^(" \
	0xC0 "log(" \
	0xC1 "10^(" \
	0xC2 "sin(" \
	0xC3 "sin^-1(" \
	0xC4 "cos(" \
	0xC5 "cos^-1(" \
	0xC6 "tan(" \
	0xC7 "tan^-1(" \
	0xC8 ">Ab/c<->d/e" \
	0xC9 ">F<->D" \
	0xCA ">Simp " \
	0xCB "^" \
	0xCC "xroot(" \
	0xCD "SetMenu(" \
	0xCE "If " \
	0xCF "Then" \
	0xD0 "Else" \
	0xD1 "While " \
	0xD2 "Repeat " \
	0xD3 "For(" \
	0xD4 "End" \
	0xD5 "Return" \
	0xD6 "Lbl " \
	0xD7 "Goto " \
	0xD8 "Pause " \
	0xD9 "Stop" \
	0xDA "IS>(" \
	0xDB "DS<(" \
	0xDC "Input " \
	0xDD "Prompt " \
	0xDE "Disp " \
	0xDF "DispGraph" \
	0xE0 "Output(" \
	0xE1 "ClrScreen" \
	0xE2 "Fill(" \
	0xE3 "SortA(" \
	0xE4 "SortD(" \
	0xE5 "DispTable" \
	0xE6 "Menu(" \
	0xE7 "Send(" \
	0xE8 "Get(" \
	0xE9 "PlotsOn " \
	0xEA "PlotsOff " \
	0xEB "|L" \
	0xEC "Plot1(" \
	0xED "Plot2(" \
	0xEE "Plot3(" \
	0xEF "|_" \
	0xF0 "|/" \
]

set	BAZIC_5C [dict create \
	0x01 "\[A]" \
	0x02 "\[B]" \
	0x03 "\[C]" \
	0x04 "\[D]" \
	0x05 "\[E]" \
	0x06 "\[F]" \
	0x07 "\[G]" \
	0x08 "\[H]" \
	0x09 "\[I]" \
	0x0A "\[J]" \
]

set	BAZIC_5D [dict create \
	0x01 "L1" \
	0x02 "L2" \
	0x03 "L3" \
	0x04 "L4" \
	0x05 "L5" \
	0x06 "L6" \
]

set	BAZIC_5E [dict create \
	0x10 "{Y1}" \
	0x11 "{Y2}" \
	0x12 "{Y3}" \
	0x13 "{Y4}" \
	0x10 "{Y5}" \
	0x11 "{Y6}" \
	0x12 "{Y7}" \
	0x13 "{Y8}" \
	0x10 "{Y9}" \
	0x11 "{Y0}" \
	0x20 "{X1T}" \
	0x21 "{Y1T}" \
	0x22 "{X2T}" \
	0x23 "{Y2T}" \
	0x24 "{X3T}" \
	0x25 "{Y3T}" \
	0x26 "{X4T}" \
	0x27 "{Y4T}" \
	0x28 "{X5T}" \
	0x29 "{Y5T}" \
	0x2A "{X6T}" \
	0x2B "{Y6T}" \
	0x40 "{r1}" \
	0x41 "{r2}" \
	0x42 "{r3}" \
	0x43 "{r4}" \
	0x44 "{r5}" \
	0x45 "{r6}" \
	0x80 "{C1}" \
	0x81 "{C2}" \
	0x82 "{C3}" \
	0x83 "{C4}" \
]

set	BAZIC_60 [dict create \
	0x01 "Pic1" \
	0x02 "Pic2" \
	0x03 "Pic3" \
	0x04 "Pic4" \
	0x05 "Pic5" \
	0x06 "Pic6" \
	0x07 "Pic7" \
	0x08 "Pic8" \
	0x09 "Pic9" \
	0x0A "Pic0" \
]

set	BAZIC_61 [dict create \
	0x01 "GDB1" \
	0x02 "GDB2" \
	0x03 "GDB3" \
	0x04 "GDB4" \
	0x05 "GDB5" \
	0x06 "GDB6" \
	0x07 "GDB7" \
	0x08 "GDB8" \
	0x09 "GDB9" \
	0x0A "GDB0" \
]

set	BAZIC_62 [dict create \
	0x01 "\[RegEQ]" \
	0x02 "\[n]" \
	0x03 "\[xhat]" \
	0x04 "\[Sigmax]" \
	0x05 "\[Sigmax^2]" \
	0x06 "\[Sx]" \
	0x07 "\[sigmax]" \
	0x08 "\[minX]" \
	0x09 "\[maxX]" \
	0x0A "\[minY]" \
	0x0B "\[maxY]" \
	0x0C "\[yhat]" \
	0x0D "\[Sigmay]" \
	0x0E "\[Sigmay^2]" \
	0x0F "\[Sy]" \
	0x10 "\[sigmay]" \
	0x11 "\[Sigmaxy]" \
	0x12 "\[r]" \
	0x13 "\[Med]" \
	0x14 "\[Q1]" \
	0x15 "\[Q3]" \
	0x16 "\[|a]" \
	0x17 "\[|b]" \
	0x18 "\[|c]" \
	0x19 "\[|d]" \
	0x1A "\[|e]" \
	0x1B "\[x1]" \
	0x1C "\[x2]" \
	0x1D "\[x3]" \
	0x1E "\[y1]" \
	0x1F "\[y2]" \
	0x20 "\[y3]" \
	0x21 "\[r^2]" \
	0x22 "\[R^2]" \
	0x23 "Error" \
	0x24 "Done" \
]

set	BAZIC_63 [dict create \
	0x01 "ZXscl" \
	0x02 "ZYscl" \
	0x03 "Xscl" \
	0x04 "Yscl" \
	0x0A "Xmin" \
	0x0B "Xmax" \
	0x0C "Ymin" \
	0x0D "Ymax" \
	0x0E "Tmin" \
	0x0F "Tmax" \
	0x10 "thetamin" \
	0x11 "thetamax" \
	0x12 "ZXmin" \
	0x13 "ZXmax" \
	0x14 "ZYmin" \
	0x15 "ZYmax" \
	0x16 "Zthetamin" \
	0x17 "Zthetamax" \
	0x18 "ZTmin" \
	0x19 "ZTmax" \
	0x1A "TblStart" \
	0x1B "PlotStart" \
	0x1C "ZPlotStart" \
	0x21 "DeltaTbl" \
	0x22 "Tstep" \
	0x23 "thetastep" \
	0x24 "ZTstep" \
	0x25 "Zthetastep" \
	0x26 "DeltaX" \
	0x27 "DeltaY" \
	0x28 "XFact" \
	0x29 "YFact" \
	0x2A "TblInput" \
	0x2B "Factor" \
	0x34 "PlotStep" \
	0x35 "ZPlotStep" \
	0x36 "Xres" \
	0x37 "ZXres" \
]

set	BAZIC_73 [dict create \
	0x01 "Sequential" \
	0x02 "Simul" \
	0x03 "CoordOn" \
	0x04 "CoordOff" \
	0x05 "Connected" \
	0x06 "Dot" \
	0x07 "AxesOn" \
	0x08 "AxesOff" \
	0x09 "GridOn" \
	0x0A "GridOff" \
	0x0B "LabelOn" \
	0x0C "LabelOff" \
	0x0D "PolarGC" \
	0x0E "RectGC" \
	0x0F "Func" \
	0x10 "Param" \
	0x11 "Polar" \
	0x12 "IndpntAuto" \
	0x13 "IndpntAsk" \
	0x14 "DependAuto" \
	0x15 "DependAsk" \
	0x16 "A_b/c" \
	0x17 "b/c" \
	0x18 "AutoSimp" \
	0x19 "ManSimp" \
	0x1A "SingleConst" \
	0x1B "MultiConst" \
]

set	BAZIC_AA [dict create \
	0x01 "Str1" \
	0x02 "Str2" \
	0x03 "Str3" \
	0x04 "Str4" \
	0x05 "Str5" \
	0x06 "Str6" \
	0x07 "Str7" \
	0x08 "Str8" \
	0x09 "Str9" \
	0x0A "Str0" \
]

set	BAZIC_BB [dict create \
	0x01 "lcm(" \
	0x02 "gcd(" \
	0x03 "randint(" \
	0x04 "sub(" \
	0x05 "stdDev(" \
	0x06 "variance(" \
	0x07 "inString(" \
	0x08 "coin(" \
	0x09 "dice(" \
	0x0A "remainder(" \
	0x0B "cumSum(" \
	0x0C "expr(" \
	0x0D "length(" \
	0x0E "DeltaList(" \
	0x0F "ref(" \
	0x10 "rref(" \
	0x12 "Matr>list(" \
	0x13 "List>matr(" \
	0x14 "SetConst(" \
	0x15 "GraphStyle(" \
	0x16 "SetUpEditor " \
	0x1A "ExprOn" \
	0x1B "ExprOff" \
	0x1C "ClrAllLists" \
	0x1D "GetCalc(" \
	0x1E "DelVar " \
	0x1F "Equ>String(" \
	0x20 "String>Equ(" \
	0x21 "Clear Home" \
	0x22 "Select(" \
	0x23 "ModBoxPlot" \
	0x24 "NormProbPlot" \
	0x25 "PictoPlot" \
	0x26 "PiePlot" \
	0x27 "StemPlot" \
	0x28 "BarPlot" \
	0x29 "ZoomFit" \
	0x2A "DiagnosticOn" \
	0x2B "DiagnosticOff" \
]

set	BAZIC_F2 [dict create \
	0x01 "1-Var Stats " \
	0x02 "2-Var Stats " \
	0x03 "LinReg(ax+b) " \
	0x04 "ExpReg " \
	0x05 "LnReg " \
	0x07 "Med-Med " \
	0x08 "QuadReg " \
	0x09 "ClrList " \
	0x0A "ClrTable" \
	0x0B "Histogram" \
	0x0C "xyLine" \
	0x0D "Scatter" \
	0x0E "LinReg(a+bx) " \
]

# F8 thru FE use proceeding two nybbles for conversion info
set	BAZIC_F8 [dict create \
	1 mm \
	2 cm \
	3 m \
	4 inch \
	5 ft \
	6 yard \
	7 km \
	8 mile \
]
set	BAZIC_F9 [dict create \
	1 ft^2 \
	2 m^2 \
	3 mi^2 \
	4 km^2 \
	5 acre \
	6 in^2 \
	7 cm^2 \
	8 yd^2 \
	9 ha \
]
set	BAZIC_FA [dict create \
	1 liter \
	2 gal \
	3 qt \
	4 pt \
	5 oz \
	6 cm^3 \
	7 in^3 \
	8 ft^3 \
	9 m^3 \
	10 galUK \
	11 ozUK \
]
set	BAZIC_FB [dict create \
	1 sec \
	2 min \
	3 hr \
	4 day \
	5 year \
	6 week \
]
set	BAZIC_FC [dict create \
	1 degC \
	2 degF \
	3 degK \
]
set	BAZIC_FD [dict create \
	1 g \
	2 kg \
	3 lb \
	4 ton \
	5 mton \
]
set	BAZIC_FE [dict create \
	1 ft/s \
	2 m/s \
	3 mi/hr \
	4 km/hr \
	5 knot \
]


	proc BAZICdict {a b {c -1}} {
		if [dict exists $b $a] {
			return	[dict get $b $a]
		} elseif {$c == -1} {
			return	%$a%
		} else {
			return	%$c[format "%02X" $a]%
		}
	}

	#set	term [hex 1]
	if {$term in {0x5C 0x5D 0x5E 0x60 0x61 0x62 0x63 0x73 0xAA 0xBB 0xF2}} {
		set	token [BAZICdict [hex 1] [set "BAZIC_[format "%02X" $term]"] $term]
	} elseif {$term in {0xF8 0xF9 0xFA 0xFB 0xFC 0xFD 0xFE}} {
		set dic "BAZIC_[format "%02X" $term]"
		set conv [hex 1]
		set first [expr $conv/16]
		set firstex [dict exists [set $dic] $first]
		set second [expr $conv&15]
		set secondex [dict exists [set $dic] $second]
		if {$firstex && $secondex} {
			set token " [dict get [set $dic] $first]>[dict get [set $dic] $second]"
		} else {
			set token "%[format "%02X" $term][format "%02X" $conv]%"
		}
	} else {
		set	token [BAZICdict $term $BAZIC_00]
	}
	return $token
}

proc BAZIC73 {size} {
	section -collapsed "Code" {
		set	start [pos]

		set	e 0
		while {[pos]-$start < $size} {
			incr	e
			set	line ""
			set	term 0
			set	Linestart [pos]
			while {($term != 0x3F) && ([pos]-$start < $size)} {
				set	term [hex 1]
				set	line $line[BAZIC73_GetToken $term]
			}
			entry	"Line $e" $line [expr [pos]-$Linestart] $Linestart
		}
		# if it was a single line, display it as the section value
		if {$e == 1} {
			sectionvalue $line
		} elseif {$size != 0} {
			sectionvalue "\[expand for code]"
		}
	}
	goto [expr $start + $size]
}
