# TI-8[56] TI-BASIC Detokenizer HexFiend template include
# Version 1.0
# (c) 2021-2025 LogicalJoe
# .hidden = true;

# magic is required to detokenize \x8E correctly
proc BAZIC85 {size {magic "**TI86**"}} {

# in general, with few exceptions:
# ^\W(.*\W)?$ -> 0
# ^\W.*\w$    -> 4
# ^\w.*\W$    -> 8
# ^\w(.*\w)?$ -> C

set	BAZIC85_00 [dict create \
	0x01 {">Rec" 4} \
	0x02 {">Pol" 4} \
	0x03 {">Cyl" 4} \
	0x04 {">Sph" 4} \
	0x05 {">DMS" 4} \
	0x06 {">Bin" 4} \
	0x07 {">hex" 4} \
	0x08 {">Oct" 4} \
	0x09 {">Dec" 4} \
	0x0A {">Frac" 4} \
	0x0B {"->" 0} \
	0x0C {"\[" 0} \
	0x0D {"\]" 0} \
	0x0E {"\{" 0} \
	0x0F {"\}" 0} \
	0x10 {"(" 0} \
	0x11 {")" 0} \
	0x12 {"round" C} \
	0x13 {"max" C} \
	0x14 {"min" C} \
	0x15 {"mod" C} \
	0x16 {"cross" C} \
	0x17 {"dot" C} \
	0x18 {"aug" C} \
	0x19 {"rSwap" C} \
	0x1A {"rAdd" C} \
	0x1B {"multR" C} \
	0x1C {"mRAdd" C} \
	0x1D {"sub" C} \
	0x1E {"lcm" C} \
	0x1F {"gcd" C} \
	0x20 {"simult" C} \
	0x21 {"inter" C} \
	0x22 {"pEval" C} \
	0x23 {"randM" C} \
	0x24 {"seq" C} \
	0x25 {"evalF" C} \
	0x26 {"fnInt" C} \
	0x27 {"arc" C} \
	0x28 {"fMin" C} \
	0x29 {"fMax" C} \
	0x2A {"der1" C} \
	0x2B {"der2" C} \
	0x2C {"nDer" C} \
	0x2E {"|<" 0} \
	0x2F {"," 0} \
	0x30 {" or " 0} \
	0x31 {" xor " 0} \
	0x3F {"=" 0} \
	0x40 {" and " 0} \
	0x41 {"rand" C} \
	0x42 {"π" 0} \
	0x43 {"getKy" C} \
	0x45 {"%" 0} \
	0x46 {"!" 0} \
	0x47 {"ʳ" 0} \
	0x48 {"°" 0} \
	0x49 {"⁻¹" 0} \
	0x4A {"²" 0} \
	0x4B {"ᵀ" 0} \
	0x4C {"Menu" C} \
	0x4D {"P2Reg " 8} \
	0x4E {"P3Reg " 8} \
	0x4F {"P4Reg " 8} \
	0x50 {"==" 0} \
	0x51 {"<" 0} \
	0x52 {">" 0} \
	0x53 {"<=" 0} \
	0x54 {">=" 0} \
	0x55 {"!=" 0} \
	0x56 {"Radian" C} \
	0x57 {"Degree" C} \
	0x58 {"Normal" C} \
	0x59 {"Sci" C} \
	0x5A {"Eng" C} \
	0x5B {"Float" C} \
	0x5C {"Fix " 8} \
	0x5D {"RectV" C} \
	0x5E {"CylV" C} \
	0x5F {"SphereV" C} \
	0x60 {"+" 0} \
	0x61 {"-" 0} \
	0x62 {"Func" C} \
	0x63 {"Param" C} \
	0x64 {"Pol" C} \
	0x65 {"DifEq" C} \
	0x66 {"Bin" C} \
	0x67 {"Oct" C} \
	0x68 {"Hex" C} \
	0x69 {"Dec" C} \
	0x6A {"RectC" C} \
	0x6B {"PolarC" C} \
	0x6C {"dxDer1" C} \
	0x6D {"dxNDer" C} \
	0x6E {":" 0} \
	0x6F {"\n" 0} \
	0x70 {"*" 0} \
	0x71 {"/" 0} \
	0x72 {"SeqG" C} \
	0x73 {"SimulG" C} \
	0x74 {"PolarGC" C} \
	0x75 {"RectGC" C} \
	0x76 {"CoordOn" C} \
	0x77 {"CoordOff" C} \
	0x78 {"DrawLine" C} \
	0x79 {"DrawDot" C} \
	0x7A {"AxesOn" C} \
	0x7B {"AxesOff" C} \
	0x7C {"GridOn" C} \
	0x7D {"GridOff" C} \
	0x7E {"LabelOn" C} \
	0x7F {"LabelOff" C} \
	0x80 {" nPr " 0} \
	0x81 {" nCr " 0} \
	0x82 {"Trace" C} \
	0x83 {"ClDrw" C} \
	0x84 {"ZStd" C} \
	0x85 {"ZTrig" C} \
	0x86 {"ZFit" C} \
	0x87 {"ZIn" C} \
	0x88 {"ZOut" C} \
	0x89 {"ZSqr" C} \
	0x8A {"ZInt" C} \
	0x8B {"ZPrev" C} \
	0x8C {"ZDecm" C} \
	0x8D {"ZRcl" C} \
	0x8E {"PrtScrn" C} \
	0x8F {"DrawF " 8} \
	0x90 {"FnOn " 8} \
	0x91 {"FnOff " 8} \
	0x92 {"Stpic " 8} \
	0x93 {"RcPic " 8} \
	0x94 {"StGDB " 8} \
	0x95 {"RcGDB " 8} \
	0x96 {"Line" C} \
	0x97 {"Vert " 8} \
	0x98 {"PtOn" C} \
	0x99 {"PtOff" C} \
	0x9A {"PtChg" C} \
	0x9B {"Shade" C} \
	0x9C {"Circl" C} \
	0x9D {"Axes" C} \
	0x9E {"TanLn" C} \
	0x9F {"DrInv " 8} \
	0xA0 {"√" 0} \
	0xA1 {"~" 0} \
	0xA2 {"abs " 8} \
	0xA3 {"iPart " 8} \
	0xA4 {"fPart " 8} \
	0xA5 {"int " 8} \
	0xA6 {"ln " 8} \
	0xA7 {"e^" 8} \
	0xA8 {"log " 8} \
	0xA9 {"⏨^" 0} \
	0xAA {"sin " 8} \
	0xAB {"asin " 8} \
	0xAC {"cos " 8} \
	0xAD {"acos " 8} \
	0xAE {"tan " 8} \
	0xAF {"atan " 8} \
	0xB0 {"sinh " 8} \
	0xB1 {"asinh " 8} \
	0xB2 {"cosh " 8} \
	0xB3 {"acosh " 8} \
	0xB4 {"tanh " 8} \
	0xB5 {"atanh " 8} \
	0xB6 {"sign " 8} \
	0xB7 {"det " 8} \
	0xB8 {"ident " 8} \
	0xB9 {"unitV " 8} \
	0xBA {"norm " 8} \
	0xBB {"rnorm " 8} \
	0xBC {"cnorm " 8} \
	0xBD {"ref " 8} \
	0xBE {"rref " 8} \
	0xBF {"dim " 8} \
	0xC0 {"dimL " 8} \
	0xC1 {"sum " 8} \
	0xC2 {"prod " 8} \
	0xC3 {"sortA " 8} \
	0xC4 {"sortD " 8} \
	0xC5 {"li>vc " 8} \
	0xC6 {"vc>li " 8} \
	0xC7 {"lngth " 8} \
	0xC8 {"conj " 8} \
	0xC9 {"real " 8} \
	0xCA {"imag " 8} \
	0xCB {"angle " 8} \
	0xCC {"not " 8} \
	0xCD {"rotR " 8} \
	0xCE {"rotL " 8} \
	0xCF {"shftR " 8} \
	0xD0 {"shftL " 8} \
	0xD1 {"eigVl " 8} \
	0xD2 {"eigVc " 8} \
	0xD3 {"cond " 8} \
	0xD4 {"poly " 8} \
	0xD5 {"fcstx " 8} \
	0xD6 {"fcsty " 8} \
	0xD7 {"eval " 8} \
	0xD8 {"If " 8} \
	0xD9 {"Then" C} \
	0xDA {"Else" C} \
	0xDB {"While " 8} \
	0xDC {"Repeat " 8} \
	0xDD {"For" C} \
	0xDE {"End" C} \
	0xDF {"Return" C} \
	0xE0 {"Lbl " 8} \
	0xE1 {"Goto " 8} \
	0xE2 {"Pause " 8} \
	0xE3 {"Stop" C} \
	0xE4 {"IS>" 8} \
	0xE5 {"DS<" 8} \
	0xE6 {"Input " 8} \
	0xE7 {"Prompt " 8} \
	0xE8 {"InpSt " 8} \
	0xE9 {"Disp " 8} \
	0xEA {"DispG" C} \
	0xEB {"Outpt" C} \
	0xEC {"ClLCD" C} \
	0xED {"Eq>St" C} \
	0xEE {"St>Eq" C} \
	0xEF {"Fill" C} \
	0xF0 {"^" 0} \
	0xF1 {"˟√" 0} \
	0xF2 {"Solver" C} \
	0xF3 {"OneVar " 8} \
	0xF4 {"LinR " 8} \
	0xF5 {"ExpR " 8} \
	0xF6 {"LnR " 8} \
	0xF7 {"PwrR " 8} \
	0xF8 {"ShwSt" C} \
	0xF9 {"Hist " 8} \
	0xFA {"xyLine " 8} \
	0xFB {"Scatter " 8} \
	0xFC {"Sortx " 8} \
	0xFD {"Sorty " 8} \
	0xFE {"LU" C} \
]

# all have effective descriptor C
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

# \u8Exx token values were finalized in 0.2026; some differ in 0.2014
# \u8E28, \x8E29, and \x8E32 have token values of {"³³³³³" 0}
# \u8E2F has a token value of {"cSum" 0}
# \u8E33 was given the wrong descriptor (is 8 should be C)
# everything above \u8E33 is coersed to \u8E33
set	BAZIC86_8E [dict create \
	0x00 {"PxOn" C} \
	0x01 {"PxOff" C} \
	0x02 {"PxChg" C} \
	0x03 {"Get" C} \
	0x04 {"Send" C} \
	0x05 {"SinR " 8} \
	0x06 {"LgstR " 8} \
	0x07 {"TwoVar " 8} \
	0x08 {"GrStl" C} \
	0x09 {"DrEqu" C} \
	0x0A {"LCust" C} \
	0x0B {"Form" C} \
	0x0C {"Select" C} \
	0x0D {"PlOn " 8} \
	0x0E {"PlOff " 8} \
	0x0F {"ClrEnt" C} \
	0x10 {"StReg" C} \
	0x11 {"IAsk" C} \
	0x12 {"IAuto" C} \
	0x13 {"Text" C} \
	0x14 {"Horiz " 8} \
	0x15 {"DispT" C} \
	0x16 {"ClTbl" C} \
	0x17 {"DelVar" C} \
	0x18 {"Box" C} \
	0x19 {"MBox" C} \
	0x1A {"ClrLsts" C} \
	0x1B {"FldOff" C} \
	0x1C {"DirFld" C} \
	0x1D {"SlpFld" C} \
	0x1E {"SetLEdit " 8} \
	0x1F {"Plot1" C} \
	0x20 {"Plot2" C} \
	0x21 {"Plot3" C} \
	0x22 {"RK" C} \
	0x23 {"Euler" C} \
	0x24 {"ZData" C} \
	0x25 {"Asm" C} \
	0x26 {"AsmComp" C} \
	0x27 {"AsmPrgm" C} \
	0x2A {"PxTest" C} \
	0x2B {"randInt" C} \
	0x2C {"randBin" C} \
	0x2D {"randNorm" C} \
	0x2E {"median" C} \
	0x30 {"cSum" C} \
	0x31 {"Deltalst" C} \
	0x33 {"PrtScrn" 8} \
]

	proc BAZIC85dictSingle {a b {c 0}} {
		if [dict exists $b $a] {
			return [dict get $b $a]
		} elseif $c {
			return [format "\\u%02X%02X" $c $a]
		} else {
			return [format "\\x%02X" $a]
		}
	}

	proc BAZIC85dict {a b {c 0}} {
		if [dict exists $b $a] {
			return [dict get $b $a]
		} elseif $c {
			return [format {\\u%02X%02X 0} $c $a]
		} else {
			return [format {\\x%02X 0} $a]
		}
	}

	variable font_map { \
		\x01 [b] \x02 [o] \x03 [d] \x04 [h] \x05 ▶ \x06 ⬆ \x07 ⬇ \
		\x08 ∫ \x09 × \
		\x0A [A] \x0B [B] \x0C [C] \x0D [D] \x0E [E] \x0F [F] \
		\x10 √ \x11 ⁻¹ \x12 ² \x13 ∠ \x14 ° \x15 ʳ \x16 ᵀ \x17 ≤ \
		\x18 ≠ \x19 ≥ \x1A - \x1B ᴇ \x1C → \x1D ⏨ \x1E ↑ \x1F ↓ \
		\x7F [=] \
		\x80 ₀ \x81 ₁ \x82 ₂ \x83 ₃ \x84 ₄ \x85 ₅ \x86 ₆ \x87 ₇ \
		\x88 ₈ \x89 ₉ \x8A Á \x8B À \x8C Â \x8D Ä \x8E á \x8F à \
		\x90 â \x91 ä \x92 É \x93 È \x94 Ê \x95 Ë \x96 é \x97 è \
		\x98 ê \x99 ë \x9A Í \x9B Ì \x9C Î \x9D Ï \x9E í \x9F ì \
		\xA0 î \xA1 ï \xA2 Ó \xA3 Ò \xA4 Ô \xA5 Ö \xA6 ó \xA7 ò \
		\xA8 ô \xA9 ö \xAA Ú \xAB Ù \xAC Û \xAD Ü \xAE ú \xAF ù \
		\xB0 û \xB1 ü \xB2 Ç \xB3 ç \xB4 Ñ \xB5 ñ \xB6 ´ \xB7 ` \
		\xB8 ¨ \xB9 ¿ \xBA ¡ \xBB α \xBC β \xBD γ \xBE Δ \xBF δ \
		\xC0 ε \xC1 θ \xC2 λ \xC3 μ \xC4 π \xC5 ρ \xC6 Σ \xC7 σ \
		\xC8 τ \xC9 φ \xCA Ω \xCB x̅ \xCC y̅ \xCD ˟ \xCE … \xCF ◀ \
		\xD0 ■ \xD1 ∕ \xD2 ‐ \xD3 ² \xD4 ° \xD5 ³ \xD6 \n \xD7 ➧ \
		\xD8 [line] \xD9 [thick] \xDA ◥ \xDB ◣ \xDC [animated] \xDD ○ \xDE ⋱ \xDF █ \
		\xE0 ⇧ \xE1 [neg-A] \xE2 [neg-a] \xE3 _ \xE4 ↥ \xE5 A̲ \xE6 a̲ \xE7 ▒ \
		\xE8 ▫ \xE9 ✚ \xEA ▪ \xEB ⁴ \xEC ﹦ \
	}
	proc 85fontmap s {
		variable font_map
		return [string map $font_map $s]
	}

	proc addchartoline char {
		upvar 2 e e lineStart lineStart line line
		# if char is 0xD6 display line and clear line
		# else append mapped char to line
		if {$char eq "\xD6"} {
			if {$line==""} {
				entry "Line $e" ""
			} else {
				entry "Line $e" $line [expr [pos]-$lineStart-1] $lineStart
			}
			incr e
			set line ""
			set lineStart [pos]
		} else {
			append line [85fontmap $char]
		}
	}

	proc cstr85 {} {
		while {[uint8]} {
			move -1
			addchartoline [ascii 1]
		}
	}

	proc pstr85 l {
		while {$l} {
			incr l -1
			addchartoline [ascii 1]
		}
	}

	section -collapsed "Code" {
		set start [pos]

		if {$size>1} {
			set e [hex 2]
			move -2
			if {$e == 0x8E29} {
				hex 2 "Edit-lock"
			}
		}

		set e 0
		while {!$e || ([pos] < $size+$start)} {
			set wantsSpace 0
			if $e { int8 }
			incr e
			set line ""
			set lineStart [pos]
			while {[pos] < $size+$start} {
				if {[hex 1] == 0x6F} {
					move -1
					break
				}
				move -1

				set term [hex 1]

				if {$term == 0x44} { # number
					if {$wantsSpace} {append line " "}
					set wantsSpace 0
					cstr85
				} elseif {$term == 0x2D} { # string
					set wantsSpace 0
					append line \"
					cstr85
					append line \"
				} elseif {$term >= 0x33 && $term <=0x3A} { # variable name
					if {$wantsSpace} {append line " "}
					set wantsSpace 1
					pstr85 [expr $term-50]
				} elseif {$term == 0x3D} { # built-in variables
					if {$wantsSpace} {append line " "}
					set wantsSpace 1
					append line [BAZIC85dictSingle [hex 1] $BAZIC85_3D 3D]
				} elseif {$term in {0x32 0x3B 0x3C}} { # equation name
					if {$wantsSpace} {append line " "}
					set wantsSpace 1
					pstr85 [uint8]
				} elseif {$term == 0xFF} { # system string
					append line \\xFF
					cstr85
				} elseif {$term == 0x3E} { # conversion
					# is secretly two variable names, hence the -50s
					append line " "
					set wantsSpace 1
					pstr85 [expr [uint8]-50]
					append line ">"
					pstr85 [expr [uint8]-50]
				} elseif {$term == 0x8E && $magic == "**TI86**"} { # TI-86 tokens
					if {[hex 1]==0x32} { # system token
						# used in exec?
						int8
						set flag [uint8 a]
						if {$flag & 2} {
							append line " "
							set wantsSpace 0
						}
						pstr85 [uint8]
						if {$flag & 1} {
							append line " "
							set wantsSpace 0
						}
					} else {
						move -1
						set token [BAZIC85dict [hex 1] $BAZIC86_8E 0x8E]
						set flag [expr 0x[lindex $token 1]0]
						if {($flag & 0x80) && $wantsSpace} {
							append line " "
						}
						set wantsSpace [expr $flag & 0x40]
						append line [lindex $token 0]
						# Tokenized Assembly
						if {[lindex $token 0] == "AsmPrgm"} {
							cstr85
						}
					}
				} else { # everything else
					set token [BAZIC85dict $term $BAZIC85_00]
					set flag [expr 0x[lindex $token 1]0]
					if {($flag & 0x80) && $wantsSpace} {
						append line " "
					}
					set wantsSpace [expr $flag & 0x40]
					append line [lindex $token 0]
					if {$term == 0xE1} { # Goto
						# if !zero, this is the offset from the start of the program to right after the label
						int16
					}
					if {$term in {0xE0 0xE1}} { # Lbl & Goto
						# \xFF used for invalid labels
						if {[uint8]==255} {
							append line \\xFF
						} else {
							move -1
						}
						cstr85
					}
				}
			}
			if {$line==""} {
				entry "Line $e" ""
			} else {
				entry "Line $e" $line [expr [pos]-$lineStart] $lineStart
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
