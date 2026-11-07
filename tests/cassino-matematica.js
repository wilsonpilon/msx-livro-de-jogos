const assert = require('node:assert/strict');

function pagamento(a, b, c) {
    const simbolos = [a, b, c];
    const cerejas = simbolos.filter(s => s === 1).length;
    const naves = simbolos.filter(s => s === 9).length;
    let premio = cerejas === 3 ? 10 : cerejas === 2 ? 3 : a === 1 ? 1 : 0;
    if (simbolos.every(s => s === 7)) return 40;
    if (naves === 3 || (naves === 1 && simbolos.filter(s => s === 7).length === 2)) return 10;
    const comuns = simbolos.filter(s => s !== 9);
    if (comuns.every(s => s === comuns[0])) {
        premio = Math.max(premio, (comuns[0] === 1 ? 10 : 3) * (naves ? 2 : 1));
    }
    if (simbolos.every(s => (s >= 4 && s <= 6) || s === 9)) premio = Math.max(premio, 2);
    return premio;
}

const combinacoes = [];
for (let a = 1; a <= 9; a++) {
    for (let b = 1; b <= 9; b++) {
        for (let c = 1; c <= 9; c++) combinacoes.push([a, b, c]);
    }
}

const frequencias = {};
let soma = 0;
let somaHold = 0;
const expectativas = new Map();
for (const simbolos of combinacoes) {
    const premio = pagamento(...simbolos);
    frequencias[premio] = (frequencias[premio] || 0) + 1;
    soma += premio;
    // Mask 7 is excluded: at least one reel must spin.
    if (premio !== 0) continue;
    let melhorHold = 0;
    for (let mascara = 0; mascara < 7; mascara++) {
        const fixos = simbolos.map((s, i) => mascara & (1 << i) ? s : 0);
        const chave = fixos.join(',');
        if (!expectativas.has(chave)) {
            const finais = combinacoes.filter(r => r.every((s, i) => fixos[i] === 0 || fixos[i] === s));
            expectativas.set(chave, finais.reduce((total, r) => total + pagamento(...r), 0) / finais.length);
        }
        melhorHold = Math.max(melhorHold, expectativas.get(chave));
    }
    somaHold += melhorHold;
}

assert.deepEqual(frequencias, { 0: 546, 1: 63, 2: 42, 3: 27, 6: 39, 10: 5, 20: 6, 40: 1 });
assert.equal(soma, 672);
const retornoBase = soma / 729;
const ofertaPorGiroNormal = frequencias[0] / 729 / 12;
const retornoHold = somaHold / frequencias[0];
// A cycle is one normal spin, optionally followed by one paid Hold spin.
const retornoOtimo = (retornoBase + ofertaPorGiroNormal * retornoHold) / (1 + ofertaPorGiroNormal);
assert.ok(retornoBase > 0.92 && retornoBase < 0.93);
assert.ok(retornoOtimo > 0.97 && retornoOtimo < 0.98);
console.log(`PASS: RTP base ${(retornoBase * 100).toFixed(3)}%; Hold otimo ${(retornoOtimo * 100).toFixed(3)}%`);
