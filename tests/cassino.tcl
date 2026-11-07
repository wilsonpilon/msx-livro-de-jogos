set test_log [open [file join [file dirname [info script]] cassino.log] w]
set throttle off
set renderer none
set pause_on_lost_focus off
set pause off
set power on
set phase boot
set boot_date_sent 0
set deadline 0
set invalid_wait 0
if {![info exists test_mode]} { set test_mode random }
set turno 0
set hold_wait 0
set hold_handled 0
set gamble_handled 0
set apostas {1 1 1 1 1 1 1 2 1}
set saldos {99 98 137 136 137 176 175 173 173}
set premios {0 0 40 0 2 40 0 0 1}
set rolos_esperados {{2 3 8} {2 3 2} {1 1 9} {7 7 9} {4 5 6} {7 7 7} {2 3 8} {8 2 3} {1 2 3}}
set escolhas_moeda {N N 1 2 N N N N N}

proc report {message} {
    global test_log
    puts $test_log $message
    flush $test_log
}

proc screen_text {} {
    set text ""
    set base 0
    set cells 960
    if {[debug read memory 0xfcaf] == 1} {
        set base 0x1800
        set cells 768
    }
    for {set pos 0} {$pos < $cells} {incr pos} {
        append text [format %c [debug read VRAM [expr {$base + $pos}]]]
    }
    return $text
}

proc check_frame {} {
    set expected {
        2424242424242424 0000ff0000ff0000
        00003f2020272424 0000fc0404e42424
        24242720203f0000 2424e40404fc0000
    }
    set code 22
    foreach pattern $expected {
        for {set row 0} {$row < 8} {incr row} {
            scan [string range $pattern [expr {$row * 2}] [expr {$row * 2 + 1}]] %x byte
            if {[debug read VRAM [expr {$code * 8 + $row}]] != $byte} {
                error "Linha dupla incorreta: caractere $code, linha $row"
            }
        }
        incr code
    }
    for {set row 1} {$row <= 22} {incr row} {
        foreach column {0 31} {
            if {[debug read VRAM [expr {0x1800 + $row * 32 + $column}]] != 32} {
                error "Texto fora da moldura: linha $row, coluna $column, codigo [debug read VRAM [expr {0x1800 + $row * 32 + $column}]]"
            }
        }
    }
    for {set row 2} {$row <= 21} {incr row} {
        foreach column {1 30} {
            if {[debug read VRAM [expr {0x1800 + $row * 32 + $column}]] != 22} {
                error "Moldura alterada: linha $row, coluna $column"
            }
        }
    }
    foreach {row left right} {1 24 25 22 26 27} {
        if {[debug read VRAM [expr {0x1800 + $row * 32 + 1}]] != $left ||
            [debug read VRAM [expr {0x1800 + $row * 32 + 30}]] != $right} {
            error "Cantos da moldura alterados na linha $row"
        }
        for {set column 2} {$column < 30} {incr column} {
            if {[debug read VRAM [expr {0x1800 + $row * 32 + $column}]] != 23} {
                error "Horizontal da moldura alterada na linha $row"
            }
        }
    }
}

proc check_palette {} {
    if {[debug read memory 0xf3de] != 0} { error "Teclas de funcao visiveis" }
    set background [debug read memory 0xf3ea]
    foreach group {2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17} {
        if {$group == 2 || $group == 3} {
            set expected [expr {7 * 16 + $background}]
        } elseif {$group == 6 || $group == 7} {
            set expected [expr {10 * 16 + $background}]
        } elseif {$group == 16 || $group == 17} {
            set expected 0x34
        } else {
            set expected [expr {15 * 16 + $background}]
        }
        set actual [debug read VRAM [expr {0x2000 + $group}]]
        if {$actual != $expected} {
            error "Paleta incorreta no grupo ASCII $group: $actual, esperado $expected"
        }
    }
}

proc check_symbols {} {
    if {[debug read memory 0xfcaf] != 1 || [debug read memory 0xf3b0] != 32} {
        error "Modo=[debug read memory 0xfcaf], largura=[debug read memory 0xf3b0]; esperados SCREEN 1 e 32 colunas"
    }
    set expected {
        3c4299a5a599423c 0c182844eeee4400 003c7effff7e3c00
        183c3c3c7e7eff18 003c7eff7e3c1800 1818ff7e3c7e6642
        0066ffff7e3c1800 007e060c18303000 003c42ffff666600
        183c3c7effdb1824
    }
    set code 128
    foreach pattern $expected {
        for {set row 0} {$row < 8} {incr row} {
            scan [string range $pattern [expr {$row * 2}] [expr {$row * 2 + 1}]] %x byte
            if {[debug read VRAM [expr {$code * 8 + $row}]] != $byte} {
                error "Padrao 8x8 incorreto: caractere $code, linha $row"
            }
        }
        incr code
    }
    report "PASS: dez simbolos 8x8 gravados na VRAM, SCREEN 1, 32 colunas"
}

