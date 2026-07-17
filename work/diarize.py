import json, time, numpy as np, soundfile as sf, torch
from speechbrain.inference.speaker import EncoderClassifier
from sklearn.cluster import AgglomerativeClustering

SR = 16000
GAP = 0.8          # split a segment into sub-units at word gaps larger than this
MAX_UNIT = 8.0     # max sub-unit length (s)
MIN_EMB = 0.6      # min audio (s) fed to the embedder

t0 = time.time()
seg = json.load(open("segments.json"))["segments"]
audio, sr = sf.read("audio.wav", dtype="float32")
if audio.ndim > 1:
    audio = audio.mean(axis=1)
assert sr == SR, sr
N = len(audio)

def build_units():
    units = []
    for s in seg:
        words = s.get("words") or []
        if not words:
            units.append({"start": s["start"], "end": s["end"], "text": s["text"]})
            continue
        cur = [words[0]]
        for w in words[1:]:
            gap = w["start"] - cur[-1]["end"]
            dur = w["end"] - cur[0]["start"]
            if gap > GAP or dur > MAX_UNIT:
                units.append({"start": cur[0]["start"], "end": cur[-1]["end"],
                              "text": "".join(x["word"] for x in cur).strip()})
                cur = [w]
            else:
                cur.append(w)
        units.append({"start": cur[0]["start"], "end": cur[-1]["end"],
                      "text": "".join(x["word"] for x in cur).strip()})
    return [u for u in units if u["text"]]

units = build_units()
print(f"{len(units)} units from {len(seg)} segments; elapsed {time.time()-t0:.0f}s", flush=True)

clf = EncoderClassifier.from_hparams(source="speechbrain/spkrec-ecapa-voxceleb",
                                     savedir="ecapa", run_opts={"device": "cpu"})

embs = []
for i, u in enumerate(units):
    a = int(u["start"] * SR); b = int(u["end"] * SR)
    if b - a < int(MIN_EMB * SR):          # widen tiny slices for a stable embedding
        c = (a + b) // 2; half = int(MIN_EMB * SR / 2)
        a = max(0, c - half); b = min(N, c + half)
    clip = audio[a:b]
    with torch.no_grad():
        e = clf.encode_batch(torch.from_numpy(clip).unsqueeze(0)).squeeze().numpy()
    embs.append(e)
    if i % 50 == 0:
        print(f"  emb {i}/{len(units)}  elapsed {time.time()-t0:.0f}s", flush=True)

embs = np.vstack(embs)
embs = embs / (np.linalg.norm(embs, axis=1, keepdims=True) + 1e-9)

lab = AgglomerativeClustering(n_clusters=2, metric="cosine", linkage="average").fit_predict(embs)

# Order speakers by first appearance so labels are stable
order, seen = {}, 0
for l in lab:
    if l not in order:
        order[l] = seen; seen += 1
spk = [order[l] for l in lab]

for u, s in zip(units, spk):
    u["spk"] = int(s)

# merge consecutive same-speaker units into turns
turns = []
for u in units:
    if turns and turns[-1]["spk"] == u["spk"] and u["start"] - turns[-1]["end"] < 1.2:
        turns[-1]["end"] = u["end"]
        turns[-1]["text"] += " " + u["text"]
    else:
        turns.append(dict(u))

json.dump({"turns": turns, "units": units}, open("diarized.json", "w"), ensure_ascii=False)
from collections import Counter
print("speaker unit counts:", Counter(spk))
print(f"{len(turns)} turns; DONE elapsed {time.time()-t0:.0f}s", flush=True)
