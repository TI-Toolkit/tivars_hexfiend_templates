# TI-ROM verification HexFiend template
# Version 1.0
# (c) 2021-2023 LogicalJoe

set hl 0
set hl2 0
set a 0

while {[incr a]<[len]-1} {
	# get the next byte
	set c [uint8]
	#1.6K+
	incr hl2 $c
	#1.5K-
	set hl [expr ((4129*((($hl>>12)^($hl>>8))&15))^(528*($hl>>12))^($hl<<8)^$c)&65535]
}
entry "TI-81 hash 1.5K-:" [format %04X $hl]
entry "TI-81 hash 1.6K+:" [format %04X [expr 65535&-$hl2]]
entry "TI-81 hash curnt:" [format %04X [uint16]] 2 [expr [len]-2]
move -2
entry "checksum:" [format %02X [expr 255&($hl2+[uint8]+[uint8])]]
# TI-82 19.006 doubles the checksum so valid ROMs return 0x80
