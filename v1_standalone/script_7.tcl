proc extract_ocv_entry {line} {
    if {[string match "#*" $line]} { return {} }
    if {[scan $line "%s %f %f %f" name nominal derate ocv] != 4} { return {} }
    return [list $name $nominal $derate $ocv]
}

proc analyze_ocv_impact {filename} {
    if {[catch {open $filename r} f]} { return "FAILED" }
    set paths {}
    while {[gets $f line] >= 0} {
        set e [extract_ocv_entry $line]
        if {[llength $e] > 0} { lappend paths $e }
    }
    close $f

    set text "========== OCV DERATING ANALYSIS ==========\n"
    append text [format "%-12s  %8s  %-6s  %6s  %6s\n" \
          "Path" "Nominal" "Derate" "OCV" "Flag"]
    append text [string repeat "-" 55]
    append text "\n"

    set new_viol 0
    foreach p $paths {
        lassign $p name nominal derate ocv
        if {$nominal >= 0 && $ocv < 0} {
            set flag "NEW_VIOLATION"; incr new_viol
        } elseif {[expr {$ocv - $nominal}] < -0.05} {
            set flag "DEGRADED"
        } else {
            set flag "OK"
        }
        append text [format "%-12s  %8.3f  %-6.2f  %7.3f  %s\n" \
              $name $nominal $derate $ocv $flag]
    }
    append text [string repeat "-" 55]
    append text "\n"
    append text "New violations due to OCV: $new_viol\n"
    return $text
}

set result [analyze_ocv_impact "ocv_timing.rpt"]
if {$result eq "FAILED"} {
    puts "ERROR: Cannot open ocv_timing.rpt"
    exit 1
}
puts $result
