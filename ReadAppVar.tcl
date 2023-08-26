# TI-appvar parser HexFiend template include
# Version 1.0
# (c) 2021-2023 LogicalJoe
# .hidden = true;


# F347BFA7 - Study cards
# F347BFA8 - Study cards settings
# F347BFAA - Cell Sheet
# F347BFAB - Cell Sheet state
# F347BFAF - Notefolio

proc ReadAppVar {datasize} {
	proc readByLine {codesize {deliminator 10} {terminator 500}} {
		section	-collapsed "Body"
		set	start [pos]
		set	number 0
		set	term 400
		while {[pos] < $codesize+$start && ($term != $terminator)} {
			set	linesize 0
			set	line ""
			set	term 400
			while {($term != $deliminator) && ([pos] < $codesize+$start) && ($term != $terminator)} {
				incr	linesize 1
				set	term [uint8]
				set	line $line[format %c $term]
			}
			incr	number
			if {$linesize!=0} {
				entry	Line\ $number $line $linesize [expr [pos]-$linesize]
			}
		}
		endsection
	}

	proc reverse_leb128 {{name ""}} {
		set	start [pos]
		set	byte 128
		for {set shift 0} {$byte & 0x80} {incr shift 7} {
			set	byte [uint8]
			incr	number [expr ($byte & 127) << $shift]
		}
		if {$name != ""} {
			entry	$name $number [expr [pos]-$start] $start
		}
		return	$number
	}
	proc uint16l {a {b -1}} {
		if {$b==-1} {
			set	b [uint16]
			entry	$a [format "0x%04X" [set x $b]] 2 [expr [pos]-2]
		} else {
			entry	$a [format "0x%04X" $b] 3 [expr [pos]-2]
		}
		return $b
	}

	set	head 0
	if {$datasize > 4} {
		set	head [str 4 ascii]
		move	-4
	}

	if {$head == "PYCD" || $head == "PYSC"} {
		section	-collapsed "Data"

		ascii	4 "Python"
		set	namesize [hex 1 "Name length"]
		if {$namesize} {
			hex	1 "Version?"
			set	number [string length [cstr utf8 "Filename"]]
			incr	datasize -$number
			incr	datasize -7
		} else {
			incr	datasize -5
		}
		readByLine $datasize
		endsection
	} elseif {$head == "PYMP"} {
		#https://github.com/commandblockguy/tipycomp/blob/main/format.txt
		section	-collapsed "Data"
		ascii	4 "Python Module"
		incr	datasize -4
		set	length [reverse_leb128 "Length"]
		hex	1 "Verison?"
		incr	datasize -3
		set	offset [pos]
		#todo: sections?
		readByLine $length
		incr	datasize [expr $offset-[pos]]
		bytes	$datasize "Compiled module"
		endsection
	} elseif {$head == "\xf3\x47\xbf\xa7"} {
		#Credit to Zeroko
		#https://www.ticalc.org/archives/files/fileinfo/477/47772.html
		#https://www.ticalc.org/pub/text/misc/studycards83.txt
		#TODO: size limits

		proc ReadCardItem {} {
			section	-collapsed "Item"
			set	kind [hex 1 "Type"]
			if {$kind == 1} {
				uint8	"Y coord"
				uint8	"X coord"
				sectionvalue Text:\ [cstr ascii "Text"]
			} elseif {$kind == 9} {
				sectionvalue "Image"
				uint8	"Y coord"
				uint8	"X coord"
				set	Height [uint8 "Height"]
				set	Width [uint8 "Width"]
				hex	[expr $Height*-((-$Width)/8)] "Data"
				#hacky way to ceil
			} else {
				sectionvalue "Error"
			}
			endsection
		}
		proc ReadCardScreen {items} {
			section	"Screen"
			set	items [uint8 "Item count"]
			for_n $items {
				ReadCardItem
			}
			if {[uint8]==80} {
				move	-1
				hex	[expr 1+$items] "Unknown"
			} else {
				move	-1
			}
			endsection
		}
		proc ReadCardSide {} {
			section	-collapsed "Card side"
			set	start [pos]
			set	screens [uint8 "Screen count"]
			whiless	[expr 2*$screens] {
				lappend	cardscreens [uint16l "offset"]
			}
			foreach a $cardscreens {
				goto	$start
				move	$a
				ReadCardScreen $screens
			}
			endsection
		}
		proc ReadCard {Flags} {
			section -collapsed "Card"
			set	start [pos]
			set	cardsides [uint16l "Card front offset"]
			lappend	cardsides [uint16l "Card back offset"]
			if {[expr 1&$Flags]} {
				uint8	"Level"
			}
			if {[expr 2&$Flags]} {
				uint8	"Choices"
				uint8	"Correct"
			}
			sectionvalue [cstr ascii "Name"]
			foreach a $cardsides {
				goto	$start
				move	$a
				ReadCardSide
			}
			endsection
		}

		section	-collapsed "Data"

		set	start [pos]
		hex	4 "Study cards"
		uint16l	"Version"
		section Flags {
			proc FlagRead {Flag bit {name reserved} {notname -1}} {
				if {($Flag & (1 << $bit)) == 0} {
					if {$notname != -1} {
						entry $notname "" 1 [expr [pos] - 1]
					}
				} else {
					entry $name "" 1 [expr [pos] - 1]
				}
			}
			set	Flags [format "0x%04X" [uint16]]
			move	-1
			sectionvalue $Flags
			FlagRead $Flags 0 "Use levels" "No levels"
			FlagRead $Flags 1 "Self-check" "Multiple choice"
			for {set a 2} {$a<7} {incr a} {
				FlagRead $Flags $a
			}
			set	Flags2 [hex 1]
			for {set a 0} {$a<7} {incr a} {
				FlagRead $Flags2 $a
			}
		}

		section -collapsed "Title text offsets" {
			for {set a 0} {$a < 4} {incr a} {
				set	title($a) [uint16l "Title offset $a"]
			}
		}

		if {[expr 1&$Flags]} {
			uint8	"Level count"
		}
		uint8	"Correct reward"
		uint8	"Incorrect penalty"
		uint8	"Skip penalty"
		set	cardcount [uint8 "Number of cards"]
		section -collapsed "Card offsets" {
			for {set a 0} {$a < $cardcount} {incr a} {
				lappend cards [uint16l "offset to card"]
			}
		}

		#fix highlighting because section is dumb
		goto	$start
		move	$title(0)
		section "Title texts" {
			for {set a 0} {$a < 4} {incr a} {
				goto	$start
				move	$title($a)
				cstr	ascii "Title string $a"
			}
		}

		foreach a $cards {
			goto	$start
			move	$a
			ReadCard $Flags
		}
		endsection
	} elseif {$head == "\xf3\x47\xbf\xa8"} {
		hex	4 "Study cards settings"
		section Flags {
			set flags [uint8]
			# 0 & 1 are exclusive
			FlagRead $flags 0 "Keep known cards"
			FlagRead $flags 1 "Re-introduce cards"
			FlagRead $flags 2 "Shuffle cards"
			FlagRead $flags 3 "Ignore levels"
			FlagRead $flags 4 "Animate flip"
			FlagRead $flags 5 "5 Box mode"
			foreach a {6 7} { FlagRead $flags $a }
		}
		bytes	9 "Unused/Unknown"
	} elseif {$head == "\xf3\x47\xbf\xaa" || $head == "\xf3\x47\xbf\xab"} {
		section -collapsed "Data"
		hex	4 CelSheet
		ascii	8 Name
		if {[hex 2 Number] == 0} {
			hex	13 AA*13
			hex	40 00*40
			hex	20 !00*20
			hex	105 00*105
			while {[set secsiz [uint8]]} {
				move	-1
				section -collapsed Cell
				uint8	Size
				set	location [hex 2]
				set	a [format %c [expr 65+$location/1000]][expr $location%1000]
				entry	Cell\ position $location\ ($a) 2 [expr [pos]-2]
				sectionvalue $a
				set	r [uint8 Datatype]
				switch -- $r {
					0	{ readZ80Numb }
					1	{ BAZIC [expr $secsiz-8] }
					3	{ readZ80Numb Current
						BAZIC [expr $secsiz-17] }
				}
				hex	2 Cell\ #
				hex	2 NULLs
				endsection
			}
			move	-1
			uint8	Cell
			if [uint8] {
				move	-1
				hex	2 4C08
				hex	6 001FF8000000
				hex	2 Unknown
				hex	6 001FF8000000
				hex	6 001FF8000000
				hex	22 Datas
				hex	2 Unknown
			} else {
				move	-1
				hex	2 Nulls
			}
		}
		endsection
	} elseif {$head == "CaJu"} {
		section -collapsed "Data"
		hex	4 CabriJr
		set type [entryd Type [ascii 1] 1 "f File l Language"]
		if {$type == "File"} {
			set	struct [hex 1]
			if {$struct==0x04} {
				entry	Structure 4\ (Uncompressed) 1 [expr [pos]-1]
				hex	1 Unknown
				uint16	Unknown
				hex	1 Unknown
				set	n [uint8]
				entry	"offset to name" [expr 21*$n] 1 [expr [pos]-1]
				hex	[expr $datasize-11] Data
			} else {
				entry	Structure $struct\ (Compressed) 1 [expr [pos]-1]
				# if Number==4 && Number2==90h: Type=66h
				hex	1 Unread
				set	n [hex 1] ;# needs neg if bit 7
				entry	$n [format "0x%04X" [expr 2*$n+36]] 1 [expr [pos]-1]
				set	e [hex 1]
				entry	$e [format "0x%04X" [expr 2*$e+18]] 1 [expr [pos]-1]
				# each block is 18 bytes
				set	n [uint8 "Block count"]
				for {set a 0} {$a < $n} {incr a} {
					hex	18 Block\ $a
				}
				# hackfix something I don't understand
				if {$e == 0x20} { uint16 }
			}
		} elseif {$type == "Language"} {
			hex 2 "Unknown (0x015F)"
			ascii 3 "Lang ID"
			set start [pos]
			set start2 [pos]
			set lines [split [ascii [expr $datasize-10]] \x0D]
			goto $start
			set lineIndex -1
			for {set mainMenu 1} {$mainMenu < 6} {incr mainMenu} {
				set submenus ""
				incr lineIndex
				section -collapsed F$mainMenu {
					foreach word [split [lindex $lines $lineIndex] ","] {
						if {$word == ""} {
							lappend submenus $prevWord
						} else {
							entry Word $word [string length $word] $start
						}
						incr start [expr [string length $word]+1]
						move [expr [string length $word]+1]
						set prevWord $word
					}
					set submenus [lsearch -all -inline -regexp $submenus {\S+}]
					foreach menu $submenus {
						incr lineIndex
						section $menu {
							foreach word [split [lindex $lines $lineIndex] ","] {
								entry Word $word [string length $word] $start
								incr start [expr [string length $word]+1]
								move [expr [string length $word]+1]
							}
						}
					}
				}
			}
			move	-1
			# 0D0D2C3B0D is end of menus
			hex 5 Menus\ end
			section -collapsed Texts {
				foreach line [lrange $lines [expr $lineIndex+3] [expr $lineIndex+24]] {
					entry Word $line [string length $line] [pos]
					move [expr [string length $line]+1]
				}
			}
			incr	lineIndex 25
			set count 1
			while {$count} {
				section -collapsed "Help screen" {
					set count [lindex $lines $lineIndex]
					ascii 1 "Lines"
					move 1
					foreach line [lrange $lines [expr $lineIndex+1] [expr $lineIndex+$count]] {
						entry 0 $line [string length $line] [pos]
						move [expr [string length $line]+1]
					}
					incr lineIndex [expr $count+1]
				}
			}
		}
		endsection
	} elseif {$head == "\xf3\x47\xbf\xaf"} {
		section -collapsed "Data"
		set	start [pos]
		hex	4 NoteFolio
		hex	4 NULLs
		ascii	8 Name
		uint16	Size
		hex	6 Unknown
		cstr	ascii Text
		if {$datasize+$start-[pos] != 0} {
			bytes	[expr $datasize-[pos]+$start] Unknown
		}
		endsection
	} elseif {$datasize > 0} {
		bytes	$datasize "Data"
	} else {
		entry	"Data" ""
	}
}
