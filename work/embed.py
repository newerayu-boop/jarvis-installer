import json, time, os, numpy as np, soundfile as sf, torch
from speechbrain.inference.speaker import EncoderClassifier

SR = 16000
MIN_EMB = 0.8
EMB_NPY = "embeddings.npy"
UNITS_JSON = "units.json"
SAVE_EVERY = 5

t0 = time.time()
seg = json.load(open("segments.json"))["segments"]
units = [{"start": s["start"], "end": s["end"], "text": s["text"]}
         for s in seg if s["text"].strip()]
json.dump(units, open(UNITS_JSON, "w"), ensure_ascii=False)
n = len(units)

audio, sr = sf.read("audio.wav", dtype="float32")
if audio.ndim > 1:
    audio = audio.mean(axis=1)
N = len(audio)

# resume
if os.path.exists(EMB_NPY):
    embs = list(np.load(EMB_NPY))
    print(f"resuming: {len(embs)}/{n} already embedded", flush=True)
else:
    embs = []

clf = EncoderClassifier.from_hparams(source="speechbrain/spkrec-ecapa-voxceleb",
                                     savedir="ecapa", run_opts={"device": "cpu"})

for i in range(len(embs), n):
    u = units[i]
    a = int(u["start"] * SR); b = int(u["end"] * SR)
    if b - a < int(MIN_EMB * SR):
        c = (a + b) // 2; half = int(MIN_EMB * SR / 2)
        a = max(0, c - half); b = min(N, c + half)
    clip = audio[a:b]
    with torch.no_grad():
        e = clf.encode_batch(torch.from_numpy(clip).unsqueeze(0)).squeeze().numpy()
    embs.append(e)
    if (i + 1) % SAVE_EVERY == 0 or i == n - 1:
        np.save(EMB_NPY, np.vstack(embs))
        print(f"  emb {i+1}/{n}  elapsed {time.time()-t0:.0f}s", flush=True)

np.save(EMB_NPY, np.vstack(embs))
print(f"EMBED_DONE {len(embs)}/{n} elapsed {time.time()-t0:.0f}s", flush=True)
