'use strict';
// Тесты генерации картинки билета. Каждый кейс — то, что реально придёт от продавца.

const test = require('node:test');
const assert = require('node:assert');
const path = require('path');

const TP = path.join(__dirname, '..', '..', '..', 'ticket-platform');
const { renderTicketPng } = require(path.join(TP, 'lib', 'ticket'));

const PNG_MAGIC = Buffer.from([0x89, 0x50, 0x4e, 0x47]);
const isPng = (b) => Buffer.isBuffer(b) && b.length > 1000 && b.subarray(0, 4).equals(PNG_MAGIC);

test('обычный билет рендерится в PNG', async () => {
  const png = await renderTicketPng({ name: 'Nurgul Bekova', number: '13', tarif: 'VIP' });
  assert.ok(isPng(png), 'на выходе должен быть PNG больше 1 КБ');
});

test('билет без тарифа рендерится (подставляется тариф по умолчанию)', async () => {
  assert.ok(isPng(await renderTicketPng({ name: 'Nurgul Bekova', number: '7' })));
});

test('очень длинное имя не ломает рендер', async () => {
  const png = await renderTicketPng({
    name: 'Abdurahmonov Shohruhbek Alisherovich-Konstantinopolskiy',
    number: '128',
  });
  assert.ok(isPng(png));
});

test('кириллица и узбекская латиница рендерятся', async () => {
  assert.ok(isPng(await renderTicketPng({ name: 'Гулнора Каримова', number: '5' })));
  assert.ok(isPng(await renderTicketPng({ name: "Sherzod O'g'li G'ofurov", number: '6' })));
});

test('трёхзначный номер помещается', async () => {
  assert.ok(isPng(await renderTicketPng({ name: 'Test User', number: '999' })));
});

test('рендер укладывается в лимит Vercel (быстрее 10 секунд)', async () => {
  const t0 = Date.now();
  await renderTicketPng({ name: 'Speed Test', number: '1' });
  const ms = Date.now() - t0;
  assert.ok(ms < 10000, `рендер занял ${ms} мс — на бесплатном Vercel это уже риск таймаута`);
});

test('пустое имя не роняет процесс', async () => {
  // Продавец может прислать «  13» — бот не должен падать с 500.
  await assert.doesNotReject(() => renderTicketPng({ name: '', number: '13' }));
});

test('эмодзи вычищаются, а не печатаются пустым квадратом', async () => {
  // В шрифтах билета эмодзи нет: без чистки клиент получает «тофу» ▤.
  const png = await renderTicketPng({ name: 'Nurgul 🎉 Bekova', number: '13', tarif: '🔥' });
  assert.ok(isPng(png));
  // Тариф из одних эмодзи становится пустым, и подставляется тариф по умолчанию.
  const clean = await renderTicketPng({ name: 'Nurgul Bekova', number: '13' });
  assert.strictEqual(png.length, clean.length,
    'билет с эмодзи должен выглядеть ровно как билет без них');
});
