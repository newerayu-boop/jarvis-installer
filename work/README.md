# Узбекская транскрибация видео с таймкодами и диаризацией

Пайплайн транскрибирует узбекское видео и размечает его по говорящим с таймкодами `ЧЧ:ММ:СС`.

## Модель
Используется открытая узбекская модель **`islomov/rubaistt_v2_medium`** (rubaiSTT v2) —
та же, что и в проекте `MuhammadMirrr/uzbek-dictation`. Конвертируется в формат
CTranslate2 (int8) для быстрого инференса на CPU через `faster-whisper`.

## Шаги
1. `ffmpeg` извлекает моно-аудио 16 кГц из видео.
2. `transcribe.py` — транскрибация с word-таймкодами → `segments.json`.
3. `diarize.py` — эмбеддинги голоса (SpeechBrain ECAPA-TDNN, открытая модель) +
   агломеративная кластеризация на 2 спикера → `diarized.json`.
4. `assemble.py` — сборка `transcript.txt` (читаемый) и `transcript.srt` (субтитры).

## Запуск
```bash
# конвертация модели (один раз)
ct2-transformers-converter --model islomov/rubaistt_v2_medium \
  --output_dir ct2-rubaistt --quantization int8 --copy_files preprocessor_config.json
# tokenizer.json собирается из fast-токенайзера и кладётся в ct2-rubaistt/

python3 transcribe.py
python3 diarize.py
python3 assemble.py "Юсуфбай" "Абдуллох"   # имена: спикер 0 и спикер 1
```

`assemble.py` принимает два имени (спикер 0 = тот, кто заговорил первым).
Если имена перепутаны — переставьте аргументы местами и запустите заново.
