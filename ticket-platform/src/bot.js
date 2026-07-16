'use strict';

// Long-polling bot for local testing / always-on hosts (VPS, Railway).
// For Vercel, use the webhook handler in api/webhook.js instead.

const { Telegraf } = require('telegraf');
const { renderTicketPng } = require('../lib/ticket');
const { GREETING, NOT_UNDERSTOOD, VIP_NEEDS_NAME, DENIED, parseInput, caption, renderArgs } = require('../lib/messages');

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
    const png = await renderTicketPng(renderArgs(parsed));
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

async function handleText(ctx) {
  const parsed = parseInput(ctx.message.text);
  if (!parsed) return ctx.reply(NOT_UNDERSTOOD, { parse_mode: 'Markdown' });
  if (parsed.mode === 'vip' && !parsed.name) return ctx.reply(VIP_NEEDS_NAME, { parse_mode: 'Markdown' });
  return issueAndSend(ctx, parsed);
}

bot.command('vip', handleText);
bot.on('text', async (ctx) => {
  if (ctx.message.text.startsWith('/')) return; // other commands handled above
  return handleText(ctx);
});

module.exports = { bot };
