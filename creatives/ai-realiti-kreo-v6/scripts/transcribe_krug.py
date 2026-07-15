# -*- coding: utf-8 -*-
"""Расшифровка кружочка (узбекский) с пословными таймкодами."""
import json
from pathlib import Path
from faster_whisper import WhisperModel

SRC = Path("/root/.claude/uploads/100a0701-297d-51f6-a717-b796d20bf655/2b6915e3-video.mp4")
OUT = Path("/tmp/claude-0/-home-user-jarvis-installer/100a0701-297d-51f6-a717-b796d20bf655/scratchpad/transcript")

INITIAL_PROMPT = (
    "Bu video AI Strateg kursi va AI-Realiti haqida. So'zlar: "
    "prodyuser, zapusk, jonli efir, AI-agent, NotebookLM, Claude, Jarvis, "
    "Telegram, kopirayter, dizayner, targetolog, SMM, montajchi, "
    "$100 000, 20 kun, 200 ta joy, reality."
)

OUT.mkdir(parents=True, exist_ok=True)
print("loading large-v3 on cpu (int8)", flush=True)
model = WhisperModel("large-v3", device="cpu", compute_type="int8")

segments, info = model.transcribe(
    str(SRC), language="uz", word_timestamps=True, vad_filter=True,
    vad_parameters={"min_silence_duration_ms": 500, "threshold": 0.5},
    beam_size=5, initial_prompt=INITIAL_PROMPT,
    condition_on_previous_text=False,
    no_speech_threshold=0.6,
)

words, segs = [], []
for seg in segments:
    stext = (seg.text or "").strip()
    if stext:
        segs.append({"start": round(seg.start, 3), "end": round(seg.end, 3), "text": stext})
    for w in (seg.words or []):
        t = (w.word or "").strip()
        if t:
            words.append({"start": round(float(w.start), 3), "end": round(float(w.end), 3), "text": t})

(OUT / "krug.words.json").write_text(
    json.dumps({"file": SRC.name, "duration": float(info.duration), "words": words},
               ensure_ascii=False, indent=2), encoding="utf-8")

md = [f"# Транскрипт кружочка ({info.duration:.1f} c, lang={info.language} p={info.language_probability:.2f})\n"]
for s in segs:
    m, sec = int(s["start"] // 60), s["start"] % 60
    md.append(f"`[{m}:{sec:05.2f}]` {s['text']}")
(OUT / "transcript.md").write_text("\n".join(md), encoding="utf-8")
print("DONE", flush=True)
