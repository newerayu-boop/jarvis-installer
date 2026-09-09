'use strict';
// Тесты разбора ввода продавца. Запуск: node --test qa/tests/
// Зелёный тест = поведение зафиксировано и не сломается при правках.
// todo-тест   = известная дырка, описана в отчёте qa/report/BUGS.md.

const test = require('node:test');
const assert = require('node:assert');
const path = require('path');

const TP = path.join(__dirname, '..', '..', '..', 'ticket-platform');
const { parseInput, caption, GREETING, NOT_UNDERSTOOD } = require(path.join(TP, 'lib', 'messages'));
const config = require(path.join(TP, 'config'));

test('обычный ввод: имя + номер', () => {
  assert.deepStrictEqual(parseInput('Nurgul Bekova 13'), { name: 'Nurgul Bekova', number: '13', tarif: undefined });
});

test('имя + номер + тариф', () => {
  const r = parseInput('Nurgul Bekova 13 VIP');
  assert.strictEqual(r.name, 'Nurgul Bekova');
  assert.strictEqual(r.number, '13');
  assert.strictEqual(r.tarif, 'VIP');
});

test('запятая между именем и номером', () => {
  assert.strictEqual(parseInput('Nurgul Bekova, 13').name, 'Nurgul Bekova');
});

test('лишние пробелы по краям не мешают', () => {
  assert.strictEqual(parseInput('   Nurgul Bekova 13   ').number, '13');
});

test('узбекские апострофы в имени сохраняются', () => {
  assert.strictEqual(parseInput("Sherzod O'g'li 7").name, "Sherzod O'g'li");
});

test('кириллица в имени работает', () => {
  assert.strictEqual(parseInput('Гулнора Каримова 5').name, 'Гулнора Каримова');
});

test('перенос строки вместо пробела перед тарифом', () => {
  assert.strictEqual(parseInput('Nurgul Bekova 13\nVIP').tarif, 'VIP');
});

test('мусорный текст не превращается в билет', () => {
  assert.strictEqual(parseInput('Salom'), null);
  assert.strictEqual(parseInput('/start'), null);
  assert.strictEqual(parseInput(''), null);
});

test('подпись к билету содержит имя, номер и тариф', () => {
  const cap = caption({ name: 'Nurgul Bekova', number: '13' });
  assert.match(cap, /Nurgul Bekova/);
  assert.match(cap, /#13/);
  assert.match(cap, new RegExp(config.defaultTarif), 'тариф по умолчанию должен подставляться');
});

test('приветствие показывает пример правильного ввода', () => {
  assert.match(GREETING, /\d/, 'в примере должен быть номер');
  assert.ok(GREETING.length > 20);
});

// ── Известные дырки: продавец так пишет, а бот отвечает «не понял» ──
test('номер со знаком #: «Nurgul Bekova #13»', { todo: 'баг QA-01, см. qa/report/BUGS.md' }, () => {
  assert.strictEqual(parseInput('Nurgul Bekova #13').number, '13');
});

test('сначала номер: «13 Nurgul Bekova»', { todo: 'баг QA-02' }, () => {
  assert.strictEqual(parseInput('13 Nurgul Bekova').name, 'Nurgul Bekova');
});

test('имя и номер через тире: «Nurgul Bekova - 13»', { todo: 'баг QA-03' }, () => {
  assert.strictEqual(parseInput('Nurgul Bekova - 13').name, 'Nurgul Bekova');
});

test('тариф с эмодзи не должен ломать разбор', { todo: 'баг QA-04' }, () => {
  assert.ok(parseInput('Nurgul Bekova 13 🔥'));
});

test('текст «не понял» должен подсказывать формат', () => {
  assert.match(NOT_UNDERSTOOD, /\d/, 'в подсказке должен быть пример с номером');
});
