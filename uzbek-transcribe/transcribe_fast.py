#!/usr/bin/env python3
"""
Быстрый CPU-вариант узбекской транскрибации (faster-whisper / CTranslate2).

Именно этот пайплайн использовался для обработки в облаке без GPU. На машине
без видеокарты он в разы быстрее обычного transcribe.py, потому что модель
rubaistt_v2_medium конвертируется в формат CTranslate2 (int8).

Что делает:
  1. Извлекает аудио из видео (ffmpeg) -> 16kHz mono wav.
  2. При первом запуске конвертирует islomov/rubaistt_v2_medium -> CTranslate2 int8.
  3. Транскрибирует с таймкодами (VAD + пословные таймкоды).
  4. (опционально) Определяет спикеров БЕЗ токена HuggingFace — через
     resemblyzer + кластеризацию (--diarize).
  5. Пишет .txt (таймкоды ЧЧ:ММ:СС + спикер) и .srt.

Установка:
    pip install faster-whisper ctranslate2 transformers torch gdown
    # для --diarize дополнительно:
    pip install resemblyzer scikit-learn librosa
    # ffmpeg: macOS `brew install ffmpeg`, Windows — см. README

Запуск:
    python3 transcribe_fast.py "video.mp4"
    python3 transcribe_fast.py "video.mp4" --diarize --name Yusuf
"""

import argparse
import json
import os
import subprocess
import sys
import tempfile

MODEL_ID = "islomov/rubaistt_v2_medium"
CT2_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "rubaistt-ct2")
SR = 16000


def log(m):
    print(f"[fast] {m}", flush=True)


