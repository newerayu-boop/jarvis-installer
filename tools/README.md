# Video highlight montage pipeline

Tools for turning a folder of raw event footage (no captions, no script) into a
short highlight reel selected **by meaning** — the emotional moments (laughter,
smiles, warm interactions, energetic presenting) — rather than by hand-scrubbing.

## Flow

1. **Probe / audio profile** — `audio_profile.py`
   Per-window RMS + voice-band energy for every clip to locate laughter,
   cheering and speech peaks. Loud, dynamic audio is a cheap first proxy for
   "something lively is happening here".

2. **Contact sheets** — `contact_sheet.py`
   Frame grids with a deterministic cell→timestamp mapping so the footage can be
   reviewed visually and the exact second of an expression can be read back.

3. **Selection** — pick 6–8 short clips that form an arc
   (establishing → build → peak emotion → warm close), keeping variety of
   scenes and people.

4. **Assemble** — `build_montage.py`
   Cuts the chosen segments, normalizes them to a common format
   (1080×1920, 30 fps, square pixels), joins them with short crossfades to land
   on exactly 30.0 s, and builds the audio: a ducked music bed plus the
   presenter's **live voice** on the clip where he speaks to camera.

## The reel that shipped

Built from 148 vertical iPhone clips (~82 min) of an AI/startup accelerator
("MPULSE Business Hub"). Final 30 s, 1080×1920:

| # | Source     | In-point | Len | Moment                                   |
|---|------------|----------|-----|------------------------------------------|
| 1 | IMG_2013   | 1.0 s    | 4.6 | opener — presenter w/ mic, room, cameras |
| 2 | IMG_1979   | 4.5 s    | 5.0 | hero speaks to camera (**live voice**)   |
| 3 | IMG_2380   | 28.5 s   | 4.4 | two young people chatting, smiling       |
| 4 | IMG_2521   | 26.0 s   | 4.4 | energetic stage pitch                    |
| 5 | IMG_2387   | 44.5 s   | 4.6 | two women laughing warmly                |
| 6 | IMG_1992   | 82.0 s   | 4.4 | hero co-hosting, warm exchange           |
| 7 | IMG_1979   | 15.0 s   | 4.4 | hero, warm smile — close                 |

Music bed: **"Inspired" by Kevin MacLeod** (incompetech.com), licensed
**CC BY 3.0** — attribution required if the reel is published.

## Requirements

`ffmpeg` + `ffprobe`, Python 3, and (for contact sheets) ImageMagick.
`build_montage.py` reads its working directory from `VIDEO_MONTAGE_DIR`
(default: current dir), expecting `videos/` and `music/` subfolders.
