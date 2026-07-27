'use strict';

const GREETING =
  'Assalomu alaykum! 🎫\n\n' +
  'Bilet olish uchun *ism va familiyani* yuboring:\n' +
  '`Nurgul Bekova`\n\n' +
  'Bot tayyor biletni rasm ko\'rinishida yuboradi.';

const NOT_UNDERSTOOD =
  'Iltimos, *ism va familiyani* yuboring:\n`Nurgul Bekova`';

const DENIED = '⛔️ Sizda ruxsat yo\'q. Administrator bilan bog\'laning.';

// The whole message is treated as the guest name. Common habits are stripped:
// a leading "VIP"/"вип" keyword and a trailing seat number, if present.
// Returns { name } or null if nothing usable remains.
function parseInput(text) {
  let t = String(text).trim();
  t = t.replace(/^(?:\/?vip(?:\s*bilet)?|вип(?:\s*билет)?)(?=$|[\s,:\-–—])[\s,:\-–—]*/iu, '');
  t = t.replace(/[\s,]+\d{1,7}\s*$/u, '').trim(); // drop a trailing seat number
  t = t.replace(/[,\s]+$/u, '').trim();
  if (!t) return null;
  return { name: t };
}

function caption(req) {
  return `✅ Bilet tayyor!\n\n👤 ${req.name}`;
}

function renderArgs(req) {
  return { personal: true, name: req.name };
}

module.exports = { GREETING, NOT_UNDERSTOOD, DENIED, parseInput, caption, renderArgs };
