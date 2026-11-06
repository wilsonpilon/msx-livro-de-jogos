# Cassino MSX - historico da conversa e estado do trabalho

Registro da conversa de 05/11/2026, em ordem cronologica. As solicitacoes e
respostas abaixo preservam o conteudo da conversa; a execucao das ferramentas
esta consolidada nas notas tecnicas, sem transcrever seus logs.

## 1. Conversao inicial para Basic Dignified

### Solicitacao do usuario

> Temos a estrutura do Basic Dignified Suite que troca os goto e gosub
> numericos por labels e elimina linhas, voce consegue mudar esta listagem
> para eliminar as linhas e usar labels para podermos nor adequar
> inicialmente ao Basic Dignified? aproveite e espace bem os comandos que
> estao todos ligados uns nos outros, tente inferir nas variaveis e mude
> para nomes longos que facam mais sentido so que simples letras

Arquivo indicado: [cassino.dmx](cassino.dmx), originalmente com 31 linhas
numeradas de 10 a 310.

### Trabalho realizado

- Removida a numeracao das linhas.
- Substituidos os destinos numericos de `goto`, `gosub` e `then` por labels.
- Separados os comandos concatenados por dois-pontos em linhas individuais.
- Aplicados espacos e indentacao no laco.
- Mantidas inicialmente a logica, as mensagens e as coordenadas originais.
- Conferida a sintaxe na documentacao do Basic Dignified Suite.
- Localizada a implementacao Python original em
  `C:\dos\goBaDig\badig\badig.py`.

Renomeacao das variaveis originais:

| Original | Nome descritivo |
|---|---|
| F | semente_aleatoria |
| I | indice |
| Y | descarte_aleatorio |
| P | saldo |
| M | aposta |
| A | primeiro_numero |
| B | segundo_numero |
| X | numero_sorteado |
| N | resultado |
| R$ | tecla$ |

### Resposta entregue

> Atualizei cassino.dmx:
>
> - Removi a numeracao e substitui os saltos por labels `{nome}`.
> - Separei os comandos em linhas, com espacamento e indentacao.
> - Renomeei variaveis para nomes como `saldo`, `aposta`, `resultado` e
>   `numero_sorteado`.
> - Preservei a logica, as mensagens e as posicoes de tela originais.
>
> Validado com sucesso no conversor Basic Dignified para MSX.
> Nao testado em emulador.

## 2. Padronizacao visual do fonte

### Solicitacao do usuario

> Otimo, agora faca a identacao nos labels para ficar tudo organizado,
> tambem troque todos os comandos e palavras chave para minusculas, os
> literais dos campos play tambem para minusculas. As literais de input e
> print mude para Capitalizado

### Trabalho realizado

- Labels mantidos na margem esquerda.
- Blocos abaixo dos labels indentados com quatro espacos.
- Corpos de lacos dentro desses blocos indentados com oito espacos.
- Comandos, funcoes e palavras-chave convertidos para minusculas.
- Sequencias MML de `play` convertidas para minusculas.
- Mensagens de `print` e `input` com inicial maiuscula e restante em
  minusculas, preservando a escrita sem acentos no programa MSX.
- Nova conversao de validacao concluida.

### Resposta entregue

> Atualizado em cassino.dmx:
>
> - Blocos indentados abaixo dos labels.
> - Comandos e palavras-chave em minusculas.
> - Literais de `play` em minusculas.
> - Mensagens de `input` e `print` com inicial maiuscula.
>
> Conversao validada no Basic Dignified, sem alterar a logica.

## 3. Abertura, cores, molduras e audio

### Solicitacao do usuario

> Agora a partir do cassino.md crie uma abertura para o jogo, pode ser na
> mesma screen do jogo para nao ficar destoante., aproveite e coloque mais
> cores no jogo, melhore os efeitos sonoros/musicas do jogo e a tela que
> desenha os quadros com +-- mude para os caracteres do MSX que geram
> quadros graficos, use a tabela internacional do msx

### Trabalho realizado

