proc get_wns_from_file {filename} {
    set wns ""
    if {[catch {open $filename r} f]} { return "N/A" }
    while {[gets $f line] >= 0} {
        if {[string match "#*" $line]} { continue }
        if {[scan $line "%s corner=%s slack=%f" path corner slack] != 3} { continue }
        if {$wns eq "" || $slack < $wns} {
            set wns $slack
        }
    }
    close $f
    if {$wns eq ""} { return "N/A" }
    return $wns
}

proc build_mmmc_matrix {corner_files} {
    set text "========== MMMC WNS MATRIX ==========\n"
    append text [format "%-15s  %-8s  %s\n" "Corner File" "WNS(ns)" "Status"]
    append text [string repeat "-" 45]
    append text "\n"
    foreach fname $corner_files {
        set wns [get_wns_from_file $fname]
        if {$wns eq "N/A"} {
            set flag "N/A"
            append text [format "%-15s  %-8s  %s\n" $fname "N/A" $flag]
        } else {
            set flag [expr {$wns < 0 ? "VIOLATED" : "OK"}]
            append text [format "%-15s  %+6.3f  %s\n" $fname $wns $flag]
        }
    }
    append text [string repeat "-" 45]
    append text "\n"
    return $text
}

puts [build_mmmc_matrix {timing_SS.rpt timing_FF.rpt timing_TT.rpt}]
