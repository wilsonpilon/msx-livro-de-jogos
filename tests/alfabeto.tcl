set test_log [open [file join [file dirname [info script]] alfabeto.log] w]
set root [file normalize [file join [file dirname [info script]] ..]]
set disk_path [file join $root examples]
set font_file [open [file join $root resources menu.alf] rb]
binary scan [read $font_file] cu* original
close $font_file
set patterns [lrange $original 7 end]
set throttle off
set renderer none
set pause_on_lost_focus off
set pause off
set power on
set phase boot
set deadline 0
set sample_index 0
set test_samples {{1 0} {0 0} {2 0} {2 1} {0 1} {1 1}}

proc report {message} {
    global test_log
    puts $test_log $message
    flush $test_log
}

proc row_text {row} {
    set mode [debug read memory 0xfcaf]
    set base [expr {$mode == 0 ? 0 : 0x1800}]
    set width [expr {$mode == 0 ? 40 : 32}]
    set text ""
    for {set column 0} {$column < $width} {incr column} {
        append text [format %c [debug read VRAM [expr {$base + $row * $width + $column}]]]
    }
    return $text
}

proc screen_text {} {
    set text ""
    for {set row 0} {$row < 24} {incr row} { append text [row_text $row] }
    return $text
}

proc check_frame_pixels {mode} {
    set cell_width [expr {$mode == 0 ? 6 : 8}]
    set width [expr {$mode == 0 ? 40 : 32}]
    set names [expr {$mode == 0 ? 0 : 0x1800}]
    set left [expr {6 * $cell_width + 3}]
    set right [expr {25 * $cell_width + 3}]
    set top 19
    set bottom 155
    for {set row 2} {$row <= 19} {incr row} {
        for {set column 6} {$column <= 25} {incr column} {
            if {$row != 2 && $row != 19 && $column != 6 && $column != 25} { continue }
            set code [debug read VRAM [expr {$names + $row * $width + $column}]]
            set base [expr {$mode == 0 ? 0x800 : ($mode == 2 ? ($row / 8) * 2048 : 0)}]
            for {set line 0} {$line < 8} {incr line} {
                set pattern [debug read VRAM [expr {$base + $code * 8 + $line}]]
                set y [expr {$row * 8 + $line}]
                for {set pixel 0} {$pixel < $cell_width} {incr pixel} {
                    set x [expr {$column * $cell_width + $pixel}]
                    set expected [expr {
                        ($y == $top && $x >= $left && $x <= $right) ||
                        ($x == $left && $y >= $top && $y <= $bottom) ||
                        ($x == $right && $y >= $top && $y <= $bottom + 1) ||
                        ($y == $bottom && $x >= $left && $x <= $right + 1) ||
                        ($x == $right + 1 && $y >= $top + 2 && $y <= $bottom + 1) ||
                        ($y == $bottom + 1 && $x >= $left + 2 && $x <= $right + 1)
                    }]
                    set actual [expr {($pattern & (128 >> $pixel)) != 0}]
                    if {$actual != $expected} { error "Borda/sombra incorreta: SCREEN $mode, pixel $x,$y" }
                }
            }
        }
    }
}

