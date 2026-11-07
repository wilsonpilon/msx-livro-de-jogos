set test_log [open [file join [file dirname [info script]] menu.log] w]
set font_file [open [file join [file dirname [info script]] .. examples alfabeto.bin] rb]
binary scan [read $font_file] cu* font_bytes
close $font_file
set font_patterns [lrange $font_bytes 7 end]
set throttle off
set renderer none
set pause_on_lost_focus off
set pause off
set power on
set phase boot
set deadline 0
set date_sent 0
set titles {{Cassino} {Batalha naval} {Gorks} {Vinte e um} {Roleta} {Eletricista louco} {Frogger} {Tubarao} {Cemiterio} {Formula um} {Poker profiss.} {Trem maluco} {Caple} {F. Interlagos} {Labirinto 3D}}

proc report {message} {
    global test_log
    puts $test_log $message
    flush $test_log
}

proc raw_screen {} {
    set text ""
    set base 0
    set cells 960
    if {[debug read memory 0xfcaf] == 1} { set base 0x1800; set cells 768 }
    for {set position 0} {$position < $cells} {incr position} {
        append text [format %c [debug read VRAM [expr {$base + $position}]]]
    }
    return $text
}

proc screen_text {} {
    set text ""
    foreach character [split [raw_screen] ""] {
        scan $character %c code
        if {$code >= 160} { set code [expr {$code - 128}] }
        append text [format %c $code]
    }
    return $text
}

proc check_menu {selection file} {
    global titles font_patterns
    if {[string first "Arquivo: $file" [screen_text]] < 0} { return 0 }
    if {[debug read memory 0xfcaf] != 0 || [debug read memory 0xf3b0] != 40 ||
        [debug read memory 0xf3de] != 0 ||
        [debug read memory 0xf3e9] != 15 || [debug read memory 0xf3ea] != 4 ||
        [debug read memory 0xf3eb] != 4} { error "Modo ou cores do menu incorretos" }
    set raw [raw_screen]
    foreach {row column code} {1 1 24 1 38 1 22 1 3 22 38 5 7 20 18 17 20 17
        3 12 11 3 13 12 3 14 13 3 15 14} {
        scan [string index $raw [expr {$row * 40 + $column}]] %c actual
        if {$actual != $code} { error "Moldura incorreta em $column,$row" }
    }
    for {set column 2} {$column <= 37} {incr column} {
        foreach {row code} {1 23 22 4 5 23 7 23 17 23} {
            if {$column == 20 && ($row == 7 || $row == 17)} { continue }
            scan [string index $raw [expr {$row * 40 + $column}]] %c actual
            if {$actual != $code} { error "Horizontal incorreta em $column,$row" }
        }
    }
    for {set row 2} {$row <= 21} {incr row} {
        foreach {column code} {1 22 38 2} {
            scan [string index $raw [expr {$row * 40 + $column}]] %c actual
            if {$actual != $code} { error "Sombra ou vertical incorreta em $column,$row" }
        }
    }
    for {set offset 0} {$offset < 2048} {incr offset} {
        if {[debug read VRAM [expr {0x800 + $offset}]] != [lindex $font_patterns $offset]} {
            error "Alfabeto Graphos modificado ou nao carregado no byte $offset"
        }
    }
    if {$selection == 8 && [string first "Tubarao!" $raw] < 0} { error "Nome completo de Tubarao! perdido" }
    for {set index 1} {$index <= 15} {incr index} {
        set column 3
        set row [expr {7 + $index}]
        if {$index > 6} { set column 22; set row [expr {1 + $index}] }
        set expected [format %-16s [lindex $titles [expr {$index - 1}]]]
        for {set letter 0} {$letter < 16} {incr letter} {
            scan [string index $raw [expr {$row * 40 + $column + $letter}]] %c actual
            scan [string index $expected $letter] %c normal
            if {$actual != $normal + ($index == $selection ? 128 : 0)} {
                error "Texto ou destaque incorreto na opcao $index"
            }
            if {$index == $selection} {
                for {set line 0} {$line < 8} {incr line} {
                    set pattern [debug read VRAM [expr {0x800 + $normal * 8 + $line}]]
                    set inverse [debug read VRAM [expr {0x800 + $actual * 8 + $line}]]
                    if {$inverse != ($pattern ^ 255)} { error "Destaque nao usa o video inverso do Graphos" }
                }
            }
        }
        scan [string index $raw [expr {$row * 40 + $column - 1}]] %c marker
        if {$marker != ($index == $selection ? 166 : 32)} { error "Seta de selecao incorreta" }
    }
    return 1
}

