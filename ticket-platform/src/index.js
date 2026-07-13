'use strict';

require('dotenv').config();

const { app } = require('./server');
const { bot } = require('./bot');
const { closeBrowser } = require('./render');
const { usingSupabase } = require('./db');

const PORT = process.env.PORT || 3000;

async function main() {
  // Verification web server (also serves the QR check-in page).
  const server = app.listen(PORT, () => {
    console.log(`🌐 Verify server on :${PORT}`);
    console.log(`   Storage: ${usingSupabase ? 'Supabase' : 'local JSON file (data/tickets.json)'}`);
    console.log(`   Public URL: ${process.env.PUBLIC_URL || 'http://localhost:' + PORT}`);
  });

  const shutdown = async (sig) => {
    console.log(`\n${sig} received, shutting down...`);
    bot.stop(sig);
    server.close();
    await closeBrowser();
    process.exit(0);
  };
  process.once('SIGINT', () => shutdown('SIGINT'));
  process.once('SIGTERM', () => shutdown('SIGTERM'));

  // Telegram bot (long polling). launch() only resolves once the bot stops,
  // so we don't await it here — register handlers above first.
  bot.launch({ dropPendingUpdates: true })
    .catch((err) => { console.error('Bot launch failed:', err); process.exit(1); });
  console.log('🤖 Telegram bot started');
}

main().catch((err) => {
  console.error('Fatal:', err);
  process.exit(1);
});
