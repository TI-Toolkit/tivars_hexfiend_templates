# TI 68K RPN parser HexFiend template include
# Version 1.0
# (c) 2021-2023 LogicalJoe
# .hidden = true;

proc 68KRPN {size} {

proc Recursive_RPN {{expression ""}} {

set 68KRPN_TAGS [dict create \
	0x00 VAR_NAME \
	0x01 _VAR_Q \
	0x02 VAR_R \
	0x03 VAR_S \
	0x04 VAR_T \
	0x05 VAR_U \
	0x06 VAR_V \
	0x07 VAR_W \
	0x08 VAR_X \
	0x09 VAR_Y \
	0x0A VAR_Z \
	0x0B VAR_A \
	0x0C VAR_B \
	0x0D VAR_C \
	0x0E VAR_D \
	0x0F VAR_E \
	0x10 VAR_F \
	0x11 VAR_G \
	0x12 VAR_H \
	0x13 VAR_I \
	0x14 VAR_J \
	0x15 VAR_K \
	0x16 VAR_L \
	0x17 VAR_M \
	0x18 VAR_N \
	0x19 VAR_O \
	0x1A VAR_P \
	0x1B VAR_Q \
	0x1C EXT_SYSTEM \
	0x1D ARB_REAL \
	0x1E ARB_INT \
	0x1F POSINT \
	0x20 NEGINT \
	0x21 POSFRAC \
	0x22 NEGFRAC \
	0x23 FLOAT \
	0x24 PI \
	0x25 EXP \
	0x26 IM \
	0x27 NEGINFINITY \
	0x28 INFINITY \
	0x29 PN_INFINITY \
	0x2A UNDEF \
	0x2B FALSE \
	0x2C TRUE \
	0x2D STR \
	0x2E NOTHING \
	0x2F ACOSH \
	0x30 ASINH \
	0x31 ATANH \
	0x32 ASECH \
	0x33 ACSCH \
	0x34 ACOTH \
	0x35 COSH \
	0x36 SINH \
	0x37 TANH \
	0x38 SECH \
	0x39 CSCH \
	0x3A COTH \
	0x3B ACOS \
	0x3C ASIN \
	0x3D ATAN \
	0x3E ASEC \
	0x3F ACSC \
	0x40 ACOT \
	0x41 RACOS \
	0x42 RASIN \
	0x43 RATAN \
	0x44 COS \
	0x45 SIN \
	0x46 TAN \
	0x47 SEC \
	0x48 CSC \
	0x49 COT \
	0x4A ITAN \
	0x4B ABS \
	0x4C ANGLE \
	0x4D CEILING \
	0x4E FLOOR \
	0x4F INT \
	0x50 SIGN \
	0x51 SQRT \
	0x52 EXPF \
	0x53 LN \
	0x54 LOG \
	0x55 FPART \
	0x56 IPART \
	0x57 CONJ \
	0x58 IMAG \
	0x59 REAL \
	0x5A APPROX \
	0x5B TEXPAND \
	0x5C TCOLLECT \
	0x5D GETDENOM \
	0x5E GETNUM \
	0x5F ERROR \
	0x60 CUMSUM \
	0x61 DET \
	0x62 COLNORM \
	0x63 ROWNORM \
	0x64 NORM \
	0x65 MEAN \
	0x66 MEDIAN \
	0x67 PRODUCT \
	0x68 STDDEV \
	0x69 SUM \
	0x70 REF \
	0x71 IDENTITY \
	0x72 DIAG \
	0x73 COLDIM \
	0x74 ROWDIM \
	0x75 TRANSPOSE \
	0x76 FACTORIAL \
	0x77 PERCENT \
	0x78 RADIANS \
	0x79 NOT \
	0x7A MINUS \
	0x7B VEC_POLAR \
	0x7C VEC_CYLIND \
	0x7D VEC_SPHERE \
	0x7E START \
	0x7F ISTORE \
	0x80 STORE \
	0x81 WITH \
	0x82 XOR \
	0x83 OR \
	0x84 AND \
	0x85 LT \
	0x86 LE \
	0x87 EQ \
	0x88 GE \
	0x89 GT \
	0x8A NE \
	0x8B ADD \
	0x8C ADDELT \
	0x8D SUB \
	0x8E SUBELT \
	0x8F MUL \
	0x90 MULELT \
	0x91 DIV \
	0x92 DIVELT \
	0x93 POW \
	0x94 POWELT \
	0x95 SINCOS \
	0x96 SOLVE \
	0x97 CSOLVE \
	0x98 NSOLVE \
	0x99 ZEROS \
	0x9A CZEROS \
	0x9B FMIN \
	0x9C FMAX \
	0x9D COMPLEX \
	0x9E POLYEVEL \
	0x9F RANDPOLY \
	0xA0 CROSSP \
	0xA1 DOTP \
	0xA2 GCD \
	0xA3 LCM \
	0xA4 MOD \
	0xA5 INTDIV \
	0xA6 REMAIN \
	0xA7 NCR \
	0xA8 NPR \
	0xA9 P2RX \
	0xAA P2RY \
	0xAB P2PTHETA \
	0xAC P2PR \
	0xAD AUGMENT \
	0xAE NEWMAT \
	0xAF RANDMAT \
	0xB0 SIMULT \
	0xB1 PART \
	0xB2 EXP2LIST \
	0xB3 RANDNORM \
	0xB4 MROW \
	0xB5 ROWADD \
	0xB6 ROWSWAP \
	0xB7 ARCLEN \
	0xB8 NINT \
	0xB9 PI_PRODUCT \
	0xBA SIGMA_SUM \
	0xBB MROWADD \
	0xBC ANS \
	0xBD ENTRY \
	0xBE EXACT \
	0xBF LOGB \
	0xC0 COMDENOM \
	0xC1 EXPAND \
	0xC2 FACTOR \
	0xC3 CFACTOR \
	0xC4 INTEGRATE \
	0xC5 DIFFERENTIATE \
	0xC6 AVGRC \
	0xC7 NDERIV \
	0xC8 TAYLOR \
	0xC9 LIMIT \
	0xCA PROPFRAC \
	0xCB WHEN \
	0xCC ROUND \
	0xCD DMS \
	0xCE LEFT \
	0xCF RIGHT \
	0xD0 MID \
	0xD1 SHIFT \
	0xD2 SEQ \
	0xD3 LIST2MAT \
	0xD4 SUBMAT \
	0xD5 SUBSCRIPT \
	0xD6 RAND \
	0xD7 MIN \
	0xD8 MAX \
	0xD9 LIST \
	0xDA USERFUNC \
	0xDB MATRIX \
	0xDC FUNC \
	0xDD DATA \
	0xDE GDB \
	0xDF PIC \
	0xE0 TEXT \
	0xE1 FIG \
	0xE2 MAC \
	0xE3 EXT \
	0xE4 EXTR_INSTR \
	0xE5 END \
	0xE6 COMMENT \
	0xE7 NEXTEXPR \
	0xE8 NEWLINE \
	0xE9 ENDSTACK \
	0xEA PN1 \
	0xEB PN2 \
	0xEC ERROR_MSG \
	0xED EIGVC \
	0xEE EIGVL \
	0xEF DASH \
	0xF0 LOCALVAR \
	0xF1 DESOLVE \
	0xF2 FDASH \
	0xF3 ASM \
	0xF4 ISPRIME \
	0xF8 OTH \
	0xF9 ROTATE \
]

	set	tag_type [hex 1]
	set	tag_name [entryd TAG $tag_type 1 $68KRPN_TAGS]
	move	-2
	switch $tag_name {
		EXT_SYSTEM {
			hex	1 "Sys token"
			move	-2
		}
		ADD -
		POW -
		MUL -
		DIV -
		MINUS {
			set expression $tag_name$expression
			section $tag_name
			set expression [Recursive_RPN $expression]
			set expression [Recursive_RPN $expression]
			endsection
		}
		COS -
		SIN -
		SQRT -
		LOCALVAR {
			set expression $tag_name$expression
			section $tag_name
			set expression [Recursive_RPN $expression]
			endsection
		}
		NEGINT -
		POSINT {
			section $tag_name
			set	num_bytes [hex 1 S_$tag_name]
			move	-$num_bytes
			move	-1
			if {$num_bytes} {
				set expression [hex $num_bytes $tag_name]$expression
				move	-$num_bytes
				move	-1
			} else {
				entry	$tag_name 0
			}
			endsection
		}
		MAX -
		MIN -
		LIST {
			section $tag_name
			while {[hex 1] != 0xE5} {
				move -1
				set expression [Recursive_RPN $expression]
			}
			move -1
			set expression [Recursive_RPN $expression]
			endsection
		}
		STR {
			section $tag_name
			move	-1
			while {[int8]} {move -2}
			set	start [pos]
			cstr	ascii STR
			goto	$start
			move	-2
			endsection
		}
		FLOAT {
			move	-8
			hex	9 FLOAT
			move	-11
		}
		FUNC {
			section $tag_name
			hex	1 Flags
			# assume tokenized for now
			move	-3
			hex	2 NULLs
			set	s [pos]
			while {[uint8] != 229} {move -2}
			set	t [pos]
			move	-1
			hex	[expr $s-$t-1] Arguments
			goto 	$t
			move	-2
			set expression [Recursive_RPN $expression]
			endsection
		}
		SIGMA_SUM {
			section $tag_name
			section Expr {Recursive_RPN $expression}
			section Var {Recursive_RPN $expression}
			section Start {Recursive_RPN $expression}
			section End {Recursive_RPN $expression}
			Recursive_RPN $expression ;# END_TAG
			endsection
		}
	}
	return $expression
}

	set	start [pos]
	move	$size
	move	-1
	while {[pos] >= $start} {
		entry RPN: [Recursive_RPN]
	}
	goto	[expr $start+$size]
}
