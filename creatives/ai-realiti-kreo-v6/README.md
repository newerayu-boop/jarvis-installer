# AI-Realiti — крео для таргета (Instagram Reels / Stories, 9:16)

**Актуальный файл:** `AIStrateg_kreo_v7.mp4` — 1080×1920, 63.8 с, ~43 МБ.
`AIStrateg_kreo_v6.mp4` — предыдущая версия (оставлена для истории).

## v7 (актуальная) — что изменилось относительно v6

- **Сплошные субтитры на всю речь** (12 фраз, выверенный узбекский с золотыми акцентами) вместо 7 точечных.
- **Новая фоновая музыка** из `IMG_8960.MP4` — зациклена на всю длину, с дакингом под голос (sidechain).
- Убраны нижние карточки-тезисы (дублировали субтитры); оставлены 2 ключевых штампа ($1000–1500, 4 ODAM) и чипы Claude / NotebookLM / Jarvis вокруг кружка.
- Хук в начале ($100 000 + «Jamoasiz. Prodyusersiz.») сохранён.

Скрипты v7: `scripts/make_subs_v7.py`, `scripts/render_v7.py`, `scripts/subs_v7.ass`.

---

## v6 (архив)

**Файл:** `AIStrateg_kreo_v6.mp4` — 1080×1920, 63.8 с, ~43 МБ, звук: голос кружочка + музыкальная подложка из v5.

Собрано по мотивам крео #2 и #5 из `AI-Realiti_Kreativlar_Target.md` (стиль: чёрный `#0a0a0a`, золото `#C9A961`, Unbounded / Inter / Playfair Italic) и видео-референса `AIStrateg_kreo_target_v5.mp4`.

## Таймлайн

| Время | Что происходит |
|---|---|
| 0.0–2.6 | Интро-хук: киккер «— REALITY · 20 KUN», штамп **$100 000**, серифный «Jamoasiz. Prodyusersiz.», золотая вспышка на стыке |
| 2.6–61.0 | Кружочек в золотом кольце (900px) с вращающимися дугами и свечением; дрейфующие частицы; вращающийся бейдж «AI STRATEG · REALITY · 20 KUN» |
| 2.8–31.3 | Фразовые титры (выверенный узбекский): «PRODYUSER? EKSPERT? MARKETOLOG?» → «KADRLAR NARXI — JUDA BALAND» → «SIFATSIZ KADRLARDAN CHARCHAB» → «O'ZIMGA AI-AGENTLAR YARATDIM» (золото) → «MANA — MENING AI-JAMOAM» |
| 12.1–16.2 | Штамп **$1 000 – $1 500** «bitta mutaxassis narxi» |
| 16.4–24.2 | Карточка «Tajriba bor / Rossiya bozorida jamoa bilan ishlaganman» |
| 31.5–39.0 | Карточка «AI-agent jamoa» + чипы Claude / NotebookLM / Jarvis вокруг кружка (покачиваются) |
| 39.2–43.4 | Штамп **4 ODAM** «20 kishining ishini qilyapti» |
| 46.0–49.3 | «BU — REALITY.» (золото) → штамп **20 KUN** «jonli · montajsiz · ichkaridan» |
| 49.4–55.3 | Карточка «Hammasi — ochiq / jarayon · promptlar · raqamlar · xatolar» |
| 55.8–63.8 | CTA: кнопка **«Joy band qilish →»**, пилюля «200 ta joy · ataylab cheklangan · Telegramda», `aistrateg-reality.vercel.app`; фриз кадра, музыка затухает |

## Почему титры фразовые, а не пословные

Whisper large-v3 на разговорном узбекском (ташкентский, с русизмами) даёт много ошибок в словах — пословные субтитры выглядели бы безграмотно. Поэтому текст титров выверен вручную по смыслу речи, а тайминги взяты из пословных таймкодов (`scripts/krug.words.json`).

## Как пересобрать

```bash
apt install ffmpeg && pip install faster-whisper pillow fonttools
# шрифты: Unbounded, Inter, Playfair Display Italic (Google Fonts, variable → статика через fonttools)
# музыка: demucs --two-stems=vocals по аудио из v5 (голос отрезан, остаётся подложка)
python3 scripts/make_assets.py    # PIL-ассеты: фон, частицы, кольцо, бейдж, штампы, карточки, CTA
python3 scripts/make_subs_v6.py   # ASS-титры
python3 scripts/render_v6.py      # сборка одним проходом ffmpeg
```

Пути в скриптах абсолютные (под сессию Claude Code) — при пересборке поправить на свои.

## Аудио

- Голос кружочка: `highpass 80 Hz → afftdn → dynaudnorm`
- Музыка из v5 (стем no_vocals): дакинг через `sidechaincompress` от голоса, микс `loudnorm I=-14`
