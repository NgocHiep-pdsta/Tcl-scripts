proc classify {slack} {
   if {$slack < -0.5} {return "CRITICAL"}
   if {$slack < 0}    {return "VIOLATED"}
   if {$slack < 0.1}  {return "WARNING"}
   if {$slack < 0.5}  {return "BORDERLINE"}
   return "MET"
}
 
proc analyze_hold {filename} {
  if {[catch {open $filename r} f]} {
    return "FAILED"
  }

  set violated_list {}
  set total 0
  set violated 0
  set hold_tns 0.0
  while {[gets $f line] >= 0} { 
    if {[scan $line "%s slack=%f" cell slack] != 2} { 
      continue
    }
    incr total
    if {$slack < 0} {
      incr violated
      lappend violated_list [list $cell $slack]
      set hold_tns [expr {$hold_tns + $slack }]
    }
  }
  close $f
  dict set result hold_data [list $total $violated $violated_list $hold_tns]
  return $result
}
proc parser_master_timing {filename hold_filename timing_details} {
    array set count {CRITICAL 0 VIOLATED 0 WARNING 0 BORDERLINE 0 MET 0}
    array set total_by_type {}
    array set viol_by_type {}
    set worst_5 {}
    set total_paths 0
    set wns ""
    set tns 0.0
    
    
   if {[catch {open $filename r} f]} {
      return "FAILED"
   }
   
   while {[gets $f line] >= 0} {
      if {[scan $line "%s slack=%f" cell slack] != 2} { continue }
      set status [classify $slack]
      incr count($status)
      incr total_paths
      lappend worst_5 [list $cell $slack $status]
      if {[llength $worst_5] > 5} {
        set worst_5 [lsort -real -index 1 $worst_5]
        set worst_5 [lrange $worst_5 0 4]
      }
      if {$wns eq "" || $slack < $wns } {
         set wns $slack
      }
      if {$slack < 0} {
         set tns [expr {$tns + $slack }]
      }
      if {[regexp {U_([A-Z0-9]+)_} $cell m type]} {
         incr total_by_type($type)
         if {$slack < 0} {
            incr viol_by_type($type)
      puts $timing_details [format "%-12s %10.5g %-10s" $cell $slack $status]
      }
   }
   }

   set hold_result [analyze_hold $hold_filename]
   if {$hold_result eq "FAILED"} {
     dict set result hold_data [list 0 0 {} 0]
   } else {
   dict set result hold_data [dict get $hold_result hold_data]
   }
   dict set result total_paths $total_paths
   dict set result count_array [array get count]
   dict set result total_by_type [array get total_by_type]
   dict set result viol_by_type [array get viol_by_type]
   dict set result wns $wns
   dict set result tns $tns
   dict set result worst_5 $worst_5

   return $result
}
