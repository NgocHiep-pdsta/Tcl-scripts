proc load_drc {filename} {
    if {[catch {open $filename r} f]} { return "FAILED" }
    set violations {}
    while {[gets $f line] >= 0} {
        if {[string match "#*" $line] || [string trim $line] eq ""} {
          continue 
        }
        if {[scan $line "%s %s %d" rule layer cnt] != 3} {
          continue
        }
        lappend violations [list $rule $layer $cnt]
    }
    close $f
    return $violations
}

proc summarize_drc {violations} {
    array set by_rule  {}
    array set by_layer {}
    set total_count 0

    foreach v $violations {
        lassign $v rule layer cnt
        incr total_count $cnt
        incr by_rule($rule) $cnt
        incr by_layer($layer) $cnt
    }

    set text "===== DRC SUMMARY =====\n"
    append text [format "Total violations: %d\n\n" $total_count]
    append text " --- By Rule Type ---\n"
    foreach r [lsort [array names by_rule]] {
        append text [format "  %-8s : %3d\n" $r $by_rule($r)]
    }
    append text "\n ----- By Layer -----\n"
    foreach l [lsort [array names by_layer]] {
        append text [format "    %-6s : %3d\n" $l $by_layer($l)]
    }
    return $text
}

proc print_drc_detail {violations} {
    set text [format "%-10s %-6s %-5s\n" "Rule" "Layer" "Count"]
    append text [string repeat "-" 24]
    append text "\n"
    foreach v $violations {
        lassign $v rule layer cnt
        append text [format "%-10s %-6s %-5s\n" $rule $layer $cnt]
    }
    return $text
}

set viols [load_drc "drc_report.rpt"]
if {$viols eq "FAILED"} {
    puts "ERROR: Cannot open drc_report.rpt"
    exit 1
}
puts [summarize_drc $viols]
puts [print_drc_detail $viols]
