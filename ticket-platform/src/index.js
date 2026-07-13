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

  // Telegram bot (long polling).
  await bot.launch();
  console.log('🤖 Telegram bot started');

  const shutdown = async (sig) => {
    console.log(`\n${sig} received, shutting down...`);
    bot.stop(sig);
    server.close();
    await closeBrowser();
    process.exit(0);
  };
  process.once('SIGINT', () => shutdown('SIGINT'));
  process.once('SIGTERM', () => shutdown('SIGTERM'));
}

main().catch((err) => {
  console.error('Fatal:', err);
  process.exit(1);
});
