# Cassino

Programa em MSX-BASIC: um caça-níqueis simplificado. Código-fonte em
[cassino.dmx](cassino.dmx), no formato Basic Dignified para MSX.

## O jogo

É uma variação simplificada de um caça-níqueis, em que o jogador deve fazer uma aposta. Se você obtém certas combinações de símbolos, ganha segundo a aposta e a combinação obtida.

Os símbolos são mostrados como números de 1 a 9. A combinação especial é
7-7-7, que paga o prêmio máximo.

## Apresentação

A abertura apresenta as regras e os multiplicadores dos prêmios antes de pedir
o saldo inicial. A abertura e o jogo usam `screen 0`, com 40 colunas, fundo
escuro e molduras gráficas da tabela internacional do MSX.

As molduras usam `chr$(1)` seguido dos códigos 86 a 91: vertical, horizontal,
cantos superiores esquerdo/direito e cantos inferiores esquerdo/direito.
O prefixo é necessário para exibir esses gráficos em vez de executar códigos
de controle. Consulte a [tabela de caracteres do MSX](https://www.msx.org/wiki/MSX_Characters_and_Control_Codes).

Em `screen 0`, a cor do texto é global: a paleta muda conforme a etapa,
sem cores independentes por quadro. A abertura é ciano, as apostas são
amarelas, os giros são cianos, as perdas são vermelhas e os acertos são
verdes. O prêmio máximo ganha texto amarelo sobre fundo azul.

Os três rolos têm uma animação curta, com cliques e um som de parada.
A abertura, os acertos comuns, o prêmio máximo, as perdas e a saída têm
melodias próprias no PSG do MSX, sem exigir expansões de áudio.

## Como jogar

Digite `RUN` e ↵ ou pressione a tecla **F5**.

Após a abertura, pressione qualquer tecla. A primeira pergunta é:

```
Quantia inicial :
```

que é quanto você tem em caixa inicialmente. Após pressionar ↵ (return), introduza a primeira aposta, diferente de zero, e novamente pressione ↵ (return).

Visualize então as três cifras sorteadas, com o resultado obtido (ganhou ou perdeu).

Para apostar novamente, pressione qualquer tecla, e assim sucessivamente.
Para terminar o jogo, responda 0 (zero) à pergunta "Sua aposta :", mostrando
como final o quanto resta em caixa. Uma aposta maior que o saldo também
encerra a partida, mantendo o comportamento da listagem original.

Para interromper o jogo a qualquer momento, tecle **CTRL + STOP**.

*Extensões possíveis:* melhoramento dos controles, figuras gráficas no lugar dos números etc.

## Tabela de prêmios (conforme o código)

| Combinação            | Prêmio             |
|-----------------------|--------------------|
| Três números iguais   | 50 × a aposta      |
| Três setes (7-7-7)    | 500 × a aposta     |
| Qualquer outra        | Perde a aposta     |