def hms(t):
    t = max(0.0, float(t)); h = int(t // 3600); m = int((t % 3600) // 60); s = int(t % 60)
    return f"{h:02d}:{m:02d}:{s:02d}"


def srt_ts(t):
    t = max(0.0, float(t)); h = int(t // 3600); m = int((t % 3600) // 60); s = int(t % 60)
    ms = int(round((t - int(t)) * 1000))
    if ms == 1000:
        ms = 0; s += 1
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"


def extract_audio(src):
    if not os.path.exists(src):
        sys.exit(f"Файл не найден: {src}")
    fd, wav = tempfile.mkstemp(suffix=".wav"); os.close(fd)
    log("Извлекаю аудио через ffmpeg...")
    try:
        subprocess.run(["ffmpeg", "-y", "-i", src, "-vn", "-ac", "1", "-ar", str(SR),
                        "-f", "wav", wav], check=True,
                       stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
    except FileNotFoundError:
        sys.exit("ffmpeg не установлен.")
    except subprocess.CalledProcessError as e:
        sys.exit(f"ffmpeg упал:\n{e.stderr.decode(errors='ignore')[-1500:]}")
    return wav


def ensure_ct2_model():
    if os.path.isdir(CT2_DIR) and os.path.exists(os.path.join(CT2_DIR, "model.bin")):
        return
    log(f"Конвертирую {MODEL_ID} -> CTranslate2 int8 (один раз, качается ~1.5 ГБ)...")
    subprocess.run(["ct2-transformers-converter", "--model", MODEL_ID,
                    "--output_dir", CT2_DIR, "--quantization", "int8", "--force"],
                   check=True)


def transcribe(wav):
    from faster_whisper import WhisperModel
    ensure_ct2_model()
    log("Загружаю модель (CPU int8)...")
    model = WhisperModel(CT2_DIR, device="cpu", compute_type="int8",
                         cpu_threads=os.cpu_count() or 4)
    log("Транскрибирую...")
    segments, info = model.transcribe(
        wav, language="uz", task="transcribe", beam_size=5,
        vad_filter=True, vad_parameters=dict(min_silence_duration_ms=500),
        word_timestamps=True, condition_on_previous_text=True)
    out = []
    for seg in segments:
        out.append({"start": seg.start, "end": seg.end, "text": seg.text.strip()})
        log(f"[{hms(seg.start)}-{hms(seg.end)}] {seg.text.strip()[:60]}...")
    return out, info.duration


def diarize(wav, segs):
    """Определение спикеров без токена HuggingFace (resemblyzer + кластеризация)."""
    try:
        import numpy as np
        import librosa
        from resemblyzer import VoiceEncoder
        from sklearn.cluster import AgglomerativeClustering
        from sklearn.metrics import silhouette_score
    except ImportError:
        log("Нет resemblyzer/sklearn/librosa — пропускаю определение спикеров.")
        return {i: 0 for i in range(len(segs))}, 1

    audio, _ = librosa.load(wav, sr=SR, mono=True)
    enc = VoiceEncoder()
    embs, idx = [], []
    for i, s in enumerate(segs):
        clip = audio[int(s["start"] * SR):int(s["end"] * SR)]
        if len(clip) < int(0.6 * SR):
            continue
        try:
            embs.append(enc.embed_utterance(clip)); idx.append(i)
        except Exception:
            continue
    labels = {}
    if len(embs) >= 2:
        X = np.vstack(embs)
        best_k, best_sc = 1, -1
        for k in range(2, min(5, len(embs)) + 1):
            lab = AgglomerativeClustering(n_clusters=k, metric="cosine",
                                          linkage="average").fit_predict(X)
            if len(set(lab)) < 2:
                continue
            sc = silhouette_score(X, lab, metric="cosine")
            if sc > best_sc:
                best_sc, best_k = sc, k
        if best_k >= 2:
            lab = AgglomerativeClustering(n_clusters=best_k, metric="cosine",
                                          linkage="average").fit_predict(X)
            for j, i in enumerate(idx):
                labels[i] = int(lab[j])
            log(f"Оценка числа спикеров: {best_k} (silhouette={best_sc:.3f})")
    # заполнить пропуски ближайшим соседом
    for i in range(len(segs)):
        if i not in labels:
            found = 0
            for d in range(1, len(segs)):
                for c in (i - d, i + d):
                    if c in labels:
                        found = labels[c]; break
                else:
                    continue
                break
            labels[i] = found
    # стабильная нумерация: SPEAKER_00 = заговоривший первым
    order, seen = {}, 0
    for i in range(len(segs)):
        if labels[i] not in order:
            order[labels[i]] = seen; seen += 1
    return {i: order[labels[i]] for i in range(len(segs))}, max(seen, 1)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("input")
    ap.add_argument("--out")
    ap.add_argument("--diarize", action="store_true", help="Определять спикеров (без HF-токена)")
    ap.add_argument("--name", default="", help="Если один спикер — подписать этим именем")
    args = ap.parse_args()
    base = args.out or os.path.splitext(args.input)[0]

    wav = extract_audio(args.input)
    try:
        segs, dur = transcribe(wav)
        if args.diarize:
            spk_map, n = diarize(wav, segs)
        else:
            spk_map, n = {i: 0 for i in range(len(segs))}, 1

        def label(i):
            if n <= 1 and args.name:
                return args.name
            if n <= 1:
                return args.name or "SPEAKER_00"
            return f"SPEAKER_{spk_map[i]:02d}"

        with open(base + ".txt", "w", encoding="utf-8") as f:
            f.write(f"Транскрибация: {os.path.basename(args.input)}\n")
            f.write(f"Длительность: {hms(dur)} | Модель: {MODEL_ID}\n")
            f.write("=" * 70 + "\n\n")
            for i, s in enumerate(segs):
                f.write(f"[{hms(s['start'])} - {hms(s['end'])}] {label(i)}: {s['text']}\n\n")
        with open(base + ".srt", "w", encoding="utf-8") as f:
            for i, s in enumerate(segs):
                f.write(f"{i+1}\n{srt_ts(s['start'])} --> {srt_ts(s['end'])}\n"
                        f"{label(i)}: {s['text']}\n\n")
        log(f"Готово: {base}.txt и {base}.srt")
    finally:
        try:
            os.remove(wav)
        except OSError:
            pass


if __name__ == "__main__":
    main()
