proc classify_hold {slack} {
  if {$slack < 0} {return "HOLD_VIOLATION"}
  return "HOLD_MET"
}

proc analyze_hold {filename} {
  if {![file exists $filename]} {
     puts "ERROR: $filename not found" 
     return {}
  }
  set f [open $filename r]
  set violated_list {}
  set total 0
  set violated 0
  while {[gets $f line] >= 0} { 
    if {[scan $line "%s slack=%f" m val] != 2} { 
      continue
    }
    set sf [expr {double($val)}]
    incr total
    if {$sf < 0} {
      incr violated
      regexp {^(\S+)} $line m cell
      lappend violated_list [list $cell $sf]
    }
  }
  close $f
  return [list $total $violated $violated_list]  
}

lassign [analyze_hold "hold_timing.rpt"] total violated vlist
puts "Total: $total | Violated: $violated"
foreach v [lsort -real -index 1 $vlist] {
  lassign $v cell sf
  puts [format "  %-12s  slack=%-8.3f  %s" $cell $sf [classify_hold $sf]]
}