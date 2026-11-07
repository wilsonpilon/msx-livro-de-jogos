# Cassino

Programa em MSX-BASIC: um caça-níqueis simplificado. Código-fonte em
[cassino.dmx](cassino.dmx), no formato Basic Dignified para MSX.

## O jogo

É uma variação simplificada de um caça-níqueis, em que o jogador deve fazer uma aposta. Se você obtém certas combinações de símbolos, ganha segundo a aposta e a combinação obtida.

Os rolos mostram símbolos personalizados de 8×8 pixels. Cada rolo livre
sorteia uniformemente um número de 1 a 9 e exibe
`chr$(128 + numero_sorteado)`. A tabela foi recalibrada para premiar
mais combinações: cerejas, joias misturadas e trincas com nave curinga.
Três setes naturais (7-7-7) dão o jackpot.

## Apresentação

A abertura apresenta duas páginas: pagamentos e controles de Hold/dobro
ou nada, antes de pedir o saldo inicial. A abertura e o jogo usam
`screen 1`, com 32 colunas, fundo
escuro e molduras duplas inspiradas nos quadros dos PCs clássicos.

Os textos e os três quadros foram reposicionados para caber dentro da
moldura. `SCREEN 1` mostra os oito pixels de largura de cada caractere;
`SCREEN 0` mostrava somente seis.

### Símbolos dos rolos

A rotina `{definir_simbolos}` lê oito bytes por desenho e grava a tabela
de padrões com `vpoke base(7) + codigo_simbolo * 8 + linha_simbolo, padrao_simbolo`.
Cada literal binário em `{dados_simbolos}` representa uma linha de oito
pixels: 1 acende o pixel, 0 deixa o fundo.

| Código | Valor interno | Desenho |
|---|---|---|
| 128 | — | Moeda, reservada e não sorteada |
| 129 | 1 | Cerejas |
| 130 | 2 | Limão |
| 131 | 3 | Sino |
| 132 | 4 | Diamante |
| 133 | 5 | Estrela |
| 134 | 6 | Coração |
| 135 | 7 | Sete, prêmio máximo |
| 136 | 8 | Carro |
| 137 | 9 | Nave, curinga |

