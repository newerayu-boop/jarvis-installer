#!/usr/bin/env python3
"""Audio energy profile for a video: RMS per window + peak windows.

Usage: audio_profile.py <video> [--window 0.5] [--json out.json]

Prints a compact summary (duration, loudness percentiles, top peak windows)
and optionally dumps the full per-window profile as JSON. Peaks in the
2–4 kHz-weighted band correlate with laughter/cheering/speech, so we also
compute a high-band profile to separate voices from low rumble.
"""
import argparse
import json
import subprocess
import sys

import numpy as np

try:
    from imageio_ffmpeg import get_ffmpeg_exe
    FFMPEG = get_ffmpeg_exe()
except ImportError:
    FFMPEG = "ffmpeg"

SR = 16000


def decode_mono(path: str) -> np.ndarray:
    cmd = [
        FFMPEG, "-v", "error", "-i", path,
        "-vn", "-ac", "1", "-ar", str(SR), "-f", "s16le", "-",
    ]
    raw = subprocess.run(cmd, capture_output=True, check=True).stdout
    return np.frombuffer(raw, dtype=np.int16).astype(np.float32) / 32768.0


def band_energy(x: np.ndarray, lo: float, hi: float) -> np.ndarray:
    """Per-sample envelope of the [lo, hi] Hz band via FFT filtering."""
    spec = np.fft.rfft(x)
    freqs = np.fft.rfftfreq(len(x), 1 / SR)
    spec[(freqs < lo) | (freqs > hi)] = 0
    return np.fft.irfft(spec, len(x)).astype(np.float32)


def profile(path: str, window: float):
    x = decode_mono(path)
    dur = len(x) / SR
    hop = int(window * SR)
    n = len(x) // hop
    voice = band_energy(x, 300, 4000)

    rows = []
    for i in range(n):
        seg = x[i * hop:(i + 1) * hop]
        vseg = voice[i * hop:(i + 1) * hop]
        rms = float(np.sqrt(np.mean(seg ** 2)) + 1e-9)
        vrms = float(np.sqrt(np.mean(vseg ** 2)) + 1e-9)
        rows.append({
            "t": round(i * window, 2),
            "rms_db": round(20 * np.log10(rms), 1),
            "voice_db": round(20 * np.log10(vrms), 1),
        })
    return dur, rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("video")
    ap.add_argument("--window", type=float, default=0.5)
    ap.add_argument("--json")
    ap.add_argument("--top", type=int, default=12)
    args = ap.parse_args()

    dur, rows = profile(args.video, args.window)
    if args.json:
        with open(args.json, "w") as f:
            json.dump({"duration": dur, "window": args.window, "rows": rows}, f)

    db = np.array([r["rms_db"] for r in rows])
    vdb = np.array([r["voice_db"] for r in rows])
    print(f"duration={dur:.1f}s windows={len(rows)} "
          f"rms p50={np.percentile(db, 50):.1f} p90={np.percentile(db, 90):.1f} "
          f"max={db.max():.1f} dB")

    # Merge loud windows (above p90) into contiguous peak spans.
    thr = np.percentile(db, 90)
    spans, cur = [], None
    for r, loud in zip(rows, db >= thr):
        if loud:
            if cur is None:
                cur = [r["t"], r["t"], r["rms_db"], r["voice_db"]]
            else:
                cur[1] = r["t"]
                cur[2] = max(cur[2], r["rms_db"])
                cur[3] = max(cur[3], r["voice_db"])
        elif cur is not None:
            spans.append(cur)
            cur = None
    if cur is not None:
        spans.append(cur)
    spans.sort(key=lambda s: -s[2])
    print("top peak spans (start-end, peak rms dB, peak voice dB):")
    for s in spans[:args.top]:
        print(f"  {s[0]:7.1f}-{s[1] + args.window:7.1f}  {s[2]:6.1f}  {s[3]:6.1f}")
    # Voice-forward spans hint at speech/laughter rather than mere noise.
    voice_thr = np.percentile(vdb, 92)
    vmask = vdb >= voice_thr
    print(f"voice-heavy fraction: {vmask.mean() * 100:.0f}% of windows above p92 voice band")


if __name__ == "__main__":
    sys.exit(main())