- Lido [cassino.md](cassino.md) como referencia das regras.
- Mantido `screen 0`, com `width 40` e `key off` durante o jogo.
- Criada abertura com regras, pagamentos e espera por qualquer tecla.
- Criada moldura externa comum a abertura, jogo e despedida.
- Substituidos os quadros ASCII dos rolos por caracteres graficos MSX.
- Reposicionados os tres numeros dentro dos respectivos quadros,
  inclusive o terceiro, antes exibido fora do seu quadro.
- Adicionadas oito atualizacoes aleatorias por rolo, com cliques e
  som de parada.
- Adicionadas melodias PSG para abertura, perda, acerto comum,
  premio maximo e despedida.
- Adicionadas paletas por etapa; em `screen 0` a cor do texto e global,
  nao individual por caractere ou quadro.
- Mantidos os pagamentos e a regra de encerramento da listagem original.
- Atualizado [cassino.md](cassino.md), inclusive a referencia ao fonte,
  antes descrito como `cassino.bas`, e a combinacao especial, que e
  7-7-7, nao limoes.

### Molduras internacionais

Cada caractere grafico e impresso como `chr$(1) + chr$(codigo)`.
O prefixo evita interpretar os graficos como comandos de controle.

| Codigo apos o prefixo | Grafico |
|---|---|
| 86 | Linha vertical |
| 87 | Linha horizontal |
| 88 | Canto superior esquerdo |
| 89 | Canto superior direito |
| 90 | Canto inferior esquerdo |
| 91 | Canto inferior direito |

Fontes consultadas:

