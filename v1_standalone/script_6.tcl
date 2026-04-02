# Tao ham ktra loc cac dong header co #*, dong trong va cac dong scan != 3
proc parse_drc_line {line} {
  if {[string match "#*" $line] || [string trim $line] eq ""} {
    return {}
  }
  if {[scan $line "%s %s %d" rule layer cnt] != 3} {
    return {}
  }
  return [list $rule $layer $cnt]
}

# Tao ham doc file va dung parse_dcr_line de lay data roi tra ve bien violations
proc load_drc {filename} {
  if {[catch {open $filename r} f]} {
    return "FAILED"
  }
  set violations {}
  while {[gets $f line] >= 0} {
    set data [parse_drc_line $line]
    if {$data ne {}} {
      lappend violations $data
    }
  }
  close $f
  return $violations
}

# Raw text -> list {rule layer cnt}

proc summarize_drc {violations} {
  array set by_rule {}
  array set by_layer {}
  set total_count 0
 
  foreach v $violations {
    lassign $v rule layer cnt
    set c [expr {int($cnt)}]
    incr total_count $c
    incr by_rule($rule) $c
    incr by_layer($rule) $c
  }
  
  set text " ===== DRC SUMMARY =====\n"
  append text [format "Total violations: %d\n\n" $total_count]
  append text "By Rule Type: \n"
  foreach r [lsort [array names by_rule]] {
    append text [format "  %-15s : %d\n" $r $by_rule($r)]
  }
  append text "\nBy Layer: \n"
  foreach l [lsort [array names by_layer]] {
    append text [format "  %-5s : %d\n" $l $by_layer($l)]
  }
  return $text
}

proc print_drc_detail {violations} {
  set text [format "%-12s %-6s %-5s\n" "Rule" "layer" "Count"]
  append text [string repeat "-" 26]
  append text "\n"
  foreach v $violations {
    lassign $v rule layer cnt
    append text [format "%-12s %-6s %-5s\n" $rule $layer $cnt]
  }
  return $text
}

set viols [load_drc "drc_report.rpt"]
if {$viols eq "FAILED"} {
  puts "ERROR: can not open drc_report.rpt"
  exit 1
}
puts [summarize_drc $viols]
puts [print_drc_detail $viols]
