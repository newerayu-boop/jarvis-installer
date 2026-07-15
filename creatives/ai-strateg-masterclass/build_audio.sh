#!/usr/bin/env bash
# Ovoz (krujok) 1.1x + atmosferali musiqa (fon, ancha past) -> final_mix_40.wav
# krug.mp4 = telegram krujok; music.wav = atmosferali trek. Chiqish: 40s.
set -e
ffmpeg -y -i krug.mp4 -stream_loop 4 -i music.wav -filter_complex "
[0:a]atempo=1.1,highpass=f=90,afftdn=nf=-24,acompressor=threshold=-18dB:ratio=3:attack=8:release=180,loudnorm=I=-14:TP=-1.2:LRA=11,aresample=48000,apad,atrim=0:40,asplit[vmain][vkey];
[1:a]atrim=0:40,aresample=48000,volume=0.26,lowpass=f=7000,highpass=f=70[mus];
[mus][vkey]sidechaincompress=threshold=0.025:ratio=16:attack=6:release=420:makeup=1[musd];
[musd]afade=t=in:st=0:d=1.4,afade=t=out:st=38.4:d=1.6[musf];
[vmain][musf]amix=inputs=2:normalize=0[mix];
[mix]alimiter=limit=0.96,apad,atrim=0:40" -map "[mix]" -c:a pcm_s16le -ar 48000 -ac 2 final_mix_40.wav
