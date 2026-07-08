# Воронка Jeff Su: куда и как он ведёт трафик из видео

Анализ построен на 100 описаниях топ-видео канала (2020–2026) и агрегированной статистике ссылок (`funnel_stats.json`): категории доменов, первая ссылка каждого описания, лейблы строк, UTM-разметка, разбивка по видео.

---

## 1. Анатомия описания

Описание у Jeff Su — не «текст под видео», а стандартизированный лендинг из повторяющихся блоков. Шаблон стабилен годами, меняется только наполнение. Сверху вниз:

### 1.1. Лид-магнит с эмодзи — первая строка

```
🌟 Grab my free AI Toolkit: https://academy.jeffsu.org/ai-toolkit?utm_source=youtube&utm_medium=video&utm_campaign=v202
```
или (карьерные видео):
```
🎯 My free Job Search Toolkit: https://academy.jeffsu.org/job-search-toolkit?utm_source=youtube&utm_medium=video&utm_campaign=037
```

**Роль:** единственная ссылка, которую видно до нажатия «ещё» — самое ценное место описания. Почти всегда это *бесплатный* оффер («Grab my free…»), тематически подобранный под видео, с UTM-меткой номера видео. Это вход в email-воронку.

### 1.2. Спонсор / партнёрка (когда есть — вытесняет лид-магнит с первой строки)

```
⚡️ HubSpot’s Free Guide: https://clickhubspot.com/5c4cca
```
```
✅ Get 40% off 3 months of Coursera Plus: https://imp.i384100.net/c/2464514/3102764/14726
```

**Роль:** прямая монетизация интеграции. В спонсорских видео этот блок занимает первую строку, а собственный лид-магнит сдвигается ниже — спонсор покупает лучшее место.

### 1.3. Краткое резюме видео (2–3 абзаца, часто с эмодзи/нумерацией)

```
🌟 All-Star LinkedIn profiles are 40x more likely to be contacted by recruiters and 18x more likely to show up in hiring managers’ search results...
```

