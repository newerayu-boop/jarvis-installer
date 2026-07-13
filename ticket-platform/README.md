# 🎫 Ticket Platform — Sun'iy Intellekt

Telegram-bot, который по **имени и номеру билета** мгновенно генерирует готовый
брендированный билет (PNG) в стиле сайта suniyintellect.uz и записывает его в базу
для **проверки по QR-коду на входе**.

Продажник пишет боту `Nurgul Bekova 13` → получает картинку билета. На входе
контролёр сканирует QR → видит, действителен ли билет, и отмечает вход
(повторный скан того же билета показывает «уже использован»).

---

## Как это работает

```
Продажник ──▶ Telegram-бот ──▶ рендер PNG (Chromium) ──▶ картинка билета
                   │
                   └──▶ запись в базу (Supabase): token, имя, номер, тариф

Контролёр ──▶ сканирует QR ──▶ https://<ваш-домен>/t/<token>
                                   ├─ ✅ действителен  → кнопка «Kirdi»
                                   ├─ ⚠️ уже использован
                                   └─ ⛔️ не найден (подделка)
```

Одно Node-приложение делает и бота, и веб-страницу проверки.

---

## Что вводит продажник

- **Одной строкой:** `Nurgul Bekova 13`
- **Или по шагам:** команда `/new` → «Имя?» → «Номер?»

Всё остальное (дата, площадка, время, спикер, тариф по умолчанию) зашито в
`src/config.js` и одинаково для всего мероприятия.

---

## Локальный запуск

```bash
cd ticket-platform
npm install                 # поставит зависимости + Chromium
cp .env.example .env        # впишите BOT_TOKEN (минимум)
npm start
```

Без Supabase билеты пишутся в локальный `data/tickets.json` — удобно для теста.

**Превью билета без бота:**
```bash
npm run preview -- "Nurgul Bekova" 13 Standart   # → preview.png
```

---

## Настройка

### 1. Токен бота
Создайте бота у [@BotFather](https://t.me/BotFather) → `/newbot` → скопируйте токен
в `BOT_TOKEN`.

### 2. Кто может пользоваться ботом
Узнайте свой Telegram ID у [@userinfobot](https://t.me/userinfobot) и впишите ID
продажников через запятую в `ALLOWED_USER_IDS`. Пусто = доступ всем (не для прода).

### 3. База (Supabase) — нужна для QR-проверки
1. В Supabase → **SQL Editor** выполните `supabase/schema.sql`.
2. **Project Settings → API** → скопируйте:
   - `Project URL` → `SUPABASE_URL`
   - `service_role` ключ → `SUPABASE_SERVICE_KEY` (секретный, только на сервере!)

### 4. Публичный адрес для QR
После деплоя впишите в `PUBLIC_URL` полный адрес сервиса
(например `https://tickets.suniyintellect.uz`). Именно на него ведёт QR.

### 5. PIN контролёра (опционально)
`STAFF_PIN=1234` — тогда при отметке входа страница спросит PIN, чтобы гость сам
себя не «отметил».

---

## Правка данных мероприятия

Всё в одном файле — `src/config.js`:

```js
event: {
  date:     '18-iyul',
  time:     '14:00–18:00',
  venue:    'M-Factor',
  speaker:  'Yusufbay Kadirov',
  eventSub: 'AI OFFLINE TRENING · 1 KUNLIK MASTER KLASS',
  photo:    'assets/expert.jpg',   // фон-фото (положите в src/assets/)
},
defaultTarif: 'Standart',
```

---

## Деплой (бесплатно) — Render

1. Запушьте репозиторий на GitHub.
2. [Render](https://render.com) → **New → Web Service** → выберите репозиторий.
3. **Root Directory:** `ticket-platform`, **Runtime:** `Docker` (используется `Dockerfile`).
4. В **Environment** добавьте переменные из `.env.example`
   (`BOT_TOKEN`, `SUPABASE_URL`, `SUPABASE_SERVICE_KEY`, `PUBLIC_URL`, …).
   `PUBLIC_URL` = адрес, который выдаст Render (`https://xxx.onrender.com`).
5. Deploy. Бот стартует, страница проверки доступна по `PUBLIC_URL`.

> Chromium уже входит в Docker-образ (`mcr.microsoft.com/playwright`), скачивать
> ничего не нужно. Railway / Fly.io разворачиваются так же по `Dockerfile`.

---

## Структура

```
ticket-platform/
├── src/
│   ├── index.js        # запуск: бот + веб-сервер
│   ├── bot.js          # логика Telegram-бота
│   ├── render.js       # рендер билета в PNG (Chromium)
│   ├── server.js       # страница проверки по QR + отметка входа
│   ├── db.js           # хранилище (Supabase / локальный JSON)
│   ├── token.js        # генератор кодов билетов
│   ├── config.js       # ⚙️ данные мероприятия и бренда
│   ├── template.html   # HTML-шаблон билета
│   └── assets/         # фото + шрифты
├── supabase/schema.sql # SQL для таблицы билетов
├── scripts/preview.js  # генерация примера билета
├── Dockerfile
└── .env.example
```
