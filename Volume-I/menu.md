# Menu do Volume I

[menu.dmx](menu.dmx) é o fonte Basic Dignified. O menu apresenta os 15 jogos
do [sumário](Volume-I.md#sumário), separados em **Aprender / Criar** e
**Profissionais**.

- **↑ / ↓**: selecionam um jogo na categoria, voltando ao início/fim nos limites.
- **← / →**: mudam de categoria, mantendo a linha quando possível.
- **Enter**: carrega e executa o jogo selecionado.
- **Esc**: limpa a tela e retorna ao BASIC em `SCREEN 0`, `WIDTH 40`,
  `COLOR 15,1,1` e `KEY OFF`.

O desenho usa caracteres gráficos, molduras duplas e padrões de seis pixels
gravados com `VPOKE BASE(2)`. `SCREEN 0` não oferece `LINE`, `CIRCLE` nem cores
individuais: o menu usa branco sobre azul e uma cópia inversa da fonte para
a faixa de seleção, sem mudar a cor da tela inteira. O nome completo e o
arquivo aparecem abaixo da lista.

## Disco e boot

Monte [disk/](disk/) como disco A. O [autoexec.bas](disk/autoexec.bas) executa
`RUN"MENU.BMX"` durante o boot do MSX Disk BASIC. O menu e os jogos precisam
estar no mesmo disco. Em máquinas que pedem data, confirme primeiro essa
pergunta. Sem autoboot, digite `RUN"MENU.BMX"`.

O pacote da versão 0.1.0 contém os três arquivos necessários para iniciar
o menu e executar o Cassino (`AUTOEXEC.BAS`, `MENU.BMX` e `CASSINO.BMX`).
Extraia-os para um disco MSX; o ZIP não é uma imagem de disco `.dsk`.

A pasta de disco do repositório também contém [cassino.bas](disk/cassino.bas),
a listagem original legada. Para executá-la separadamente, saia do menu e
digite `RUN"CASSINO.BAS"`; ela não está no ZIP publicado da versão 0.1.0.
O menu continua carregando o Cassino modernizado (`CASSINO.BMX`).

Só o Cassino está disponível nesta etapa. Escolher um arquivo ausente mostra
**Arquivo nao encontrado no disco.**; pressione uma tecla para continuar.
Outros erros BASIC não são ocultados. Ao encerrar um jogo, ele mantém seu
próprio comportamento de saída; para reabrir o menu, use `RUN"MENU.BMX"`.

Os nomes de arquivo respeitam o formato 8.3 do MSX:

| Jogo | Arquivo esperado |
|---|---|
| Cassino | CASSINO.BMX |
| Batalha naval | BATALHA.BMX |
| Gorks | GORKS.BMX |
| Vinte e um | VINTEUM.BMX |
| Roleta | ROLETA.BMX |
| O eletricista louco | ELETRIC.BMX |
| Frogger | FROGGER.BMX |
| Tubarão! | TUBARAO.BMX |
| O jogo do cemitério | CEMITER.BMX |
| Fórmula um | FORMULA1.BMX |
| Poker profissional | POKER.BMX |
| Trem maluco | TREM.BMX |
| Caple | CAPLE.BMX |
| Fórmula Interlagos | INTERLAG.BMX |
| Labirinto tridimensional | LABIR3D.BMX |

## Compilação e teste

Na raiz do repositório:

```powershell
python resources\badig\badig.py Volume-I\menu.dmx -id msx --tk_tokenize -vb 4
python resources\badig\badig.py Volume-I\disk\menu.dmx -id msx --tk_tokenize -vb 4
$p = Start-Process openmsx -ArgumentList '-machine Gradiente_Expert_DD_Plus -diska Volume-I\disk -command "set renderer none" -script tests\menu.tcl' -PassThru -Wait
Get-Content tests\menu.log
$p.ExitCode
```

O fonte no disco inclui o fonte principal para evitar cópias divergentes;
os dois geram o mesmo programa tokenizado. O teste usa uma instância própria
do openMSX e verifica autoboot, os 15 títulos, vídeo inverso, as quatro setas,
arquivo ausente, saída e carregamento do Cassino real.
