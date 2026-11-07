# Histórico de versões

## Não lançado

- Mapa e include compartilhado do alfabeto Graphos III, com identificação
  das letras, vídeo inverso, molduras, sombras, setas e logotipo MSX.
- Exemplos com os 256 caracteres editáveis em DATA binário, geração de
  `ALFABETO.BIN` e demonstração em `SCREEN 0`, `1` e `2`, testados no openMSX.
- Menu do Volume I usa o alfabeto Graphos III em `ALFABETO.BIN`, com
  logotipo MSX, borda fina e sombra sólida, sem redefinir os padrões.
  O BIN deve acompanhar o menu no disco. Cassino permanece inalterado.
- Incluída no disco do repositório a listagem legada `CASSINO.BAS`, para
  execução independente. O pacote publicado de 0.1.0 permanece inalterado.

## 0.1.0 — 2026-11-06

Primeira versão funcional do Volume I, com menu inicializável e Cassino
modernizado. Os outros 14 jogos aparecem no menu, mas ainda não estão
disponíveis.

### Menu e distribuição

- Menu em `SCREEN 0`, com molduras duplas, seleção por setas e vídeo inverso.
- `AUTOEXEC.BAS` inicia o menu; Enter executa o jogo e Esc volta ao BASIC.
- Arquivos ausentes mostram um aviso, sem sair do menu.
- Pacote de disco com `AUTOEXEC.BAS`, `MENU.BMX` e `CASSINO.BMX` (ZIP,
  não uma imagem `.dsk`).

### Cassino

- Editor de entrada compartilhado com setas, Insert, DEL e Backspace.
- `SCREEN 1`, dez símbolos 8×8, molduras duplas, cores por grupos e som.
- Regras recalibradas com cerejas, joias, nave curinga, Hold e dobro ou
  nada; pagamentos brutos incluem a aposta. Nudge não foi implementado.
- Regras na abertura, reinício com novo saldo e saída limpa ao BASIC.

### Validação

- Conversão e tokenização das versões principal e de disco.
- Testes no openMSX do menu, do boot e do Cassino, incluindo nove giros
  controlados e as 729 combinações do avaliador de prêmios.
- Testes de edição de entrada e cálculo independente da calibração.
- Não houve validação em hardware real.
