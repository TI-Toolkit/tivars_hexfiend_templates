# TI-8[56] TI-BASIC Detokenizer HexFiend template include
# Version 1.0
# (c) 2021-2025 LogicalJoe
# .hidden = true;


proc BAZIC85_GetToken {term {magic "**TI86**"}} {
set	BAZIC85_00 [dict create \
	0x01 ">Rec" \
	0x02 ">Pol" \
	0x03 ">Cyl" \
	0x04 ">Sph" \
	0x05 ">DMS" \
	0x06 ">Bin" \
	0x07 ">hex" \
	0x08 ">Oct" \
	0x09 ">Dec" \
	0x0A ">Frac" \
	0x0B "->" \
	0x0C "\[" \
	0x0D "\]" \
	0x0E "{" \
	0x0F "}" \
	0x10 "(" \
	0x11 ")" \
	0x12 "round" \
	0x13 "max" \
	0x14 "min" \
	0x15 "mod" \
	0x16 "cross" \
	0x17 "dot" \
	0x18 "aug" \
	0x19 "rSwap" \
	0x1A "rAdd" \
	0x1B "multR" \
	0x1C "mRAdd" \
	0x1D "sub" \
	0x1E "lcm" \
	0x1F "gcd" \
	0x20 "simult" \
	0x21 "inter" \
	0x22 "pEval" \
	0x23 "randM" \
	0x24 "seq" \
	0x25 "evalF" \
	0x26 "fnInt" \
	0x27 "arc" \
	0x28 "fMin" \
	0x29 "fMax" \
	0x2A "der1" \
	0x2B "der2" \
	0x2C "nDer" \
	0x2E "|<" \
	0x2F "," \
	0x30 " or " \
	0x31 " xor " \
	0x3F "=" \
	0x40 " and " \
	0x41 "rand" \
	0x42 "pi" \
	0x43 "getKy" \
	0x45 "%" \
	0x46 "!" \
	0x47 "^^r" \
	0x48 "^^o" \
	0x49 "^^-1" \
	0x4A "^^2" \
	0x4B "^^T" \
	0x4C "Menu" \
	0x4D "P2Reg " \
	0x4E "P3Reg " \
	0x4F "P4Reg " \
	0x50 "==" \
	0x51 "<" \
	0x52 ">" \
	0x53 "<=" \
	0x54 ">=" \
	0x55 "!=" \
	0x56 "Radian" \
	0x57 "Degree" \
	0x58 "Normal" \
	0x59 "Sci" \
	0x5A "Eng" \
	0x5B "Float" \
	0x5C "Fix " \
	0x5D "RectV" \
	0x5E "CylV" \
	0x5F "SphereV" \
	0x60 "+" \
	0x61 "-" \
	0x62 "Func" \
	0x63 "Param" \
	0x64 "Pol" \
	0x65 "DifEq" \
	0x66 "Bin" \
	0x67 "Oct" \
	0x68 "Hex" \
	0x69 "Dec" \
	0x6A "RectC" \
	0x6B "PolarC" \
	0x6C "dxDer1" \
	0x6D "dxNDer" \
	0x6E ":" \
	0x6F "\n" \
	0x70 "*" \
	0x71 "/" \
	0x72 "SeqG" \
	0x73 "SimulG" \
	0x74 "PolarGC" \
	0x75 "RectGC" \
	0x76 "CoordOn" \
	0x77 "CoordOff" \
	0x78 "DrawLine" \
	0x79 "DrawDot" \
	0x7A "AxesOn" \
	0x7B "AxesOff" \
	0x7C "GridOn" \
	0x7D "GridOff" \
	0x7E "LabelOn" \
	0x7F "LabelOff" \
	0x80 " nPr " \
	0x81 " nCr " \
	0x82 "Trace" \
	0x83 "ClDrw" \
	0x84 "ZStd" \
	0x85 "ZTrig" \
	0x86 "ZFit" \
	0x87 "ZIn" \
	0x88 "ZOut" \
	0x89 "ZSqr" \
	0x8A "ZInt" \
	0x8B "ZPrev" \
	0x8C "ZDecm" \
	0x8D "ZRcl" \
	0x8E "PrtScrn" \
	0x8F "DrawF " \
	0x90 "FnOn " \
	0x91 "FnOff " \
	0x92 "Stpic " \
	0x93 "RcPic " \
	0x94 "StGDB " \
	0x95 "RcGDB " \
	0x96 "Line" \
	0x97 "Vert " \
	0x98 "PtOn" \
	0x99 "PtOff" \
	0x9A "PtChg" \
	0x9B "Shade" \
	0x9C "Circl" \
	0x9D "Axes" \
	0x9E "TanLn" \
	0x9F "DrInv " \
	0xA0 "sqrt" \
	0xA1 "~" \
	0xA2 "abs " \
	0xA3 "iPart " \
	0xA4 "fPart " \
	0xA5 "int " \
	0xA6 "ln " \
	0xA7 "e^" \
	0xA8 "log " \
	0xA9 "10^" \
	0xAA "sin " \
	0xAB "asin " \
	0xAC "cos " \
	0xAD "acos " \
	0xAE "tan " \
	0xAF "atan " \
	0xB0 "sinh " \
	0xB1 "asinh " \
	0xB2 "cosh " \
	0xB3 "acosh " \
	0xB4 "tanh " \
	0xB5 "atanh " \
	0xB6 "sign " \
	0xB7 "det " \
	0xB8 "ident " \
	0xB9 "unitV " \
	0xBA "norm " \
	0xBB "rnorm " \
	0xBC "cnorm " \
	0xBD "ref " \
	0xBE "rref " \
	0xBF "dim " \
	0xC0 "dimL " \
	0xC1 "sum " \
	0xC2 "prod " \
	0xC3 "sortA " \
	0xC4 "sortD " \
	0xC5 "li>vc " \
	0xC6 "vc>li " \
	0xC7 "lngth " \
	0xC8 "conj " \
	0xC9 "real " \
	0xCA "imag " \
	0xCB "angle " \
	0xCC "not " \
	0xCD "rotR " \
	0xCE "rotL " \
	0xCF "shftR " \
	0xD0 "shftL " \
	0xD1 "eigVl " \
	0xD2 "eigVc " \
	0xD3 "cond " \
	0xD4 "poly " \
	0xD5 "fcstx " \
	0xD6 "fcsty " \
	0xD7 "eval " \
	0xD8 "If " \
	0xD9 "Then" \
	0xDA "Else" \
	0xDB "While " \
	0xDC "Repeat " \
	0xDD "For" \
	0xDE "End" \
	0xDF "Return" \
	0xE2 "Pause " \
	0xE3 "Stop" \
	0xE4 "IS>" \
	0xE5 "DS<" \
	0xE6 "Input " \
	0xE7 "Prompt " \
	0xE8 "InpSt " \
	0xE9 "Disp " \
	0xEA "DispG" \
	0xEB "Outpt" \
	0xEC "ClLCD" \
	0xED "Eq>St" \
	0xEE "St>Eq" \
	0xEF "Fill" \
	0xF0 "^" \
	0xF1 "xroot" \
	0xF2 "Solver" \
	0xF3 "OneVar " \
	0xF4 "LinR " \
	0xF5 "ExpR " \
	0xF6 "LnR " \
	0xF7 "PwrR " \
	0xF8 "ShwSt" \
	0xF9 "Hist " \
	0xFA "xyLine " \
	0xFB "Scatter " \
	0xFC "Sortx " \
	0xFD "Sorty " \
	0xFE "LU" \
]
set	BAZIC85_3D [dict create \
	0x00 "zxScl" \
	0x01 "zyScl" \
	0x02 "xScl" \
	0x03 "yScl" \
	0x04 "xMin" \
	0x05 "xMax" \
	0x06 "yMin" \
	0x07 "yMax" \
	0x08 "tMin" \
	0x09 "tMax" \
	0x0A "tStep" \
	0x0B "thetaStep" \
	0x0C "ztStep" \
	0x0D "zthetaStep" \
	0x0E "tPlot" \
	0x0F "thetaMin" \
	0x10 "thetaMax" \
	0x11 "zxMin" \
	0x12 "zxMax" \
	0x13 "zyMin" \
	0x14 "zyMax" \
	0x15 "ztPlot" \
	0x16 "zthetaMin" \
	0x17 "zthetaMax" \
	0x18 "ztMin" \
	0x19 "ztMax" \
	0x1A "lower" \
	0x1B "upper" \
	0x1C "deltax" \
	0x1D "deltay" \
	0x1E "xFact" \
	0x1F "yFact" \
	0x20 "difTol" \
	0x21 "tol" \
	0x22 "delta" \
	0x23 "Na" \
	0x24 "k" \
	0x25 "Cc" \
	0x26 "ec" \
	0x27 "Rc" \
	0x28 "Gc" \
	0x29 "g" \
	0x2A "Me" \
	0x2B "Mp" \
	0x2C "Mn" \
	0x2D "mu0" \
	0x2E "epsilon0" \
	0x2F "h" \
	0x30 "c" \
	0x31 "u" \
	0x32 "e" \
	0x33 "xStat" \
	0x34 "yStat" \
	0x35 "fStat" \
	0x36 "TblStart" \
	0x37 "deltaTbl" \
	0x38 "fldRes" \
	0x39 "EStep" \
	0x3A "dTime" \
	0x3B "xRes" \
	0x3C "zxRes" \
	0x3D "FldPic" \
]

set	BAZIC86_8E [dict create \
	0x00 "PxOn" \
	0x01 "PxOff" \
	0x02 "PxChg" \
	0x03 "Get" \
	0x04 "Send" \
	0x05 "SinR " \
	0x06 "LgstR " \
	0x07 "TwoVar " \
	0x08 "GrStl" \
	0x09 "DrEqu" \
	0x0A "LCust" \
	0x0B "Form" \
	0x0C "Select" \
	0x0D "PlOn " \
	0x0E "PlOff " \
	0x0F "ClrEnt" \
	0x10 "StReg" \
	0x11 "IAsk" \
	0x12 "IAuto" \
	0x13 "Text" \
	0x14 "Horiz " \
	0x15 "DispT" \
	0x16 "ClTbl" \
	0x17 "DelVar" \
	0x18 "Box" \
	0x19 "MBox" \
	0x1A "ClrLsts" \
	0x1B "FldOff" \
	0x1C "DirFld" \
	0x1D "SlpFld" \
	0x1E "SetLEdit " \
	0x1F "Plot1" \
	0x20 "Plot2" \
	0x21 "Plot3" \
	0x22 "RK" \
	0x23 "Euler" \
	0x24 "ZData" \
	0x25 "Asm" \
	0x26 "AsmComp" \
	0x27 "AsmPrgm" \
	0x2A "PxTest" \
	0x2B "randInt" \
	0x2C "randBin" \
	0x2D "randNorm" \
	0x2E "median" \
	0x2F "cSum" \
	0x30 "cSum" \
	0x31 "Deltalst" \
]

	proc BAZIC85dict {a b {c 0}} {
		if [dict exists $b $a] {
			return [dict get $b $a]
		} elseif $c {
			return [format "\\u%02X%02X" $c $a]
		} else {
			return [format "\\x%02X" $a]
		}
	}
	proc 85fontmap {s} {
		return [string map {\xC1 θ} $s]
	}

	if {$term == 0x2D} { # string
		set token \"[cstr ascii]\"
	} elseif {$term in {0x32 0x3B 0x3C}} { # equation name
		set token [ascii [uint8]]
	} elseif {$term >= 0x33 && $term <=0x3A} { # variable name
		set token [ascii [expr $term-50]]
	} elseif {$term == 0x3D} { # built-in variables
		set token [BAZIC85dict [hex 1] $BAZIC85_3D 3D]
	} elseif {$term == 0x3E} { # conversion
		set token \ [ascii [expr [uint8]-50]]>[ascii [expr [uint8]-50]]
	} elseif {$term == 0x44} { # number
		set token [cstr ascii]
	} elseif {$term == 0x8E && $magic == "**TI86**"} { # TI-86 tokens
		set token [BAZIC85dict [hex 1] $BAZIC86_8E 8E]
	} elseif {$term == 0xE0} { # Lbl
		set token \Lbl\ [cstr ascii]
	} elseif {$term == 0xE1} { # Goto
		# if !zero, this is the offset from the start of the program to right after the label
		uint16
		set token \Goto\ [cstr ascii]
	} else {
		set token [BAZIC85dict $term $BAZIC85_00]
	}
	# how to account for carrage returns?
	if {$token == "AsmPrgm"} { # Tokenized Assembly
		set token $token\ [cstr ascii]
	}
	return $token
}

# magic is required to detokenize `PrtScrn` correctly, unfortunately
proc BAZIC85 {size {magic "**TI86**"}} {
	section -collapsed "Code" {
		if {$size>1} {
			set e [hex 2]
			move -2
			if {$e == 0x8E29} {
				hex 2 "Edit-lock"
				incr size -2
			}
		}

		set start [pos]

		set e 0
		while {!$e || ([pos] < $size+$start)} {
			if $e { int8 }
			incr e
			set line ""
			set Linestart [pos]
			while {[pos] < $size+$start} {
				if {[hex 1] == 0x6F} {
					move -1
					break
				}
				move -1
				append line [BAZIC85_GetToken [hex 1] $magic]
			}
			if {$line==""} {
				entry "Line $e" ""
			} else {
				entry "Line $e" $line [expr [pos]-$Linestart] $Linestart
			}
		}
		# if it was a single line, display it as the section value
		if {$e == 1} {
			sectionvalue $line
		} elseif $size {
			sectionvalue "\[expand for code]"
		}
	}
	goto [expr $start + $size]
}
