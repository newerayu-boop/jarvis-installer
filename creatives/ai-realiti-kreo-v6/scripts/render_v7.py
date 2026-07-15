# -*- coding: utf-8 -*-
"""Сборка крео v6 одним проходом ffmpeg.
Таймлайн (глобальное время, кружок стартует на KOFF=2.6):
  0.0–2.6   интро: $100 000 + Jamoasiz. Prodyusersiz. + киккер
  2.6–61.0  кружок + титры + карточки + штампы + чипы
  55.6–63.8 CTA (кнопка/пилюля/URL), 61.0–63.8 фриз кадра, музыка затухает
"""
import subprocess
from pathlib import Path

S = Path("/tmp/claude-0/-home-user-jarvis-installer/100a0701-297d-51f6-a717-b796d20bf655/scratchpad")
A = S / "assets"
KRUG = "/root/.claude/uploads/100a0701-297d-51f6-a717-b796d20bf655/2b6915e3-video.mp4"
MUSIC = S / "music_bed.wav"        # новая музыка (IMG_8960), зациклена до 63.8с
OUT = S / "AIStrateg_kreo_v7.mp4"

T = 63.8          # общая длительность
KOFF = 2.6        # старт кружка
KEND = 61.0       # конец кружка (2.6 + 58.4)
D = 900           # диаметр кружка
CX, CY = 540, 610 # центр кружка

inputs = []
def inp(path, loop=True, dur=T):
    idx = len(inputs)
    if loop:
        inputs.append(f"-loop 1 -t {dur} -i '{path}'")
    else:
        inputs.append(f"-i '{path}'")
    return idx

i_bg    = inp(A/"bg.png")
i_pa    = inp(A/"part_a.png")
i_pb    = inp(A/"part_b.png")
i_glow  = inp(A/"glow.png")
i_ring  = inp(A/"ring.png")
i_arc1  = inp(A/"arc1.png")
i_arc2  = inp(A/"arc2.png")
i_badge = inp(A/"badge_ring.png")
i_bai   = inp(A/"badge_ai.png")
i_pill  = inp(A/"rec_pill.png")
i_dot   = inp(A/"rec_dot.png")
i_krug  = inp(KRUG, loop=False)
i_mask  = inp(A/"mask.png")
i_kick  = inp(A/"kicker_intro.png")
i_100k  = inp(A/"stamp_100k.png")
i_serif = inp(A/"intro_serif.png")
i_price = inp(A/"stamp_price.png")
i_4odam = inp(A/"stamp_4odam.png")
i_chC   = inp(A/"chip_claude.png")
i_chN   = inp(A/"chip_nlm.png")
i_chJ   = inp(A/"chip_jarvis.png")
i_btn   = inp(A/"cta_button.png")
i_cpill = inp(A/"cta_pill.png")
i_url   = inp(A/"url.png")
i_music = inp(MUSIC, loop=False)

fc = []

# --- фон + дрейфующие частицы (2 слоя, бесшовный цикл 2400px)
fc.append(f"[{i_bg}:v]format=rgba[bg]")
fc.append(f"[{i_pa}:v]format=rgba,split=2[pa1][pa2]")
fc.append(f"[{i_pb}:v]format=rgba,colorchannelmixer=aa=0.75,split=2[pb1][pb2]")
fc.append("[bg][pa1]overlay=x=0:y='-mod(t*16,2400)':shortest=1[b1]")
fc.append("[b1][pa2]overlay=x=0:y='-mod(t*16,2400)+2400'[b2]")
fc.append("[b2][pb1]overlay=x=0:y='-mod(t*7,2400)'[b3]")
fc.append("[b3][pb2]overlay=x=0:y='-mod(t*7,2400)+2400'[base]")

# --- вращающееся свечение за кружком (с 2.4)
fc.append(f"[{i_glow}:v]format=rgba,rotate=a='t*0.18':c=none:ow=1400:oh=1400,"
          f"fade=in:st=2.4:d=0.5:alpha=1[glr]")
fc.append(f"[base][glr]overlay=x={CX-700}:y={CY-700}[v0]")

