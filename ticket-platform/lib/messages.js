'use strict';

const config = require('../config');

const GREETING =
  'Assalomu alaykum! 🎫\n\n' +
  'Bilet yaratish uchun *ism va bilet raqamini* bitta qatorda yuboring:\n\n' +
  '`Nurgul Bekova 13`\n\n' +
  'Tarifni ham qo\'shishingiz mumkin:\n' +
  '`Nurgul Bekova 13 VIP`';

const NOT_UNDERSTOOD =
  'Tushunmadim 🤔\n\nBitta qatorda yuboring: `Nurgul Bekova 13`';

const DENIED = '⛔️ Sizda ruxsat yo\'q. Administrator bilan bog\'laning.';

// Parse "Ism Familiya 13" or "Ism Familiya 13 VIP" -> { name, number, tarif }.
//
// Продавцы пишут не по образцу, а как удобно: «Ism Familiya #13»,
// «13 Ism Familiya», «Ism Familiya - 13», тариф эмодзи. Разбираем всё это,
// потому что отказ «Tushunmadim» на живом вводе — потерянный билет.

const HAS_LETTER = /\p{L}/u;

// Хвостовая пунктуация имени: «Ism Familiya -» → «Ism Familiya».
const cleanName = (s) => s.replace(/^[\s,;:.\-–—]+|[\s,;:.\-–—]+$/g, '').trim();

function parseInput(text) {
  // Переносы строк и двойные пробелы приводим к одному пробелу,
  // «#13» и «№13» — к «13»: номер один и тот же, форма записи разная.
  const s = String(text == null ? '' : text)
    .replace(/\s+/g, ' ')
    .trim()
    .replace(/[#№]\s*(?=\d)/g, '');
  if (!s) return null;

  // Имя, затем номер, затем необязательный тариф.
  // Имя берём жадно, поэтому номером считается ПОСЛЕДНЕЕ число строки:
  // в «Nurgul 2 Bekova 13» номер билета — 13, а не 2.
  // В тарифе цифр не бывает, иначе он перетянет на себя номер.
  const direct = s.match(/^(.+)[\s,]+(\d{1,7})(?:[\s,]+([^\d]{1,20}))?$/u);
  if (direct) {
    const name = cleanName(direct[1]);
    if (name && HAS_LETTER.test(name)) {
      return { name, number: direct[2], tarif: cleanName(direct[3] || '') || undefined };
    }
  }

  // Номер впереди: «13 Nurgul Bekova». Тариф в этой форме не разбираем —
  // отличить его от части имени нечем.
  const reversed = s.match(/^(\d{1,7})[\s,]+(.+)$/u);
  if (reversed) {
    const name = cleanName(reversed[2]);
    if (name && HAS_LETTER.test(name)) {
      return { name, number: reversed[1], tarif: undefined };
    }
  }

  return null;
}

function caption(t) {
  return (
    '✅ Bilet tayyor!\n\n' +
    `👤 ${t.name}\n🎫 Bilet raqami: #${t.number}\n💳 Tarif: ${t.tarif || config.defaultTarif}`
  );
}

module.exports = { GREETING, NOT_UNDERSTOOD, DENIED, parseInput, caption };
