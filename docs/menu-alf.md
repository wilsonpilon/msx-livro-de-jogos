# Mapa de caracteres do menu

O [include](../include/menu-alf.dmx) descreve o alfabeto de
[menu.alf](../resources/menu.alf), do **Graphos III**, visualizado em
[menu-alf.png](../resources/menu-alf.png). Pode ser usado nos três volumes,
mas **não carrega a fonte nem altera o menu existente**.

## Formato e coordenadas

O arquivo tem 2.055 bytes: cabeçalho de sete bytes de `BSAVE` (`FE`,
início `9200h`, fim inclusivo `99FFh`, execução `9200h`) e 2.048 bytes
de padrões. São 256 caracteres de oito linhas, oito bits por linha;
o bit 7 é o pixel da esquerda. O padrão do código `c` começa no byte
`7 + c * 8`, contado a partir de zero.

A imagem é uma grade de **16 × 16**, em ordem de código, não uma tabela
Unicode. Contando linhas e colunas a partir de zero:

```text
codigo = linha * 16 + coluna
linha = codigo \ 16
coluna = codigo mod 16
```

Na PNG, cada pixel do glifo foi ampliado para 4 × 4; as células avançam
33 pixels, incluindo a linha da grade. O primeiro pixel de cada padrão
fica em `(7 + coluna * 33, 7 + linha * 33)`. Os pixels dos códigos
1–255 correspondem aos bytes do arquivo; a célula 0 aparece selecionada
em cinza.

`SCREEN 0` mostra somente os seis bits da esquerda; `SCREEN 1` mostra
os oito. As molduras horizontais usam os oito pixels, portanto podem
ficar descontínuas ou perder detalhes em `SCREEN 0`.

O endereço `9200h` do cabeçalho não é a tabela de padrões da VRAM.
Não use `BLOAD` sem considerar o destino: a carga em RAM pode atingir
o programa BASIC, e a carga direta com `,S` não posiciona esta fonte em
`BASE(2)`. Este include pressupõe que os 2.048 bytes de padrões já
tenham sido instalados na tabela correspondente ao modo de tela.

## Exemplo executável e alfabeto editável

- [alfabeto.dmx](../examples/alfabeto.dmx): os 256 caracteres em `DATA`
  binário, usados para gravar **ALFABETO.BIN** pelo próprio MSX-BASIC.
- [alfabeto.bin](../examples/alfabeto.bin): arquivo já gerado e validado.
- [demoalf.dmx](../examples/demoalf.dmx): carrega a fonte e mostra os
  256 códigos, moldura com sombra sólida, MSX e texto inverso.

Compile os exemplos na raiz:

```powershell
python resources\badig\badig.py examples\alfabeto.dmx -id msx --tk_tokenize -vb 4
python resources\badig\badig.py examples\demoalf.dmx -id msx --tk_tokenize -vb 4
openmsx -machine Gradiente_Expert_DD_Plus -diska examples
```

No MSX, `RUN"DEMOALF.BMX"` abre a demonstração em `SCREEN 1`.
Use **0**, **1** e **2** para mudar de modo e **Esc** para voltar ao BASIC.
Para experimentar também o arquivo Graphos original, copie-o para o
mesmo disco antes de abrir o emulador:

```powershell
Copy-Item resources\menu.alf examples\menu.alf
```

A tecla **L** alterna entre `ALFABETO.BIN` e `MENU.ALF`. Sem essa cópia,
selecionar o original produz o erro normal de arquivo ausente; o exemplo
não esconde falhas de carregamento.

### Editar os desenhos

Em [alfabeto.dmx](../examples/alfabeto.dmx), cada comentário identifica o
código decimal/hexadecimal, seguido de uma string `DATA` com **oito
grupos de oito bits**, separados por um espaço. Os grupos são as linhas
do desenho de cima para baixo; dentro de cada grupo, os pixels vão
da esquerda para a direita. `1` acende um pixel e `0` apaga.

Por exemplo, o caractere 65 (`A`):

```basic
data "00000000 11111000 11011000 11011000 11111000 11011000 11011000 00000000"
```

Essa forma compacta mantém os pixels legíveis sem estourar a memória do
MSX com Disk BASIC, como ocorria com 2.048 literais individuais `&B...`.
O gerador separa os grupos, valida os bits e converte com `VAL("&B" + bits$)`
antes de gravar cada linha na VRAM. Strings malformadas geram `ERROR 5`.