# --- интро (фейды в обе стороны)
fc.append(f"[{i_kick}:v]format=rgba,fade=in:st=0.12:d=0.25:alpha=1,fade=out:st=2.25:d=0.3:alpha=1[kick]")
fc.append(f"[v0][kick]overlay=x=(W-w)/2:y=330:enable='lt(t,2.6)'[v1]")
fc.append(f"[{i_100k}:v]format=rgba,fade=in:st=0.30:d=0.18:alpha=1,fade=out:st=2.25:d=0.3:alpha=1[s100]")
fc.append(f"[v1][s100]overlay=x=(W-w)/2:y='700-h/2-12*min(1,max(0,(t-0.30)/0.5))':enable='lt(t,2.6)'[v2]")
fc.append(f"[{i_serif}:v]format=rgba,fade=in:st=0.85:d=0.25:alpha=1,fade=out:st=2.25:d=0.3:alpha=1[srf]")
fc.append(f"[v2][srf]overlay=x=(W-w)/2:y='1010+18*(1-min(1,max(0,(t-0.85)/0.45)))':enable='lt(t,2.6)'[v3]")

# --- кружок: 900px, круглая маска, PTS+2.6, фриз последнего кадра
fc.append(f"[{i_krug}:v]scale={D}:{D}:flags=lanczos,format=rgba[kv]")
fc.append(f"[{i_mask}:v]alphaextract[am]")
fc.append(f"[kv][am]alphamerge,tpad=stop_mode=clone:stop_duration=3.2,"
          f"setpts=PTS-STARTPTS+{KOFF}/TB,fade=in:st={KOFF}:d=0.28:alpha=1[krg]")

# --- дуги и кольцо вокруг кружка
fc.append(f"[{i_arc1}:v]format=rgba,rotate=a='t*0.55':c=none:ow=1180:oh=1180,"
          f"fade=in:st={KOFF}:d=0.5:alpha=1[a1]")
fc.append(f"[{i_arc2}:v]format=rgba,rotate=a='-t*0.38':c=none:ow=1180:oh=1180,"
          f"fade=in:st={KOFF}:d=0.5:alpha=1[a2]")
fc.append(f"[v3][a1]overlay=x={CX}-590:y={CY}-590[v4]")
fc.append(f"[v4][a2]overlay=x={CX}-590:y={CY}-590[v5]")
fc.append(f"[v5][krg]overlay=x={CX-D//2}:y={CY-D//2}:enable='gte(t,{KOFF})'[v6]")
fc.append(f"[{i_ring}:v]format=rgba,fade=in:st={KOFF}:d=0.3:alpha=1[rng]")
fc.append(f"[v6][rng]overlay=x={CX}-w/2:y={CY}-h/2:enable='gte(t,{KOFF})'[v7]")

# --- REC-пилюля сверху + мигающая точка (всё видео)
fc.append(f"[{i_pill}:v]format=rgba,fade=in:st=0.10:d=0.25:alpha=1[rp]")
fc.append(f"[v7][rp]overlay=x=(W-w)/2:y=96[v8]")
# точка: пилюля 532x62 на y=96; центр точки = левый край + 44
fc.append(f"[{i_dot}:v]format=rgba[rd]")
fc.append(f"[v8][rd]overlay=x=(1080-532)/2+44-13:y=96+31-13:enable='lt(mod(t,1.2),0.75)'[v9]")

# --- бейдж снизу: кольцо вращается, AI статичен; гаснет перед CTA
fc.append(f"[{i_badge}:v]format=rgba,rotate=a='t*0.32':c=none:ow=300:oh=300,"
          f"fade=in:st=0.4:d=0.4:alpha=1,fade=out:st=55.2:d=0.45:alpha=1,"
          f"colorchannelmixer=aa=0.9[bdg]")
fc.append(f"[v9][bdg]overlay=x=(W-w)/2:y=1720-h/2:enable='lt(t,55.7)'[v9b]")
fc.append(f"[{i_bai}:v]format=rgba,fade=in:st=0.4:d=0.4:alpha=1,"
          f"fade=out:st=55.2:d=0.45:alpha=1,colorchannelmixer=aa=0.9[bai]")
fc.append(f"[v9b][bai]overlay=x=(W-w)/2:y=1720-h/2:enable='lt(t,55.7)'[v10]")

# --- штампы-цифры (fade in/out + лёгкий подъём)
def stamp_chain(idx, label, t0, t1, y):
    fc.append(f"[{idx}:v]format=rgba,fade=in:st={t0}:d=0.16:alpha=1,"
              f"fade=out:st={t1-0.22}:d=0.22:alpha=1[{label}]")
    return (f"overlay=x=(W-w)/2:y='{y}-h/2-14*min(1,max(0,(t-{t0})/0.4))'"
            f":enable='between(t,{t0},{t1})'")

