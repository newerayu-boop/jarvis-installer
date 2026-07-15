#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
OUT="${1:-AI_Strateg_masterclass_9x16.mp4}"
AUD="../audio/final_mix_44.wav"
NF=$(ls frames/f_*.png | wc -l)
echo "encoding $NF frames -> $OUT"
ffmpeg -y -framerate 30 -i frames/f_%05d.png -i "$AUD" \
  -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p -profile:v high -level 4.2 \
  -x264-params "keyint=60:min-keyint=30" \
  -c:a aac -b:a 192k -ar 48000 -ac 2 \
  -movflags +faststart -shortest "$OUT"
echo "=== result ==="
ffprobe -v error -show_entries format=duration,size:stream=codec_type,codec_name,width,height,r_frame_rate,bit_rate -of default=noprint_wrappers=1 "$OUT"
du -h "$OUT"
