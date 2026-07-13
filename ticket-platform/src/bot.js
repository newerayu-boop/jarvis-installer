'use strict';

// Long-polling bot for local testing / always-on hosts (VPS, Railway).
// For Vercel, use the webhook handler in api/webhook.js instead.

const { Telegraf } = require('telegraf');
const { renderTicketPng } = require('../lib/ticket');
const { GREETING, NOT_UNDERSTOOD, DENIED, parseInput, caption } = require('../lib/messages');

const TOKEN = process.env.BOT_TOKEN;
if (!TOKEN) throw new Error('BOT_TOKEN is not set');

const ALLOWED = (process.env.ALLOWED_USER_IDS || '')
  .split(',').map((s) => s.trim()).filter(Boolean);

const bot = new Telegraf(TOKEN);

function isAllowed(ctx) {
  if (ALLOWED.length === 0) return true;
  return ALLOWED.includes(String(ctx.from && ctx.from.id));
}

async function issueAndSend(ctx, parsed) {
  const waiting = await ctx.reply('⏳ Bilet tayyorlanmoqda...');
  try {
    const png = await renderTicketPng(parsed);
    await ctx.replyWithPhoto({ source: png }, { caption: caption(parsed) });
  } catch (err) {
    console.error('issue error:', err);
    await ctx.reply('❌ Xatolik yuz berdi. Qaytadan urinib ko\'ring.');
  } finally {
    ctx.telegram.deleteMessage(ctx.chat.id, waiting.message_id).catch(() => {});
  }
}

bot.use(async (ctx, next) => {
  if (ctx.updateType === 'message' && !isAllowed(ctx)) return ctx.reply(DENIED);
  return next();
});

bot.start((ctx) => ctx.reply(GREETING, { parse_mode: 'Markdown' }));
bot.help((ctx) => ctx.reply(GREETING, { parse_mode: 'Markdown' }));

bot.on('text', async (ctx) => {
  const text = ctx.message.text;
  if (text.startsWith('/')) return;
  const parsed = parseInput(text);
  if (parsed) return issueAndSend(ctx, parsed);
  return ctx.reply(NOT_UNDERSTOOD, { parse_mode: 'Markdown' });
});

module.exports = { bot };
