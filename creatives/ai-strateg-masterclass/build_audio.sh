#!/usr/bin/env bash
# Ovoz (krujok) + atmosferali musiqa -> final_mix_44.wav (sidechain duck, outro swell)
# krug.mp4 = telegram krujok; music.wav = atmosferali trek
set -e
ffmpeg -y -i krug.mp4 -stream_loop 3 -i music.wav -filter_complex "
[0:a]highpass=f=90,afftdn=nf=-24,acompressor=threshold=-18dB:ratio=3:attack=8:release=180,loudnorm=I=-14:TP=-1.2:LRA=11,aresample=48000,apad,atrim=0:44,asplit[vmain][vkey];
[1:a]atrim=0:44,aresample=48000,volume=0.42,lowpass=f=7200,highpass=f=60[mus];
[mus][vkey]sidechaincompress=threshold=0.028:ratio=12:attack=6:release=380:makeup=1[musd];
[musd]afade=t=in:st=0:d=1.6,afade=t=out:st=42.2:d=1.8[musf];
[vmain][musf]amix=inputs=2:normalize=0:dropout_transition=0[mix];
[mix]alimiter=limit=0.96,apad -t 44" -map "[mix]" -c:a pcm_s16le -ar 48000 -ac 2 final_mix_44.wav
