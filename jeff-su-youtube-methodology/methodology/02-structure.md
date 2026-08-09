# Структура видео: скелет и тайминги

> Синтез на основе разбора 100 видео канала Jeff Su. Все цитаты — дословные, на английском. Типичный хронометраж видео — 8–15 минут; тайминги ниже даны в процентах и в минутах для условного 12-минутного ролика.

---

## Часть 1. Каноническая анатомия видео Jeff Su

```
┌─────────────────────────────────────────────────────────────────┐
│ 0:00–0:30   ХУК (ценность/скетч/цифра/провокация — до интро)    │
│ 0:20–0:45   ROADMAP ("In this video I'll first... then...")     │
│             + open loop на бонус ("stick around to the end...") │
│ 0:30–0:45   "Let's get started."                                │
│ 0:40–1:10   (в ранних видео) Приветствие + джингл               │
│             "Hi friends... Come for the X and stay for the Y"   │
│─────────────────────────────────────────────────────────────────│
│ 1:00–5:30   ПУНКТЫ 1–3 ("Diving right into tip number one...")  │
│             каждый пункт: сценарий → демо → Pro tip → мостик    │
│ ~2:30–4:00  Mid-roll вовлечение (лайк/вопрос в комменты)        │
│─────────────────────────────────────────────────────────────────│
│ 5:00–7:00   СПОНСОР / ЛИД-МАГНИТ (~40–60% хронометража,         │
│  (40–60%)   всегда через смысловой мост "Speaking of..." /      │
│             "By the way...", всегда с возвратом "back to...")   │
│─────────────────────────────────────────────────────────────────│
│ 7:00–10:30  ПУНКТЫ 4–N (эскалация сложности:                    │
│             "Onto the really, really fun stuff...")             │
│─────────────────────────────────────────────────────────────────│
│ 10:30–11:15 БОНУС — награда за досмотр                          │
│             "Bonus tip for everyone still watching..."          │
│ 11:15–11:40 РЕКАП — "To quickly recap, number one..."           │
│ 11:40–12:00 ФИНАЛ-ВОРОНКА — вопрос в комменты → увод на         │
│             конкретное видео → "See you on the next video.      │
│             In the meantime, have a great one."                 │
└─────────────────────────────────────────────────────────────────┘
```

### Пояснения к сегментам

**Хук (0–30 сек).** Ценность до приветствия — см. документ `01-hooks.md`. Закрывается ритуальным "Let's get started."

**Roadmap (1 предложение).** Всегда формула «сначала → затем → в конце»: "In this video we'll first run through the setup process for Microsoft Outlook then go through the workflow you'll use to get to inbox zero every single day and end with some drawbacks". Часто в roadmap зашит open loop до самого конца: "make sure to stick around to the very end because I have one small hack designed, especially for you" (*8 Google Calendar Settings*, 1.4M).

**Пункты.** Нумерованный листикл — базовый каркас (см. Часть 2). Внутри длинных видео сложность нарастает и это проговаривается: "And this got progressively more advanced by the way", "Onto the really, really fun stuff. Gmail tip and trick number five", "ordered from simple to advanced", "sorted from easiest to hardest" (в *95% of People STILL Prompt ChatGPT-5 Wrong* у каждого совета даже маркирован уровень усилий: "effort low / medium / high").

**Mid-roll вовлечение (после 1–2 пунктов).** Вопрос или лайк вшивается в момент, когда зритель уже получил ценность: "Have you found this first tip helpful? Let me know by dropping a like and commenting down below which industry you wanna learn more about"; "If you're enjoying these tips so far, please drop a like, and if not, keep watching, because we're going to now turn it up a notch." Фирменные шутки-инверсии: "if you haven't found this useful at all, make sure to click that thumbs up button twice"; "feel free to hit that dislike button twice to really make your point".

