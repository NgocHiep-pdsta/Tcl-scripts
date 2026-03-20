proc extract_slack {line} {
  if {[regexp {slack = ([-\d.]+)} $line _ val]} {
     return $val
  }
  return ""  
}

proc classify {slack} {
if {$slack < - 0.5}    {return "CRITICAL"}
if {$slack < 0}        {return "VIOLATED"}
if {$slack < 0.1}      {return "WARNING"}
if {$slack < 0.5} {return "BORDERLINE"}
  return "MET"
}

if {![file exists "timing.rpt"]} {
  puts "file not found"
  exit 1
}

set f [open "timing.rpt" r]
set results {}
while {[gets $f line] >= 0} {
  set slack [extract_slack $line]
  if {$slack eq ""} continue
  set parts [lsearch -all -inline -not [split $line] ""]
  lappend results [list [lindex $parts 0] $slack [classify $slack]]
}
close $f

set results [lsort -real -index 1 $results]

puts "========================================="
puts "        TIMING VIOLATION REPORT"
puts "========================================="
puts [format "%-15s %-10s %-10s" "Cell" "Slack" "Status"]
puts [string repeat "-" 35]

array set count {CRITICAL 0 BORDERLINE 0 VIOLATED 0 WARNING 0 MET 0}
foreach r $results {
   lassign $r cell slack status
   incr count($status)
   puts [format "%-15s %-10s %-10s" $cell $slack $status]
}

puts [string repeat "-" 35]
puts "SUMMARY: "
puts "  Critical  :  $count(CRITICAL)"
puts "  BORDERLINE:  $count(BORDERLINE)"
puts "  Violated  :  $count(VIOLATED)"
puts "  Warning   :  $count(WARNING)" 
puts "  Met       :  $count(MET)"

set fout [open "summary.rpt" w]
puts $fout "Critical   : $count(CRITICAL)"
puts $fout "BORDERLINE : $count(BORDERLINE)"
puts $fout "Violated   : $count(VIOLATED)"
puts $fout "Warning    : $count(WARNING)"
puts $fout "Met        : $count(MET)"
close $fout
puts "\n -> Đã ghi vào summary.rpt"



