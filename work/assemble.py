import json, sys

# spk index -> name. Speaker 0 = first person heard in the video.
NAMES = {0: "Юсуфбай", 1: "Абдуллох"}
if len(sys.argv) > 2:
    NAMES = {0: sys.argv[1], 1: sys.argv[2]}

d = json.load(open("diarized.json"))
units = d["units"]

# group consecutive same-speaker units, but start a fresh timecoded block
# every ~40s so timecodes stay frequent and paragraphs stay readable
MAX_TURN = 40.0
turns = []
for u in units:
    if (turns and turns[-1]["spk"] == u["spk"]
            and u["start"] - turns[-1]["end"] < 1.5
            and u["end"] - turns[-1]["start"] <= MAX_TURN):
        turns[-1]["end"] = u["end"]; turns[-1]["text"] += " " + u["text"]
    else:
        turns.append(dict(u))

def hms(t):
    t = max(0, int(round(t))); h = t // 3600; m = (t % 3600) // 60; s = t % 60
    return f"{h:02d}:{m:02d}:{s:02d}"

def hmsms(t):
    ms = int(round(t * 1000)); h = ms // 3600000; m = (ms % 3600000) // 60000
    s = (ms % 60000) // 1000; ms = ms % 1000
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"

# ---- readable TXT (merged turns) ----
with open("transcript.txt", "w") as f:
    f.write("Транскрипт видео (узбекский)\n")
    f.write("Говорящие: " + ", ".join(NAMES.values()) + "\n")
    f.write("=" * 60 + "\n\n")
    for t in turns:
        f.write(f"[{hms(t['start'])}] {NAMES[t['spk']]}: {t['text']}\n\n")

# ---- SRT (finer units) ----
with open("transcript.srt", "w") as f:
    for i, u in enumerate(units, 1):
        f.write(f"{i}\n{hmsms(u['start'])} --> {hmsms(u['end'])}\n")
        f.write(f"{NAMES[u['spk']]}: {u['text']}\n\n")

print("wrote transcript.txt and transcript.srt")
print("turns:", len(turns), "units:", len(units))