Os padrões são carregados uma vez após `SCREEN 1`. `CLS` e as mudanças de
cor preservam os desenhos. Os padrões das molduras também são carregados
na inicialização, nos códigos 22–27, sem alterar os símbolos dos rolos.
Consulte [BASE](https://www.msx.org/wiki/BASE()) para os endereços das tabelas.

### Molduras duplas

As molduras usam `chr$(1)` seguido dos códigos 86 a 91: vertical, horizontal,
cantos superiores esquerdo/direito e cantos inferiores esquerdo/direito.
O prefixo é necessário para exibir esses gráficos em vez de executar códigos
de controle. Consulte a [tabela de caracteres do MSX](https://www.msx.org/wiki/MSX_Characters_and_Control_Codes).

Essas sequências exibem os caracteres 22–27, cujos padrões agora são
redefinidos em `{dados_moldura}`. Duas linhas paralelas, separadas por
dois pixels, conectam-se aos quatro cantos em 8×8. A moldura externa e
os três quadros dos rolos usam os mesmos desenhos.

### Cores por grupos de caracteres

Em `SCREEN 1`, cada grupo de oito códigos consecutivos compartilha uma
cor de desenho e uma de fundo. `{aplicar_cores}` grava a tabela `BASE(6)`;
o byte de cada grupo é `cor_do_desenho * 16 + cor_do_fundo`.

| Códigos | Elementos | Desenho | Fundo |
|---|---|---|---|
| 16–31 | Molduras (22–27) | Ciano | Da etapa |
| 48–63 | Números e parte da pontuação | Amarelo | Da etapa |
| 32–47 e 64–127 | Textos, maiúsculas e minúsculas | Branco | Da etapa |
| 128–143 | Todos os desenhos dos rolos | Verde claro | Azul escuro |

Todas as letras mantêm a mesma cor branca durante a partida, sem destacar
as maiúsculas em outra cor. Números, molduras e desenhos usam cores
distintas. O fundo geral é preto, exceto no prêmio máximo, que usa azul escuro.
Como `COLOR` redefine a tabela de cores, o jogo reaplica os grupos logo
após cada `COLOR`. `CLS` não remove os padrões personalizados.

Não há cor independente por posição: o mesmo caractere usa as mesmas
cores onde quer que apareça, e os oito códigos de cada grupo compartilham
a paleta. Por isso, os símbolos 128–135 não têm cores individuais.

Os três rolos têm uma animação curta, com cliques e um som de parada.
A abertura, os acertos comuns, o prêmio máximo, as perdas e a saída têm
melodias próprias no PSG do MSX, sem exigir expansões de áudio.

## Como jogar

Digite `RUN` e ↵ ou pressione a tecla **F5**.

Pressione uma tecla em cada uma das duas páginas de regras. A primeira pergunta é:

```
Saldo:
```

que é quanto você tem em caixa inicialmente. Após pressionar ↵ (return), introduza a primeira aposta, diferente de zero, e novamente pressione ↵ (return).

Cada giro desconta a aposta antes do sorteio. Se houver prêmio, escolha
**N** para recebê-lo ou **S** para tentar o dobro ou nada. A tela mostra
aposta, prêmio bruto, resultado líquido e saldo atualizado.

### Hold: travar rolos

Após um giro sem combinação premiada, há **1 chance em 12** de receber
Hold, desde que ainda exista saldo. Ele vale apenas para o próximo giro,
que continua **pago e com a mesma aposta**; mudar a aposta cancela a oferta.

- **1 / 2 / 3** alternam a trava do respectivo rolo.
- Podem ficar travados no máximo **dois** rolos; tentar o terceiro emite um beep.
- **Enter** confirma e gira apenas os rolos livres. Também pode girar sem travar nenhum.
- Uma rodada que recebeu a oferta não gera outra, mesmo se perder ou cancelar
  o Hold. Perder no dobro ou nada não gera Hold.

### Dobro ou nada

Qualquer prêmio positivo, inclusive a devolução da aposta, permite **uma**
tentativa opcional: **1 = Cara**, **2 = Coroa**, com 50% de chance cada.
Acertar dobra o prêmio bruto; errar perde esse prêmio inteiro. O saldo
restante não entra nessa aposta extra, e não há segundo desconto da aposta.
O prêmio final é creditado uma única vez. Não há Nudge.

Para apostar novamente, pressione qualquer tecla, e assim sucessivamente.
Para terminar o jogo, responda 0 (zero) à pergunta "Sua aposta:", mostrando
como final o quanto resta em caixa. Uma aposta maior que o saldo também
encerra a partida, mantendo o comportamento da listagem original.

Ao terminar, o jogo pergunta **Jogar novamente? (S/N)**:

- **S** reinicia pela abertura e pede um novo saldo inicial.
- **N** limpa a tela e retorna ao BASIC com `screen 0`, `width 40` e
  `color 15, 1, 1`.
- Maiúsculas e minúsculas são aceitas, sem precisar de Enter. Outras
  teclas emitem um aviso sonoro e mantêm a pergunta.

A linha das teclas de função fica oculta com `key off` tanto durante
o jogo quanto após o encerramento.

Para interromper o jogo a qualquer momento, tecle **CTRL + STOP**.

### Entrada e edição dos valores

Saldo e aposta usam o editor compartilhado de
[entrada.dmx](../include/entrada.dmx), baseado em `inkey$`. Ele lê somente
o conteúdo do campo, não a linha da tela; assim, os caracteres da moldura
não entram na conversão numérica e não causam `Redo from start`.

- **← / →**: movem o cursor dentro do texto.
- A digitação começa em **sobrescrita**; **Insert** alterna entre inserir
  e sobrescrever, sem ultrapassar o tamanho do campo.
- **DEL** apaga o caractere na posição do cursor; **Backspace**, o anterior.
- **Enter** confirma. Valores vazios ou incompletos não são confirmados.
- São aceitos dígitos, um separador decimal (`.` ou `,`) e sinal inicial
  opcional (`+` ou `-`). A vírgula é normalizada para ponto.
- O Cassino rejeita valores negativos com um aviso sonoro e pede o valor
  novamente. A rotina compartilhada aceita negativos para outros programas.

Cada campo do Cassino comporta 14 caracteres, incluindo sinal e separador.
Caracteres inválidos e tentativas de exceder o tamanho emitem um aviso sonoro.
As esperas por qualquer tecla continuam usando `input$(1)`, que não lê linhas.

### Reutilização em outros programas

O include atende texto e números com o mesmo editor. Como o Basic Dignified
separa os rótulos e as variáveis longas de cada include em namespaces, coloque
estes pontos de entrada **no início do programa**, antes da inicialização:

```basic
goto {inicializar}

{entrada_numero}
    em = 1
    goto {entrada_campo}

{entrada_texto}
    em = 0

{entrada_campo}
    include "..\include\entrada.dmx"

{inicializar}
    screen 0
    width 40
    key off
```

O caminho é relativo ao fonte; ajuste-o conforme a pasta do programa.
Os parâmetros usam nomes curtos para compartilhar os mesmos valores entre
os namespaces. Reserve estes nomes no programa:

| Variável | Uso |
|---|---|
| `ec`, `el` | Coluna e linha iniciais, contando a partir de zero |
| `et` | Largura máxima do campo em caracteres |
| `em` | Modo interno: zero para texto, um para número |
| `es$` | Texto confirmado; somente este resultado é atualizado no modo texto |
| `ev#` | Valor numérico confirmado, em dupla precisão |

Exemplo de chamada, após desenhar a tela:

```basic
locate 4, 8
print "Nome: ";
ec = 10
el = 8
et = 20
gosub {entrada_texto}
nome$ = es$

locate 4, 10
print "Valor: ";
ec = 11
el = 10
et = 14
gosub {entrada_numero}
quantia# = ev#
```

O editor inicia vazio, em sobrescrita, a cada chamada. O modo texto aceita
caracteres imprimíveis, inclusive espaços, pontuação e códigos estendidos
MSX (128–255), e permite confirmar texto vazio. Códigos de controle não são
inseridos como texto: os de edição são tratados pelo editor e os demais
são ignorados, para não executar comandos de tela nem deslocar as molduras.

Use em `SCREEN 0` ou `SCREEN 1`, com coordenadas e largura inteiras. A linha
deve estar entre 0 e 23; o campo precisa terminar antes da última coluna
da largura atual e não deve ocupar a linha das teclas de função quando
elas estiverem visíveis. Parâmetros inválidos geram `Illegal function call`
(`error 5`). No modo numérico, a largura máxima é 14, evitando overflow
na conversão. Notação exponencial e separadores de milhar não são aceitos.
O cursor fica visível durante a edição e é ocultado ao confirmar; com o
campo cheio, sua posição visual permanece na última célula, sem atingir
o caractere seguinte ao campo. Para substituir a última letra, pressione
← antes de digitar; Backspace apaga a última letra diretamente.

### Validação no emulador

Na raiz do repositório, gere o jogo e a listagem de testes:

```powershell
python resources\badig\badig.py Volume-I\cassino.dmx -id msx --tk_tokenize -vb 4
python resources\badig\badig.py tests\entrada.dmx -id msx --tk_tokenize -vb 4
python resources\badig\badig.py tests\premios.dmx -id msx --tk_tokenize -vb 4
node tests\cassino-matematica.js
```

Com openMSX e as ROMs do Gradiente Expert DD Plus disponíveis:

```powershell
$p = Start-Process openmsx -ArgumentList '-machine Gradiente_Expert_DD_Plus -diska tests -command "set renderer none" -script tests\entrada.tcl' -PassThru -Wait
Get-Content tests\entrada.log
$p.ExitCode

$p = Start-Process openmsx -ArgumentList '-machine Gradiente_Expert_DD_Plus -diska tests -command "set renderer none" -script tests\premios.tcl' -PassThru -Wait
Get-Content tests\premios.log
$p.ExitCode

$p = Start-Process openmsx -ArgumentList '-machine Gradiente_Expert_DD_Plus -diska Volume-I -command "set renderer none" -script tests\cassino.tcl' -PassThru -Wait
Get-Content tests\cassino.log
$p.ExitCode
```

Os testes verificam 15 sequências de edição, o limite de campo em `SCREEN 1`
e a preservação dos caracteres gráficos e textos adjacentes. No jogo,
conferem os 80 bytes dos dez padrões na VRAM, o modo de 32 colunas,
os códigos exibidos nos três rolos, os 48 bytes das molduras duplas,
as letras com cor uniforme, as cores por grupo e o fluxo saldo decimal →
aposta → rodada → aposta zero → pergunta de reinício → nova partida →
retorno ao BASIC. Também verificam `key off`, a limpeza da tela e a
restauração exata de modo, largura e cores. Falhas são registradas nos logs e
encerram o emulador com código 1. Os testes usam instâncias próprias.

Para testar Hold e dobro ou nada sem depender da sorte, gere uma cópia
temporária fora da distribuição, com sorteios controlados:

```powershell
node tests\preparar-cassino.js "$env:TEMP\cassino-controlado"
python resources\badig\badig.py "$env:TEMP\cassino-controlado\cassino.dmx" -id msx --tk_tokenize -vb 4
$p = Start-Process openmsx -ArgumentList "-machine Gradiente_Expert_DD_Plus -diska `"$env:TEMP\cassino-controlado`" -command `"set renderer none; set test_mode deterministic`" -script tests\cassino.tcl" -PassThru -Wait
Get-Content tests\cassino.log
$p.ExitCode
```

A cópia altera apenas as fontes de aleatoriedade. O teste integrado confere
nove rodadas, limite/alternância de travas, giro sem oferta consecutiva,
cancelamento por mudança de aposta, vitória e derrota no dobro ou nada,
curinga, joias, jackpot e devolução da aposta, além de reinício/saída.
O teste `premios` executa o avaliador real em 25 casos específicos e nas
729 combinações, verificando a soma e a distribuição dos multiplicadores.
O teste matemático independente enumera também as escolhas de Hold.

*Extensões possíveis:* animações adicionais dos símbolos e uso de sprites.

## Tabela de prêmios (conforme o código)

Os multiplicadores são **brutos, incluindo a aposta**. Vale apenas o maior
prêmio aplicável, sem somar regras. Por exemplo, apostar 10 e receber 3×
credita 30: o resultado líquido é +20. Receber 1× devolve a aposta.

| Combinação | Pagamento bruto |
|---|---|
| Cerejas no primeiro rolo | 1× |
| Duas cerejas reais, em qualquer posição | 3× |
| Três cerejas | 10× |
| Trinca comum natural (exceto cerejas e setes) | 3× |
| Diamante/estrela/coração misturados | 2× |
| Trinca comum formada com uma ou duas naves | 6× |
| Trinca de cerejas formada com uma ou duas naves | 20× |
| Dois setes reais + nave, em qualquer ordem | 10× |
| Três naves | 10× |
| Três setes naturais | 40× |
| Nenhuma combinação premiada | 0: perde a aposta |

A nave substitui símbolos para formar trincas e pode completar a família
de joias. As regras especiais de setes/naves prevalecem: sete + duas naves
paga 6×, dois setes + nave paga 10×, e somente 777 natural paga 40×.
Uma nave não conta como cereja isolada para os prêmios de consolação.

O avaliador compartilhado está em [premios.dmx](../include/premios.dmx).
Recebe `ra`, `rb`, `rc` (inteiros de 1 a 9) e devolve `pm` (multiplicador),
`mp$` (mensagem) e `jp` (jackpot natural). Entradas inválidas geram `error 5`.

### Calibração

Sem Hold, 183 das 729 combinações pagam alguma coisa: **25,10%** dos giros,
incluindo devoluções da aposta. A soma dos multiplicadores é 672, dando
retorno médio teórico de **92,18%** do valor apostado.

Com aposta fixa e escolha ótima dos rolos travados, considerando a oferta
1/12 após perdas e a proibição de ofertas consecutivas, o retorno sobe
para cerca de **97,09%**. O dobro ou nada justo mantém o valor esperado,
mas aumenta a variação do saldo. São médias de muitos giros, não garantia
de resultado numa partida.