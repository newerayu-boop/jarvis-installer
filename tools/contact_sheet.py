#!/usr/bin/env python3
"""Build contact sheets (frame grids) from a video for visual review.

Usage: contact_sheet.py <video> <outdir> [--interval 2] [--grid 5] [--tile-w 360]

Sheet layout is deterministic, so a cell's timestamp is derived from its
position (the ffmpeg build here has no drawtext to burn timecodes in):
    frame_index = sheet_no * grid^2 + row * grid + col   (0-based, row-major)
    t = frame_index * interval
A <stem>_map.txt with each sheet's time range is written alongside.
"""
import argparse
import math
import os
import subprocess
import sys

try:
    from imageio_ffmpeg import get_ffmpeg_exe
    FFMPEG = get_ffmpeg_exe()
except ImportError:
    FFMPEG = "ffmpeg"


def ffprobe_duration(path: str) -> float:
    # imageio-ffmpeg ships no ffprobe; parse duration from ffmpeg -i output.
    p = subprocess.run([FFMPEG, "-i", path], capture_output=True, text=True)
    for line in p.stderr.splitlines():
        line = line.strip()
        if line.startswith("Duration:"):
            hms = line.split()[1].rstrip(",")
            h, m, s = hms.split(":")
            return int(h) * 3600 + int(m) * 60 + float(s)
    raise RuntimeError(f"no duration found for {path}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("video")
    ap.add_argument("outdir")
    ap.add_argument("--interval", type=float, default=2.0)
    ap.add_argument("--grid", type=int, default=5)
    ap.add_argument("--tile-w", type=int, default=360)
    args = ap.parse_args()

    os.makedirs(args.outdir, exist_ok=True)
    stem = os.path.splitext(os.path.basename(args.video))[0].replace(" ", "_")
    dur = ffprobe_duration(args.video)
    per_sheet = args.grid * args.grid

    out_pattern = os.path.join(args.outdir, f"{stem}_sheet%02d.jpg")
    vf = (
        f"fps=1/{args.interval},scale={args.tile_w}:-2,"
        f"tile={args.grid}x{args.grid}:color=black"
    )
    subprocess.run(
        [FFMPEG, "-v", "error", "-y", "-i", args.video,
         "-vf", vf, "-q:v", "4", out_pattern],
        check=True,
    )

    n_frames = math.ceil(dur / args.interval)
    n_sheets = math.ceil(n_frames / per_sheet)
    map_path = os.path.join(args.outdir, f"{stem}_map.txt")
    with open(map_path, "w") as f:
        f.write(f"{stem}: duration={dur:.1f}s interval={args.interval}s "
                f"grid={args.grid}x{args.grid} frames={n_frames}\n")
        for k in range(n_sheets):
            t0 = k * per_sheet * args.interval
            t1 = min(dur, ((k + 1) * per_sheet - 1) * args.interval)
            f.write(f"  sheet{k + 1:02d}: {t0:.0f}s - {t1:.0f}s "
                    f"(cell(r,c) -> t = {t0:.0f} + (r*{args.grid}+c)*{args.interval})\n")
    print(open(map_path).read())


if __name__ == "__main__":
    sys.exit(main())
