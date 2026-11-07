const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const destino = process.argv[2];
if (!destino) throw new Error('Informe a pasta temporaria para o jogo de teste.');
const raiz = path.resolve(__dirname, '..');
let fonte = fs.readFileSync(path.join(raiz, 'Volume-I', 'cassino.dmx'), 'utf8');

function substituir(antes, depois) {
    assert.equal(fonte.split(antes).length, 2, `Trecho de teste ausente ou duplicado: ${antes}`);
    fonte = fonte.replace(antes, depois);
}

// Only random outcomes are controlled; the production gameplay stays intact.
substituir('numero_sorteado = int(rnd(1) * 9 + 1)', 'read numero_sorteado');
substituir('int(rnd(1) * 12) = 0', '0 = 0');
substituir('lado_sorteado = int(rnd(1) * 2)', 'lado_sorteado = 0');
substituir('gosub {definir_simbolos}', 'gosub {definir_simbolos}\nrestore {dados_testes}');
for (const arquivo of ['entrada.dmx', 'premios.dmx']) {
    substituir(`include "..\\include\\${arquivo}"`, `include "${path.join(raiz, 'include', arquivo)}"`);
}

const giros = [
    [2, 3, 8], // loss: offer Hold
    [2], // reels 1 and 2 held; only reel 3 spins
    [1, 1, 9], // cherry wildcard, successful gamble
    [7, 7, 9], // near jackpot, failed gamble
    [4, 5, 6], // mixed family, collect
    [7, 7, 7], // jackpot, collect
    [2, 3, 8], // offer Hold again
    [8, 2, 3], // changed stake cancels Hold
    [1, 2, 3], // one cherry on reel 1 refunds the stake
];
const numeros = giros.flatMap(giro => giro.flatMap(simbolo => Array(8).fill(simbolo)));
fonte += '\n{dados_testes}\n';
for (let inicio = 0; inicio < numeros.length; inicio += 16) {
    fonte += `    data ${numeros.slice(inicio, inicio + 16).join(',')}\n`;
}
fs.mkdirSync(destino, { recursive: true });
const arquivo = path.join(destino, 'cassino.dmx');
fs.writeFileSync(arquivo, fonte);
console.log(arquivo);
