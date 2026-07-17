import json, time, os, numpy as np, soundfile as sf
from concurrent.futures import ProcessPoolExecutor

SR = 16000
MODEL_DIR = "ct2-rubaistt"
AUDIO = "audio.wav"
OUT = "segments.json"
SEGDIR = "segs"          # per-chunk results (resume-safe)
CHUNK = 300.0            # nominal chunk length (s)
SEARCH = 6.0            # +/- window to snap cut to a quiet point (s)
WORKERS = 2             # medium int8 model; 2 workers keeps peak RAM safe

os.makedirs(SEGDIR, exist_ok=True)
t0 = time.time()

# ---- find cut points at low-energy (silence) near nominal boundaries ----
audio, sr = sf.read(AUDIO, dtype="float32")
if audio.ndim > 1:
    audio = audio.mean(axis=1)
assert sr == SR
N = len(audio); dur = N / SR
hop = int(0.02 * SR)
frames = np.abs(audio[:len(audio)//hop*hop]).reshape(-1, hop).mean(axis=1)
del audio  # free memory in the parent; workers re-read their slice from disk

def snap(t):
    center = int(t / 0.02); w = int(SEARCH / 0.02)
    lo = max(0, center - w); hi = min(len(frames), center + w)
    if hi <= lo:
        return t
    return (lo + int(np.argmin(frames[lo:hi]))) * 0.02

cuts = [0.0]; tt = CHUNK
while tt < dur - SEARCH:
    c = snap(tt)
    if c > cuts[-1] + 30:
        cuts.append(c)
    tt += CHUNK
cuts.append(dur)
chunks = [(i, cuts[i], cuts[i+1]) for i in range(len(cuts)-1)]
todo = [c for c in chunks if not os.path.exists(f"{SEGDIR}/seg_{c[0]:02d}.json")]
print(f"duration={dur:.0f}s -> {len(chunks)} chunks, {len(todo)} to do "
      f"({len(chunks)-len(todo)} already done)", flush=True)

_model = None
def init():
    global _model
    from faster_whisper import WhisperModel
    _model = WhisperModel(MODEL_DIR, device="cpu", compute_type="int8", cpu_threads=2)

def work(chunk):
    idx, start, end = chunk
    a = int(start * SR); b = int(end * SR)
    clip, _ = sf.read(AUDIO, start=a, frames=b - a, dtype="float32")
    if clip.ndim > 1:
        clip = clip.mean(axis=1)
    segs, _info = _model.transcribe(
        clip, language="uz", beam_size=1, vad_filter=True,
        vad_parameters=dict(min_silence_duration_ms=300,
                            max_speech_duration_s=15, speech_pad_ms=100),
        word_timestamps=False, condition_on_previous_text=False)
    out = [{"start": s.start + start, "end": s.end + start, "text": s.text.strip()}
           for s in segs if s.text.strip()]
    with open(f"{SEGDIR}/seg_{idx:02d}.json", "w") as f:
        json.dump(out, f, ensure_ascii=False)
    return idx, len(out)

if todo:
    with ProcessPoolExecutor(max_workers=WORKERS, initializer=init) as ex:
        for idx, n in ex.map(work, todo):
            print(f"  chunk {idx} done ({n} segs) saved  elapsed={time.time()-t0:.0f}s", flush=True)

# ---- merge all per-chunk results ----
data = []
for i in range(len(chunks)):
    p = f"{SEGDIR}/seg_{i:02d}.json"
    if os.path.exists(p):
        data.extend(json.load(open(p)))
data.sort(key=lambda x: x["start"])
json.dump({"segments": data, "duration": dur}, open(OUT, "w"), ensure_ascii=False)
print(f"DONE segs={len(data)} merged  elapsed={time.time()-t0:.0f}s -> {OUT}", flush=True)
