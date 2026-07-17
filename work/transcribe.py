import json, sys, time
from faster_whisper import WhisperModel

MODEL_DIR = "ct2-rubaistt"
AUDIO = "audio.wav"
OUT = "segments.json"

t0 = time.time()
print("loading model...", flush=True)
model = WhisperModel(MODEL_DIR, device="cpu", compute_type="int8", cpu_threads=4)

print("transcribing...", flush=True)
segments, info = model.transcribe(
    AUDIO,
    language="uz",
    beam_size=1,
    vad_filter=True,
    vad_parameters=dict(min_silence_duration_ms=500),
    word_timestamps=True,
    condition_on_previous_text=False,
)

data = []
last_log = time.time()
for seg in segments:
    words = []
    if seg.words:
        for w in seg.words:
            words.append({"start": w.start, "end": w.end, "word": w.word})
    data.append({"start": seg.start, "end": seg.end, "text": seg.text.strip(), "words": words})
    # progress logging by audio time
    if time.time() - last_log > 30:
        el = time.time() - t0
        print(f"  audio_t={seg.end:.0f}s  segs={len(data)}  elapsed={el:.0f}s", flush=True)
        last_log = time.time()
        with open(OUT, "w") as f:
            json.dump({"segments": data}, f, ensure_ascii=False)

with open(OUT, "w") as f:
    json.dump({"segments": data, "duration": info.duration}, f, ensure_ascii=False)
print(f"DONE segs={len(data)} elapsed={time.time()-t0:.0f}s -> {OUT}", flush=True)
