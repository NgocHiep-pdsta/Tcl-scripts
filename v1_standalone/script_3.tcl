proc classify {slack} {
   if {$slack < -0.5} {return "CRITICAL"}
   if {$slack < 0}    {return "VIOLATED"}
   if {$slack < 0.1}  {return "WARNING"}
   if {$slack < 0.5}  {return "BORDERLINE"}
   return "MET"
}
proc parse_timing_report {filename} {
   array set count {CRITICAL 0 VIOLATED 0 WARNING 0 BORDERLINE 0 MET 0}
   set total 0
   set tns 0.0
   set wns ""
   if {[catch {open $filename r} f]} {
      puts "ERROR: he thong tu choi mo file $filename"
      puts "Ly do: $f"
      return "FAILED"
   }
   while {[gets $f line] >= 0} {
      if {![regexp {^(\S+).*?slack\s*=\s*([-\d.]+)} $line match cell slack]} {
         continue
      }
      set status [classify $slack]
      incr count($status)
      incr total
      if {$wns eq "" || $slack < $wns} {
         set wns $slack
      }
      if {$slack < 0} {
         set tns [expr {$tns + $slack}]
      }
   }
   close $f
   return [list $total [array get count] $wns $tns]
}   

proc generate_summary_text {data} {
   set total [lindex $data 0]
   array set count [lindex $data 1]
   set wns [lindex $data 2]
   set tns [lindex $data 3]
   set text ""
   append text "===== TIMING SUMMARY =====\n"
   append text [format "      Total path: %d\n" $total]
   append text "\n"
   if {$total > 0} {
      foreach cat {CRITICAL VIOLATED WARNING BORDERLINE MET} {
         set pct [expr {$count($cat) * 100.0 / $total}]
         append text [format " %-12s : %3d (%5.1f%%)\n" $cat $count($cat) $pct]
      }
   append text "=========================\n"
      append text [format " WNS : %.3f ns\n" $wns]
      append text [format " TNS : %.3f ns\n" $tns]
      append text "=========================\n"
   }
return $text
}

proc print_summary {filename} {
   set data [parse_timing_report $filename]
   if {$data eq "FAILED"} return
   set text [generate_summary_text $data]
   puts $text
}

proc write_summary_file {input_rpt output_rpt} {
   set data [parse_timing_report $input_rpt]
   if {$data eq "FAILED"} return
   set text [generate_summary_text $data] 
   if {[catch {open $output_rpt w} f]} {
      puts "ERROR: he thong tu choi mo file $output_rpt"
      puts "Ly do: $f"
      return "FAILED"
   }
   puts $f "$text"
   close $f
   puts " Da xuat bao cao thanh cong ra file -> $output_rpt"
}

puts "Đang xu ly bao cao..."
print_summary "timing.rpt"
write_summary_file "timing.rpt" "timing_summary.rpt"
print_summary "clean.rpt"
write_summary_file "clean.rpt" "clean_summary.rpt"

  

  
