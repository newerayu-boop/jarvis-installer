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

### macOS / Linux

```bash
cd uzbek-transcribe
bash setup.sh
```

Скрипт поставит `ffmpeg` (через Homebrew, если его нет), создаст окружение
`.venv` и установит зависимости.

### Windows

1. Установи **Python 3.11** с https://www.python.org/downloads/ — при установке
   обязательно поставь галочку **«Add Python to PATH»**.
2. Установи **ffmpeg**: скачай `ffmpeg-release-essentials.zip` с
   https://www.gyan.dev/ffmpeg/builds/, распакуй, и добавь папку `bin` в
   переменную среды `PATH`.
3. В папке `uzbek-transcribe` запусти двойным кликом `setup_windows.bat`
   (или в командной строке: `setup_windows.bat`).
4. Запуск транскрибации:
   ```bat
   .venv\Scripts\activate.bat
   python transcribe.py "C:\Users\ТВОЁ_ИМЯ\Downloads\yusuf sotuv.mp4"
   ```

> На Windows определение спикеров (диаризация) работает так же, как на Mac —
> нужен токен HuggingFace (см. ниже). Если у тебя видеокарта NVIDIA, обработка
> пойдёт быстро; без неё — на CPU (медленнее, но работает).

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

## Быстрый вариант для CPU (без видеокарты): `transcribe_fast.py`

Если у тебя нет GPU (обычный ПК/ноутбук), обычный `transcribe.py` на CPU идёт
медленно. Для этого есть `transcribe_fast.py` — он конвертирует ту же модель в
формат CTranslate2 (int8) и работает в разы быстрее. Именно этим скриптом было
обработано видео `yusuf sotuv`.

```bash
pip install faster-whisper ctranslate2 transformers torch gdown
# для определения спикеров без токена HuggingFace:
pip install resemblyzer scikit-learn librosa

python3 transcribe_fast.py "video.mp4"                       # только текст+таймкоды
python3 transcribe_fast.py "video.mp4" --diarize             # + определение спикеров (без HF-токена)
python3 transcribe_fast.py "video.mp4" --name Yusuf          # если один говорящий — подписать именем
```

Определение спикеров тут работает **без токена HuggingFace** (через resemblyzer
+ кластеризацию), в отличие от `transcribe.py` (там pyannote и нужен токен).

## Частые вопросы

- **Долго качает при первом запуске** — модель ~1.5 ГБ, качается один раз, потом
  кешируется.
- **Медленно на CPU** — на Apple Silicon (M1/M2/M3) автоматически используется
  GPU (MPS). На старых Intel-маках будет медленнее, но работает.
- **`ffmpeg не установлен`** — `brew install ffmpeg`.
- **Поддерживаемые форматы** — любые, что читает ffmpeg: mp4, mov, mkv, mp3, m4a, wav…
