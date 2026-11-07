# Histórico de versões

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