# окна штампов синхронны с речью и НЕ перекрываются субтитрами (см. make_subs_v7)
cur = "v10"
for n, (idx, t0, t1) in enumerate([(i_price, 11.45, 15.60),
                                   (i_4odam, 39.00, 43.30)]):
    ov = stamp_chain(idx, f"st{n}", t0, t1, 1205)
    fc.append(f"[{cur}][st{n}]{ov}[vs{n}]")
    cur = f"vs{n}"

# --- чипы инструментов вокруг кружка (покачивание)
chips = [(i_chC, 130, 838, 31.6, 0.0), (i_chN, 610, 196, 32.1, 1.1), (i_chJ, 688, 895, 32.6, 2.2)]
for n, (idx, x, y, t0, ph) in enumerate(chips):
    fc.append(f"[{idx}:v]format=rgba,fade=in:st={t0}:d=0.25:alpha=1,"
              f"fade=out:st=38.6:d=0.3:alpha=1[ch{n}]")
    fc.append(f"[{cur}][ch{n}]overlay=x={x}:y='{y}+7*sin(2*PI*(t/3.4+{ph}))'"
              f":enable='between(t,{t0},39.0)'[vch{n}]")
    cur = f"vch{n}"

# --- CTA: кнопка + пилюля + URL (пульс кнопки лёгким масштабом нельзя — слайд+фейд)
fc.append(f"[{i_btn}:v]format=rgba,fade=in:st=55.80:d=0.25:alpha=1[btn]")
fc.append(f"[{cur}][btn]overlay=x=(W-w)/2:y='1400-h/2+30*(1-min(1,max(0,(t-55.8)/0.45)))'"
          f":enable='gte(t,55.8)'[vb1]")
fc.append(f"[{i_cpill}:v]format=rgba,fade=in:st=56.30:d=0.25:alpha=1[cpl]")
fc.append(f"[vb1][cpl]overlay=x=(W-w)/2:y='1530+24*(1-min(1,max(0,(t-56.3)/0.45)))'"
          f":enable='gte(t,56.3)'[vb2]")
fc.append(f"[{i_url}:v]format=rgba,fade=in:st=56.80:d=0.3:alpha=1[url]")
fc.append(f"[vb2][url]overlay=x=(W-w)/2:y=1636:enable='gte(t,56.8)'[vb3]")

# --- золотая вспышка на стыке интро → кружок
fc.append(f"color=c=0xC9A961:s=1080x1920:d={T},format=rgba,"
          f"colorchannelmixer=aa=0.55,fade=in:st=2.45:d=0.12:alpha=1,"
          f"fade=out:st=2.60:d=0.30:alpha=1[flash]")
fc.append(f"[vb3][flash]overlay=enable='between(t,2.45,3.0)'[vfl]")

# --- титры + зерно
fc.append(f"[vfl]ass='{S}/subs.ass':fontsdir='{S}/fonts',noise=alls=5:allf=t,format=yuv420p[vout]")

# --- аудио: голос кружка (чистка) + музыка (дак через sidechain)
fc.append(f"[{i_krug}:a]adelay={int(KOFF*1000)}|{int(KOFF*1000)},"
          f"highpass=f=80,afftdn=nf=-28,dynaudnorm=f=250:g=15,"
          f"apad=pad_dur=4,atrim=0:{T},asplit=2[voice][sc]")
fc.append(f"[{i_music}:a]volume=1.0,afade=in:st=0:d=0.9,apad=pad_dur=4,atrim=0:{T}[mus0]")
fc.append("[mus0][sc]sidechaincompress=threshold=0.015:ratio=10:attack=40:release=800:makeup=1.6[musd]")
fc.append("[voice][musd]amix=inputs=2:duration=first:weights='1 0.55':normalize=0,"
          f"loudnorm=I=-14:TP=-1.5:LRA=11,afade=out:st={T-2.4}:d=2.4[aout]")

cmd = ("ffmpeg -y " + " ".join(inputs) +
       f" -filter_complex \"{';'.join(fc)}\" "
       f"-map '[vout]' -map '[aout]' -t {T} -r 30 "
       "-c:v libx264 -preset veryfast -crf 21 -maxrate 9M -bufsize 14M "
       "-pix_fmt yuv420p -c:a aac -b:a 192k -movflags +faststart "
       f"'{OUT}'")

print(cmd[:2000])
r = subprocess.run(cmd, shell=True, capture_output=True, text=True)
print("RC =", r.returncode)
if r.returncode != 0:
    print(r.stderr[-4000:])
else:
    print(r.stderr[-600:])
