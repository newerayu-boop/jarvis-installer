# Узбекская транскрибация с таймкодами и определением собеседников

Транскрибирует видео/аудио на узбекском **той же обученной моделью**, что и
проект [uzbek-dictation](https://github.com/MuhammadMirrr/uzbek-dictation) —
`islomov/rubaistt_v2_medium` (Whisper, дообученный на узбекском).

Результат:
- разбивка по таймкодам **ЧЧ:ММ:СС** (посекундно),
- определение **разных собеседников** (SPEAKER_00, SPEAKER_01…), которых можно
  подписать реальными именами (Yusuf, Mijoz и т.д.),
- файлы `.txt` (читаемый) и `.srt` (субтитры).

> ⚠️ Важно: этот скрипт запускается **у тебя на компьютере**, потому что твоё
> видео лежит локально в `Downloads`. Claude в облаке не имеет доступа к твоему
> диску, поэтому обработку делаешь ты одной командой ниже.

---

## Установка (один раз)

```bash
cd uzbek-transcribe
bash setup.sh
```

Скрипт поставит `ffmpeg` (через Homebrew, если его нет), создаст окружение
`.venv` и установит зависимости.

---

## Запуск

```bash
source .venv/bin/activate

python3 transcribe.py "/Users/ТВОЁ_ИМЯ/Downloads/yusuf sotuv.mp4"
```

Путь бери свой. Если в имени файла есть пробел — оборачивай в кавычки (как выше).
Не знаешь точный путь — перетащи файл в терминал, он сам подставит путь.

После обработки рядом появятся:
- `yusuf sotuv.txt`
- `yusuf sotuv.srt`

Пример строки в `.txt`:
```
[00:00:00 - 00:00:04] SPEAKER_00: Assalomu alaykum, bugun mahsulot haqida gaplashamiz.
[00:00:05 - 00:00:09] SPEAKER_01: Ha, albatta. Narxi qancha?
```

---

## Подписать собеседников реальными именами

Сначала запусти обычным способом и посмотри, кто есть (SPEAKER_00, SPEAKER_01…).
Потом перезапусти с заменой:

```bash
python3 transcribe.py "/Users/ТВОЁ_ИМЯ/Downloads/yusuf sotuv.mp4" \
  --names "SPEAKER_00=Yusuf,SPEAKER_01=Mijoz"
```

Получится:
```
[00:00:00 - 00:00:04] Yusuf: Assalomu alaykum...
[00:00:05 - 00:00:09] Mijoz: Ha, albatta. Narxi qancha?
```

---

## Включить определение собеседников (диаризацию)

Модель определения спикеров `pyannote/speaker-diarization-3.1` бесплатная, но
требует токен HuggingFace и принять условия:

1. Зарегистрируйся на https://huggingface.co
2. Прими условия на страницах:
   - https://huggingface.co/pyannote/speaker-diarization-3.1
   - https://huggingface.co/pyannote/segmentation-3.0
3. Создай токен: https://huggingface.co/settings/tokens (тип **Read**)
4. Запусти с токеном:

```bash
export HF_TOKEN=hf_твой_токен
python3 transcribe.py "/Users/ТВОЁ_ИМЯ/Downloads/yusuf sotuv.mp4"
```

Без токена спикеры просто не будут определяться — текст с таймкодами всё равно
получится. Чтобы сознательно отключить определение спикеров:

```bash
python3 transcribe.py "video.mp4" --no-diarize
```

---

## Частые вопросы

- **Долго качает при первом запуске** — модель ~1.5 ГБ, качается один раз, потом
  кешируется.
- **Медленно на CPU** — на Apple Silicon (M1/M2/M3) автоматически используется
  GPU (MPS). На старых Intel-маках будет медленнее, но работает.
- **`ffmpeg не установлен`** — `brew install ffmpeg`.
- **Поддерживаемые форматы** — любые, что читает ffmpeg: mp4, mov, mkv, mp3, m4a, wav…
