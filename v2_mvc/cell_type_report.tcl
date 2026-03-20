proc cell_type_report {master_data} {
   array set total_by_type [dict get $master_data total_by_type]
   array set viol_by_type  [dict get $master_data viol_by_type] 
   set text "===== VIOLATIONS BY CELL TYPE =====\n"
   append text [format "%-12s %-10s %-10s" "Type" "Total" "Violated"]
   append text "\n" 
   append text "-----------------------------------\n"
   
   foreach t [lsort [array names total_by_type]] {
      set v [expr {[info exists viol_by_type($t)] ? $viol_by_type($t) : 0}]
      append text [format "%-12s %-10d %-10d\n" $t $total_by_type($t) $v]
   }
   return $text
}
   