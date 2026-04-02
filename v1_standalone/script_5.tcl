proc classify_skew {skew_ps} {
  if {$skew_ps <= 50}  {return "GOOD_SKEW"}
  if {$skew_ps <= 150} {return "OK_SKEW"}
  if {$skew_ps <= 300} {return "TIGHT_SKEW"}
  return "BAD_SKEW"
}

proc load_clock_data {filename} {
  if {[catch {open $filename r} f]} {
    return "FAILED"
  }
  set data {}
  while {[gets $f line] >= 0} {
    if {[string match "#*" $line]} {
      continue
    }
    if {[scan $line "%s %s %d" ff domain arrival] != 3} {
      continue
    }
    lappend data [list $ff $domain $arrival]
  }
  close $f
  return $data
}

proc calc_skew_by_domain {data} {
  array set arrivals {}
  foreach e $data {
    lassign $e ff domain arrival
    lappend arrivals($domain) $arrival
  }
  set result {}
  foreach domain [lsort [array names arrivals]] {
    set arr [lsort -integer $arrivals($domain)]
    set count [llength $arr]
    if {$count < 2} {
      lappend result [list $domain [lindex $arr 0] [lindex $arr 0] 0 "SINGLE_FF"]
      continue
    }
    set mn [lindex $arr 0]
    set mx [lindex $arr end]
    set skew [expr {$mx - $mn}]
    set skew_status [classify_skew $skew]
    lappend result [list $domain $skew $mn $mx $skew_status]
  }
  return $result
}


proc print_skew_report {skew_report} {
  set text [string repeat "-" 18] 
  append text " CLOCK SKEW ANALYSIS " 
  append text [string repeat "-" 18]
  puts $text
  puts [format "%-12s  %-8s  %-8s  %-8s  %s" "  Domain" "Min(ps)" "Max(ps)" "Skew(ps)" "Status"]
    puts [string repeat "-" 58]
    foreach e $skew_report {
      lassign $e domain skew mn mx status
      puts [format "%-12s  %-8d  %-8d  %-8d  %s" $domain $mn $mx $skew $status]
    }
  puts [string repeat "-" 58]
}
 
proc write_skew_report {skew_report outfile} {
  if {[catch {open $outfile w} fout]} {
        return "FAILED"
  }
  set text [string repeat "-" 18] 
  append text " CLOCK SKEW ANALYSIS " 
  append text [string repeat "-" 18]
  puts $fout $text
  puts $fout [format "%-12s  %-8s  %-8s  %-8s  %s" "  Domain" "Min(ps)" "Max(ps)" "Skew(ps)" "Status"]
  puts $fout [string repeat "-" 58]
  foreach e $skew_report {
    lassign $e domain skew mn mx status
    puts $fout [format "%-12s  %-8d  %-8d  %-8d  %s" $domain $mn $mx $skew $status]
    }
    close $fout
}

set data [load_clock_data "clock_timing.rpt"]
if {$data eq "FAILED"} {
    puts "ERROR: Cannot open clock_timing.rpt"
    exit 1
}
if {[llength $data] == 0} {
    puts "WARNING: No valid entries found"
    exit 0
}

set skew_rep [calc_skew_by_domain $data]
print_skew_report $skew_rep
write_skew_report $skew_rep "skew_report.txt"
puts "\n-> Written: skew_report.txt"
