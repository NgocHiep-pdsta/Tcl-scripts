# Tcl Timing Analysis Scripts

Tcl scripts for parsing and analyzing timing reports (setup + hold) in VLSI/ASIC design flow.

## Structure

### v1_standalone/
Early standalone scripts — each script handles one task independently.

- `script_1.tcl` — Parse timing.rpt, classify paths, generate violation report
- `script_2.tcl` — Count violations by cell type
- `script_3.tcl` — Calculate WNS/TNS, generate timing summary
- `script_4.tcl` — Analyze hold timing violations

### v2_mvc/
Refactored into modular architecture — single dict-based data contract between Parser, Controller, and Formatters.

- `parser_master_timing.tcl` — Parser: reads setup + hold files, classifies paths, calculates WNS/TNS, packs into dict
- `run_master_timing.tcl` — Controller: coordinates Parser and Formatters, handles errors
- `cell_type_report.tcl` — Formatter: violations by cell type
- `timing_summary_report.tcl` — Formatter: timing summary with WNS/TNS
- `hold_report.tcl` — Formatter: hold timing violations

## Why this structure?
- Separation of concerns: Parser only collects data, Controller only coordinates, Formatters only display
- Error handling: Parser returns FAILED flag, Controller decides to stop or continue
- Extensible: adding new report types only requires a new Formatter file

## Tools
- Language: Tcl 8.6
- Input: timing report files (slack-based format)