Depois de editar, recompile e execute `RUN"ALFABETO.BMX"` no MSX. Isso
sobrescreve `ALFABETO.BIN` no disco atual; execute novamente a demonstração
para ver o resultado. Não é necessário manter `MENU.ALF` para esse fluxo.

Os padrões inversos também são editáveis e não são recalculados pelo
gerador. Ao alterar uma letra normal, atualize seu equivalente inverso
(código + 128), invertendo os oito bits de cada linha, se quiser manter
a relação de vídeo inverso.

### BLOAD com deslocamento

O BIN continua sendo um arquivo **BSAVE**, não apenas bytes crus:
cabeçalho `FE 00 00 FF 07 00 00` e 2.048 bytes de padrões. O endereço
zero simplifica a carga na tabela escolhida:

```basic
screen 0
bload "ALFABETO.BIN", s, base(2)

screen 1
bload "ALFABETO.BIN", s, base(7)

screen 2
bload "ALFABETO.BIN", s, base(12)
bload "ALFABETO.BIN", s, base(12) + &h800
bload "ALFABETO.BIN", s, base(12) + &h1000
```

Para o arquivo original em `9200h`, subtraia esse endereço:

```basic
screen 0
bload "MENU.ALF", s, base(2) - &h9200

screen 1
bload "MENU.ALF", s, base(7) - &h9200

screen 2
bload "MENU.ALF", s, base(12) - &h9200
bload "MENU.ALF", s, base(12) - &h9200 + &h800
bload "MENU.ALF", s, base(12) - &h9200 + &h1000
```

Nas configurações padrão, os deslocamentos originais são `7600h` para
`SCREEN 0`, `6E00h` para `SCREEN 1`, e `6E00h`, `7600h`, `7E00h` para
os três bancos de `SCREEN 2`. A soma do endereço inicial com o deslocamento
é feita em 16 bits. Esses carregamentos foram conferidos no openMSX,
sem usar a região RAM `9200h` como intermediária.

Faça a carga **depois** de `SCREEN`, `COLOR` e `CLS`. Em `SCREEN 2`,
carregar os padrões não basta: cada faixa de oito linhas usa um banco,
a tabela de cores precisa ser configurada, e os códigos são escritos
na tabela de nomes (`VPOKE BASE(10) + linha * 32 + coluna, codigo`).
A demonstração faz tudo isso; não usa `PRINT` para desenhar nesse modo.

## Letras e vídeo inverso

O alfabeto principal ocupa 32–127, mas contém desenhos em algumas
posições ASCII. As faixas 0–31 e 128–175 concentram molduras e símbolos;
176–255 contêm os dígitos e letras inversos, com exceções abaixo.

As letras aparentando “negrito” na parte inferior são, na verdade,
**vídeo inverso**: cada byte é o correspondente normal XOR `FFh`.
Não há uma segunda família de letras engrossadas.

| Conteúdo | Normal (decimal / hex) | Inverso (decimal / hex) |
|---|---|---|
| Espaço | 32 / 20 | 160 / A0 |
| Ponto | 46 / 2E | 174 / AE |
| Dígitos `0`–`9` | 48–57 / 30–39 | 176–185 / B0–B9 |
| `: ; < = > ?` | 58–63 / 3A–3F | 186–191 / BA–BF |
| Maiúsculas `A`–`Z` | 65–90 / 41–5A | 193–218 / C1–DA |
| Minúsculas `a`–`z` | 97–122 / 61–7A | 225–250 / E1–FA |

Na grade, `A` começa em **linha 4, coluna 1**, e `a` em **linha 6,
coluna 1**. Seus inversos começam em **linha 12, coluna 1** e **linha
14, coluna 1**. Os dígitos começam nas linhas **3** e **11**, coluna 0.
Essas coordenadas também são contadas a partir de zero.

Somente nessas faixas é seguro somar 128. Por exemplo, `! + 128`
vira o canto 129, não uma exclamação inversa; `@ + 128` vira 192.
Os códigos 96 e 192 têm pequenos desenhos distintos, não a crase e o `@`
inverso. Os códigos 123–125 são outras peças com aparência de letras
estilizadas, e 126 é uma ampulheta, não `{ | } ~`. Não há aqui um mapa
validado de letras acentuadas.

## Quadros

SE/SD/IE/ID significam superior esquerdo/direito e inferior
esquerdo/direito. A direção das junções T indica a haste que sai
da barra. Os números são **códigos de glifo**, não bytes para enviar
diretamente a `PRINT` quando menores que 32.