**Спонсор — только в середине (~40–60%).** Никогда не в начале. Три железных правила:
1. *Вход через смысловой мост:* "Speaking of recording your screen, the sponsor of today's video is Scribe"; "Speaking of matching the right tool to the task, today's sponsor HubSpot put together a free guide..."; "everything we built today revolves around one important concept, relevant context. And that's something I learned firsthand from today's sponsor, Coursera."
2. *Личное доверие внутри интеграции:* "I've been using Dropbox since I started YouTube years ago so I'm pretty excited they're sponsoring this portion of the video"; "I probably would have talked about them anyways"; "the only job search company I've agreed to a sponsorship with".
3. *Явное закрытие и возврат:* "Thank you HubSpot for sponsoring this portion of the video" → "back to coming up with relevant metrics" / "but for now back to the digital world" / "moving on."

Если спонсора нет — на том же месте стоит собственный лид-магнит с фирменной формулой: **"By the way, this video is not sponsored but it is supported by those of you who subscribe to my paid productivity newsletter... Link in the description to learn more."** Или анти-спонсорский гэг: "by the way both open AI and Microsoft refused to sponsor this video for whatever reason"; "Apple still refuses to sponsor me because I'm apparently too sarcastic".

**Бонус — награда за досмотр.** Ставится после последнего пункта, до рекапа: "Bonus tip for everyone still watching, embedding AI triggers"; "bonus tip for those of you who stuck around this far"; "Here's a bonus update for those of you still watching"; "To reward those of you who have stuck around until now, here's a link to download this exact template"; "as a reward for those of you who stayed until the end I've listed out all the prompts mentioned in this video on a single page"; "Easter egg for those of you who didn't catch this at the beginning of this video". Фирменная самоидентификация приёма: "it wouldn't be a Jeffs video without a bonus tip" (*How to Get Started with Notion*).

