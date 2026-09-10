'use strict';
// Живой прогон в НАСТОЯЩЕМ Telegram.
// Берёт chat_id из свежего сообщения боту и прогоняет проблемные вводы
// через боевой обработчик продукта (api/webhook.js). Ответы уходят
// в реальный чат, а сюда возвращается, что именно ответил Telegram.
//
//   BOT_TOKEN=... node qa/live/tg-real.js <путь/к/api/webhook.js>

const path = require('path');

const TOKEN = process.env.BOT_TOKEN;
if (!TOKEN) { console.error('Нет BOT_TOKEN'); process.exit(2); }
const API = `https://api.telegram.org/bot${TOKEN}`;

const CASES = [
  { text: 'Nurgul Bekova 13', ждём: 'билет, имя «Nurgul Bekova», номер 13' },
  { text: 'Nurgul Bekova - 13', ждём: 'билет; на стенде имя приходило с лишним тире' },
  { text: 'Nurgul Bekova #13', ждём: 'на стенде бот не понимал ввод со знаком #' },
  { text: '13 Nurgul Bekova', ждём: 'на стенде бот не понимал номер впереди' },
  { text: 'Nurgul Bekova 13 🔥', ждём: 'на стенде бот не понимал тариф с эмодзи' },
  { text: "Sherzod O'g'li G'ofurov 7", ждём: 'узбекские апострофы на билете' },
];

async function tg(method, params) {
  const r = await fetch(`${API}/${method}`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(params || {}),
  });
  return r.json();
}

async function findChat() {
  const d = await tg('getUpdates', { limit: 20, timeout: 0 });
  if (!d.ok) throw new Error(d.description);
  for (let i = d.result.length - 1; i >= 0; i--) {
    const m = d.result[i].message || d.result[i].edited_message;
    if (m && m.chat && m.chat.id) {
      return { id: m.chat.id, name: m.chat.first_name || '', from: m.from };
    }
  }
  return null;
}

(async () => {
  const target = process.argv[2] || 'ticket-platform/api/webhook.js';
  const chat = await findChat();
  if (!chat) {
    console.log('Свежих сообщений боту нет. Попросите написать боту любое слово и запустите снова.');
    process.exit(3);
  }
  console.log(`Чат найден: ${chat.id} (${chat.name})`);
  console.log(`Гоняю через боевой обработчик: ${target}\n`);

  const handler = require(path.resolve(target));
  let n = 0;
  for (const c of CASES) {
    n += 1;
    const update = {
      update_id: 900000 + n,
      message: {
        message_id: 900000 + n,
        date: Math.floor(Date.now() / 1000),
        chat: { id: chat.id, type: 'private' },
        from: chat.from || { id: chat.id, is_bot: false, first_name: 'Продавец' },
        text: c.text,
      },
    };
    const res = {
      _c: 200,
      status(x) { this._c = x; return this; },
      json() { return this; },
      send() { return this; },
      end() { return this; },
    };
    process.stdout.write(`${n}. «${c.text}» → `);
    try {
      await handler({ method: 'POST', headers: { host: 'live.test' }, body: update }, res);
      console.log(`отправлено (HTTP ${res._c}) · ожидали: ${c.ждём}`);
    } catch (e) {
      console.log(`ПАДЕНИЕ: ${String(e && e.message).slice(0, 140)}`);
    }
  }
  console.log('\nГотово. Посмотрите чат с ботом: там должны лежать настоящие билеты и отказы.');
})();
