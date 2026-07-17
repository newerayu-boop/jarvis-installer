import json, numpy as np
from sklearn.cluster import KMeans
from collections import Counter

units = json.load(open("units.json"))
E = np.load("embeddings.npy").astype(np.float64)
E = E / (np.linalg.norm(E, axis=1, keepdims=True) + 1e-9)   # cosine geometry

# KMeans on L2-normalized vectors ~ spherical k-means; balanced 2-way split
km = KMeans(n_clusters=2, n_init=10, random_state=0).fit(E)
lab = km.labels_

# label speakers by first appearance
order, seen = {}, 0
for l in lab:
    if l not in order:
        order[l] = seen; seen += 1
spk = np.array([order[l] for l in lab])

# smooth isolated single-segment flips (A B A -> A A A)
s = spk.copy()
for i in range(1, len(s) - 1):
    if s[i] != s[i-1] and s[i-1] == s[i+1]:
        s[i] = s[i-1]
spk = s

for u, k in zip(units, spk):
    u["spk"] = int(k)

# merge consecutive same-speaker units into turns
turns = []
for u in units:
    if turns and turns[-1]["spk"] == u["spk"] and u["start"] - turns[-1]["end"] < 1.5:
        turns[-1]["end"] = u["end"]; turns[-1]["text"] += " " + u["text"]
    else:
        turns.append(dict(u))

json.dump({"turns": turns, "units": units}, open("diarized.json", "w"), ensure_ascii=False)
print("speaker unit counts:", Counter(spk.tolist()))
print("turns:", len(turns))