proc check_demo {mode original_font} {
    global patterns
    if {[debug read memory 0xfcaf] != $mode} { return 0 }
    set file [expr {$original_font ? "MENU.ALF" : "ALFABETO.BIN"}]
    if {[string first "Fonte: $file" [row_text 21]] < 0} { return 0 }
    if {[string first "GRAPHOS III - SCREEN $mode" [row_text 0]] < 0} { error "Titulo incorreto" }
    set base [expr {$mode == 0 ? 0x800 : 0}]
    set banks [expr {$mode == 2 ? 3 : 1}]
    for {set bank 0} {$bank < $banks} {incr bank} {
        for {set offset 0} {$offset < 2048} {incr offset} {
            set actual [debug read VRAM [expr {$base + $bank * 2048 + $offset}]]
            if {$actual != [lindex $patterns $offset]} { error "Padrao incorreto: SCREEN $mode, banco $bank, byte $offset" }
        }
    }
    set names [expr {$mode == 0 ? 0 : 0x1800}]
    set width [expr {$mode == 0 ? 40 : 32}]
    for {set code 0} {$code < 256} {incr code} {
        set address [expr {$names + (3 + $code / 16) * $width + 8 + $code % 16}]
        set actual [debug read VRAM $address]
        set expected [expr {$code == 127 && $mode != 2 ? 32 : $code}]
        if {$actual != $expected} { error "Atlas incorreto: SCREEN $mode, glifo $code -> $actual" }
    }
    foreach {column code} {26 11 27 12 28 13 29 14} {
        if {[debug read VRAM [expr {$names + $column}]] != $code} { error "Logotipo MSX incorreto" }
    }
    foreach {row column code} {2 6 24 2 25 1 19 6 3 19 25 5} {
        if {[debug read VRAM [expr {$names + $row * $width + $column}]] != $code} { error "Moldura incorreta" }
    }
    check_frame_pixels $mode
    if {$mode == 2} {
        for {set offset 0} {$offset < 6144} {incr offset} {
            if {[debug read VRAM [expr {0x2000 + $offset}]] != 244} { error "Cores incorretas em SCREEN 2" }
        }
    }
    report "PASS: SCREEN $mode, $file, atlas, MSX, borda fina com sombra solida pixel a pixel e $banks banco(s)"
    return 1
}

proc tick {} {
    global phase deadline disk_path patterns sample_index test_samples
    set previous $phase
    set text [screen_text]
    if {[regexp -nocase {error|Redo|Out of|Illegal|Type mismatch|Undefined|Subscript|Duplicate|Overflow|Syntax|NEXT without|RETURN without|File not found} $text]} { error $text }
    if {$phase eq "boot"} {
        type_via_keybuf "\r"
        set phase basic
    } elseif {$phase eq "basic" && [string first "Ok" $text] >= 0} {
        type_via_keybuf "load\"alfabeto.amx\"\rrun\r"
        set phase generating
    } elseif {$phase eq "generating" && [string first "SALVO ALFABETO.BIN" $text] >= 0} {
        diska eject
        set file [open [file join $disk_path alfabeto.bin] rb]
        binary scan [read $file] cu* bytes
        close $file
        if {[llength $bytes] != 2055 || [lrange $bytes 0 6] ne {254 0 0 255 7 0 0}} { error "Cabecalho BIN incorreto" }
        if {[lrange $bytes 7 end] ne $patterns} { error "DATA nao preservou os 2048 bytes do Graphos" }
        report "PASS: BASIC gerou ALFABETO.BIN com endereco 0 e os 256 caracteres originais"
        diska $disk_path
        type_via_keybuf "load\"demoalf.amx\"\rrun\r"
        set phase demo
    } elseif {$phase eq "demo"} {
        lassign [lindex $test_samples $sample_index] mode original_font
        if {[check_demo $mode $original_font]} {
            incr sample_index
            if {$sample_index == [llength $test_samples]} {
                type_via_keybuf [format %c 27]
                set phase exit
            } else {
                lassign [lindex $test_samples $sample_index] next_mode next_original
                if {$next_original != $original_font} {
                    type_via_keybuf "L"
                } else {
                    type_via_keybuf $next_mode
                }
            }
            set deadline 0
        }
    } elseif {$phase eq "exit" && [debug read memory 0xfcaf] == 0 && [string first "Ok" $text] >= 0} {
        if {[debug read memory 0xf3b0] != 40 || [debug read memory 0xf3ea] != 1} { error "ESC nao restaurou o BASIC" }
        report "PASS: ESC restaura SCREEN 0 e o BASIC"
        exit
    }
    if {$phase ne $previous} { set deadline 0 } else { incr deadline }
    set limit [expr {$phase eq "generating" ? 6000 : 1200}]
    if {$deadline > $limit} { error "Tempo esgotado: $phase; $text" }
    after time 0.1 checked_tick
}

proc checked_tick {} {
    if {[catch tick message]} {
        report "FAIL: $message"
        exit 1
    }
}

report "Iniciando teste de geracao e BLOAD nos tres modos"
after time 5 checked_tick
