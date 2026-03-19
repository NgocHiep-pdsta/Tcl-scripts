
proc hold_report {master_data} {
  set hold_data [dict get $master_data hold_data]
  lassign $hold_data total violated vlist
  set text "===== HOLD TIMING REPORT =====\n"
  append text "  TOTAL: $total | VIOLATED: $violated \n"
  append text "---------------------------------\n"
  foreach v [lsort -real -index 1 $vlist] { 
    lassign $v cell sf
    append text [format "%-10s  slack=%-8.3f  %s\n" $cell $sf [classify_hold $sf]]
  }
  return $text
}
