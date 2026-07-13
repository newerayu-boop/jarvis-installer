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
function parseInput(text) {
  const m = String(text).trim().match(/^(.+?)[\s,]+(\d{1,7})(?:[\s,]+([\p{L}\d .-]{1,20}))?\s*$/u);
  if (!m) return null;
  const name = m[1].replace(/[,\s]+$/, '').trim();
  if (!name) return null;
  return { name, number: m[2], tarif: (m[3] || '').trim() || undefined };
}

function caption(t) {
  return (
    '✅ Bilet tayyor!\n\n' +
    `👤 ${t.name}\n🎫 Bilet raqami: #${t.number}\n💳 Tarif: ${t.tarif || config.defaultTarif}`
  );
}

module.exports = { GREETING, NOT_UNDERSTOOD, DENIED, parseInput, caption };
