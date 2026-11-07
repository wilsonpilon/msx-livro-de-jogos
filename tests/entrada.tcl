# Run with openMSX -machine Gradiente_Expert_DD_Plus -diska tests -script tests\entrada.tcl
set test_log [open [file join [file dirname [info script]] entrada.log] w]
proc report {message} {
    global test_log
    puts $test_log $message
    flush $test_log
}
report "Iniciando testes"
set throttle off
set renderer none
set pause_on_lost_focus off
set pause off
set power on
report "Emulacao ativa"
set test_samples [list \
    "abcd\x1d\x1dX\r" \
    "abcd\x1d\x1d\x1d\x12X\r" \
    "abcd\x1d\x1d\x7f\x08\r" \
    "abcd\x1d\x1d\x1d\x12X\x12Y\r" \
    "12345678\x12X\x1c\r" \
    "\x1d\x08\x7f\r" \
    "a b!?~\r" \
    "-12,5\r" \
    "+3.25\r" \
    "a12.3.4\x08\r" \
    "\r-\r\x08.\r\x080\r" \
    "12\x1d\x1d\x7f\r" \
    "\xe9\":\r" \
    "123456789\r" \
    "12345678\x1dX\r"]
# Case 11 must not accept empty input, a sign, or a decimal point alone.
set case_index 0
set deadline 0
set phase boot

proc screen_text {} {
    set text ""
    for {set pos 0} {$pos < 960} {incr pos} {
        append text [format %c [debug read VRAM $pos]]
    }
    return $text
}

proc fail {message} {
    report "FAIL: $message"
    exit 1
}

proc tick {} {
    global phase case_index test_samples deadline
    set text [screen_text]
    if {[string first "FALHOU" $text] >= 0 ||
        [string first "INCORRETO" $text] >= 0 ||
        [string first "error" $text] >= 0 ||
        [string first "Redo" $text] >= 0} {
        fail $text
    }
    if {$phase eq "boot"} {
        type_via_keybuf "\r"
        set phase basic
    } elseif {$phase eq "basic" && [string first "Ok" $text] >= 0} {
        type_via_keybuf "load\"entrada.amx\"\rrun\r"
        set phase field
    } elseif {$phase eq "field" && [string first "ANTES>" $text] >= 0} {
        type_via_keybuf [lindex $test_samples $case_index]
        set phase result
    } elseif {$phase eq "result" && [string first "PASSOU" $text] >= 0} {
        if {[string range $text 203 209] ne "\x16ANTES>" ||
            [string range $text 218 225] ne "<DEPOIS\x16"} {
            fail "Moldura alterada no caso [expr {$case_index + 1}]"
        }
        report "PASS: caso [expr {$case_index + 1}] e moldura intacta"
        incr case_index
        type_via_keybuf " "
        set phase next
    } elseif {$phase eq "next"} {
        if {$case_index == [llength $test_samples] && [string first "TODOS PASSARAM" $text] >= 0} {
            report "PASS: todos os 15 casos no MSX-BASIC"
            report "PASS: campo fora das 32 colunas rejeitado em SCREEN 1"
            exit
        }
        if {$case_index < [llength $test_samples] && [string first "PASSOU" $text] < 0} {
            set phase field
        }
    }
    incr deadline
    if {$deadline > 600} { fail "Tempo esgotado: $phase, caso $case_index, $text" }
    after time 0.1 checked_tick
}
proc checked_tick {} {
    if {[catch tick message]} { fail $message }
}
after time 5 checked_tick
