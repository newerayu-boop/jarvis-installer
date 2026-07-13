'use strict';

// Generate a sample ticket PNG without running the bot or a DB.
//   node scripts/preview.js "Nurgul Bekova" 13 Standart
const fs = require('fs');
const path = require('path');
const { renderTicket, closeBrowser } = require('../src/render');

(async () => {
  const [, , name = 'Nurgul Bekova', number = '13', tarif = 'Standart'] = process.argv;
  const png = await renderTicket({ name, number, tarif, token: 'SAMPLE12' });
  const out = path.join(__dirname, '..', 'preview.png');
  fs.writeFileSync(out, png);
  console.log('Saved', out);
  await closeBrowser();
})();