**Роль:** SEO (ключевые слова + хэштеги вида #ChatGPT, #NotebookLM внутри текста) и «продажа» просмотра тем, кто читает описание до просмотра. Прямых ссылок здесь почти нет.

### 1.4. TIMESTAMPS

```
*TIMESTAMPS*
00:00 AI vs. AI Agents
01:04 Level 1: LLMs
02:17 Level 2: AI Workflows
...
```

**Роль:** главы = удержание + SEO по подзапросам. В воронке — доверие: зритель видит структуру и остаётся.

### 1.5. RESOURCES I MENTION (IN THE VIDEO) / RESOURCES MENTIONED

```
*RESOURCES MENTIONED*
Helena Liu's AI Workflow Tutorial: https://youtu.be/H0YRniHh2tg
Andrew Ng's AI Agent Demo: https://youtu.be/KrRD7r7y7NY
```

**Роль:** выполнение обещания «ссылка в описании» из видео. Сюда же Jeff вшивает свои активы: блогпост-компаньон на jeffsu.org («Full written guide», «Resources for Claude Cowork» — с тем же UTM видео), свои другие ролики, шаблоны Notion, и даже повтор лид-магнита («Free AI Toolkit») и рассылки («My insanely actionable newsletter»).

### 1.6. MY FAVORITE GEAR

```
*MY FAVORITE GEAR*
🎬 My YouTube Gear - https://www.jeffsu.org/yt-gear/
🎒 Everyday Carry - https://www.jeffsu.org/my-edc/
```
(в старых видео — напрямую партнёрские шорт-линки:)
```
🎥 My YouTube Gear - https://geni.us/youtube-gear
🎒 What's In My Bag - https://geni.us/mybag
💻 What's On My Desk - https://geni.us/mydesk
🛩 What I Travel With - https://geni.us/mytravel
```

**Роль:** пассивный Amazon/партнёрский доход с «хвоста» каждого видео. Позже geni.us-ссылки заменены страницами jeffsu.org (yt-gear — 64 вхождения, my-edc — 56), где партнёрки уже внутри сайта + пиксель/аналитика у себя.

### 1.7. MY TOP 3 FAVORITE SOFTWARE

```
*MY TOP 3 FAVORITE SOFTWARE*
❎ CleanShot X - https://geni.us/cleanshotx
✍️ Skillshare - https://geni.us/skillshare-jeff
💼 Teal - http://tealhq.co/jeffsu
```

**Роль:** три вечнозелёные партнёрки в каждом описании независимо от темы (Skillshare — 80 вхождений, CleanShot X — 67, Teal — 19+16). Третий слот ротируется под аудиторию видео: Teal — в карьерных, Readwise — в продуктивити.

### 1.8. BUILD A POWERFUL WORKFLOW (новый блок, 2025+)

```
*BUILD A POWERFUL WORKFLOW*
🦾 AI Systems Academy - https://systemsacademy.ai/?utm_source=youtube&utm_medium=video&utm_campaign=186
📈 The Workspace Academy - https://academy.jeffsu.org/workspace-academy?utm_source=youtube&utm_medium=video&utm_campaign=186
✍️ My Notion Command Center - https://www.pressplay.cc/link/s/DE1C4C50
```

**Роль:** витрина платных продуктов — постоянный блок в каждом AI-видео. Заменил собой часть gear/software-блоков.

### 1.9. BE MY FRIEND (рассылка + соцсети)

```
*BE MY FRIEND:*
📧 Subscribe to my newsletter - https://www.jeffsu.org/newsletter/?utm_source=youtube&utm_medium=video&utm_campaign=description
📸 Instagram - https://instagram.com/j.sushie
🤝 LinkedIn - https://www.linkedin.com/in/jsu05/
```
(старая версия: `📧 Subscribe to my Productivity newsletter - https://www.jeffsu.org/productivity-ping/`, плюс `👋🏻 Clubhouse`, `🙋👦🏻 Facebook Group`.)

**Роль:** второй заход на email (129 newsletter-ссылок на 100 видео — почти всегда дважды в описании) + перевод в соцсети (Instagram и LinkedIn — по 98 из 100 видео).

### 1.10. WHO AM I

```
👨🏻‍💻 WHO AM I:
I'm Jeff, a full time Product Marketer. In my spare time I like to tinker with tools and create systems that help me get things done faster - or as one of my friends puts it: "Get better at being lazy" 😏
If you'd like to talk, I'd love to hear from you. Messaging me on Instagram (@j.sushie) directly will be the quickest way to get a response!
```

**Роль:** позиционирование «свой парень из Google, не гуру» + CTA на личный контакт в Instagram. В новых видео блок сокращён или убран.

### 1.11. Дисклеймер про партнёрки

```
PS: Some of the links in this description are affiliate links I get a kickback from 😇

Disclaimer: My opinions are my own and may not reflect that of my employer
```

**Роль:** юридическая чистота (FTC) поданная в фирменном самоироничном тоне; второй абзац — защита при работе в Google.

### 1.12. Хэштеги

```
#resumeTips #incredibleResume #jeffsu
```
```
#aiagents #ai #automation
```

**Роль:** SEO/категоризация, 1–3 штуки, по теме видео.

---

## 2. Главная воронка: бесплатный toolkit → рассылка → академия

### Первая ссылка описания (100 видео)

| Категория первой ссылки | Видео |
|---|---|
| **Academy (academy.jeffsu.org: toolkit'ы и курсы)** | **50** |
| Gumroad (premium-resume-package и др.) | 11 |
| Сайт jeffsu.org (блогпост/gear) | 9 |
| imp.i384100.net (Coursera, спонсор/партнёрка) | 7 |
| clickhubspot.com (HubSpot, спонсор) | 6 |
| YouTube (своё видео) | 6 |
| Newsletter напрямую | 4 |
| Прочее (claude.ai referral, pressplay, amzn, gamma, ntn.so, systemsacademy, dropbox) | 7 |

Половина всех топ-видео начинается с домена academy.jeffsu.org — и это всегда **бесплатный** продукт, подобранный под тему:

- `academy.jeffsu.org/ai-toolkit` (22 вхождения) — «Grab my AI Toolkit for free» — под все AI-видео;
- `academy.jeffsu.org/job-search-toolkit` (17) — «🎯 My free Job Search Toolkit» — под резюме/LinkedIn/интервью;
- `academy.jeffsu.org/workspace-toolkit` (11) — «🔩 Grab my free Workspace Toolkit» — под Gmail/Calendar/Sheets;
- `academy.jeffsu.org/notion-toolkit` (8) — «My free Notion Toolkit» — под Notion-видео;
- `academy.jeffsu.org/workspace-academy` (25) — уже платный флагман, чаще во втором эшелоне описания.

### Уровни лестницы

1. **Бесплатный лид-магнит (вход).** Toolkit/шаблон, релевантный именно этому видео. Формулировка всегда «free» + глагол («Grab my free…», «Download my favorite prompts…»). Обмен — email.
2. **Email-рассылка (ядро).** «Productivity Ping» (`jeffsu.org/productivity-ping/` — 79 вхождений) → позже `jeffsu.org/newsletter/` (47+3). Рассылка упоминается в описании дважды: иногда в RESOURCES («My insanely actionable newsletter») и всегда в BE MY FRIEND. Итого 129 newsletter-ссылок на 100 видео. Email-база — то, что переживает алгоритм YouTube и продаёт платные продукты.
3. **Платные продукты (монетизация ядра).** The Workspace Academy ($, 25 вхождений), AI Systems Academy (systemsacademy.ai, 13), Cowork Academy (coworkacademy.ai, waitlist), Notion Command Center (pressplay.cc, 24), Gumroad-пакеты (Premium Resume Package — 21). Плюс членство канала (`/join` — 12).

### UTM-разметка

Практически все ссылки на собственные ресурсы имеют вид:

```
?utm_source=youtube&utm_medium=video&utm_campaign=037   ← номер видео
?utm_source=youtube&utm_medium=video&utm_campaign=v202  ← новый формат нумерации
?utm_source=youtube&utm_medium=video&utm_campaign=description ← шаблонный блок BE MY FRIEND
```

Что это говорит о системе:

- **У каждого видео есть внутренний порядковый номер** (037, 139, 170, 195, v202, v205…) — контент ведётся как каталог, и Jeff может точно измерить, какое видео принесло сколько лидов/подписок/продаж.
- **Шаблонные блоки помечены отдельно** (`utm_campaign=description`) — трафик из «вечного» футера отделён от трафика из «горячего» лид-магнита конкретного видео. Это позволяет сравнивать конверсию первой строки против футера.
- Встречается `utm_campaign=XXX` (в описании Gemini 3.1) — след копипаст-шаблона, куда номер подставляется вручную: подтверждение, что описание собирается из заготовки.

---

## 3. Монетизационные слои

По данным `domain_count`, на 100 описаний:

| Слой | Домены | Вхождений | Где живёт |
|---|---|---|---|
| **Партнёрки вечнозелёные** | geni.us (skillshare-jeff — 80, cleanshotx — 67, youtube-gear/mybag/mydesk/mytravel — 112, jefftodoist, downie…) | **265** | Блоки GEAR и TOP 3 SOFTWARE в каждом видео любой темы |
| **Партнёрки нишевые** | get.tealhq.com (19) + tealhq.co (16) — карьерные; partner.canva.com (12); readwise.io (26); amzn.to (3) | ~76 | Teal — в job-search видео (часто 2 раза за описание); Readwise — в продуктивити; Canva — в LinkedIn/презентациях |
| **Спонсоры интеграций** | clickhubspot.com (6, HubSpot), imp.i384100.net (8, Coursera), ntn.so (Notion), gamma.app, claude.ai referral | ~20 | Первая строка описания в новых AI-видео («⚡️ HubSpot’s Free Guide», «✅ Get 40% off 3 months of Coursera Plus») |
| **Собственные продукты** | academy.jeffsu.org (93), systemsacademy.ai (13), pressplay.cc (24, Notion Command Center), coworkacademy.ai (4), Gumroad (35) | ~169 | Первая строка (бесплатные toolkit'ы) + блок BUILD A POWERFUL WORKFLOW (платные) |
| **Свой сайт как прокладка** | jeffsu.org (177: yt-gear, my-edc, блогпосты-компаньоны) | 177 | GEAR-блок + RESOURCES; партнёрки и пиксели — уже на сайте |

Распределение по типам видео:

- **Карьерные (Resume/LinkedIn/Interview):** Gumroad Premium Resume Package + Teal (дважды) + job-search-toolkit + Canva. Самый «продуктовый» тип: у Tt08KmFfIYQ 16 ссылок, из них 6 geni.us.
- **AI-видео 2023–2024:** ai-toolkit первой строкой + newsletter дважды + стандартные geni.us. Монетизация в основном через лид-магнит → email.
- **AI-видео 2025–2026:** спонсор первой строкой (HubSpot/Coursera) + блок BUILD A POWERFUL WORKFLOW (systemsacademy.ai + workspace-academy + pressplay) — три платных слоя одновременно, geni.us-блок сокращён.
- **Mac/гаджеты:** максимум geni.us (в «10 BEST Mac Apps» — 24 ссылки, 6 geni.us) — тут аудитория готова покупать софт и железо.
- **Менеджерские/soft-skills:** слабее всех монетизированы — только вечнозелёные партнёрки, лид-магнита часто нет (LWz57CpcSnE начинается со ссылки на своё же видео).

---

## 4. Эволюция воронки по эпохам

### Эпоха 1: 2020–2022 — «карьерный ютубер с Gumroad»

- Первая строка: `My Premium Resume Package: https://jeffsu.gumroad.com/l/premium-resume-package` (21 вхождение) или free Job Search Toolkit.
- Дешёвые цифровые товары: resume package, `gradient-wallpaper-pack` (11), Editable Google Doc на Gumroad.
- Комьюнити-эксперименты: `👋🏻 Clubhouse` (15), `🙋👦🏻 Facebook Group` (6) — оба позже исчезли.
- Рассылка называется «Productivity Ping» (productivity-ping — 79 вхождений).
- GEAR-блок — прямые geni.us-ссылки (4 строки: youtube-gear, mybag, mydesk, mytravel).
- Длинный WHO AM I («full time Product Marketer», «Get better at being lazy 😏»).

### Эпоха 2: 2023–2024 — «академия и email-машина»

- Gumroad вытеснен собственной платформой academy.jeffsu.org: бесплатные toolkit'ы (ai-toolkit, workspace-toolkit, notion-toolkit) первой строкой, платная Workspace Academy внутри.
- Рассылка переименована/переехала на `jeffsu.org/newsletter/`, появляется UTM `campaign=description` в футере.
- GEAR сокращён до 2 строк и ведёт на свой сайт (yt-gear, my-edc), а не напрямую на geni.us.
- Описания короче, WHO AM I сжат до одной строки («I'm Jeff, a tech professional trying to figure life out. What I do end up figuring out, I share!»).

### Эпоха 3: 2025–2026 — «AI-продукты премиум-сегмента + спонсоры»

- Новый флагман **AI Systems Academy** (systemsacademy.ai) и постоянный блок `*BUILD A POWERFUL WORKFLOW*` с тремя платными продуктами.
- Notion Command Center продаётся через pressplay.cc (24 вхождения).
- Запуск **Cowork Academy** (coworkacademy.ai) через waitlist + бесплатный Cowork Toolkit — классический пре-лонч.
- Первую строку всё чаще выкупают спонсоры: clickhubspot.com (6 видео), Coursera imp.i384100.net (7 видео первой ссылкой), Notion ntn.so, gamma.app, Claude referral.
- Под каждое крупное видео — блогпост-компаньон на jeffsu.org с тем же UTM («Full written guide», «Resources for Claude Cowork») — контент дублируется на собственный домен.
- TOP 3 SOFTWARE-блок в самых новых видео исчезает — его место заняли собственные продукты.

**Итог эволюции оффера:** шаблоны за $10–30 (Gumroad) → бесплатные toolkit'ы + курс-флагман (Academy) → экосистема из 3–4 премиум-продуктов + спонсорские интеграции. Средний чек и число слоёв растут, число случайных партнёрок падает.

### 4.1. Смена нейминга и структуры (быстрая шпаргалка)

| Было (2020–22) | Стало (2025–26) |
|---|---|
| Gumroad resume package первой строкой | Спонсор или free AI Toolkit первой строкой |
| Productivity Ping | newsletter (utm_campaign=description) |
| 4 строки geni.us gear | 2 строки jeffsu.org gear |
| Clubhouse, Facebook Group | только Instagram + LinkedIn |
| WHO AM I + двойной дисклеймер | без WHO AM I, 1 хэштег |

---

## 5. Кросс-контент воронка

132 YouTube-ссылки в 100 описаниях — Jeff системно возвращает трафик в собственный каталог:

- **Ссылки на «следующее логичное видео»** в RESOURCES: из «5 MUST-KNOW LinkedIn Profile Tips» → «Message recruiters on LinkedIn the right way 👉🏻 https://youtu.be/jnzh5QTKbsw», «Write an Amazing Resume - https://youtu.be/Tt08KmFfIYQ». Флагманы связаны друг с другом перекрёстно.
- **Плейлисты**: «My LinkedIn Tips & Tricks Playlist», «Think Outside the Box (fully playlist) 👉🏻…» — иногда прямо в первых строках описания.
- **Самые цитируемые собственные видео** — те же флагманы воронки: Tt08KmFfIYQ «Write an Incredible Resume» (6 ссылок из других описаний), Q07rFZtc2Ao «Top 8 ChatGPT Tips» (5), jC4v5AS4RIM «Prompt Formula» (4), 7M6bIeVbCqA «My Simple Productivity System» (4). Просмотры перетекают в видео с самыми сильными лид-магнитами.
- **Чужие видео** — редко и только как «источник» (Helena Liu, Andrew Ng, Ali Abdaal): жест доверия, укрепляющий экспертность.
- В карьерных видео с 13–19 ссылками до 5 из них — свои ролики (pmnY5V16GSE «Land a Job using ChatGPT» — 5 YouTube-ссылок): описание работает как мини-хаб серии.

---

## 6. Схема воронки одним блоком

```
                       ВИДЕО (YouTube, тема X)
                              │
        «ссылка в описании» проговаривается в ролике
                              │
   ┌──────────────────────────┼───────────────────────────────┐
   ▼                          ▼                               ▼
ПЕРВАЯ СТРОКА          RESOURCES/футер                ПАРАЛЛЕЛЬНЫЕ СЛОИ
Бесплатный toolkit     • блогпост на jeffsu.org       • Спонсор первой строкой
под тему X             • свои видео/плейлисты (132)     (HubSpot, Coursera, Notion)
academy.jeffsu.org       → назад в каталог канала     • Партнёрки geni.us ×265
?utm_campaign=<№видео> • newsletter (2-й заход)         (Skillshare, CleanShot X, gear)
   │                                                  • Нишевые: Teal, Canva, Readwise
   ▼                                                  • Членство канала /join
EMAIL-РАССЫЛКА  ◄── utm_campaign=description (футер)
Productivity Ping / newsletter (129 ссылок)
   │  прогрев письмами
   ▼
ПЛАТНАЯ ЛЕСТНИЦА
Notion Command Center (pressplay) → Workspace Academy →
AI Systems Academy → Cowork Academy (waitlist = пре-лонч)
```

Логика: каждое видео продаёт не курс, а **бесплатный шаг** к курсу; продают курс уже письма. Спонсоры и партнёрки — независимые денежные слои, не конкурирующие с главной воронкой (они монетизируют тех, кто никогда не купит курс).

---

## 7. Плейбук: как скопировать воронку себе

1. **Сделай шаблон описания из фиксированных блоков** (лид-магнит → [спонсор] → резюме с ключевиками → TIMESTAMPS → RESOURCES → GEAR → TOP 3 SOFTWARE → продукты → BE MY FRIEND → дисклеймер → 1–3 хэштега) и храни как заготовку — у Jeff даже след `utm_campaign=XXX` выдаёт копипаст-шаблон.
2. **Первая строка — всегда бесплатный оффер с эмодзи и глаголом**: «🌟 Grab my free … Toolkit: <ссылка>?utm_campaign=<№>». Это единственное, что видно без клика «ещё».
3. **Заведи 3–4 лид-магнита под кластеры контента**, а не один общий: AI-видео → AI toolkit, карьерные → job-search toolkit, инструментные → workspace toolkit. Релевантность лид-магнита теме видео — главный множитель конверсии.
4. **Собирай email, а не подписчиков**: рассылка упоминается в каждом описании минимум дважды (в RESOURCES «на горячую» и в футере BE MY FRIEND). Назови её характерно («insanely actionable newsletter»).
5. **Пронумеруй видео и размечай каждую свою ссылку** `utm_source=youtube&utm_medium=video&utm_campaign=<номер видео>`; для шаблонного футера — отдельная метка `utm_campaign=description`. Так видно, какое видео и какой блок описания реально приносит лидов.
6. **Построй лестницу продуктов**: бесплатный toolkit (email) → дешёвый шаблон/пакет $10–50 (Gumroad/Notion-шаблон) → флагманский курс $100+ (академия) → следующий премиум-продукт. Новые продукты запускай через waitlist + бесплатный мини-toolkit (как Cowork Academy).
7. **Добавь вечнозелёный партнёрский слой**: 2–3 инструмента, которые сам используешь, в каждый ролик через шорт-линки (geni.us/аналог) — блоки GEAR и TOP 3 SOFTWARE. Плюс 1 нишевая партнёрка под тип видео (Teal — для карьерных, Readwise — для продуктивити).
8. **Прокладывай трафик через свой сайт**: вместо прямых партнёрских ссылок — страницы «My YouTube Gear», «Everyday Carry» на своём домене; под большие видео — блогпост-компаньон «Full written guide» с тем же UTM. Ретаргетинг и SEO остаются у тебя.
9. **Связывай видео между собой**: в RESOURCES каждого ролика — 1–3 своих видео/плейлиста, ведущих к флагманам с лучшими лид-магнитами; флагманы линкуй перекрёстно.
10. **Спонсора ставь первой строкой, а не пятой** — и только когда есть трафик: у Jeff спонсорские первые ссылки (HubSpot, Coursera) появились массово лишь в 2025+. Свой лид-магнит при этом опусти в RESOURCES, но не убирай.
11. **Пиши дисклеймер про партнёрки в своём тоне** («PS: Some of the links… I get a kickback from 😇») — честность как часть бренда, а не мелкий шрифт.
12. **Раз в 1–2 года ревизуй футер**: Jeff выкидывал мёртвые каналы (Clubhouse, Facebook Group), переименовывал рассылку, сокращал WHO AM I и заменял gear-партнёрки собственными продуктами. Описание — живой лендинг, а не архив.

---

## Приложение: опорные цифры

- Первая ссылка: Academy — 50/100, Gumroad — 11, jeffsu.org — 9, Coursera — 7, HubSpot — 6, свои видео — 6, newsletter — 4.
- Топ-домены: geni.us — 265, соцсети — 196, jeffsu.org — 177, YouTube — 132, newsletter — 129, academy.jeffsu.org — 93, Gumroad — 35, readwise — 26, pressplay — 24, Teal — 35, systemsacademy.ai — 13.
- Топ-URL: instagram/j.sushie — 98, linkedin/jsu05 — 98, geni.us/skillshare-jeff — 80, productivity-ping — 79, geni.us/cleanshotx — 67, yt-gear — 64, my-edc — 56.
- Топ-лейблы лид-магнитов: «Grab my AI Toolkit for free» (11), «🎯 My free Job Search Toolkit» (16), «🔩 Grab my free Workspace Toolkit» (9+5+3), «My Premium Resume Package» (19).