| Índice | Peça | Linha simples `qn$()` | Hachura superior/esquerda `qs$()` |
|---|---|---:|---:|
| 0 | Canto SE | 24 | 152 |
| 1 | Canto SD | 25 | 153 |
| 2 | Canto IE | 26 | 154 |
| 3 | Canto ID | 27 | 155 |
| 4 | Horizontal | 23 | 151 |
| 5 | Vertical | 22 | 150 |
| 6 | T para baixo | 18 | 161 |
| 7 | T para cima | 17 | 145 |
| 8 | T para a direita | 20 | 162 |
| 9 | T para a esquerda | 19 | 163 |
| 10 | Cruz | 21 | 149 |

Na segunda família, nem todas as peças têm hachura: 145, 149 e 150
são cópias das peças simples. Portanto, esse array não representa
oito peças intercambiáveis de uma moldura completa. A horizontal 151
tem hachura **acima**: repeti-la na base coloca a hachura dentro do quadro.
Os códigos 146–148 repetem
18–20; 164 é um T para cima com hachura **abaixo**.

Uma terceira família tem barra horizontal espessa e sombra hachurada
abaixo/à direita:

| Índice `qh$()` | Peça | Código |
|---|---|---:|
| 0 | Canto SD com sombra | 129 |
| 1 | Vertical esquerda | 130 |
| 2 | Canto IE com sombra | 131 |
| 3 | Horizontal espessa com sombra abaixo | 132 |
| 4 | Canto ID com sombra | 133 |
| 5 | Vertical direita com sombra à direita | 156 |

Não há um canto SE exclusivo nessa terceira família. Não se deve
presumir que os seis glifos componham uma moldura simétrica.
Os códigos 1–5 são peças sem hachura, mas não devem ser tratados
como equivalentes geométricos de todos os códigos 129–133.
157 é a horizontal espessa com hachura acima.

### Borda fina com sombra sólida

A referência de menu fornecida mostra uma linha fina com um segundo
traço sólido deslocado para a direita e para baixo, **não hachura**.
Essa moldura usa peças distintas em cada lado:

| Índice `qb$()` | Peça | Código |
|---|---|---:|
| 0 | Canto SE fino | 24 |
| 1 | Canto SD com início da sombra à direita | 1 |
| 2 | Canto IE com início da sombra abaixo | 3 |
| 3 | Canto ID com fechamento da sombra | 5 |
| 4 | Horizontal superior fina | 23 |
| 5 | Horizontal inferior com sombra | 4 |
| 6 | Vertical esquerda fina | 22 |
| 7 | Vertical direita com sombra | 2 |

Em coordenadas de pixels, a sombra começa duas posições após o canto:
à direita, duas linhas abaixo do topo; embaixo, duas colunas após a
esquerda. A borda fica com um pixel no topo/esquerda e dois na base/direita.
Não é preciso modificar os padrões do alfabeto para montar esse quadro.

O exemplo executável usa `qb$()` e verifica a continuidade da borda e
a sombra pixel a pixel, inclusive com os seis pixels de `SCREEN 0`.

## Outros gráficos e logotipos

