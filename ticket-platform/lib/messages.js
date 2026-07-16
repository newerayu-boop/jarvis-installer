'use strict';

const config = require('../config');

const GREETING =
  'Assalomu alaykum! 🎫\n\n' +
  '*Oddiy bilet* — ism va raqamni yuboring:\n' +
  '`Nurgul Bekova 13`\n' +
  '(tarif ham mumkin: `Nurgul Bekova 13 VIP`)\n\n' +
  '*Shaxsiy VIP taklifnoma* — oldiga VIP yozing, raqam shart emas:\n' +
  '`VIP Nurgul Bekova`';

const NOT_UNDERSTOOD =
  'Tushunmadim 🤔\n\n' +
  'Oddiy bilet: `Nurgul Bekova 13`\n' +
  'VIP taklifnoma: `VIP Nurgul Bekova`';

const VIP_NEEDS_NAME =
  'VIP taklifnoma uchun ism yuboring:\n`VIP Nurgul Bekova`';

const DENIED = '⛔️ Sizda ruxsat yo\'q. Administrator bilan bog\'laning.';

// Parse the seller's message into a ticket request.
// Returns:
//   { mode:'vip', name }                       — personal VIP invitation (no number)
//   { mode:'standard', name, number, tarif? }  — regular numbered ticket
//   null                                       — unrecognized
function parseInput(text) {
  const t = String(text).trim();

  // VIP: starts with "vip" / "vip bilet" / "вип" (any case), rest is the name.
  // Lookahead (not \b) so it works for Cyrillic and won't match inside a word.
  const vip = t.match(/^(?:\/?vip(?:\s*bilet)?|вип(?:\s*билет)?)(?=$|[\s,:\-–—])[\s,:\-–—]*(.*)$/iu);
  if (vip) {
    return { mode: 'vip', name: vip[1].replace(/[,\s]+$/, '').trim() };
  }

  // Standard: "Ism Familiya 13" or "Ism Familiya 13 VIP".
  const m = t.match(/^(.+?)[\s,]+(\d{1,7})(?:[\s,]+([\p{L}\d .-]{1,20}))?\s*$/u);
  if (m) {
    const name = m[1].replace(/[,\s]+$/, '').trim();
    if (name) return { mode: 'standard', name, number: m[2], tarif: (m[3] || '').trim() || undefined };
  }

  return null;
}

function caption(req) {
  if (req.mode === 'vip') {
    return `✅ VIP taklifnoma tayyor!\n\n👤 ${req.name}\n💳 Tarif: VIP`;
  }
  return (
    '✅ Bilet tayyor!\n\n' +
    `👤 ${req.name}\n🎫 Bilet raqami: #${req.number}\n💳 Tarif: ${req.tarif || config.defaultTarif}`
  );
}

// Map a parsed request to renderTicketPng() arguments.
function renderArgs(req) {
  if (req.mode === 'vip') return { invite: true, name: req.name };
  return { name: req.name, number: req.number, tarif: req.tarif };
}

module.exports = { GREETING, NOT_UNDERSTOOD, VIP_NEEDS_NAME, DENIED, parseInput, caption, renderArgs };
