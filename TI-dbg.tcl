# Debugging wrapper for TI.tcl
# Version 1.0
# (c) 2021-2026 LogicalJoe
# Remove this line to use:
# .hidden = true;

if [catch {
	source [file join [file dirname [file normalize [info script]]] TI.tcl]
}] {
	set a $errorInfo
	if [catch {
		while 1 endsection
	}] { }
	entry "Template parsing failed:" "$a"
	foreach r [lrange [split $a "\n"] 1 end] {
		entry "" $r
	}
}
