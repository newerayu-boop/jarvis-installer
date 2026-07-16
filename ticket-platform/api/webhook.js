'use strict';

// Vercel serverless Telegram webhook handler.
//
// Telegram POSTs updates here. We render a ticket and reply with the image.
//
// One-time setup — visit in a browser to register the webhook:
//   https://<your-project>.vercel.app/api/webhook?setup=<SETUP_SECRET>
// (SETUP_SECRET must be set in the Vercel environment.)

const { renderTicketPng } = require('../lib/ticket');
const { GREETING, NOT_UNDERSTOOD, VIP_NEEDS_NAME, DENIED, parseInput, caption, renderArgs } = require('../lib/messages');

const TOKEN = process.env.BOT_TOKEN;
const API = `https://api.telegram.org/bot${TOKEN}`;
const ALLOWED = (process.env.ALLOWED_USER_IDS || '')
  .split(',').map((s) => s.trim()).filter(Boolean);

async function tg(method, body) {
  const r = await fetch(`${API}/${method}`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(body),
  });
  return r.json();
}

function sendMessage(chatId, text) {
  return tg('sendMessage', { chat_id: chatId, text, parse_mode: 'Markdown' });
}

async function sendPhoto(chatId, png, cap) {
  const fd = new FormData();
  fd.append('chat_id', String(chatId));
  fd.append('caption', cap);
  fd.append('photo', new Blob([png], { type: 'image/png' }), 'bilet.png');
  const r = await fetch(`${API}/sendPhoto`, { method: 'POST', body: fd });
  return r.json();
}

module.exports = async (req, res) => {
  if (!TOKEN) return res.status(500).send('BOT_TOKEN is not set');

  // GET: health check / one-time webhook registration.
  if (req.method === 'GET') {
    const secret = process.env.SETUP_SECRET;
    if (secret && req.query && req.query.setup === secret) {
      const url = `https://${req.headers.host}/api/webhook`;
      const result = await tg('setWebhook', { url, allowed_updates: ['message'] });
      return res.status(200).json({ webhook: url, result });
    }
    return res.status(200).send('OK');
  }

  if (req.method !== 'POST') return res.status(405).send('Method Not Allowed');

  const update = req.body || {};
  const msg = update.message || update.edited_message;

  try {
    if (!msg || !msg.text) return res.status(200).end();
    const chatId = msg.chat.id;

    if (ALLOWED.length && !ALLOWED.includes(String(msg.from && msg.from.id))) {
      await sendMessage(chatId, DENIED);
      return res.status(200).end();
    }

    const text = msg.text.trim();
    if (text === '/start' || text === '/help') {
      await sendMessage(chatId, GREETING);
      return res.status(200).end();
    }

    const parsed = parseInput(text);
    if (!parsed) {
      await sendMessage(chatId, NOT_UNDERSTOOD);
      return res.status(200).end();
    }
    if (parsed.mode === 'vip' && !parsed.name) {
      await sendMessage(chatId, VIP_NEEDS_NAME);
      return res.status(200).end();
    }

    const png = await renderTicketPng(renderArgs(parsed));
    await sendPhoto(chatId, png, caption(parsed));
    return res.status(200).end();
  } catch (err) {
    console.error('webhook error:', err);
    try { if (msg) await sendMessage(msg.chat.id, '❌ Xatolik yuz berdi. Qaytadan urinib ko\'ring.'); } catch (_) {}
    return res.status(200).end();
  }
};
