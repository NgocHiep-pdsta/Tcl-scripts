proc main {} {
   source "parser_master_timing.tcl"
   source "cell_type_report.tcl"
   source "timing_summary_report.tcl"
   source "hold_report.tcl"

   set file "timing.rpt"
   set hold_file "hold_timing.rpt"
   set f_detail [open "detail_timing.rpt" w]
   puts "... Dang phan tich File: $file ..."

   set master_data [parser_master_timing $file $hold_file $f_detail]
   if {$master_data eq "FAILED"} {
     puts "ERROR: NOT FOUND PATH DATA"
     close $f_detail
     return
   }
   
   set cell_report [cell_type_report $master_data]
   set summary_report [timing_summary_report $master_data]
   set hold_report [hold_report $master_data]
   puts $cell_report
   puts $summary_report
   puts $hold_report
   
   close $f_detail
}
main