proc tick {} {
    global phase deadline invalid_wait test_mode turno apostas saldos premios rolos_esperados escolhas_moeda hold_wait hold_handled gamble_handled boot_date_sent
    set text [screen_text]
    if {[string first "error" $text] >= 0 || [string first "Redo" $text] >= 0} {
        error $text
    }
    switch $phase {
        boot {
            if {[string first "M S X  J O G O S" $text] >= 0 && [string first "Arquivo:" $text] >= 0} {
                type_via_keybuf [format %c 27]
                set phase basic
            } elseif {[string first "Ok" $text] >= 0} {
                set phase basic
            } elseif {!$boot_date_sent && [regexp -nocase {date|data} $text]} {
                type_via_keybuf "\r"
                set boot_date_sent 1
            }
        }
        basic {
            if {[string first "Ok" $text] >= 0} {
                type_via_keybuf "load\"cassino.bmx\"\rrun\r"
                set phase opening
            }
        }
        opening {
            if {[string first "Tecla: controles" $text] >= 0} {
                check_symbols
                check_frame
                check_palette
                type_via_keybuf " "
                set phase controls
            }
        }
        controls {
            if {[string first "Pressione uma tecla" $text] >= 0} {
                check_frame
                type_via_keybuf " "
                set phase balance
            }
        }
        balance {
            if {[string first "Saldo: " $text] >= 0} {
                check_frame
                check_palette
                type_via_keybuf "-1\r10a0\r"
                set phase bet
            }
        }
        bet {
            if {[string first "Sua aposta: " $text] >= 0} {
                if {[string first "Saldo : 100 " $text] < 0} { error "Saldo incorreto: $text" }
                check_frame
                check_palette
                type_via_keybuf "1\r"
                set phase result
            }
        }
        result {
            if {[string first "ENTER gira" $text] >= 0 && $test_mode eq "deterministic" && !$hold_handled} {
                if {$turno != 1} { error "Hold oferecido no giro incorreto: $turno" }
                type_via_keybuf "12113"
                set phase hold_limit
            } elseif {[string first "Dobro ou nada? (S/N)" $text] >= 0 && !$gamble_handled} {
                if {$test_mode eq "deterministic" && [lindex $escolhas_moeda $turno] ne "N"} {
                    type_via_keybuf "s"
                    set phase coin_choice
                } else {
                    type_via_keybuf "n"
                    set gamble_handled 1
                }
            }
            if {[string first "Saldo: " $text] >= 0} {
                check_symbols
                check_frame
                check_palette
                set indice 0
                foreach column {6 15 24} {
                    set symbol [debug read VRAM [expr {0x1800 + 8 * 32 + $column}]]
                    if {$symbol < 129 || $symbol > 137} {
                        error "Rolo sem simbolo sorteado: coluna $column, codigo $symbol"
                    }
                    if {$test_mode eq "deterministic" && $symbol != 128 + [lindex [lindex $rolos_esperados $turno] $indice]} {
                        error "Rolo alterado incorretamente no giro $turno"
                    }
                    incr indice
                }
                if {$test_mode eq "deterministic"} {
                    set linha [string range $text [expr {18 * 32}] [expr {19 * 32 - 1}]]
                    if {![regexp {Saldo:\s+([0-9.]+)} $linha -> saldo] || $saldo != [lindex $saldos $turno]} {
                        error "Premio ou desconto duplicado no giro $turno: $linha"
                    }
                    set linha_premio [string range $text [expr {14 * 32}] [expr {15 * 32 - 1}]]
                    set linha_resultado [string range $text [expr {15 * 32}] [expr {16 * 32 - 1}]]
                    if {![regexp {Premio:\s+([0-9.]+)} $linha_premio -> premio] || $premio != [lindex $premios $turno]} {
                        error "Premio bruto incorreto: $linha_premio"
                    }
                    if {![regexp {Resultado:\s*([-0-9.]+)} $linha_resultado -> resultado] || $resultado != $premio - [lindex $apostas $turno]} {
                        error "Resultado liquido incorreto: $linha_resultado"
                    }
                    if {$turno == 1 && [string first "Hold: mantenha" $text] >= 0} { error "Hold consecutivo permitido" }
                    report "PASS: giro [expr {$turno + 1}], rolos corretos e saldo $saldo"
                    incr turno
                }
                type_via_keybuf " "
                set gamble_handled 0
                set hold_handled 0
                if {$test_mode eq "deterministic" && $turno < [llength $apostas]} {
                    set phase next_bet
                } else {
                    set phase last_bet
                }
            }
        }
        hold_limit {
            if {[peek16 0xf3f8] == [peek16 0xf3fa]} { incr hold_wait } else { set hold_wait 0 }
            if {$hold_wait >= 3} {
                foreach {column expected} {3 { TRAVA } 12 { TRAVA } 21 {       }} {
                    if {[string range $text [expr {10 * 32 + $column}] [expr {10 * 32 + $column + 6}]] ne $expected} {
                        error "Hold incorreto na coluna $column: [string range $text [expr {10 * 32 + $column}] [expr {10 * 32 + $column + 6}]]"
                    }
                }
                report "PASS: Hold alterna rolos e rejeita terceira trava"
                set hold_handled 1
                type_via_keybuf "\r"
                set phase result
            }
        }
        coin_choice {
            if {[string first "1=Cara / 2=Coroa" $text] >= 0} {
                type_via_keybuf [lindex $escolhas_moeda $turno]
                set gamble_handled 1
                set phase result
            }
        }
        next_bet {
            if {[string first "Sua aposta: " $text] >= 0} {
                set tem_hold [expr {[string first "Hold: mesma aposta" $text] >= 0}]
                if {$tem_hold != ($turno == 1 || $turno == 7)} { error "Oferta de Hold incorreta no giro $turno" }
                type_via_keybuf "[lindex $apostas $turno]\r"
                set phase result
            }
        }
        last_bet {
            if {[string first "Sua aposta: " $text] >= 0} {
                check_frame
                check_palette
                type_via_keybuf "0\r"
                set phase ending
            }
        }
        ending {
            if {[string first "Jogar novamente? (S/N)" $text] >= 0} {
                check_frame
                check_palette
                type_via_keybuf "x"
                set phase invalid_answer
            }
        }
        invalid_answer {
            incr invalid_wait
            if {$invalid_wait >= 3} {
                if {[string first "Jogar novamente? (S/N)" $text] < 0 ||
                    [debug read memory 0xfcaf] != 1} { error "Resposta invalida encerrou a partida" }
                type_via_keybuf "s"
                set phase restart_opening
            }
        }
        restart_opening {
            if {[string first "Tecla: controles" $text] >= 0} {
                check_symbols
                check_frame
                check_palette
                type_via_keybuf " "
                set phase restart_controls
            }
        }
        restart_controls {
            if {[string first "Pressione uma tecla" $text] >= 0} {
                type_via_keybuf " "
                set phase restart_balance
            }
        }
        restart_balance {
            if {[string first "Saldo: " $text] >= 0} {
                type_via_keybuf "5\r"
                set phase restart_bet
            }
        }
        restart_bet {
            if {[string first "Sua aposta: " $text] >= 0} {
                if {[string first "Saldo : 5 " $text] < 0} { error "Saldo nao reiniciado: $text" }
                check_frame
                check_palette
                report "PASS: resposta invalida ignorada e S reinicia com novo saldo"
                type_via_keybuf "0\r"
                set phase final_question
            }
        }
        final_question {
            if {[string first "Jogar novamente? (S/N)" $text] >= 0} {
                check_frame
                check_palette
                type_via_keybuf "N"
                set phase basic_restored
            }
        }
        basic_restored {
            if {[debug read memory 0xfcaf] == 0 && [string first "Ok" $text] >= 0} {
                if {[debug read memory 0xf3b0] != 40 ||
                    [debug read memory 0xf3e9] != 15 ||
                    [debug read memory 0xf3ea] != 1 ||
                    [debug read memory 0xf3eb] != 1 ||
                    [debug read memory 0xf3de] != 0} { error "Configuracao final incorreta" }
                if {[string trim [string map [list "\xff" ""] $text]] ne "Ok"} {
                    error "Tela nao foi limpa: $text"
                }
                report "PASS: N limpa a tela e retorna ao BASIC em SCREEN 0, WIDTH 40, COLOR 15,1,1 e KEY OFF"
                exit
            }
        }
    }
    incr deadline
    if {$deadline > 600} { error "Tempo esgotado: $phase, $text" }
    after time 0.1 checked_tick
}

proc checked_tick {} {
    if {[catch tick message]} {
        report "FAIL: $message"
        exit 1
    }
}
after time 5 checked_tick
