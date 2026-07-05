#!/usr/bin/env python3
"""
Build a 30-second highlight montage from event footage.

This is the exact recipe used to produce the "best moments" reel:
  * 7 clips cut from the source .MOV files (all vertical iPhone footage),
    normalized to 1080x1920 @ 30fps and joined with 0.3s crossfades so the
    total lands on exactly 30.0s.
  * Audio = a background music bed (ducked) plus the presenter's LIVE voice
    on the one clip where he speaks to camera.

Paths are resolved from the VIDEO_MONTAGE_DIR env var (default: current dir).
That directory must contain:
  videos/   - the source clips referenced in SEGS
  music/    - the background track (see MUSIC)

Usage:
  VIDEO_MONTAGE_DIR=/path/to/work python3 build_montage.py
"""
import os, subprocess

BASE  = os.environ.get("VIDEO_MONTAGE_DIR", os.getcwd())
VID   = os.path.join(BASE, "videos")
WORK  = os.path.join(BASE, "work"); os.makedirs(WORK, exist_ok=True)
MUSIC = os.path.join(BASE, "music", "Inspired.mp3")   # Kevin MacLeod, CC-BY
OUT   = os.path.join(BASE, "best-moments-30s.mp4")

# --- selection: (source file, start sec, duration sec) ---------------------
# Chosen after audio profiling + visual contact-sheet review of 148 clips.
SEGS = [
    ("IMG_2013.MOV",  1.0, 4.6),   # opener: presenter w/ mic + room, cameras
    ("IMG_1979.MOV",  4.5, 5.0),   # HERO speaks to camera (keep live voice)
    ("IMG_2380.MOV", 28.5, 4.4),   # two young people chatting, smiling
    ("IMG_2521.MOV", 26.0, 4.4),   # energetic stage pitch ("change your life")
    ("IMG_2387.MOV", 44.5, 4.6),   # two women laughing warmly
    ("IMG_1992.MOV", 82.0, 4.4),   # hero co-hosting with mic, warm exchange
    ("IMG_1979.MOV", 15.0, 4.4),   # hero, warm smile — close
]
XF = 0.3
NORM = ("scale=1080:1920:force_original_aspect_ratio=increase,"
        "crop=1080:1920,fps=30,setsar=1,format=yuv420p")

# audio: hero voice sits on clip #2, which begins at (d0 - XF) in the output.
HERO      = os.path.join(VID, "IMG_1979.MOV")
V_SRC, V_DUR, V_DELAY_MS = 4.5, 5.0, 4300
DUCK_A, DUCK_B = 4.0, 9.9          # window where music ducks under the voice
MUSIC_START = 32.0                 # offset into the track (past the soft intro)


def cut_clips():
    clips = []
    for i, (f, s, d) in enumerate(SEGS):
        out = os.path.join(WORK, "c%d.mp4" % i)
        subprocess.run(
            ["ffmpeg", "-y", "-loglevel", "error", "-ss", str(s),
             "-i", os.path.join(VID, f), "-t", str(d), "-an", "-vf", NORM,
             "-r", "30", "-c:v", "libx264", "-crf", "18", "-preset", "veryfast",
             "-pix_fmt", "yuv420p", "-video_track_timescale", "30000", out],
            check=True)
        clips.append((out, d))
        print("cut", f, "->", out, flush=True)
    return clips


def build(clips):
    inputs, fc, prev, off = [], [], "0:v", 0.0
    for c, _ in clips:
        inputs += ["-i", c]
    durs = [d for _, d in clips]
    for i in range(1, len(clips)):
        off += durs[i - 1] - XF
        fc.append("[%s][%d:v]xfade=transition=fade:duration=%s:offset=%.3f[v%d]"
                  % (prev, i, XF, off, i))
        prev = "v%d" % i
    vfilt = ";".join(fc)

    # audio graph: ducked music bed + delayed, loudness-matched hero voice
    afilt = (
        "[%d:a]atrim=start=%s:duration=30,asetpts=PTS-STARTPTS,"
        "loudnorm=I=-21:TP=-2:LRA=11,afade=t=in:st=0:d=0.6,"
        "afade=t=out:st=29:d=1.0,"
        "volume='1-0.72*between(t,%s,%s)':eval=frame[music];"
        "[%d:a]atrim=start=%s:duration=%s,asetpts=PTS-STARTPTS,"
        "loudnorm=I=-15:TP=-1.5,adelay=%d|%d[voice];"
        "[music][voice]amix=inputs=2:duration=first:dropout_transition=0:"
        "normalize=0[mx];[mx]loudnorm=I=-14:TP=-1.5,aresample=48000[aout]"
        % (len(clips), MUSIC_START, DUCK_A, DUCK_B,
           len(clips) + 1, V_SRC, V_DUR, V_DELAY_MS, V_DELAY_MS)
    )
    cmd = (["ffmpeg", "-y", "-loglevel", "error"] + inputs
           + ["-i", MUSIC, "-i", HERO,
              "-filter_complex", vfilt + ";" + afilt,
              "-map", "[%s]" % prev, "-map", "[aout]",
              "-c:v", "libx264", "-crf", "19", "-preset", "medium",
              "-pix_fmt", "yuv420p", "-r", "30",
              "-c:a", "aac", "-b:a", "192k",
              "-t", "30", "-movflags", "+faststart", OUT])
    subprocess.run(cmd, check=True)
    print("wrote", OUT, flush=True)


if __name__ == "__main__":
    build(cut_clips())
