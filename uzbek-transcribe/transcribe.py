#!/usr/bin/env python3
"""
Узбекская транскрибация видео/аудио с таймкодами и определением собеседников.

Использует ту же обученную модель, что и uzbek-dictation:
    islomov/rubaistt_v2_medium  (Whisper, дообученный на узбекском)

Что делает:
  1. Достаёт аудио из видео (ffmpeg) -> 16kHz mono wav.
  2. Транскрибирует с таймкодами (сегменты).
  3. (опционально) Определяет спикеров через pyannote.audio (диаризация).
  4. Пишет результат в .txt (с таймкодами ЧЧ:ММ:СС и спикерами) и .srt.

Запуск:
    python3 transcribe.py "/Users/ТВОЁ_ИМЯ/Downloads/yusuf sotuv.mp4"

С реальными именами вместо SPEAKER_00 / SPEAKER_01:
    python3 transcribe.py "video.mp4" --names "SPEAKER_00=Yusuf,SPEAKER_01=Mijoz"

Без диаризации (быстрее, только текст с таймкодами):
    python3 transcribe.py "video.mp4" --no-diarize
"""

import argparse
import os
import subprocess
import sys
import tempfile

MODEL_ID = "islomov/rubaistt_v2_medium"
DIARIZE_MODEL = "pyannote/speaker-diarization-3.1"


def log(msg: str) -> None:
    print(f"[transcribe] {msg}", flush=True)


