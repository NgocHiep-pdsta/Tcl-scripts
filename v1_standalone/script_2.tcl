if {![file exists "timing.rpt"]} {
   puts "ERROR: timing.rpt not found!"
   exit 1
}

set total_paths 0
set f [open "timing.rpt" r]
while {[gets $f line] >=0} {
   if {[scan $line "%s slack=%f" cell slack] != 2} { 
      continue   
      }
   incr total_paths
   if {[regexp {U_([A-Z0-9]+)_} $cell m type]} {
      incr total_by_type($type)
      if {$slack < 0} {
         incr viol_by_type($type)
       }
   }
}
close $f
set text "===== VIOLATIONS BY CELL TYPE =====\n"
   append text [format "%-12s %-10s %-10s" "Type" "Total" "Violated"]
   append text "\n" 
   append text "-----------------------------------\n"
   
foreach t [lsort [array names total_by_type]] {
   set v [expr {[info exists viol_by_type($t)] ? $viol_by_type($t) : 0}]
   append text [format "%-12s %-10d %-10d\n" $t $total_by_type($t) $v]
   }
puts $text
puts "===== TOTAL PATHS : $total_paths ====="


