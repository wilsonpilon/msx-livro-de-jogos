# MSX Jogos — Projeto de modernização

![Arte do projeto: os três volumes de MSX Jogos e suas releituras digitais](./images/projeto-livro-de-jogos.jpg)

Este projeto revisita a coleção **MSX Jogos — Para Aprender e Criar e Jogos Profissionais**, publicada pela **McGraw-Hill nos anos 1980**, trazendo seus programas para um fluxo de trabalho atual sem perder de vista o computador e o espírito para os quais foram criados. A proposta é preservar e estudar os jogos originais, modernizar sua apresentação e, quando fizer sentido, experimentar novos recursos.

Os livros foram obtidos por meio do projeto **MSX Livros**, de **Alexandre Antoniutti**. A digitalização e a organização dos textos tornam possível consultar os sumários e trabalhar novamente com este material histórico. Nosso agradecimento a Alexandre e a todos que ajudam a preservar a memória do MSX.

## Como estamos trabalhando

Esta remodelagem combina ferramentas de inteligência artificial com pesquisa, testes e **inferência própria**. Gemini, Claude e GitHub Copilot são usados como assistentes para explorar ideias, apoiar a leitura e a organização do material e auxiliar no desenvolvimento. As decisões sobre interpretação do original, comportamento esperado, adaptações e prioridades são avaliadas por mim — a IA é apoio ao trabalho, não substitui essa análise nem a validação dos programas.

O ambiente principal de desenvolvimento é o **Visual Studio Code**. Os programas estão sendo escritos no dialeto da **Basic Dignified Suite**, que permite trabalhar com um estilo mais legível e organizado e gerar BASIC compatível com o ambiente clássico do MSX. A intenção é manter o código acessível a quem quer aprender, estudar e modificar os jogos.

### Ferramentas

