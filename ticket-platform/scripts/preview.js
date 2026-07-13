'use strict';

// Generate a sample ticket PNG without a bot.
//   node scripts/preview.js "Nurgul Bekova" 13 Standart
const fs = require('fs');
const path = require('path');
const { renderTicketPng } = require('../lib/ticket');

(async () => {
  const [, , name = 'Nurgul Bekova', number = '13', tarif = 'Standart'] = process.argv;
  const png = await renderTicketPng({ name, number, tarif });
  const out = path.join(__dirname, '..', 'preview.png');
  fs.writeFileSync(out, png);
  console.log('Saved', out);
})();
