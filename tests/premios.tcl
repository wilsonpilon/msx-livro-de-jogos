set test_log [open [file join [file dirname [info script]] premios.log] w]
set renderer none
set throttle off
set pause_on_lost_focus off
set pause off
set power on
set phase boot
set deadline 0

proc tick {} {
    global phase deadline test_log
    set text ""
    for {set pos 0} {$pos < 960} {incr pos} {
        append text [format %c [debug read VRAM $pos]]
    }
    if {[string first "FALHOU" $text] >= 0 || [string first "error" $text] >= 0} {
        puts $test_log "FAIL: $text"
        flush $test_log
        exit 1
    }
    if {$phase eq "boot"} {
        type_via_keybuf "\r"
        set phase basic
    } elseif {$phase eq "basic" && [string first "Ok" $text] >= 0} {
        type_via_keybuf "load\"premios.bmx\"\rrun\r"
        set phase results
    } elseif {$phase eq "results" && [string first "TODOS OS PREMIOS PASSARAM" $text] >= 0} {
        puts $test_log "PASS: 25 casos de prioridade e todas as 729 combinacoes no MSX-BASIC; soma 672"
        flush $test_log
        exit
    }
    incr deadline
    if {$deadline > 6000} {
        puts $test_log "FAIL: tempo esgotado: $text"
        flush $test_log
        exit 1
    }
    after time 0.1 tick
}
after time 5 tick