def sec_to_hms(seconds: float) -> str:
    """12.5 -> '00:00:12'  (ЧЧ:ММ:СС)"""
    if seconds is None:
        seconds = 0.0
    seconds = max(0.0, float(seconds))
    h = int(seconds // 3600)
    m = int((seconds % 3600) // 60)
    s = int(seconds % 60)
    return f"{h:02d}:{m:02d}:{s:02d}"


def sec_to_srt(seconds: float) -> str:
    """12.5 -> '00:00:12,500'  (формат SRT)"""
    if seconds is None:
        seconds = 0.0
    seconds = max(0.0, float(seconds))
    h = int(seconds // 3600)
    m = int((seconds % 3600) // 60)
    s = int(seconds % 60)
    ms = int(round((seconds - int(seconds)) * 1000))
    if ms == 1000:
        ms = 0
        s += 1
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"


def extract_audio(src_path: str) -> str:
    """Извлекает аудио из видео/аудио в 16kHz mono WAV через ffmpeg."""
    if not os.path.exists(src_path):
        sys.exit(f"Файл не найден: {src_path}")

    fd, wav_path = tempfile.mkstemp(suffix=".wav")
    os.close(fd)
    log(f"Извлекаю аудио через ffmpeg -> {wav_path}")
    cmd = [
        "ffmpeg", "-y", "-i", src_path,
        "-vn", "-ac", "1", "-ar", "16000", "-f", "wav",
        wav_path,
    ]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL,
                       stderr=subprocess.PIPE)
    except FileNotFoundError:
        sys.exit("ffmpeg не установлен. Установи: brew install ffmpeg")
    except subprocess.CalledProcessError as e:
        sys.exit(f"ffmpeg упал:\n{e.stderr.decode(errors='ignore')[-2000:]}")
    return wav_path


def pick_device():
    import torch
    if torch.cuda.is_available():
        return "cuda", torch.float16
    if getattr(torch.backends, "mps", None) and torch.backends.mps.is_available():
        # MPS (Apple Silicon). float16 на MPS иногда нестабилен -> float32.
        return "mps", torch.float32
    return "cpu", torch.float32


def transcribe(wav_path: str):
    """Возвращает список сегментов: [{start, end, text}, ...]"""
    import torch
    from transformers import (AutoModelForSpeechSeq2Seq, AutoProcessor,
                              pipeline)

    device, dtype = pick_device()
    log(f"Устройство: {device}, тип: {dtype}")
    log(f"Загружаю модель {MODEL_ID} (первый раз качается ~1.5 ГБ)...")

    model = AutoModelForSpeechSeq2Seq.from_pretrained(
        MODEL_ID, torch_dtype=dtype, low_cpu_mem_usage=True
    ).to(device)
    processor = AutoProcessor.from_pretrained(MODEL_ID)

    asr = pipeline(
        "automatic-speech-recognition",
        model=model,
        tokenizer=processor.tokenizer,
        feature_extractor=processor.feature_extractor,
        torch_dtype=dtype,
        device=device,
        chunk_length_s=30,
        stride_length_s=5,
        return_timestamps=True,
    )

    generate_kwargs = {}
    # Пытаемся форсировать узбекский; если модель это не поддерживает — молча пропускаем.
    try:
        asr.model.generation_config.language = "uzbek"
        asr.model.generation_config.task = "transcribe"
    except Exception:
        pass

    log("Транскрибирую... (может занять несколько минут)")
    result = asr(wav_path, generate_kwargs=generate_kwargs)

    segments = []
    for chunk in result.get("chunks", []):
        ts = chunk.get("timestamp", (None, None))
        start, end = (ts + (None, None))[:2] if ts else (None, None)
        text = (chunk.get("text") or "").strip()
        if text:
            segments.append({"start": start, "end": end, "text": text})

    # Фолбэк: если чанков нет — весь текст одним блоком.
    if not segments and result.get("text"):
        segments.append({"start": 0.0, "end": None, "text": result["text"].strip()})

    # Чиним хвостовые None в end.
    for i, seg in enumerate(segments):
        if seg["start"] is None:
            seg["start"] = segments[i - 1]["end"] if i > 0 and segments[i - 1]["end"] else 0.0
        if seg["end"] is None:
            seg["end"] = segments[i + 1]["start"] if i + 1 < len(segments) and segments[i + 1]["start"] else seg["start"]

    log(f"Готово: {len(segments)} сегментов.")
    return segments


def diarize(wav_path: str, hf_token: str):
    """Возвращает список интервалов спикеров: [{start, end, speaker}, ...]"""
    try:
        from pyannote.audio import Pipeline
    except ImportError:
        log("pyannote.audio не установлен — пропускаю определение спикеров.")
        return None

    if not hf_token:
        log("Нет HF_TOKEN — пропускаю определение спикеров.")
        log("Как включить: см. README (нужен бесплатный токен HuggingFace + принять условия модели).")
        return None

    import torch
    log(f"Загружаю модель диаризации {DIARIZE_MODEL}...")
    try:
        pipe = Pipeline.from_pretrained(DIARIZE_MODEL, use_auth_token=hf_token)
    except Exception as e:
        log(f"Не удалось загрузить диаризацию: {e}")
        log("Проверь: 1) токен валиден 2) принял условия на страницах "
            "pyannote/speaker-diarization-3.1 и pyannote/segmentation-3.0")
        return None

    device, _ = pick_device()
    try:
        pipe.to(torch.device("cuda" if device == "cuda" else "cpu"))
    except Exception:
        pass

    log("Определяю собеседников...")
    diar = pipe(wav_path)
    turns = []
    for turn, _, speaker in diar.itertracks(yield_label=True):
        turns.append({"start": turn.start, "end": turn.end, "speaker": speaker})
    log(f"Найдено спикеров: {len(set(t['speaker'] for t in turns))}")
    return turns


def assign_speakers(segments, turns):
    """Каждому сегменту назначает спикера по максимальному пересечению во времени."""
    if not turns:
        for seg in segments:
            seg["speaker"] = None
        return segments

    for seg in segments:
        s, e = seg["start"], seg["end"]
        best, best_overlap = None, 0.0
        for t in turns:
            overlap = max(0.0, min(e, t["end"]) - max(s, t["start"]))
            if overlap > best_overlap:
                best_overlap, best = overlap, t["speaker"]
        seg["speaker"] = best
    return segments


def apply_names(segments, names_arg: str):
    """SPEAKER_00=Yusuf,SPEAKER_01=Mijoz -> подменяет метки."""
    if not names_arg:
        return
    mapping = {}
    for pair in names_arg.split(","):
        if "=" in pair:
            k, v = pair.split("=", 1)
            mapping[k.strip()] = v.strip()
    for seg in segments:
        if seg.get("speaker") in mapping:
            seg["speaker"] = mapping[seg["speaker"]]


def write_txt(segments, out_path: str):
    with open(out_path, "w", encoding="utf-8") as f:
        for seg in segments:
            tc = f"[{sec_to_hms(seg['start'])} - {sec_to_hms(seg['end'])}]"
            spk = f" {seg['speaker']}:" if seg.get("speaker") else ""
            f.write(f"{tc}{spk} {seg['text']}\n")
    log(f"Сохранено: {out_path}")


def write_srt(segments, out_path: str):
    with open(out_path, "w", encoding="utf-8") as f:
        for i, seg in enumerate(segments, 1):
            spk = f"{seg['speaker']}: " if seg.get("speaker") else ""
            f.write(f"{i}\n")
            f.write(f"{sec_to_srt(seg['start'])} --> {sec_to_srt(seg['end'])}\n")
            f.write(f"{spk}{seg['text']}\n\n")
    log(f"Сохранено: {out_path}")


def main():
    ap = argparse.ArgumentParser(description="Узбекская транскрибация с таймкодами и спикерами")
    ap.add_argument("input", help="Путь к видео или аудио файлу")
    ap.add_argument("--out", help="Базовое имя выходных файлов (без расширения)")
    ap.add_argument("--no-diarize", action="store_true", help="Не определять спикеров")
    ap.add_argument("--names", default="", help='Замена меток: "SPEAKER_00=Yusuf,SPEAKER_01=Mijoz"')
    ap.add_argument("--hf-token", default=os.environ.get("HF_TOKEN", ""),
                    help="Токен HuggingFace для диаризации (или переменная HF_TOKEN)")
    args = ap.parse_args()

    base = args.out or os.path.splitext(args.input)[0]

    wav_path = extract_audio(args.input)
    try:
        segments = transcribe(wav_path)

        turns = None
        if not args.no_diarize:
            turns = diarize(wav_path, args.hf_token)
        assign_speakers(segments, turns)
        apply_names(segments, args.names)

        write_txt(segments, base + ".txt")
        write_srt(segments, base + ".srt")
    finally:
        try:
            os.remove(wav_path)
        except OSError:
            pass

    print("\n===== ПРЕВЬЮ =====")
    for seg in segments[:15]:
        spk = f" {seg['speaker']}:" if seg.get("speaker") else ""
        print(f"[{sec_to_hms(seg['start'])} - {sec_to_hms(seg['end'])}]{spk} {seg['text']}")
    if len(segments) > 15:
        print(f"... ещё {len(segments) - 15} строк в файле {base}.txt")


if __name__ == "__main__":
    main()
