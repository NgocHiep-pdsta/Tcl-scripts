proc timing_summary_report {master_data} {
   set total_path [dict get $master_data total_paths]
   array set count [dict get $master_data count_array]
   set wns [dict get $master_data wns]
   set tns [dict get $master_data tns]
   set text "===== TIMING SUMMARY REPORT =====\n"
   append text [format "        Total path: %d\n" $total_path]
   append text "\n"
   if {$total_path > 0} {
      foreach z {CRITICAL VIOLATED WARNING BORDERLINE MET} {
         set x [expr {$count($z) * 100.0 / $total_path}]
         append text [format "%-12s : %3d (%5.1f%%)\n" $z $count($z) $x]
      }
   append text "=================================\n"
   append text [format "      WNS : %.3f ns\n" $wns]
   append text [format "      TNS : %.3f ns\n" $tns]
   append text "=================================\n"
   }
   return $text
}
