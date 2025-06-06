# TI 68K RPN parser HexFiend template include
# Version 2.0
# (c) 2021-2025 LogicalJoe
# .hidden = true;

proc 68KRPN {dataSize varName} {

big_endian

proc read68KNumb {} {
	set Flags [uint16]
	set Sign [expr $Flags & 32768?"-":""]
	# bit 14 set might mean the value is defined
	set Exp [expr $Flags & 0x3FFF]
	if {$Exp > 0x2000} {
		set Exp [expr $Exp-0x4000]
	}
	set Body [hex 7]
	set Body [string index $Body 2].[string range $Body 3 end]
	move 1
	return $Sign$Body\e$Exp
}

# Map of 68K characters which differ from isolatin1
# - HexFiend encodes ascii the same as isolatin1
# - UTF-16-only because Tcl 8.5 ships with MacOS
#  - https://core.tcl-lang.org/tips/doc/trunk/tip/600.md
# Note the lack of a return character (typically 0x0D)
variable font_map { \
\x01 ␁ \x02 ␂ \x03 ␃ \x04 ␄ \x05 ␅ \x06 ␆ \x07 [bell] \
\x08 ⌫ \x09 ⇥ \x0A ↴ \x0B ⮵ \x0C ⤒ \x0D ↵ \x0E [lock] \x0F ✓ \
\x10 ■ \x11 ◂ \x12 ▸ \x13 ▴ \x14 ▾ \x15 ← \x16 → \x17 ↑ \
\x18 ↓ \x19 ◀ \x1A ▶ \x1B ⬆ \x1C ∪ \x1D ∩ \x1E ⊂ \x1F ∈ \
\x7F ◆ \
\x80 α \x81 β \x82 Γ \x83 γ \x84 Δ \x85 δ \x86 ε \x87 ζ \
\x88 θ \x89 λ \x8A ξ \x8B ∏ \x8C π \x8D ρ \x8E ∑ \x8F σ \
\x90 τ \x91 φ \x92 ψ \x93 Ω \x94 ω \x95 ᴇ \x96 ℯ \x97 [i] \
\x98 ʳ \x99 ᵀ \x9A x̅ \x9B y̅ \x9C ≤ \x9D ≠ \x9E ≥ \x9F ∠ \
\xA0 … \xA8 √ \xAA ᴳ \xAD ⁻ \
\xB4 ⁻¹ \xB8 ⁺ \xBC ∂ \xBD ∫ \xBE ∞ }

proc swap_endianness {a} {
	regsub .. $a "" a
	return "0x[join [lreverse [regexp -all -inline .. $a]] ""]"
}

# \0 string \0
proc String_68 {} {
	variable font_map
	move -1
	while {[int8]} {move -2}
	set start [pos]
	set expression [cstr isolatin1]
	goto $start
	move -2
	return [string map $font_map $expression]
}

# read args to 0xE5
# or argv[1] args
proc has_args {{n -1} {d ,}} {
	set list ""
	if {$n+1} {
		while {[incr n -1]+1} {
			lappend list [Recursive_RPN]
		}
	} else {
		while {[hex 1] != 0xE5} {
			move -1
			lappend list [Recursive_RPN]
		}
		move -2
	}
	return [join $list $d]
}

# https://debrouxl.github.io/gcc4ti/estack.html
variable 68KRPN_TAGS [dict create \
	0x01 q \
	0x02 r \
	0x03 s \
	0x04 t \
	0x05 u \
	0x06 v \
	0x07 w \
	0x08 x \
	0x09 y \
	0x0A z \
	0x0B a \
	0x0C b \
	0x0D c \
	0x0E d \
	0x0F e \
	0x10 f \
	0x11 g \
	0x12 h \
	0x13 i \
	0x14 j \
	0x15 k \
	0x16 l \
	0x17 m \
	0x18 n \
	0x19 o \
	0x1A p \
	0x1B q \
	0x24 π \
	0x25 ℯ \
	0x26 \[i\] \
	0x27 -∞ \
	0x28 ∞ \
	0x29 ±∞ \
	0x2A undef \
	0x2B false \
	0x2C true \
	0x2F acosh \
	0x30 asinh \
	0x31 atanh \
	0x32 asech \
	0x33 acsch \
	0x34 acoth \
	0x35 cosh \
	0x36 sinh \
	0x37 tanh \
	0x38 sech \
	0x39 csch \
	0x3A coth \
	0x3B acos \
	0x3C asin \
	0x3D atan \
	0x3E asec \
	0x3F acsc \
	0x40 acot \
	0x44 cos \
	0x45 sin \
	0x46 tan \
	0x47 sec \
	0x48 csc \
	0x49 cot \
	0x4B abs \
	0x4C angle \
	0x4D ceiling \
	0x4E floor \
	0x4F int \
	0x50 sign \
	0x51 sqrt \
	0x52 e^ \
	0x53 ln \
	0x54 log \
	0x55 fPart \
	0x56 iPart \
	0x57 conj \
	0x58 imag \
	0x59 real \
	0x5A approx \
	0x5B tExpand \
	0x5C tCollect \
	0x5D getDenom \
	0x5E getNum \
	0x60 cumSum \
	0x61 det \
	0x62 colNorm \
	0x63 rowNorm \
	0x64 norm \
	0x65 mean \
	0x66 median \
	0x67 product \
	0x68 stdDev \
	0x69 sum \
	0x6A variance \
	0x6B unitV \
	0x6C dim \
	0x6D mat>list \
	0x6E newList \
	0x6F rref \
	0x70 ref \
	0x71 identity \
	0x72 diag \
	0x73 colDim \
	0x74 rowDim \
	0x75 ᵀ \
	0x76 ! \
	0x77 % \
	0x78 ʳ \
	0x79 not \
	0x7A ⁻ \
	0x80 -> \
	0x81 | \
	0x82 " xor " \
	0x83 " or " \
	0x84 " and " \
	0x85 < \
	0x86 <= \
	0x87 = \
	0x88 >= \
	0x89 > \
	0x8A ≠ \
	0x8B + \
	0x8C .+ \
	0x8D - \
	0x8E .- \
	0x8F * \
	0x90 .* \
	0x91 / \
	0x92 ./ \
	0x93 ^ \
	0x94 .^ \
	0x95 trig \
	0x96 solve \
	0x97 cSolve \
	0x98 nSolve \
	0x99 zeros \
	0x9A cZeros \
	0x9B fMin \
	0x9C fMax \
	0x9E polyEval \
	0x9F randPoly \
	0xA0 crossP \
	0xA1 dotP \
	0xA2 gcd \
	0xA3 lcm \
	0xA4 mod \
	0xA5 intDiv \
	0xA6 remain \
	0xA7 nCr \
	0xA8 nPr \
	0xA9 P>Rx \
	0xAA P>Ry \
	0xAB R>Pθ \
	0xAC R>Pr \
	0xAD augment \
	0xAE newMat \
	0xAF randMat \
	0xB0 simult \
	0xB1 part \
	0xB2 exp>list \
	0xB3 randNorm \
	0xB4 mRow \
	0xB5 rowAdd \
	0xB6 rowSwap \
	0xB7 arcLen \
	0xB8 nInt \
	0xB9 Π \
	0xBA Σ \
	0xBB mRowAdd \
	0xBC ans \
	0xBD entry \
	0xBE exact \
	0xBF logb \
	0xC0 comDenom \
	0xC1 expand \
	0xC2 factor \
	0xC3 cFactor \
	0xC4 ∫ \
	0xC5 ∂ \
	0xC6 avgRC \
	0xC7 nDeriv \
	0xC8 taylor \
	0xC9 limit \
	0xCA propFrac \
	0xCB when \
	0xCC round \
	0xCE left \
	0xCF right \
	0xD0 mid \
	0xD1 shift \
	0xD2 seq \
	0xD3 list->mat \
	0xD4 subMat \
	0xD6 rand \
	0xD7 min \
	0xD8 max \
	0xE7 : \
	0xE8 "" \
	0xEA ± \
	0xEB ± \
	0xED eigVc \
	0xEE eigVl \
	0xEF \' \
	0xF1 deSolve \
	0xF4 isPrime \
	0xF9 rotate \
]

variable 68KRPN_SysTags [dict create \
	0x01 x̄ \
	0x02 ȳ \
	0x03 Σx \
	0x04 Σx^2 \
	0x05 Σy \
	0x06 Σy^2 \
	0x07 Σxy \
	0x08 Sx \
	0x09 Sy \
	0x0A σx \
	0x0B σy \
	0x0C nStat \
	0x0D minX \
	0x0E minY \
	0x0F q1 \
	0x10 medStat \
	0x11 q3 \
	0x12 maxX \
	0x13 maxY \
	0x14 corr \
	0x15 R^2 \
	0x16 medx1 \
	0x17 medx2 \
	0x18 medx3 \
	0x19 medy1 \
	0x1A medy2 \
	0x1B medy3 \
	0x1C xc \
	0x1D yc \
	0x1E zc \
	0x1F tc \
	0x20 rc \
	0x21 θc \
	0x22 nc \
	0x23 xfact \
	0x24 yfact \
	0x25 zfact \
	0x26 xmin \
	0x27 xmax \
	0x28 xscl \
	0x29 ymin \
	0x2A ymax \
	0x2B yscl \
	0x2C Δx \
	0x2D Δy \
	0x2E xres \
	0x2F xgrid \
	0x30 ygrid \
	0x31 zmin \
	0x32 zmax \
	0x33 zscl \
	0x34 eyeθ \
	0x35 eyeΦ \
	0x36 θmin \
	0x37 θmax \
	0x38 θstep \
	0x39 tmin \
	0x3A tmax \
	0x3B tstep \
	0x3C nmin \
	0x3D nmax \
	0x3E plotStrt \
	0x3F plotStep \
	0x40 zxmin \
	0x41 zxmax \
	0x42 zxscl \
	0x43 zymin \
	0x44 zymax \
	0x45 zyscl \
	0x46 zxres \
	0x47 zθmin \
	0x48 zθmax \
	0x49 zθstep \
	0x4A ztmin \
	0x4B ztmax \
	0x4C ztstep \
	0x4D zxgrid \
	0x4E zygrid \
	0x4F zzmin \
	0x50 zzmax \
	0x51 zzscl \
	0x52 zeyeθ \
	0x53 zeyeΦ \
	0x54 znmin \
	0x55 znmax \
	0x56 zpltstep \
	0x57 zpltstrt \
	0x58 seed1 \
	0x59 seed2 \
	0x5A ok \
	0x5B errornum \
	0x5C sysMath \
	0x5D sysData \
	0x5E regEq \
	0x5F regCoef \
	0x60 tblInput \
	0x61 tblStart \
	0x62 Δtbl \
	0x63 fldpic \
	0x64 eyeΨ \
	0x65 tplot \
	0x66 diftol \
	0x67 zeyeΨ \
	0x68 t0 \
	0x69 dtime \
	0x6A ncurves \
	0x6B fldres \
	0x6C Estep \
	0x6D zt0de \
	0x6E ztmaxde \
	0x6F ztstepde \
	0x70 ztplotde \
	0x71 ncontour \
]

variable 68KRPN_ExTags [dict create \
	0x01 # \
	0x02 getKey \
	0x03 getFold \
	0x04 switch \
	0x05 > \
	0x06 ord \
	0x07 expr \
	0x08 char \
	0x09 string \
	0x0A getType \
	0x0B getMode \
	0x0C setFold \
	0x0D ptTest \
	0x0E pxlTest \
	0x0F setGraph \
	0x10 setTable \
	0x11 setMode \
	0x12 format \
	0x13 inString \
	0x14 & \
	0x15 >DD \
	0x16 >DMS \
	0x17 >Rect \
	0x18 >Polar \
	0x19 >Cylind \
	0x1A >Sphere \
	0x26 ∠ \
	0x27 tmpCnv \
	0x28 ΔtmpCnv \
	0x29 getUnits \
	0x2A setUnits \
	0x2B 0b \
	0x2C 0h \
	0x2D >Bin \
	0x2E >Dec \
	0x2F >Hex \
	0x30 det \
	0x31 ref \
	0x32 rref \
	0x33 simult \
	0x34 getConfg \
	0x35 augment \
	0x36 mean \
	0x37 product \
	0x38 stdDev \
	0x39 sum \
	0x3A variance \
	0x3B Δlist \
	0x46 isClkOn \
	0x47 getDate \
	0x48 getTime \
	0x49 getTmZn \
	0x4A setDate \
	0x4B setTime \
	0x4C setTmZn \
	0x4D dayOfWk \
	0x4E startTmr \
	0x4F checkTmr \
	0x50 timeCnv \
	0x51 getDtFmt \
	0x52 getTmFmt \
	0x53 getDtStr \
	0x54 getTmStr \
	0x55 setDtFmt \
	0x56 setTmFmt \
	0x57 root \
	0x58 exprIO \
	0x59 impDif \
	0x5A stDevPop \
	0x5B isVar \
	0x5C isLocked \
	0x5D isArchiv \
	0x5E ᴳ \
	0x5F >Grad \
	0x60 >Rad \
	0x61 >ln \
	0x62 >logbase \
]

variable 68KRPN_ITags [dict create \
	0x01 ClrDraw \
	0x02 ClrGraph \
	0x03 ClrHome \
	0x04 ClrIO \
	0x05 ClrTable \
	0x06 Custom \
	0x07 Cycle \
	0x08 Dialog \
	0x09 DispG \
	0x0A DispTbl \
	0x0B Else \
	0x0C EndCustm \
	0x0D EndDlog \
	0x0E EndFor \
	0x0F EndFunc \
	0x10 EndIf \
	0x11 EndLoop \
	0x12 EndPrgm \
	0x13 EndTBar \
	0x14 EndTry \
	0x15 EndWhile \
	0x16 Exit \
	0x17 Func \
	0x18 Loop \
	0x19 Prgm \
	0x1A ShowStat \
	0x1B Stop \
	0x1C Then \
	0x1D ToolBar \
	0x1E Trace \
	0x1F Try \
	0x20 ZoomBox \
	0x21 ZomData \
	0x22 ZoomDec \
	0x23 ZoomFit \
	0x24 ZoomIn \
	0x25 ZoomInt \
	0x26 ZoomOut \
	0x27 ZoomPrev \
	0x28 ZoomRcl \
	0x29 ZoomSqr \
	0x2A ZoomStd \
	0x2B ZoomSto \
	0x2C ZoomTrig \
	0x2D DrawFunc \
	0x2E DrawInv \
	0x2F Goto \
	0x30 Lbl \
	0x31 Get \
	0x32 Send \
	0x33 GetCalc \
	0x34 SendCalc \
	0x35 NewFold \
	0x36 PrintObj \
	0x37 RclGDB \
	0x38 StoGDB \
	0x39 ElseIf \
	0x3A If \
	0x3B If \
	0x3C RandSeed \
	0x3D While \
	0x3E LineTan \
	0x3F CopyVar \
	0x40 Rename \
	0x41 Style \
	0x42 Fill \
	0x43 Request \
	0x44 PopUp \
	0x45 PtChg \
	0x46 PtOff \
	0x47 PtOn \
	0x48 PxlChg \
	0x49 PxlOff \
	0x4A PxlOn \
	0x4B MoveVar \
	0x4C DropDown \
	0x4D Output \
	0x4E PtTest \
	0x4F PxlTest \
	0x50 DrawSlp \
	0x51 Pause \
	0x52 Return \
	0x53 Input \
	0x54 PlotsOff \
	0x55 PlotsOn \
	0x56 Title \
	0x57 Item \
	0x58 InputStr \
	0x59 LineHorz \
	0x5A LineVert \
	0x5B PxlHorz \
	0x5C PxlVert \
	0x5D AndPic \
	0x5E RclPic \
	0x5F RplcPic \
	0x60 XorPic \
	0x61 DrawPol \
	0x62 Text \
	0x63 OneVar \
	0x64 StoPic \
	0x65 Graph \
	0x66 Table \
	0x67 NewPic \
	0x68 DrawParm \
	0x69 Cycle \
	0x6A CubicReg \
	0x6B ExpReg \
	0x6C LinReg \
	0x6D LnReg \
	0x6E MedReg \
	0x6F PowerReg \
	0x70 QuadReg \
	0x71 QuartReg \
	0x72 TwoVar \
	0x73 Shade \
	0x74 For \
	0x75 Circle \
	0x76 PxlCrcl \
	0x77 NewPlot \
	0x78 Line \
	0x79 PxlLine \
	0x7A Disp \
	0x7B FnOff \
	0x7C FnOn \
	0x7D Local \
	0x7E DelFold \
	0x7F DelVer \
	0x80 Lock \
	0x81 Prompt \
	0x82 SortA \
	0x83 SortD \
	0x84 UnLock \
	0x85 NewData \
	0x86 Define \
	0x87 Else \
	0x88 ClrErr \
	0x89 PassErr \
	0x8A DispHome \
	0x8B Exec \
	0x8C Archive \
	0x8D Unarchiv \
	0x8E LU \
	0x8F QR \
	0x90 BldData \
	0x91 DrwCtour \
	0x92 NewProb \
	0x93 SinReg \
	0x94 Logistic \
	0x95 CustmOn \
	0x96 CustmOff \
	0x97 SendChat \
	0x99 Request \
	0x9A ClockOn \
	0x9B ClockOff \
	0x9C SendCalc \
	0x9D GetCalc \
	0x9E delType \
	0x9F Data>Mat \
	0xA0 Mat>Data \
]

# dictionary_lookup value length dict
proc dictionary_lookup {b c d} {
	if [dict exists $d [set e $b]] {
		set e [dict get $d $b]
	}
	return $e
}

proc Recursive_RPN {{parent_precedence 15}} {
	variable 68KRPN_TAGS
	variable 68KRPN_SysTags
	variable 68KRPN_ExTags
	variable 68KRPN_ITags
	set tag_type [hex 1]
	set tag_name [dictionary_lookup $tag_type 1 $68KRPN_TAGS]
	set expression $tag_name
	set current_precedence 0
	move -2
	switch $tag_type {
		0x00 {
			set expression [String_68]
		}
		0x1C {
			set SysTAG [hex 1]
			set expression Sys_$SysTAG
			move -2
			if [dict exists $68KRPN_SysTags $SysTAG] {
				set expression [dict get $68KRPN_SysTags $SysTAG]
			}
		}
		0x1D -
		0x1E {
			# TODO: Arbatrary Real
		}
		0x1F -
		0x20 {
			set num_bytes [uint8]
			move -$num_bytes
			move -1
			if {$num_bytes} {
				set expression [expr {[swap_endianness [hex $num_bytes]]}]
				move -$num_bytes
				move -1
			} else {
				set expression 0
				move -1
			}
			if {$tag_type == 0x20} {
				set expression -$expression
			}
		}
		0x21 -
		0x22 {
			set num_bytes [uint8]
			move -$num_bytes
			move -1
			if {$num_bytes} {
				set expression [expr {[swap_endianness [hex $num_bytes]]}]
				move -$num_bytes
				move -1
			} else {
				set expression 0
				move -1
			}

			set num_bytes [uint8]
			move -$num_bytes
			move -1
			if {$num_bytes} {
				set expression $expression/[expr {[swap_endianness [hex $num_bytes]]}]
				move -$num_bytes
				move -1
			} else {
				set expression $expression/0
				move -1
			}
			if {$tag_type == 0x22} {
				set expression -$expression
			}
		}
		0x23 {
			# TODO: FLOAT
			move -8
			set expression [read68KNumb]
			move -11
		}
		0x2D {
			set expression \"[String_68]\"
		}
		0x2F -
		0x30 - 0x31 - 0x32 - 0x33 - 0x34 - 0x35 - 0x36 - 0x37 -
		0x38 - 0x39 - 0x3A - 0x3B - 0x3C - 0x3D - 0x3E - 0x3F -
		0x40 -                      0x44 - 0x45 - 0x46 - 0x47 -
		0x48 - 0x49 -        0x4B - 0x4C - 0x4D - 0x4E - 0x4F -
		0x50 - 0x51 - 0x52 - 0x53 - 0x54 - 0x55 - 0x56 - 0x57 -
		0x58 - 0x59 - 0x5A - 0x5B - 0x5C - 0x5D - 0x5E -
		0x60 - 0x61 - 0x62 - 0x63 - 0x64 - 0x65 - 0x66 - 0x67 -
		0x68 - 0x69 - 0x6A - 0x6B - 0x6C - 0x6D - 0x6E - 0x6F -
		0x70 - 0x71 - 0x72 - 0x73 - 0x74 -
		0xED - 0xEE -
		0xF4 {
			# tags with one argument and parentheses
			set current_precedence 3
			set expression "$tag_name\([has_args 1])"
		}
		0x75 - 0x76 - 0x77 - 0x78 - 0xEF {
			# postfix tags
			set current_precedence 4
			set expression "[Recursive_RPN $current_precedence]$tag_name"
		}
		0x79 {
			# not $expression
			set current_precedence 11
			set expression $tag_name\ [Recursive_RPN $current_precedence]
		}
		0x7A - 0xEA {
			# -$expression
			set current_precedence 6
			set expression $tag_name[Recursive_RPN $current_precedence]
		}
		0x7B - 0x7C - 0x7D - 0xF0 {
			set expression [has_args 1]
		}
		0x80 {
			# reducable into dyatic tags?
			set current_precedence 15
			set expression [Recursive_RPN]
			set expression "[Recursive_RPN]$tag_name$expression"
		}
		0x81 - 0x82 - 0x83 - 0x84 - 0x85 - 0x86 - 0x87 -
		0x88 - 0x89 - 0x8A -
		0x93 - 0x94 {
			# dyatic tags of form `2 1 TAG` -> `1 TAG 2`
			set mini_dict [dict create 0x81 14 0x82 13 0x83 13 0x84 12 0x93 5 0x94 5]
			if [dict exists $mini_dict $tag_type] {
				set current_precedence [dict get $mini_dict $tag_type]
			} else {
				set current_precedence 10
			}
			set expression "[Recursive_RPN $current_precedence]$tag_name[Recursive_RPN $current_precedence]"
		}
		0x8B - 0x8C - 0x8D - 0x8E - 0x8F - 0x90 - 0x91 - 0x92 - 0xEB {
			# dyatic tags of form `1 2 TAG` -> `1 TAG 2`
			if {$tag_type in {0x8F 0x90 0x91 0x92}} {
				set current_precedence 8
			} else {
				set current_precedence 9
			}
			set expression [Recursive_RPN $current_precedence]
			set expression "[Recursive_RPN $current_precedence]$tag_name$expression"
		}
		0x95 - 0x96 - 0x97 -
		0x98 - 0x99 - 0x9A - 0x9B - 0x9C -        0x9E - 0x9F -
		0xA0 - 0xA1 - 0xA2 - 0xA3 - 0xA4 - 0xA5 - 0xA6 - 0xA7 -
		0xA8 - 0xA9 - 0xAA - 0xAB - 0xAC - 0xAD - 0xAE - 0xAF -
		0xB0 -        0xB2 - 0xB3 -
		0xBF {
			# tags with two arguments and parentheses
			set expression "$tag_name\([has_args 2])"
		}
		0x9D {
			# TODO: COMPLEX NUMBER
		}
		0xB1 - 0xB4 - 0xB5 - 0xB6 - 0xB7 -
		0xB8 - 0xB9 - 0xBA - 0xBB - 0xBC - 0xBD - 0xBE -
		0xC0 - 0xC1 - 0xC2 - 0xC3 - 0xC4 - 0xC5 - 0xC6 - 0xC7 -
		0xC8 - 0xC9 - 0xCA - 0xCB - 0xCC - 0xCD - 0xCE - 0xCF -
		0xD0 - 0xD1 - 0xD2 - 0xD3 - 0xD4 -        0xD6 - 0xD7 -
		0xD8 -
		0xF1 -
		0xF9 {
			# tags with N arguments and parentheses
			set expression "$tag_name\([has_args])"
		}
		0xD5 {
			set expression "[Recursive_RPN]\[[has_args]\]"
		}
		0xD9 {
			set expression "\{[has_args]\}"
		}
		0xDA {
			set expression [Recursive_RPN]\([has_args]\)
		}
		0xE3 {
			set ExTAG [hex 1]
			set expression Sys_$ExTAG
			move -2
			if [dict exists $68KRPN_ExTags $ExTAG] {
				set expression [dict get $68KRPN_ExTags $ExTAG]
			}

			switch $ExTAG {
				0x01 {
					set current_precedence 2
					set expression "#[Recursive_RPN $current_precedence]"
				}
				0x02 - 0x03 - 0x04 -
				0x11 - 0x12 - 0x13 -
				0x29 -
				0x34 - 0x37 - 0x39 -
				0x46 - 0x47 - 0x48 - 0x49 - 0x4A - 0x4B - 0x4D - 0x4E -
				0x51 - 0x52 - 0x53 - 0x54 - 0x55 - 0x56 - 0x59 - 0x5A {
					append expression "([has_args])"
				}
				0x05 {
					# TODO
				}
				0x06 - 0x07 - 0x08 - 0x09 - 0x0A - 0x0B - 0x0C -
				0x2A -
				0x3B -
				0x4C - 0x4F -
				0x50 - 0x58 - 0x5B - 0x5C - 0x5D {
					append expression "([has_args 1])"
				}
				0x0D - 0x0E - 0x0F - 0x10 -
				0x27 - 0x28 -
				0x30 - 0x31 - 0x32 - 0x36 - 0x38 - 0x3A -
				0x57 {
					append expression "([has_args 2])"
				}
				0x14 {
					set current_precedence 7
					set expression [Recursive_RPN $current_precedence]
					set expression "[Recursive_RPN $current_precedence]\&$expression"
				}
				0x15 - 0x16 - 0x17 - 0x18 - 0x19 - 0x1A -
				0x2D - 0x2E - 0x2F -
				0x5F -
				0x60 - 0x61 - 0x62 {
					set expression "[Recursive_RPN]$expression"
				}
				0x26 {
					# TODO
				}
				0x2B - 0x2C {
					append expression "[Recursive_RPN]"
				}
				0x33 {
					append expression "([has_args 3])"
				}
				0x35 {
					append expression "([has_args 2 \;])"
				}
				0x5E {
					set current_precedence 4
					set expression "[Recursive_RPN $current_precedence]$expression"
				}
			}
		}
		0xE4 {
			set ITAG [hex 1]
			set expression ITag_$ITAG
			move -2
			if [dict exists $68KRPN_ITags $ITAG] {
				set expression [dict get $68KRPN_ITags $ITAG]
			}

			switch $ITAG {
				0x07 - 0x0E - 0x11 - 0x15 - 0x16 {
					move -1
					append expression "\[[uint16]\]"
					move -3
				}
				0x2D - 0x2E - 0x2F -
				0x30 - 0x31 - 0x32 - 0x33 - 0x34 - 0x35 - 0x36 - 0x37 -
				0x38 - 0x39 - 0x3A - 0x3C - 0x3D -
				0x90 - 0x91 - 0x97 - 0x9E {
					append expression " [has_args 1]"
				}
				0x3B {
					set expression "If [has_args 1] Then"
				}
				0x3E - 0x3F -
				0x40 - 0x41 - 0x42 - 0x43 - 0x44 - 0x45 - 0x46 - 0x47 -
				0x48 - 0x49 - 0x4A -
				0x86 -
				0x9C - 0x9D {
					append expression " [has_args 2]"
				}
				0x4B - 0x4C - 0x4D - 0x4E - 0x4F -
				0x50 {
					append expression " [has_args 3]"
				}
				0x51 - 0x52 - 0x54 - 0x55 - 0x56 - 0x57 -
				0x58 - 0x59 - 0x5A - 0x5B - 0x5C - 0x5D - 0x5E - 0x5F -
				0x60 - 0x61 - 0x62 - 0x63 - 0x64 - 0x65 - 0x66 - 0x67 -
				0x68 - 0x69 - 0x6A - 0x6B - 0x6C - 0x6D - 0x6E - 0x6F -
				0x70 - 0x71 - 0x72 - 0x73 - 0x74 - 0x75 - 0x76 - 0x77 -
				0x78 - 0x79 - 0x7A - 0x7B - 0x7C - 0x7D - 0x7E - 0x7F -
				0x80 - 0x81 - 0x82 - 0x83 - 0x84 - 0x85 -
				0x8B - 0x8C - 0x8D - 0x8E - 0x8F -
				0x93 - 0x94 - 0x99 - 0x9F -
				0xA0 {
					append expression " [has_args]"
				}
			}
		}
		0xE6 {
			set indent [uint8]
			move -2
			set expression "[string repeat " " $indent]©[String_68]"
		}
		0xE7 - 0xE8 {
			set indent [uint8]
			move -2
			set expression "$tag_name[string repeat " " $indent]"
		}
		0xF2 {
			set expression [String_68]'\([has_args]\)
		}
	}
	if {$parent_precedence < $current_precedence} {
		set expression "($expression)"
	}
	# entry partial: $expression
	return $expression
}

	set dataStart [pos]
	move $dataSize
	move -1

	# display variable contents based on initial tag
	set tag_type [hex 1]
	move -1
	switch $tag_type {
		0xD9 { # List
			# also matrix but that's for another time
			hex 1 List
			move -2
			set element 0
			while {[hex 1] != 0xE5} {
				move -1
				incr element
				set line ""
				set lineEnd [pos]
				set line [Recursive_RPN]
				entry Element\ $element $line [expr $lineEnd-[pos]] [expr [pos]+1]
			}
		}
		0xDC { # FUNC
			hex 1 Function
			move -2
			section "Flags" {
				set Flags [hex 1]
				sectionvalue $Flags
				entryd Bits\ 0-2 [expr $Flags & 7] 1 [dict create 0 Line 1 Dot 2 Thick\ line 3 Animate 4 Path 5 Shade\ above 6 Shade\ below 7 Square]
				FlagRead $Flags 3 Untokenized Tokenized
				FlagRead $Flags 4 Unknown ;# function?
				FlagRead $Flags 5 Unknown
				FlagRead $Flags 6 "Graph 1 plot on" "Graph 1 plot off"
				FlagRead $Flags 7 "Graph 2 plot on" "Graph 2 plot off"
			}

			move -3
			hex 2 Unknown
			move -3

			set expression "$varName"

			set lineStart [pos]
			set firstLine "$expression\([has_args]\)"
			set lineNumber 1

			if {$Flags & 8} {
				move -1
				hex 3 Filler
				goto $dataStart
				set lineStart $dataStart
				set sections [split [cstr isolatin1] \x0D]
				foreach line $sections {
					if {$line==""} {
						entry "Line $lineNumber" ""
					} else {
						if {$lineNumber-1} {
							entry "Line $lineNumber" "[string map $font_map $line]" [string length $line] $lineStart
						} else {
							entry "Line $lineNumber" "$varName[string map $font_map $line]" [string length $line] $lineStart
						}
					}
					incr lineNumber
					incr lineStart [expr [string length $line]+1]
				}
				uint16 Cursor
			} else {
				entry Line\ 1 $firstLine [expr $lineStart-[pos]] [expr [pos]+1]
				while {[hex 1] != 0xE9} {
					move -1
					incr lineNumber
					set line ""
					set lineEnd [pos]
					while {[hex 1] ni {0xE8 0xE9} || [expr $lineEnd+1]==[pos]} {
						move -1
						append line [Recursive_RPN]
					}
					move -1
					if {$lineNumber > 2} {
						incr lineEnd -2
					}
					if {[pos] == $lineEnd} {
						entry "Line $lineNumber" ""
					} else {
						entry Line\ $lineNumber $line [expr $lineEnd-[pos]] [expr [pos]+1]
					}
				}

				move -2
				# fargo data is after the DC/E9 structure
				if {[pos] > $dataStart} {
					move 1
					set t [expr [pos]-$dataStart]
					goto $dataStart
					bytes $t "Fargo data"
				}
			}
		}
		0xDD { # DATA
		}
		0xDE { # GDB
			hex 1 GDB
			goto $dataStart
			set modeDict [dict create 1 Function 2 Parametric 3 Polar 4 Sequence 5 3D 6 Differential]
			set g_count [uint8 Graph\ count]
			entryd Angle\ mode [uint8] 1 [dict create 1 Radians 2 Degrees 3 Gradians]
			entryd Complex\ mode [uint8] 1 [dict create 1 Real 2 Rectangular 3 Polar]
			entryd Graph\ mode [set graphs [uint8]] 1 $modeDict
			if {$g_count > 1} {
				section Second\ graph {
					uint8 Active\ Graphs
					lappend graphs [uint8]
					move -1
					entryd Graph\ mode\ 2 [uint8] 1 $modeDict
					entryd Split\ mode [uint8] 1 [dict create 1 Full 2 Top/Bottom 3 Left/Right]
					entryd Split\ ratio [uint8] 1 [dict create 1 1:1 2 1:2 3 2:1]
				}
			}
			set g_count 0
			foreach gmode $graphs {
				incr g_count
				section Graph\ $g_count
				set numbers {xmin xmax xscl ymin ymax yscl Deltax Deltay}
				set EquPtfx ""
				switch $gmode {
					1 {
						lappend numbers xres
						set EquPrfx y
					}
					2 {
						lappend numbers Thetamin Thetamax Thetastep
						set EquPrfx \[xy]t
					}
					3 {
						lappend numbers tmin tmax tstep
						set EquPrfx r
					}
					4 {
						lappend numbers nmin nmax plotstrt plotstep
						set EquPrfx u
					}
					5 {
						lappend numbers zmin zmax zscl eyetheta eyephi eyepsi ncontour unknown1 unknown2 unknown3
						set EquPrfx z
					}
					6 {
						lappend numbers t0 tmax tstep tplot diftol ncurves fldres unknown1 unknown2
						set EquPrfx y
						set EquPtfx \'
					}
				}
				section Numbers {
					foreach num $numbers {
						entry $num [read68KNumb] 10 [expr [pos]-10]
					}
				}
				section "Format flags" {
					set Flags [hex 2]
					sectionvalue $Flags
					FlagRead $Flags 0 "Coordinates: Polar" "Coordinates: Rect"
					FlagRead $Flags 1 "Leading Cursor: On" "Leading Cursor: Off"
					FlagRead $Flags 2 "Labels: On" "Labels: Off"
					FlagRead $Flags 3 "3D Axes: Box" "3D Axes: Axes"
					FlagRead $Flags 4 "Axes: Off" "Axes: On"
					FlagRead $Flags 5 "Grid: On" "Grid: Off"
					FlagRead $Flags 6 "Graph Order: Simul" "Graph Order: Seq"
					FlagRead $Flags 7 "Coordinates: Off" "Coordinates: On"
					move -1
					FlagRead $Flags 8 "Style: Wire Frame" "Style: Hidden Surface"
					FlagRead $Flags 9
					FlagRead $Flags 10 "Discontinuity Detection: Off" "Discontinuity Detection: On"
					FlagRead $Flags 11 "3D view expanded" "3D view not expanded"
					FlagRead $Flags 12
					# Sequence flags
					FlagRead $Flags 13 "Build web: Auto" "Build web: Trace"
					entryd Bits\ 14-15 [expr ($Flags & 0xC000) >> 14] 1 [dict create 0 "Axes: Custom" 1 "Axes: Web" 2 "Axes: Time" 3 "Axes: ~Time"]
					move 1
				}
				foreach axis {X Y} {
					set a [int8]
					set b $a
					if {$gmode == 4} {
						set b u
						if {$a == -1} {
							set b n
						} elseif $a {
							set b u$a
						}
					} elseif {$gmode == 6} {
						set b t
						if $a {
							set b "y[expr abs($a)-100?abs($a):""][expr $a<0?"'":""]"
						}
					}
					entry "$axis Axis" $b 1 [expr [pos]-1]
				}
				section "Differential flags" {
					set Flags [hex 2]
					sectionvalue $Flags
					FlagRead $Flags 0 "EULER" "RK"
					entryd Bits\ 1-2 [expr $Flags & 6] 1 [dict create 0 FLDOFF 2 DIRFLD 4 SLPFLD 6 ~SLPFLD]
					FlagRead $Flags 3
					FlagRead $Flags 4 "Custom Axes" "Uncustom Axes"
					foreach a {5 6 7} {
						FlagRead $Flags $a
					}
				}
				entryd Style\ 3D [hex 1] 1 [dict create 0x00 Wire\ Frame 0x01 Hidden\ Surface 0x02 Contour\ Levels 0x03 "Wire and Contour" 0x04 Implicit\ Plot]
				hex 1 unknown
				section Equations {
					set n [uint8 Equation\ count]
					for_n $n {
						set a [uint8]
						move -1
						if {$gmode == 2} {
							set EquPrfx [expr $a & 0x80?"y":"x"]t
							set a [expr $a & 0x7F]
						}
						section $EquPrfx$a$EquPtfx {
							uint8 Equation\ number
							set size [uint16 Size]
							68KRPN $size $EquPrfx$a$EquPtfx
						}
					}
				}
				section "Initial Values" {
					set values [uint8 "Initial values count"]
					for_n $values {
						section "" {
							sectionname $EquPrfx\i[uint8 Equation\ number]
							set size [uint16 Size]
							68KRPN $size ""
						}
					}
				}
				if {$gmode != 5} {
					section Table {
						section "Table flags" {
							set Flags [hex 1]
							sectionvalue $Flags
							foreach a {0 1 2 3 4 5} {
								FlagRead $Flags $a
							}
							FlagRead $Flags 6 "Independent: Ask" "Independent: Auto"
							FlagRead $Flags 7 "Graph <-> Table: On" "Graph <-> Table: Off"
						}
						foreach num {tblStart Deltatbl} {
							entry $num [read68KNumb] 10 [expr [pos]-10]
						}
						section tblInput {
							set size [uint16 List\ size]
							68KRPN $size ""
						}
					}
				}
				endsection
			}
		}
		0xDF { # PICTURE
			hex 1 Picture
			goto $dataStart
			set h [uint16 Height]
			set w [uint16 Width]
			bytes [expr int($h*ceil($w/8.0))] Data
		}
		0xE0 { # TEXT
			hex 1 Text
			goto $dataStart
			uint16 "Cursor offset"
			set delim 1
			while {$delim} {
				section -collapsed Line {
					set LineStart [pos]
					set delim [hex 1]
					while {$delim ni {0 13}} {
						set delim [uint8]
					}
					move -2
					set lineLen [expr [pos]-$LineStart]
					goto $LineStart
					entryd "Line type" [hex 1] 1 [dict create 0x0C Page\ break 0x20 Normal 0x43 Command 0x50 Print\ object]
					if $lineLen {
						sectionvalue [ascii $lineLen "Line"]
					} else {
						entry Line ""
					}
					entryd Deliminator [hex 1] 1 [dict create 0x00 EOF 0x0D Line\ End]
				}
			}
		}
		0xE1 { # FIGURE
		}
		0xE2 { # MACRO
		}
		0xF3 { # ASM
			hex 1 ASM
			move -2
			set endLoc [pos]
			goto $dataStart
			bytes [expr $endLoc-[pos]+1] Data
		}
		0xF8 { # OTHER
			# TODO: base this on the ID instead of appvar magic (68K-natives might not have this)
			hex 1 OTH
			move -2
			entry Magic [String_68]
			set endLoc [pos]
			goto $dataStart
			ReadAppVar [expr $endLoc-[pos]+1]
			# sometimes appvars switch endianness
			big_endian
		}
		default {
			set lineEnd [pos]
			set expression [Recursive_RPN]
			entry Line\ 1 $expression [expr $lineEnd-[pos]] $dataStart
		}
	}
	goto [expr $dataStart+$dataSize]
}