**Рекап.** В длинных и обучающих видео — обязательный: "To quickly recap...", "as a quick recap number one... number two... and number three...", "let's quickly recap what we just did". В сложных туториалах рекапы стоят и после каждого крупного блока ("Here's a quick recap of level one" — *How I'd Learn AI From Scratch*).

**Финал-воронка (2–3 предложения, никаких затянутых прощаний).** См. Часть 5.

---

## Часть 2. Нумерованный листикл как каркас

Количество пунктов заявлено в заголовке и повторено в хуке. Зритель всегда знает, где находится и сколько осталось — это главный механизм удержания. Каждый пункт озвучивается с вариативной формулировкой (не механическое "tip 2, tip 3"), а у лучших пунктов есть авторские названия-неологизмы: "steal with pride", "template all the things", "context cheating", "answer leveling", "the first try fallacy", "the summary only shortfall", "the prompt overload paradox", "death by prompts", "the impact Loop", "the Anti-McDonald's Habit", "minimum viable toolkit", "the OC combo", "the Pre-Alignment Appetizer".

### Полный словарь маркеров-переходов (дословно)

**Открытие первого пункта:**
- "Diving right into..." / "Diving right into it" / "Diving right to tip number one..."
- "Diving right into an example" / "Diving right to an example"
- "Kicking things off with..." ("Kicking things off with trend number one", "Kicking things off at level one", "Kicking things off with the easiest habit to adopt")
- "First up..." / "First things first..." / "Starting off nice and easy..."
- "Starting with number one" / "starting with tip number one..."
- "Let's start breaking each one of these down."
- "all right first off..."

**Переходы между пунктами:**
- "Moving on to..." ("Moving on to tip number two", "Moving on to habit number two that requires a bit more effort", "Moving on to mobile AI habit number three")
- "Next up..." / "Next up, we have..." / "next let's talk about..."
- "Onto..." ("Onto update number three", "Onto the second category, specialist AI", "Onto the really, really fun stuff")
- "Moving over to..." ("Moving over to organization, tip number six", "Moving over to large language models", "Moving over to Google Docs")
- "Staying within..." / "Staying on the topic of..." ("Staying within Finder...", "staying on the topic of notes productivity tip number two")
- "This is a nice segue into..." / "this is a great segue into..." / "which is a great segue into why I quit"
- "This brings us to..." ("this brings us to tip number two", "This brings us to a bonus habit that ties everything together")
- "Speaking of..." ("Speaking of Gemini apps, let's start off with my favorite use case") — также главный мост к спонсору
- "Coming back to..." / "back to..." ("back to the workout example")
- "Moving on." (короткая отбивка после спонсора)
- Нумерация с эпитетами-усилителями: "Mind blowing Gmail tip number two", "the third extremely underrated LinkedIn feature", "the second mac app i use every two minutes", "this next one is my favorite by far", "Tip number five, probably the most controversial"
- Пейсинг-маркеры: "Chrome extension number six is a quickie", "Tip number three is a quick one", "gcal feature number 10 is a quickie", "App number six is a quickie"

**Закрытие списка:**
- "Last but not least..." / "last but certainly not least..." / "Last but certainly not even close to least we have..."
- "Rounding out..." ("rounding out mac apps for productivity number 10", "Rounding out the everyday AI category, Claude")
- "Ending with a very practical tip number five"
- "all right last and well maybe least..." (ироничная инверсия)

**Рекап и итоги:**
- "To quickly recap..." / "as a quick recap number one..." / "let's quickly recap what we just did"
- "So to quickly recap."
- "In summary..." / "to sum up..." / "To quickly summarize..."
- "Two things I'd like to leave you with" / "there are three things I want to leave you with. First... Second... Third..."
- "a few final thoughts I want to leave you with first... second... third..."
- "Final thought I want to leave you with"
- "Closing the loop, ..."
- "Wrapping up step three..." / "and to wrap up"

**Внутрипунктовые микро-маркеры:**
- "Pro tip..." / "Pro tip number one/two..." / "pro pro tip..." / "power tip"
- "In plain English, ..." / "In simple terms, ..." / "In a nutshell, ..." / "Put simply, ..."
- "as a rule of thumb..." / "my rule of thumb is..."
- "here's a perfect example" / "check this out" / "real world example"
- "the key Insight here is..." / "and this is the most important sentence in this entire video"
- "But here's the thing..." / "But here's where it gets tricky."
- Open loops: "more on that in a little bit", "you'll see why later", "I'll explain why later", "keep that in mind moving forward", "we'll cover that later", "I'll save that for the next video"

---

## Часть 3. Вариации структуры по форматам

### Формат A. Листикл советов (базовый, ~60% видео)

*Примеры:* Top 5 Productivity Tips (1.3M), 8 Google Calendar Settings (1.4M), Top 8 ChatGPT Productivity Tips (1.2M), 11 MUST HAVE Extensions (273K).

```
Хук → (roadmap) → пункты 1…N с нарастанием сложности →
спонсор между пунктами (~середина) → бонус-пункт → финал-воронка
```

Особенности: количество в заголовке; эскалация ("Onto the really, really fun stuff"); каждый пункт привязан к реалистичному рабочему сценарию ("very realistic use cases for each tip, so you can become more productive at work or at school immediately"). Иногда пункты группируются в проговорённые категории: "I've broken these down into three different categories. Time-savers... organizational tips... and aesthetics" (*Top 14 Notion Tips*), или в фазы: before/during/after (*Run Meetings that Don't Suck*, *6 Tips for Productive 1:1 Meetings*).

### Формат B. Туториал follow-along (build-along)

*Примеры:* How to Get Started with Notion (1.2M), How to Build a Prompts Database in Notion (259K), The AI Agent Tutorial (414K), Send Personalized BULK Emails (962K), Mortgage Calculator (157K).

```
Хук (демо конечного результата) → «сделай копию шаблона» →
пошаговая сборка с экрана (шаги, а не номера советов) →
промежуточные рекапы → демонстрация «in action» →
запланированная ошибка + отладка → финал-воронка
```

Ключевые приёмы формата:
- **Demo-first:** "before we begin building let me quickly show you what the end result looks like".
- **Лид-магнит в начале:** "I've linked this entire template down below so feel free to make a copy and follow along".
- **Снижение порога:** "don't worry I've done most of the heavy lifting"; "Don't worry, it's actually simpler than it seems. I promise, I'll explain everything."
- **Запланированная ошибка как драматургия:** "and oh crap you ran into an error see Google told you not to trust me but you didn't listen... no just kidding this is all part of the plan"; "oops we ran into an error thank god this is my design and I totally plann for this no but seriously I did".
- **Управление ожиданиями:** "This will be a slightly longer video, but by the end, you go from just using AI to actually building with it."
- **Смена темпа:** "Enough talk. Let's start building."

### Формат C. Выжимка книги / исследования / курса

*Примеры:* What Makes a GREAT Manager (Julie Zhuo, 384K), 90-Day Plan from Harvard (171K), Write an Incredible Resume (исследование Austin Belcak, 4.3M), Google's AI Course for Beginners (3.5M), 99% of Beginners Don't Know the Basics of AI (обзор курса, 3.3M).

```
Хук (авторитет + конкретная цифра источника) →
дисклеймер честности ("Austin did not ask me to make this video") →
кураторская выборка ("Julie actually covers eight qualities... but I thought
these three were the most relevant") → выводы вперёд → разбор каждого вывода
с личными историями из Google → сжатый обзор остального → финал-воронка
```

Ключевые приёмы: позиционирование «я сэкономлю вам время» ("get you 80% of the benefit with just 20% of the effort", "I care about your time so I'm going to share the five key learnings up front"); каждый тезис источника подкрепляется личным кейсом ("when I transfer from the sales team to the marketing team here at Google..."); честная критика источника как приём доверия ("the examples they give in the course are pretty vague... that was it that was entire example"); в обзорах курсов — блок pros/cons и вердикт ("I'm going to start with who this course is not for").

### Формат D. Тренды / новости с метаформулой

*Примеры:* Top 6 AI Trends That Will Define 2026 (412K), Master Gemini 3.1 for Work (368K), NotebookLM Changed Completely (359K).

Метаформула каждого сегмента объявляется в хуке и повторяется для каждого пункта:

> "For each trend, I'll first start with a big picture, then move on to the actionable takeaways so that by the end, you have a clear sense of where AI is heading and what to do about it."

```
Для каждого тренда:
  BIG PICTURE (данные, графики, источники) →
  "So, what does this mean for us?" →
  "The practical takeaway here is..." (+ челлендж: "Attempt one impossible
  task this month")
```

Ключевые приёмы: плотность цифр из источников ("Nvidia's latest chips uses 105,000 times less energy per token than they did 10 years ago"); переводчик "And here's what that means in plain English"; позиция куратора-фильтра ("after a month of going through official guides and testing Gemini 3 with real work, I've narrowed down the five changes that actually matter"); тир-листы ("I've split them into tier one must-use and tier two situational tools").

### Формат E. Скоростной гайд "Learn 80% of X"

*Примеры:* Learn 80% of Perplexity (1.8M), Learn 80% of NotebookLM (1.6M), Master 85% of Google Gemini (775K), Learn 80% of Claude Cowork (1.1M), Give Me 9 Minutes (233K).

```
Хук: ментальная модель «куда этот инструмент вписывается»
("imagine a spectrum on one end we have tools like chbt and Gemini...
on the other end are tools like perplexity and Google search") →
настройки с нуля ("diving right into the settings") →
фичи/юзкейсы по нарастающей ("my favorite feature...") →
ЧЕСТНЫЙ БЛОК СЛАБОСТЕЙ ("now let's dive into an example where perplexity
doesn't perform very well") → Pro vs Free ("most users will be just fine
with a free version") → рекап → финал-воронка
```

Обязательный элемент формата — блок честных недостатков и экономии денег зрителя: "although I pay for perplexity Pro most users will be just fine with a free version"; "projects is a paid feature so if you can only pay for one AI tool out say stick with chat BT or Google Gemini"; "I'll be very honest, this has mainly been a gimmick for me". Это главный генератор доверия в обзорах.

### Формат F. Карьерный ответ на вопрос интервью

*Примеры:* Tell Me About Yourself (1.2M), What is Your Biggest Weakness (185K), Why Are You Leaving Your Current Job (194K), Why Do You Want to Work Here (268K).

```
Хук (разрушение мифа / инсайт «что на самом деле хочет интервьюер») →
roadmap → фреймворк с именем-аббревиатурой (ETP, CARL, present-past-future,
the highlight method) → разбор каждого пилона с таймингом ответа
("50% of your answer... 30 percent... 20%"; "1 минута / 1 минута / 30 сек") →
РАЗЫГРАННЫЙ ОБРАЗЦОВЫЙ ОТВЕТ целиком ("So Jeff, can you tell me about your
biggest weakness? — Sure. I would say...") → рекап → финал-воронка
```

Кульминация формата — полный образцовый ответ, обещанный в хуке и выданный только в конце (open loop на всё видео).

### Формат G. Сторителлинг (редкий)

*Пример:* My Last Day at Google (229K). Влог-сцена с места событий → уязвимая история провала → уроки → "which is a great segue into why I quit" → 3 причины → благодарности → эмоциональный финал. Даже здесь сохраняются нумерация ("Reason number two is a push factor") и "have a great one".

---

## Часть 4. Микроструктура одного пункта

Устойчивый цикл внутри каждого совета/фичи (60–120 секунд):

```
1. НАЗВАНИЕ-КРЮЧОК
   Номер + вариативная формулировка + (в идеале) неологизм или эпитет:
   "use case number one context cheating", "Mind blowing Gmail tip number two",
   "Tip number five, probably the most controversial, be the master of one"

2. ПРОБЛЕМА / СЦЕНАРИЙ (10–20 сек)
   Узнаваемая рабочая ситуация, часто с выдуманным персонажем на базе бренда:
   "Your colleague, let's call him Tim Cookie, just rage quit for absolutely
   no reason and left you with a spreadsheet with zero context."
   Или контраст «плохо → хорошо»: "assume the role of a copywriter will perform
   worse than assume the role of a copywriter with over 20 years of experience"

3. ДЕМО НА РЕАЛЬНЫХ ДАННЫХ (30–60 сек)
   Живой экран, реальные артефакты автора (его 330 задач в Notion, 182 выпуска
   рассылки, настоящий performance review), клики и шорткаты вслух:
   "I'm just going to copy this code, open up a new chat, paste it in, click
   enter", "Feel free to just pause the video and copy my settings here."
   Живая реакция как pattern interrupt: "Whoa. Okay. 99.7." / "Okay, I I was
   going to move on, but this is crazy... Damn." / "Boom."

4. PRO TIP (10–20 сек)
   Бонусный слой ценности поверх пункта, 1–3 штуки:
   "Pro tip, people often ask me which prompts I save to my prompts database...",
   "Pro tip number two for paid users...", "pro pro tip hyperlink and bookmark
   whenever appropriate"
   + при необходимости правило-выжимка: "so as a rule of thumb, if a task has
   a lot of moving parts, and getting one wrong breaks the whole thing, start
   with Chachib"

5. МОСТИК ДАЛЬШЕ (1 фраза)
   Логическая связка, а не просто «дальше»: "Now that we can easily bring text
   and files into the AI apps, we need to reduce the friction of inputting
   prompts" → следующий пункт. Или короткое: "Moving on to..."
```

Опциональные усилители внутри пункта:
- **Голос скептичного зрителя** (отработка возражения): "but Jeff you might say skills are so easy to add I can probably add 50 in 2 minutes well yes but actually no"; "okay Jeff I hear what you say these are all great examples but my job does not have clear cut metrics... I hear you."
- **Самоирония-вставка** между блоками пользы: "as you can see, I have no friends, quality over quantity though".
- **Мгновенный откат шутки:** "...Just kidding. I love the sales team."
- **Кредит источнику:** "credit goes to Ali Miller on LinkedIn for teaching me this"; "I straight up stole this from Thomas Frank, who's like a Notion genius."
- **Вопрос в комменты по теме пункта** (не в конце видео, а там, где релевантно).

---

## Часть 5. Финал-воронка

Финал занимает 2–3 предложения и никогда не затягивается. Каноническая формула из трёх ходов:

```
1. (опционально) Рекап или последний вывод-принцип
2. Увод на КОНКРЕТНОЕ следующее видео/плейлист с обоснованием
3. Коронная фраза: "See you on the next video. In the meantime, have a great one."
```

### Дословная формула закрытия

Присутствует практически в 100% видео (включая эмоциональное прощальное видео про уход из Google — там осталось "And with that, as usual, have a great one"):

> **"See you on the next video. In the meantime, have a great one."**

Вариации: "See you all next week, and in the meantime, have a great one"; "and as usual have a great one"; "See you there. And in the meantime, have a great one"; "See you over there and in the meantime, have a great one"; ранний формат — "Until next time, bye bye" (быстро отброшен).

Полные образцы финалов:

> "If you enjoyed these tips, you should definitely check out my top five chatbt use cases for professionals. See you on the next video. In the meantime, have a great one." — *4 ChatGPT Hacks*

> "alright once you've updated that resume make sure to check out this video on how to write an effective cover letter to maximize your chances for a first round interview see you in the next video in the meantime have a great one" — *5 Resume Mistakes*

> "If you have no idea what I'm talking about, check out my step-by-step tutorial on inbox zero. See you on the next video. And in the meantime, have a great one." — *10 Gmail Productivity Tips*

### Как выбирается следующее видео

1. **Следующий шаг воронки зрителя** (сильнейший вариант): resume → cover letter ("once you've updated that resume make sure to check out this video on how to write an effective cover letter"); LinkedIn-профиль → сообщения рекрутерам ("now that you have an All-Star LinkedIn profile optimized for job search make sure to check out this video next on best practices for messaging Recruiters"); формула промптов → продвинутый уровень ("now that you know the basics of prompting my next video is going to take you from beginner to Pro").
2. **Смежная тема того же кластера:** Claude → "check out my perplexity and notebook LM tutorials next"; Gemini → "check out my claw tutorial next" (AI-туториалы перелинкованы кольцом).
3. **Часть серии:** "make sure to check out part one where I go through the best Mac apps I use for productivity"; "As a reminder, I'll cover the remaining two categories in part two, so keep an eye out for that."
4. **Плейлист** (когда нет очевидного одного видео): "If you're interviewing right now, make sure to check out my playlist on the most common interview questions and answers"; "check out my AI playlist next".
5. **Последний совет видео сознательно завязывается на другой туториал:** "tip number 10 is knowing when to snooze... If you have no idea what I'm talking about, check out my step-by-step tutorial on inbox zero" — увод становится частью контента, а не рекламой.

Дополнительные элементы финального блока (перед коронной фразой):
- **Вопрос-выбор в комменты вместо просьбы подписаться:** "please let me know down the comments which one of these tips you enjoyed the most"; "let me know in the comments what type of AI agent you'd like me to make a tutorial on next".
- **Сбор заявок на будущие видео** (комменты как фабрика контента): "let me know if you want a full tutorial on Sora 2"; "let me know in the comments if you want an adjustable rate mortgage calculator".
- **Мотивационная нота в больших видео:** "Stop worrying about developing a perfect plan to learn AI and instead just get started." (*AI Trends*); "Most people aren't here yet and that's okay. There's no rush." (*How I'd Learn AI From Scratch* — закольцовка с хуком про overwhelm).
- **Пост-финальный callback-скетч** (опционально): "let's get started dude who are you talking to no one no one no one no one" (*Top 5 Productivity Tips*).

---

## Часть 6. Чек-лист структуры для собственного видео

### Открытие (0:00–1:00)
- [ ] Первые 5 секунд — ценность/шок/смех, НЕ приветствие и НЕ заставка
- [ ] Хук соответствует заголовку дословно (провокация из заголовка отработана первой фразой)
- [ ] Roadmap одним предложением: «сначала… затем… и в конце…»
- [ ] В roadmap зашит open loop на бонус в финале («досмотри до конца — там…»)
- [ ] Ритуальная фраза-переход (своя версия "Let's get started")
- [ ] Обещание квантифицировано: сколько пунктов, за сколько минут, какой результат

### Каркас
- [ ] Количество пунктов заявлено в заголовке и в хуке
- [ ] Каждый пункт озвучен с номером, формулировки переходов варьируются ("Diving right into… / Moving on to… / Next up… / Last but not least…")
- [ ] Лучшие пункты имеют авторские названия-неологизмы
- [ ] Сложность нарастает, и это проговорено ("ordered from simple to advanced")
- [ ] Есть пейсинг: пара коротких пунктов-«квики» между длинными ("number six is a quickie")

### Микроструктура каждого пункта
- [ ] Сценарий/боль → демо на РЕАЛЬНЫХ данных → Pro tip → логический мостик дальше
- [ ] Демо показывает клики/шорткаты, зрителю разрешено «pause the video and copy my settings»
- [ ] Минимум 1 Pro tip на 1–2 пункта
- [ ] Хотя бы раз отработано возражение голосом скептичного зрителя ("but Jeff...")
- [ ] Юмор вшит ВНУТРЬ пользы (самоирония, "just kidding"-откаты), а не отдельными блоками
- [ ] Конкретные цифры вместо абстракций (не «много», а «367», «21 слово», «40 раз»)

### Удержание
- [ ] Mid-roll вовлечение после 1–2 пунктов (вопрос в комменты по теме пункта, а не «подпишись»)
- [ ] 2–3 open loops: "more on that in a little bit" / "you'll see why later" — и ВСЕ закрыты до конца видео
- [ ] Бонус для досмотревших после последнего пункта ("Bonus tip for everyone still watching")
- [ ] В обзоре инструмента есть честный блок слабостей/минусов
- [ ] Кредиты источникам и другим авторам ("credit goes to…", "I straight up stole this from…")

### Монетизация
- [ ] Спонсор/лид-магнит на 40–60% хронометража, НИКОГДА в начале
- [ ] Вход через смысловой мост ("Speaking of…" / "By the way…"), выход с явным возвратом ("back to…")
- [ ] Благодарность спонсору проговорена ("Thank you X for sponsoring this video")
- [ ] Без спонсора — формула "not sponsored but supported by…" или лид-магнит (шаблон/toolkit/рассылка)
- [ ] Все обещанные материалы реально отданы «down below» (шаблоны, промпты, PDF)

### Финал (последние 30 секунд)
- [ ] Рекап для длинных видео ("To quickly recap, number one…")
- [ ] Увод на ОДНО конкретное следующее видео (следующий шаг воронки зрителя), с обоснованием почему
- [ ] Вопрос-выбор в комменты и/или сбор тем для будущих видео
- [ ] Коронная фраза-подпись (своя версия "See you on the next video. In the meantime, have a great one.")
- [ ] Финал уложился в 2–3 предложения — без затянутых прощаний и повторных CTA
