set test_log [open [file join [file dirname [info script]] menu-alf.log] w]
set font_path [file normalize [file join [file dirname [info script]] .. resources menu.alf]]
set throttle off
set renderer none
set pause_on_lost_focus off
set pause off
set power on
set phase boot
set deadline 0

proc report {message} {
    global test_log
    puts $test_log $message
    flush $test_log
}

proc screen_text {} {
    set text ""
    set base [expr {[debug read memory 0xfcaf] == 1 ? 0x1800 : 0}]
    for {set position 0} {$position < 768} {incr position} {
        append text [format %c [debug read VRAM [expr {$base + $position}]]]
    }
    return $text
}

proc check_row {row codes} {
    set column 0
    foreach code $codes {
        set actual [debug read VRAM [expr {0x1800 + $row * 32 + $column}]]
        if {$actual != $code} { error "Glifo incorreto em $column,$row: $actual, esperado $code" }
        incr column
    }
}

proc tick {} {
    global phase deadline font_path
    set text [screen_text]
    if {[regexp -nocase {FALHOU|error|Redo|Out of|Illegal|Type mismatch|Undefined|Subscript|Duplicate|Overflow|Syntax|NEXT without|RETURN without} $text]} { error $text }
    if {$phase eq "boot"} {
        type_via_keybuf "\r"
        set phase basic
    } elseif {$phase eq "basic" && [string first "Ok" $text] >= 0} {
        type_via_keybuf "load\"menu-alf.amx\"\rrun\r"
        set phase result
    } elseif {$phase eq "result" && [string first "TODOS PASSARAM" $text] >= 0} {
        set codes {}
        for {set code 0} {$code < 32} {incr code} { lappend codes $code }
        check_row 0 $codes
        check_row 2 {24 25 26 27 23 22 18 17 20 19 21}
        check_row 3 {152 153 154 155 151 150 161 145 162 163 149}
        check_row 4 {129 130 131 132 133 156}
        check_row 5 {11 12 13 14 6 7 8 9}
        for {set code 32} {$code < 256} {incr code} {
            set actual [debug read VRAM [expr {0x1800 + 6 * 32 + $code - 32}]]
            set expected [expr {$code == 127 ? 32 : $code}]
            if {$actual != $expected} { error "Glifo imprimivel incorreto: $code -> $actual" }
        }
        set file [open $font_path rb]
        set font [read $file]
        close $file
        binary scan $font cu* bytes
        if {[llength $bytes] != 2055 ||
            [lrange $bytes 0 6] ne {254 0 146 255 153 0 146}} { error "Formato ALF inesperado" }
        for {set offset 0} {$offset < 2048} {incr offset} {
            debug write VRAM [expr {$offset}] [lindex $bytes [expr {7 + $offset}]]
        }
        for {set code 0} {$code < 256} {incr code} {
            for {set row 0} {$row < 8} {incr row} {
                set offset [expr {$code * 8 + $row}]
                set actual [debug read VRAM $offset]
                if {$actual != [lindex $bytes [expr {7 + $offset}]]} { error "Padrao ALF incorreto: $code" }
                if {$code == 32 || $code == 46 || ($code >= 48 && $code <= 63) ||
                    ($code >= 65 && $code <= 90) || ($code >= 97 && $code <= 122)} {
                    set inverse [debug read VRAM [expr {$offset + 128 * 8}]]
                    if {$inverse != ($actual ^ 255)} { error "Faixa nao e inversa: $code" }
                }
            }
        }
        report "PASS: mapa completo imprime sem controles; DEL vazio representado por espaco"
        report "PASS: quadros e logotipo MSX usam as pecas corretas"
        report "PASS: 2048 bytes ALF instalados na tabela de SCREEN 1"
        report "PASS: faixas inversas conferidas byte a byte"
        report "PASS: conversao, texto vazio e rejeicao de todos os codigos sem inverso"
        exit
    }
    incr deadline
    if {$deadline > 1800} { error "Tempo esgotado: $phase; $text" }
    after time 0.1 checked_tick
}

proc checked_tick {} {
    if {[catch tick message]} {
        report "FAIL: $message"
        exit 1
    }
}

report "Iniciando teste do mapa de caracteres"
after time 5 checked_tick