| Códigos | Identificação |
|---|---|
| 0, 32, 127, 175, 220, 251–255 | Vazios |
| 6–9; cópias 134–137 | Inscrição/assinatura estilizada; leitura textual não confirmada |
| 10; cópia 138 | Símbolo de copyright |
| **11–14**; cópias **139–142** | **Logotipo MSX: quatro peças lado a lado, nessa ordem** |
| 15 | Quadrado vazado, cinco pixels de largura |
| 16 | Pequeno pictograma; significado não confirmado |
| 28 | Diagonais cruzadas (X de oito pixels) |
| 29 / 30 | Diagonal `/` / diagonal `\` |
| 31 | Cruz com haste vertical curta |
| 128 | Hachura quadriculada de oito pixels |
| 143 / 144 | Quadrado vazado / preenchido de seis pixels |
| 158 | Faixa cheia de oito pixels de largura e cinco de altura |
| 159 | Três linhas horizontais alternadas |
| 160; cópia 219 | Bloco totalmente preenchido (espaço inverso) |
| 165–168 | Setas: esquerda, direita, cima, baixo |
| 169–173 | Ícones `F1`–`F5` |
| 174 | Ponto inverso; não é um bloco uniforme |
| 96 / 192 | Pequenos desenhos distintos; significado não confirmado |
| 221–224 | Peças gráficas especiais; significado não confirmado |

As identificações geométricas e a inversão foram conferidas nos bytes;
os significados dos pictogramas sem identificação segura permanecem
explicitamente em aberto.

## Uso do include

Como o Basic Dignified isola defines, rótulos e variáveis longas por
include, a interface usa **variáveis curtas compartilhadas**, como os
outros includes do projeto:

- `am = 0`: inicializa uma vez os arrays e os logotipos.
- `af$(codigo)`: sequência pronta para imprimir qualquer glifo.
  Para 0–31 usa `CHR$(1) + CHR$(codigo + 64)`, evitando controles
  como quebra de linha e movimento do cursor. O código 127 é `DEL` no
  MSX-BASIC e seu padrão nesta fonte é vazio: `af$(127)` imprime um
  espaço (código 32), em vez de apagar a célula anterior.
- `qn$()`, `qs$()`, `qh$()`, `qb$()`: famílias de quadros nas ordens acima.
- `mx$`: logotipo MSX completo de quatro células.
- `sg$`: inscrição de quatro células, sem atribuir uma leitura incerta.
- `am = 1`, `at$`: converte texto normal para vídeo inverso em `ar$`.
  Texto vazio é aceito; qualquer caractere fora das faixas validadas
  gera `ERROR 5`, em vez de substituir silenciosamente por um gráfico.

Não execute a inicialização duas vezes: `DIM` repetido gera erro no
MSX-BASIC. A conversão não depende da inicialização e pode ser repetida.
Reserve os nomes curtos acima no programa chamador.
Os 200 bytes de strings reservados por padrão não bastam para o mapa.
Use, por exemplo, `CLEAR 2048` **no início do programa**, antes de criar
variáveis e arrays; não faça isso no meio de um jogo, pois `CLEAR` os apaga.

```basic
rem -- Executar depois de instalar os padroes de MENU.ALF na VRAM.
clear 2048
declare am, af, qn, qs, qh, qb, mx, sg, at, ar
am = 0
gosub {mapa_menu}
locate 2, 2
print mx$;
locate 2, 4
print qb$(0);
for trecho = 1 to 12
    print qb$(4);
next trecho
print qb$(1);
locate 2, 5
print qb$(6); space$(12); qb$(7);
locate 2, 6
print qb$(2);
for trecho = 1 to 12
    print qb$(5);
next trecho
print qb$(3);
at$ = "MSX Jogos 0123."
am = 1
gosub {mapa_menu}
locate 2, 8
print ar$;
end

{mapa_menu}
    include "..\include\menu-alf.dmx"
```

O caminho do exemplo é relativo a um fonte em uma pasta de volume.
O [menu do Volume I](../Volume-I/menu.dmx) já usa esse include e carrega
`ALFABETO.BIN` do disco antes de desenhar. O Cassino ainda usa os gráficos
anteriores; sua adaptação será feita separadamente.

## Validação

Na raiz do projeto:

```powershell
python resources\badig\badig.py tests\menu-alf.dmx -id msx --tk_tokenize -vb 4
$p = Start-Process openmsx -ArgumentList '-machine Gradiente_Expert_DD_Plus -diska tests -script tests\menu-alf.tcl' -PassThru -Wait
Get-Content tests\menu-alf.log
$p.ExitCode
```

O teste instala os padrões diretamente pela interface de depuração do
emulador, sem usar o endereço RAM do cabeçalho. Verifica o escape dos
controles, a composição dos quadros e do MSX, todas as faixas inversas,
texto vazio e a rejeição dos caracteres sem equivalente inverso.

Para verificar também o gerador e os exemplos:

```powershell
python resources\badig\badig.py examples\alfabeto.dmx -id msx --tk_tokenize -vb 4
python resources\badig\badig.py examples\demoalf.dmx -id msx --tk_tokenize -vb 4
Copy-Item resources\menu.alf examples\menu.alf
$p = Start-Process openmsx -ArgumentList '-machine Gradiente_Expert_DD_Plus -diska examples -script tests\alfabeto.tcl' -PassThru -Wait
Get-Content tests\alfabeto.log
$p.ExitCode
```

Esse teste **regenera ALFABETO.BIN a partir dos DATA**, confere seu
cabeçalho e todos os padrões com o original, e verifica os dois formatos
via `BLOAD` em `SCREEN 0`, `1` e nos três bancos de `SCREEN 2`.
Também verifica o atlas, o logotipo, os pixels da borda fina e da sombra
sólida, as cores de `SCREEN 2`
e a saída por Esc.
