
proc hold_report {master_data} {
  set hold_data [dict get $master_data hold_data]
  lassign $hold_data total violated vlist
  set text "TOTAL: $total | VIOLATED: $violated"
  append text "\n"
  foreach v [lsort -real -index 1 $vlist] { 
    lassign $v cell sf
    append text [format " %-12s  slack=%-8.3f  %s\n" $cell $sf [classify_hold $sf]]
  }
  return $text
}