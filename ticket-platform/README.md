# 🎫 Ticket Platform — Sun'iy Intellekt

Telegram-бот, который по **имени и номеру билета** мгновенно генерирует готовый
брендированный билет (PNG) в стиле сайта suniyintellect.uz.

Продавец пишет боту `Nurgul Bekova 13` → получает картинку билета, готовую к
отправке клиенту.

Билет рисуется через **Satori + resvg** (без браузера), поэтому проект **бесплатно
разворачивается на Vercel** и работает без «засыпаний».

---

## Что вводит продавец

- **Имя + номер:** `Nurgul Bekova 13`
- **Имя + номер + тариф:** `Nurgul Bekova 13 VIP`

Всё остальное (дата, площадка, время, спикер, тариф по умолчанию) задаётся в
`config.js` и одинаково для всего мероприятия.

---

## 🚀 Деплой на Vercel (бесплатно, рекомендуется)

1. Запушьте репозиторий на GitHub (уже сделано).
2. Зайдите на [vercel.com](https://vercel.com) → войдите через GitHub.
3. **Add New → Project** → выберите репозиторий `jarvis-installer`.
4. В настройках импорта:
   - **Root Directory** → нажмите *Edit* и укажите `ticket-platform`.
   - Framework Preset: **Other**.
5. **Environment Variables** — добавьте:
   | Ключ | Значение |
   |---|---|
   | `BOT_TOKEN` | токен от @BotFather |
   | `ALLOWED_USER_IDS` | Telegram ID продавцов через запятую (можно оставить пустым) |
   | `SETUP_SECRET` | любое секретное слово, напр. `mysecret123` |
6. **Deploy**. Дождитесь адреса вида `https://your-project.vercel.app`.
7. **Подключите webhook** — один раз откройте в браузере:
   ```
   https://your-project.vercel.app/api/webhook?setup=mysecret123
   ```
   (подставьте свой `SETUP_SECRET`). Увидите `{"result":{"ok":true}}` — готово.
8. Напишите боту `Nurgul Bekova 13` — придёт билет. 🎉

> Каждое обновление кода в GitHub Vercel деплоит автоматически.

---

## 🖥 Локальный запуск / другой хостинг (VPS, Railway)

Тот же код умеет работать в режиме long-polling:

```bash
cd ticket-platform
npm install
cp .env.example .env      # впишите BOT_TOKEN
npm start                 # 🤖 бот на long-polling
```

**Превью билета без бота:**
```bash
npm run preview -- "Nurgul Bekova" 13 Standart   # → preview.png
```

> ⚠️ Нельзя одновременно использовать webhook (Vercel) и polling для одного
> токена — Telegram позволяет что-то одно. Для теста polling временно снимите
> webhook: `https://api.telegram.org/bot<TOKEN>/deleteWebhook`.

---

## ⚙️ Правка данных мероприятия

Всё в одном файле — `config.js`:

```js
event: {
  date:     '18-iyul',
  time:     '14:00–18:00',
  venue:    'M-Factor',
  speaker:  'Yusufbay Kadirov',
  eventSub: 'AI OFFLINE TRENING · 1 KUNLIK MASTER KLASS',
},
defaultTarif: 'Standart',
```

Фото спикера и шрифты вшиты в `lib/assets.js` (base64). Чтобы поменять фото —
замените и перегенерируйте (`scripts/build-assets.js`).

---

## Структура

```
ticket-platform/
├── api/
│   └── webhook.js      # Vercel: обработчик Telegram webhook
├── lib/
│   ├── ticket.js       # рендер билета (Satori → SVG → resvg → PNG)
│   ├── assets.js       # шрифты + фото, вшитые в base64
│   └── messages.js     # тексты и парсер ввода
├── src/
│   ├── index.js        # запуск polling-режима
│   └── bot.js          # Telegram-бот (long polling)
├── config.js           # ⚙️ данные мероприятия и бренда
├── vercel.json
└── scripts/preview.js  # генерация примера билета
```