- [**Gemini**](https://gemini.google.com/) — assistência de IA para pesquisa, exploração de ideias e apoio ao trabalho.
- [**Claude**](https://claude.ai/) — assistência de IA para análise e desenvolvimento.
- [**GitHub Copilot**](https://github.com/features/copilot) — assistência de IA integrada ao fluxo de desenvolvimento.
- [**Visual Studio Code**](https://code.visualstudio.com/) — editor e ambiente de desenvolvimento.
- [**Basic Dignified Suite**](https://github.com/farique1/basic-dignified) — ferramentas e dialeto usados para escrever e preparar os programas em BASIC.
- **SDCC** e [**MSXgl**](https://github.com/aoineko-fr/MSXgl) — ferramentas consideradas para eventuais versões em C: o compilador SDCC e a biblioteca MSXgl para desenvolvimento no MSX.

## Modernização das listagens: Cassino

As listagens originais são preservadas como referência e retrabalhadas para facilitar a leitura, a manutenção e a evolução do jogo. O exemplo abaixo é a listagem numerada original de [cassino.bas](./Volume-I/cassino.bas), com 31 linhas:

```basic
10 REM -- CASSINO
20 SCREEN0:F=RND(-TIME)
30 FORI=1TOF:Y=RND(1):NEXT
40 PRINT:INPUT"QUANTIA INICIAL :";P
50 COLOR13,14:CLS
60 FORI=1TO3
70 LOCATE4+7*I,5:PRINT"+---+":LOCATE4+7*I,6:PRINT"!   !":LOCATE4+7*I,7:PRINT"+---+"
80 NEXTI
90 LOCATE13,6:PRINT" ":LOCATE20,6:PRINT" ":LOCATE27,6:PRINT" "
100 LOCATE0,11:INPUT"SUA APOSTA :";M
110 IFM=0ORM>PTHEN290
120 GOSUB270
130 A=X
140 GOSUB270
150 B=X
160 GOSUB270
170 LOCATE12,6:PRINTA:LOCATE19,6:PRINTB:LOCATE26,2:PRINTX
180 IFA=BANDA=XTHEN240
190 N=-M
200 LOCATE0,11:PRINT"APOSTA :";M;" - RESULTADO :";N;"    "
210 PRINT:PRINT"PRESSIONE UMA TECLA":R$=INPUT$(1)
220 P=P+N
230 GOTO50
240 N=M*50
250 IFA=7THENN=M*500
260 GOTO200
270 X=INT(RND(1)*9+1):PLAY"L32A"
280 RETURN
290 CLS
300 PRINT"VOCE TEM ";P
310 PRINT"ATE LOGO.":PLAY"CDEFG"
```

Essa listagem é a base histórica, não uma conversão automática linha por linha. A versão modernizada em [cassino.dmx](./Volume-I/cassino.dmx) reorganiza o fluxo em blocos identificados por rótulos, troca nomes curtos por nomes descritivos e separa tarefas em rotinas. Também amplia a apresentação, a animação dos rolos e os efeitos sonoros. Por isso, a lógica central do cassino permanece reconhecível, mas a experiência e a estrutura do programa foram desenvolvidas além do original.

### Mudanças nos gráficos

Na listagem original, os rolos são desenhados com caracteres simples (`+---+` e `!   !`) e ocupam poucas posições da tela. A versão modernizada monta uma moldura para a tela de 40 colunas usando os caracteres gráficos internacionais do MSX, representados por `chr$(1)` seguido dos códigos 86 a 91. A moldura é desenhada por uma rotina própria e reutilizada na abertura, nas rodadas e na tela de encerramento.

Os três rolos também ganham caixas alinhadas, áreas separadas para saldo, aposta e resultado, instruções na tela e mensagens contextuais. Durante o sorteio, cada rolo mostra uma sequência curta de números em movimento antes de parar. As mudanças de cor ajudam a distinguir as etapas e resultados: por exemplo, a rodada usa texto amarelo, a perda usa vermelho e o prêmio máximo usa texto amarelo sobre fundo azul. No `SCREEN 0`, a cor é aplicada à tela toda, não individualmente a cada rolo.

```basic
rem -- Graficos internacionais: prefixo chr$(1), codigos 86 a 91.
vertical$ = chr$(1) + chr$(86)
horizontal$ = chr$(1) + chr$(87)
canto_superior_esquerdo$ = chr$(1) + chr$(88)
canto_superior_direito$ = chr$(1) + chr$(89)
canto_inferior_esquerdo$ = chr$(1) + chr$(90)
canto_inferior_direito$ = chr$(1) + chr$(91)
```

### Mudanças no som

No original, o giro toca um efeito curto (`PLAY "L32A"`) e a saída toca uma sequência simples (`PLAY "CDEFG"`). Na versão modernizada, os sons acompanham diferentes eventos: a abertura tem uma pequena música, cada passo do giro recebe um clique e o fim do giro tem um som próprio. Perdas, acertos comuns, prêmio máximo e encerramento também têm sequências distintas. As instruções `PLAY` passam parâmetros de andamento, oitava, volume e duração; várias sequências são tocadas em paralelo pelos canais do PSG do MSX.

```basic
play "t255o5v8l64c"
play "t255o6v10l32g"
play "t200o5v12l8cego6c4", "t200o4v8l4ceg2", "t200o3v6l4cgr2"
```

Por exemplo, a preparação da semente aleatória, antes condensada nas linhas 20–30, fica mais clara no Dignified:

```basic
screen 0
width 40
key off
color 11, 1, 1
semente_aleatoria = rnd(-time)
for indice = 1 to semente_aleatoria
    descarte_aleatorio = rnd(1)
next
```

E as linhas numeradas e saltos do original dão lugar a rótulos e desvios legíveis. O giro, por exemplo, passa a ser uma rotina reutilizável:

```basic
{sortear_numero}
    for passo_giro = 1 to 8
        numero_sorteado = int(rnd(1) * 9 + 1)
        locate coluna_rolo, 8
        print chr$(48 + numero_sorteado);
        play "t255o5v8l64c"
    next passo_giro
    play "t255o6v10l32g"
    return
```

O arquivo `.dmx` é o código-fonte legível no dialeto Basic Dignified. A suíte converte esse código para BASIC numerado de MSX (arquivo `.amx`), que pode então ser tokenizado e executado no computador ou emulador. Assim, a transformação do projeto é: listagem original `.bas` como referência → fonte modernizado `.dmx` → BASIC MSX gerado. O `.dmx` completo e a listagem original podem ser consultados nos links acima.

## Listagem completa de `cassino.dmx`

Abaixo está a listagem integral atual do fonte em Basic Dignified para MSX:

```basic
rem -- CASSINO

screen 0
width 40
key off
color 11, 1, 1
semente_aleatoria = rnd(-time)
for indice = 1 to semente_aleatoria
    descarte_aleatorio = rnd(1)
next

rem -- Graficos internacionais: prefixo chr$(1), codigos 86 a 91.
vertical$ = chr$(1) + chr$(86)
horizontal$ = chr$(1) + chr$(87)
canto_superior_esquerdo$ = chr$(1) + chr$(88)
canto_superior_direito$ = chr$(1) + chr$(89)
canto_inferior_esquerdo$ = chr$(1) + chr$(90)
canto_inferior_direito$ = chr$(1) + chr$(91)
linha_horizontal$ = ""
for indice = 1 to 36
    linha_horizontal$ = linha_horizontal$ + horizontal$
next
topo_rolo$ = canto_superior_esquerdo$
base_rolo$ = canto_inferior_esquerdo$
for indice = 1 to 5
    topo_rolo$ = topo_rolo$ + horizontal$
    base_rolo$ = base_rolo$ + horizontal$
next
topo_rolo$ = topo_rolo$ + canto_superior_direito$
base_rolo$ = base_rolo$ + canto_inferior_direito$

{abertura}
    gosub {desenhar_moldura}
    locate 8, 5
    print "A sorte esta nos numeros!"
    locate 4, 7
    print "Escolha o saldo e faca sua aposta."
    locate 4, 9
    print "Tres iguais: ganhe 50 x a aposta."
    locate 4, 11
    print "Tres setes: ganhe 500 x a aposta!"
    locate 4, 13
    print "Outros numeros: perde a aposta."
    locate 4, 15
    print "Aposte zero para sair do jogo."
    locate 4, 18
    print "Pressione uma tecla para comecar"
    play "t180o5v10l8cego6c4", "t180o3v7l4cge2"
    tecla$ = input$(1)
    color 15, 1, 1
    gosub {desenhar_moldura}
    locate 4, 8
    input "Quantia inicial :"; saldo

{iniciar_rodada}
    color 10, 1, 1
    gosub {desenhar_moldura}
    for indice = 1 to 3
        coluna_rolo = 6 + (indice - 1) * 10
        locate coluna_rolo, 7
        print topo_rolo$;
        locate coluna_rolo, 8
        print vertical$; "     "; vertical$;
        locate coluna_rolo, 9
        print base_rolo$;
    next indice

    locate 4, 11
    print "Saldo :"; saldo
    locate 4, 18
    print "Aposte zero para encerrar"
    locate 4, 13
    input "Sua aposta :"; aposta
    if aposta = 0 or aposta > saldo then {encerrar}

    color 11, 1, 1
    locate 4, 16
    print "Girando...";
    coluna_rolo = 9
    gosub {sortear_numero}
    primeiro_numero = numero_sorteado
    coluna_rolo = 19
    gosub {sortear_numero}
    segundo_numero = numero_sorteado
    coluna_rolo = 29
    gosub {sortear_numero}

    if primeiro_numero = segundo_numero and primeiro_numero = numero_sorteado then {premiar_acerto}
    resultado = -aposta
    mensagem_resultado$ = "Nao foi desta vez. Tente de novo!"
    color 8, 1, 1
    play "t160o4v9l8gec4", "t160o3v6l4cr4"

{mostrar_resultado}
    saldo = saldo + resultado
    locate 4, 13
    print space$(32);
    locate 4, 13
    print "Aposta :"; aposta
    locate 4, 14
    print "Resultado :"; resultado
    locate 4, 16
    print mensagem_resultado$;
    locate 4, 18
    print space$(32);
    locate 4, 18
    print "Saldo atualizado :"; saldo
    locate 4, 20
    print "Pressione uma tecla"
    tecla$ = input$(1)
    goto {iniciar_rodada}

{premiar_acerto}
    resultado = aposta * 50
    mensagem_resultado$ = "Tres iguais! Voce ganhou!"
    color 3, 1, 1
    if primeiro_numero = 7 then {premiar_setes}
    play "t200o5v12l8cego6c4", "t200o4v8l4ceg2", "t200o3v6l4cgr2"
    goto {mostrar_resultado}

{premiar_setes}
    resultado = aposta * 500
    mensagem_resultado$ = "Sete, sete, sete! Premio maximo!"
    color 10, 4, 4
    play "t220o5v13l16cego6cego5c4", "t220o4v9l8cego5c4", "t220o3v8l8cgcg4"
    goto {mostrar_resultado}

{sortear_numero}
    for passo_giro = 1 to 8
        numero_sorteado = int(rnd(1) * 9 + 1)
        locate coluna_rolo, 8
        print chr$(48 + numero_sorteado);
        play "t255o5v8l64c"
    next passo_giro
    play "t255o6v10l32g"
    return

{encerrar}
    color 11, 1, 1
    gosub {desenhar_moldura}
    locate 8, 7
    print "Obrigado por jogar!"
    locate 4, 10
    print "Voce tem :"; saldo
    locate 8, 14
    print "Ate a proxima rodada!"
    play "t160o5v10l8gec4", "t160o3v7l4gc2"
    key on
    end

{desenhar_moldura}
    cls
    locate 1, 1
    print canto_superior_esquerdo$; linha_horizontal$; canto_superior_direito$;
    for linha_tela = 2 to 21
        locate 1, linha_tela
        print vertical$;
        locate 38, linha_tela
        print vertical$;
    next linha_tela
    locate 1, 22
    print canto_inferior_esquerdo$; linha_horizontal$; canto_inferior_direito$;
    locate 14, 3
    print "Cassino MSX";
    return
```

## Os volumes

Os títulos abaixo seguem os sumários dos três livros. Não há um link separado para cada jogo: esta lista serve como visão geral da coleção e do material em processo de modernização.

### Volume I

**Cassino**, **Batalha Naval**, **Gorks**, **Vinte e Um**, **Roleta**, **O Eletricista Louco**, **Frogger**, **Tubarão!**, **O Jogo do Cemitério**, **Fórmula Um**, **Poker Profissional**, **Trem Maluco**, **Caple**, **Fórmula Interlagos** e **Labirinto Tridimensional**.

### Volume II

**O Indesejável**, **Poker**, **Prestidigitador**, **Máquina de Palavras**, **Letras**, **Loteria**, **Gênio Musical**, **Luna Um**, **Raposa**, **Pesca Piranha**, **Vinte e Um**, **Guerra dos Mundos**, **Decida-se!**, **Montador**, **Packman Sinistro** e **Capture os Mongas**.

### Volume III

**Quente, Frio**, **O Jogo da Vida**, **O Enforcado**, **Corrida de Cavalos**, **Destreza**, **Meteorito Espacial**, **Fujão**, **Fórmula 1 Suicida**, **Barreira**, **Invasores Espaciais**, **Rocky Rock** e **Torre do Mistério**. O volume também apresenta os programas **Gráficos**, **Caixa de Música**, **Bach** e **Dança do Inseto**; **Montador** aparece no sumário como utilitário, não como jogo.

## Possíveis versões e novos recursos

O foco é a versão em BASIC para MSX, mas algumas ideias podem ganhar adaptações: certos jogos poderão ser portados para **MSX 2**, com recursos de **som FM**, ou receber duas versões para diferentes configurações. Um ou outro também poderá ser refeito em **C**, usando **SDCC + MSXgl**. Essas possibilidades dependem da viabilidade de cada jogo e não significam que todas as versões já estejam implementadas.

## Progresso e imagens

Este README acompanhará a evolução do projeto. Conforme os jogos forem sendo desenvolvidos e testados, serão acrescentados detalhes, observações e screenshots para mostrar o código e os resultados em execução.

## Créditos

- **Oscar Júlio Burd** e **Luiz Sérgio Young Moreira** — autores dos livros originais.
- **McGraw-Hill** — editora da coleção original.
- **Alexandre Antoniutti** e o projeto **MSX Livros** — fonte dos livros utilizados nesta iniciativa de preservação e modernização.
- **Farique** — autor da **Basic Dignified Suite**.
- **SDCC** — compilador C para microcontroladores e sistemas embarcados, considerado para possíveis versões em C.
- **Aoinéko** — autor do **MSXgl**, considerado para possíveis versões em C para MSX.
- **Google/Gemini**, **Anthropic/Claude**, **GitHub Copilot** e **Microsoft/Visual Studio Code** — ferramentas utilizadas como apoio ao desenvolvimento.

Este trabalho é uma iniciativa independente de preservação e modernização, inspirada na coleção original. Os créditos aos autores, à editora, às ferramentas e às fontes do material são mantidos em reconhecimento às suas contribuições.

## Manifesto pessoal

---

<div align="center">
  <img src="images/Wilson-Hacker-Small.png" alt="Wilson Hacker" width="300px">

  ## ⚠️ Manifesto do Repositório: Projetos Estritamente Pessoais ⚠️
</div>

> *Se você tropeçou neste GitHub ou site, saiba que provavelmente foi por acidente, já que eu não faço a menor questão de divulgar o que construo por aqui.*

Este espaço é o meu **asilo digital**. Aqui você vai encontrar uma coleção caótica de utilitários, ferramentas, linguagens, jogos e remakes voltados para MSX, ZX-81, ZX-Spectrum e IBM-PC clássico. Antes que você comece a analisar o código ou tentar rodar alguma coisa, vamos deixar as expectativas bem alinhadas:

* 🛑 **Inutilidade Pública:** Estes projetos são de cunho estritamente pessoal. Em momento algum a minha ideia foi criar algo inovador, revolucionário ou "útil de verdade" para a humanidade. Eles existem única e exclusivamente porque me interessam.

* 🤷‍♂️ **Garantia Zero (As-Is):** Se, por algum milagre, você achar algo útil no meio disso tudo, sinta-se à vontade para usar, clonar ou modificar. Mas fique avisado: **não há absolutamente nenhuma garantia**. Se rodar, ótimo. Se queimar a sua máquina, o problema é seu.

* 🤖 **Código, IA e Terapia:** Não tenho a menor vergonha de misturar o meu próprio conhecimento de décadas com Inteligência Artificial para fazer as coisas funcionarem. O motivo é simples: isso aqui é para diversão e alívio de estresse. Estes projetos funcionam como a minha **terapia pessoal** para lidar com problemas de saúde física e mental. O objetivo final é o meu bem-estar, não a perfeição algorítmica ou agradar puristas.

* 🚫 **Ouvidoria Fechada:** Sugestões? Elas podem (ou não) ser bem-vindas, dependendo puramente do meu humor no dia. Já as críticas e "cagadas de regra", peço a gentileza de que as guarde com muito carinho para si mesmo. Se achou o código ineficiente, mal documentado ou fora dos seus padrões, recomendo fortemente que você abra o seu próprio editor, faça melhor do zero e seja muito feliz no seu próprio repositório.

---

<div align="center">
  <em>Resumindo: minha única intenção é curtir meus projetos em paz e no meu próprio ritmo.<br>Aproveite o código (ou não) e siga o seu rumo.</em> ✌️
</div>

---