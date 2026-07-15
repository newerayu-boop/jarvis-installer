#!/usr/bin/env bash
# Ovoz (krujok) 1.1x + atmosferali musiqa (fon, sezilarli lekin past) -> mix_43.wav (~42.8s)
set -e
ffmpeg -y -i krug.mp4 -stream_loop 4 -i music.wav -filter_complex "
[0:a]atempo=1.1,highpass=f=90,afftdn=nf=-24,acompressor=threshold=-18dB:ratio=3:attack=8:release=180,loudnorm=I=-14:TP=-1.2:LRA=11,aresample=48000,apad,atrim=0:42.8,asplit[vmain][vkey];
[1:a]atrim=0:42.8,aresample=48000,volume=0.36,lowpass=f=7400,highpass=f=65[mus];
[mus][vkey]sidechaincompress=threshold=0.03:ratio=9:attack=6:release=340:makeup=1[musd];
[musd]afade=t=in:st=0:d=1.4,afade=t=out:st=41.0:d=1.7[musf];
[vmain][musf]amix=inputs=2:normalize=0[mix];
[mix]alimiter=limit=0.96,apad,atrim=0:42.8" -map "[mix]" -c:a pcm_s16le -ar 48000 -ac 2 mix_43.wav