proc tick {} {
    global phase deadline date_sent
    set previous_phase $phase
    set text [screen_text]
    if {[regexp -nocase {error|Redo|Out of|Illegal|Type mismatch|File not found} $text]} { error $text }
    switch $phase {
        boot {
            if {[check_menu 1 CASSINO.BMX]} {
                set phase automatic_menu
            } elseif {!$date_sent && [regexp -nocase {date|data} $text]} {
                type_via_keybuf "\r"
                set date_sent 1
            }
        }
        automatic_menu {
            if {[check_menu 1 CASSINO.BMX]} {
                report "PASS: AUTOEXEC carrega Graphos, logotipo MSX e moldura com sombra em SCREEN 0"
                type_via_keybuf [format %c 31]
                set phase battle
            }
        }
        battle {
            if {[check_menu 2 BATALHA.BMX]} {
                type_via_keybuf "\r"
                set phase missing
            }
        }
        missing {
            if {[string first "Arquivo nao encontrado no disco." $text] >= 0} {
                report "PASS: jogo ausente mostra erro sem sair do menu"
                type_via_keybuf " "
                set phase dismissed
            }
        }
        dismissed {
            if {[string first "ENTER abre o jogo." $text] >= 0 && [check_menu 2 BATALHA.BMX]} {
                type_via_keybuf [format %c 30]
                set phase cassino
            }
        }
        cassino {
            if {[check_menu 1 CASSINO.BMX]} {
                type_via_keybuf [format %c 30]
                set phase left_wrap
            }
        }
        left_wrap {
            if {[check_menu 6 ELETRIC.BMX]} {
                type_via_keybuf [format %c 28]
                set phase right_column
            }
        }
        right_column {
            if {[check_menu 12 TREM.BMX]} {
                type_via_keybuf [string repeat [format %c 31] 3]
                set phase last_game
            }
        }
        last_game {
            if {[check_menu 15 LABIR3D.BMX]} {
                type_via_keybuf [format %c 31]
                set phase right_wrap
            }
        }
        right_wrap {
            if {[check_menu 7 FROGGER.BMX]} {
                type_via_keybuf [format %c 31]
                set phase tubarao
            }
        }
        tubarao {
            if {[check_menu 8 TUBARAO.BMX]} {
                report "PASS: Tubarao usa titulo inverso valido e preserva nome completo"
                type_via_keybuf [string repeat [format %c 30] 2]
                set phase right_up_wrap
            }
        }
        right_up_wrap {
            if {[check_menu 15 LABIR3D.BMX]} {
                type_via_keybuf [format %c 29]
                set phase left_column
            }
        }
        left_column {
            if {[check_menu 6 ELETRIC.BMX]} {
                report "PASS: 15 jogos nas duas categorias, quatro setas, limites e destaque inverso"
                type_via_keybuf [format %c 27]
                set phase basic
            }
        }
        basic {
            if {[debug read memory 0xf3ea] == 1 && [string first "Ok" [raw_screen]] >= 0} {
                if {[debug read memory 0xfcaf] != 0 || [debug read memory 0xf3b0] != 40 ||
                    [debug read memory 0xf3e9] != 15 || [debug read memory 0xf3eb] != 1 ||
                    [debug read memory 0xf3de] != 0} { error "ESC nao restaurou o BASIC" }
                report "PASS: ESC limpa a tela e restaura SCREEN 0, WIDTH 40, COLOR 15,1,1"
                type_via_keybuf "run\"menu.bmx\"\r"
                set phase reload
            }
        }
        reload {
            if {[check_menu 1 CASSINO.BMX]} {
                type_via_keybuf "\r"
                set phase game
            }
        }
        game {
            if {[debug read memory 0xfcaf] == 1} {
                set game_text [raw_screen]
                if {[string first "Premios incluem a aposta." $game_text] >= 0} {
                    report "PASS: ENTER carrega e executa o Cassino real"
                    exit
                }
            }
        }
    }
    if {$phase ne $previous_phase} { set deadline 0 } else { incr deadline }
    if {$deadline > 600} { error "Tempo esgotado em $phase (fundo [debug read memory 0xf3ea]): $text" }
    after time 0.1 checked_tick
}

proc checked_tick {} {
    if {[catch tick message]} {
        report "FAIL: $message"
        exit 1
    }
}
after time 5 checked_tick
