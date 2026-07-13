'use strict';

// Entry point for POLLING mode (local testing, VPS, Railway).
// On Vercel this file is not used — the webhook handler (api/webhook.js) is.

require('dotenv').config();

const { bot } = require('./bot');

async function main() {
  const shutdown = (sig) => { console.log(`\n${sig} received, stopping...`); bot.stop(sig); process.exit(0); };
  process.once('SIGINT', () => shutdown('SIGINT'));
  process.once('SIGTERM', () => shutdown('SIGTERM'));

  bot.launch({ dropPendingUpdates: true })
    .catch((err) => { console.error('Bot launch failed:', err); process.exit(1); });
  console.log('🤖 Telegram bot started (polling)');
}

main();
