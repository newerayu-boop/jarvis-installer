'use strict';

const { Telegraf } = require('telegraf');
const { renderTicket } = require('./render');
const { createTicket } = require('./db');
const { newToken } = require('./token');
const config = require('./config');

const TOKEN = process.env.BOT_TOKEN;
if (!TOKEN) throw new Error('BOT_TOKEN is not set');

// Optional access control: comma-separated Telegram user IDs allowed to use the
// bot. Leave ALLOWED_USER_IDS empty to allow everyone (not recommended in prod).
const ALLOWED = (process.env.ALLOWED_USER_IDS || '')
  .split(',').map((s) => s.trim()).filter(Boolean);

const bot = new Telegraf(TOKEN);

// Simple per-chat conversation state.
const sessions = new Map(); // chatId -> { step, name }

function isAllowed(ctx) {
  if (ALLOWED.length === 0) return true;
  return ALLOWED.includes(String(ctx.from && ctx.from.id));
}

function greet(ctx) {
  return ctx.reply(
    `Assalomu alaykum! 🎫\n\n` +
    `Bilet yaratish uchun *ism va bilet raqamini* yuboring.\n\n` +
    `Bir qatorda:\n\`Nurgul Bekova 13\`\n\n` +
    `Yoki /new buyrug'i bilan bosqichma-bosqich.`,
    { parse_mode: 'Markdown' }
  );
}

async function issueAndSend(ctx, name, number, tarif) {
  const token = newToken();
  const chatId = ctx.chat.id;
  const waiting = await ctx.reply('⏳ Bilet tayyorlanmoqda...');

  try {
    await createTicket({
      token, name, number,
      tarif: tarif || config.defaultTarif,
      event: config.event.eventSub,
      issuedBy: ctx.from && ctx.from.id,
      issuedByName: [ctx.from && ctx.from.first_name, ctx.from && ctx.from.username]
        .filter(Boolean).join(' @').trim(),
    });

    const png = await renderTicket({ name, number, tarif, token });

    await ctx.replyWithPhoto(
      { source: png },
      {
        caption:
          `✅ Bilet tayyor!\n\n` +
          `👤 ${name}\n🎫 Bilet raqami: #${number}\n💳 Tarif: ${tarif || config.defaultTarif}\n` +
          `🔐 Kod: ${token}`,
      }
    );
  } catch (err) {
    console.error('issue error:', err);
    await ctx.reply('❌ Xatolik yuz berdi. Qaytadan urinib ko\'ring.');
  } finally {
    ctx.telegram.deleteMessage(chatId, waiting.message_id).catch(() => {});
    sessions.delete(chatId);
  }
}

// Parse "Ism Familiya 13" or "Ism Familiya, 13" -> { name, number }.
function parseOneLine(text) {
  const m = text.trim().match(/^(.+?)[\s,]+(\d{1,7})\s*$/);
  if (!m) return null;
  const name = m[1].replace(/[,\s]+$/, '').trim();
  if (!name) return null;
  return { name, number: m[2] };
}

bot.use(async (ctx, next) => {
  if (ctx.updateType === 'message' && !isAllowed(ctx)) {
    return ctx.reply('⛔️ Sizda ruxsat yo\'q. Administrator bilan bog\'laning.');
  }
  return next();
});

bot.start(greet);
bot.help(greet);

bot.command('new', (ctx) => {
  sessions.set(ctx.chat.id, { step: 'name' });
  return ctx.reply('👤 Ishtirokchining *ism va familiyasi*ni yozing:', { parse_mode: 'Markdown' });
});

bot.command('cancel', (ctx) => {
  sessions.delete(ctx.chat.id);
  return ctx.reply('Bekor qilindi. /new bilan qaytadan boshlang.');
});

bot.on('text', async (ctx) => {
  const text = ctx.message.text;
  if (text.startsWith('/')) return; // ignore stray commands

  const state = sessions.get(ctx.chat.id);

  // Step-by-step flow.
  if (state && state.step === 'name') {
    state.name = text.trim();
    state.step = 'number';
    return ctx.reply('🎫 Endi *bilet raqami*ni yuboring (masalan `13`):', { parse_mode: 'Markdown' });
  }
  if (state && state.step === 'number') {
    const number = text.trim();
    if (!/^\d{1,7}$/.test(number)) {
      return ctx.reply('❗️ Bilet raqami faqat raqamlardan iborat bo\'lsin. Qaytadan yuboring:');
    }
    return issueAndSend(ctx, state.name, number);
  }

  // One-line flow.
  const parsed = parseOneLine(text);
  if (parsed) return issueAndSend(ctx, parsed.name, parsed.number);

  return ctx.reply(
    'Tushunmadim 🤔\n\nBir qatorda yuboring: `Nurgul Bekova 13`\nyoki /new bosing.',
    { parse_mode: 'Markdown' }
  );
});

module.exports = { bot };