- [Basic Dignified Suite](https://github.com/farique1/basic-dignified)
- [Sintaxe do Basic Dignified](https://github.com/farique1/basic-dignified/blob/main/documentation/BASIC_DIGNIFIED.md)
- [CHR$ no MSX](https://www.msx.org/wiki/CHR$())
- [Tabela de caracteres e controles MSX](https://www.msx.org/wiki/MSX_Characters_and_Control_Codes)
- [PLAY](https://www.msx.org/wiki/PLAY)
- [COLOR](https://www.msx.org/wiki/COLOR)

A correspondencia dos graficos tambem foi conferida no modulo MSX
local do Basic Dignified.

### Cores implementadas

| Etapa | Texto | Fundo |
|---|---|---|
| Abertura | 11, ciano claro | 1, preto |
| Entrada do saldo | 15, branco | 1, preto |
| Aposta | 10, amarelo | 1, preto |
| Giro | 11, ciano claro | 1, preto |
| Perda | 8, vermelho | 1, preto |
| Tres iguais | 3, verde claro | 1, preto |
| Tres setes | 10, amarelo | 4, azul escuro |
| Despedida | 11, ciano claro | 1, preto |

### Resposta entregue

> Atualizei cassino.dmx com:
>
> - Abertura com regras e premios.
> - Cores diferentes por etapa, mantendo `screen 0`.
> - Molduras graficas da tabela internacional do MSX.
> - Rolos animados, cliques e musicas distintas para vitorias, perdas e
>   saida.
>
> Tambem atualizei cassino.md.
>
> Conversao e tokenizacao validadas; textos conferidos dentro da moldura.
> Ainda falta conferir imagem e audio em emulador.

## 4. Pedido de pausa e documentacao para retomada

### Solicitacao do usuario

> salve um OUTLINE.md com toda nossa conversa e um resume.txt para
> concluirmos o trabalho outro dia

Entregas desta etapa:

- Este [OUTLINE.md](OUTLINE.md): historico completo das etapas,
  solicitacoes, respostas e decisoes tecnicas.
- [resume.txt](resume.txt): passagem de contexto objetiva para a proxima
  sessao.
- Nenhuma alteracao no jogo nesta etapa de documentacao.

## Estado atual

### Arquivos

- [cassino.dmx](cassino.dmx): fonte Basic Dignified para MSX, com 165 linhas
  no momento desta pausa.
- [cassino.md](cassino.md): descricao, instrucoes, apresentacao e premios.
- [palito.dzx](palito.dzx): fora do escopo; nao alterado nesta conversa.
- [OUTLINE.md](OUTLINE.md): este historico.
- [resume.txt](resume.txt): instrucoes para retomada.

Embora a pasta se chame `zx81-colecao`, este jogo e MSX-BASIC; usar o
dialeto MSX, nao ZX81.

### Fluxo do programa

Inicializacao e construcao das strings graficas, seguidas de:

1. `{abertura}`: regras, musica e entrada do saldo.
2. `{iniciar_rodada}`: desenho dos rolos, saldo, aposta e sorteios.
3. `{mostrar_resultado}`: atualiza o saldo, mostra resultado e aguarda tecla.
4. `{premiar_acerto}`: pagamento comum.
5. `{premiar_setes}`: pagamento especial.
6. `{sortear_numero}`: subrotina de animacao e sorteio.
7. `{encerrar}`: despedida, `key on` e `end`.
8. `{desenhar_moldura}`: subrotina compartilhada para tela e titulo.

### Regras preservadas

- Numeros sorteados de 1 a 9.
- Tres iguais: soma 50 vezes a aposta ao saldo.
- Tres setes: soma 500 vezes a aposta ao saldo.
- Outras combinacoes: subtrai a aposta.
- Nao ha desconto separado da aposta antes de um premio.
- Aposta zero ou maior que o saldo encerra a partida.
- Entradas negativas e outros casos de validacao nao foram
  redesenhados nesta conversa.

## Validacoes executadas

- Conversao Python Basic Dignified com `-id msx`: sucesso.
- Conversao apos padronizacao de caixa e indentacao: sucesso.
- Conversao e tokenizacao da versao visual com `--tk_tokenize`: sucesso.
- Binario de teste gerado: 2.600 bytes.
- Conferidas coordenadas constantes e mensagens literais dentro da
  moldura, em tela de 40 colunas.
- Uma mensagem da abertura foi encurtada apos a verificacao detectar
  invasao da borda.
- Conferido que as linhas BASIC geradas nao excediam 255 caracteres.
- Conferidas as sequencias MML contra o subconjunto utilizado.
- Saidas temporarias `.amx` e `.bmx` de validacao foram removidas.

Essas verificacoes nao substituem execucao no MSX. Nao houve teste em
emulador nem em hardware real. Valores numericos digitados pelo jogador
nao tiveram todas as larguras ou faixas possiveis verificadas.

Exemplo de comando para repetir a validacao, em PowerShell, a partir da
pasta do jogo:

```powershell
python ..\resources\badig\badig.py .\cassino.dmx .\cassino.amx -id msx --tk_tokenize -vb 4
```

Esse comando gera `cassino.amx` e `cassino.bmx`. Executar a listagem
convertida/tokenizada no emulador; o fonte `.dmx` nao e BASIC numerado
diretamente carregavel no MSX.

O conversor Python original foi utilizado porque o README local de
goBaDig consultado na conversa descrevia o executavel Go como stub,
ainda sem conversor/tokenizer. Reavaliar essa situacao antes de trocar
a ferramenta de validacao.

## Proximos passos sugeridos, ainda nao executados

1. Abrir o jogo convertido em emulador com tabela internacional MSX.
2. Conferir conexoes e proporcoes das molduras, alinhamento dos tres
   numeros e ausencia de rolagem da tela.
3. Ouvir as melodias e ajustar volume, duracao e sincronizacao dos
   cliques com os rolos, caso necessario.
4. Exercitar perda, tres iguais e tres setes; os premios raros podem
   exigir uma copia temporaria de teste com resultados controlados,
   sem deixar sorteios forcados no fonte final.
5. Conferir saldo atualizado, nova rodada, aposta zero, aposta maior
   que o saldo e restauracao da linha de teclas ao encerrar.
6. Avaliar valores longos, entradas negativas e politica de validacao
   antes de alterar o comportamento herdado.
7. Atualizar este historico e a documentacao caso haja novos ajustes.

Nao foi estabelecida uma nova funcionalidade obrigatoria para a proxima
sessao. A pendencia principal e a validacao visual e sonora em execucao.
