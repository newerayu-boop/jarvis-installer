# AI Strateg — Target krео (Yopiq masterclass · 9:16)

Vertikal 1080×1920 reklama roligi. Manba: prodyuserning telegram-krujogi (video-note) +
brend uslubi (qora/oltin "AI Strateg") + atmosferali musiqa. Butun montaj kod bilan
yig'ilgan — kadrlar HTML/CSS/Canvas orqali frame-by-frame render qilinadi (Remotion uslubi),
so'ng ffmpeg bilan kodlanadi.

## Fayllar

```
scene.html          — sahna: fon (zarralar, oltin nur), doira (krujok), kinetik subtitrlar,
                      kontekst-kartochkalar, "6 rol → 1 AI" bloki, muhr, hook, CTA outro.
                      Butun animatsiya window.renderAt(t) funksiyasida — deterministik.
render.js           — Playwright/Chromium: har bir frame uchun renderAt(t) → screenshot.
encode.sh           — frames + audio → final MP4 (libx264, crf 18, faststart).
fonts.css           — brend shriftlari (Playfair, Montserrat, Inter, JetBrains Mono) base64.
AI_Strateg_masterclass_9x16.mp4 — tayyor rolik.
```

## Qayta yig'ish (reproduce)

```bash
# 1. krujokdan kadrlarni ajratish (30fps)
ffmpeg -i krug.mp4 -vf fps=30 -q:v 3 circle/c_%04d.jpg
# 2. kadrlarni render qilish
node render.js full frames
# 3. audio: tozalangan ovoz + musiqa (sidechain duck) — pastdagi buyruq
# 4. kodlash
bash encode.sh
```

## Audio mix (ovoz + musiqa)

Ovoz (krujok) tozalanadi (highpass + denoise + loudnorm -14 LUFS), musiqa (atmosferali trek)
loop qilinib, `sidechaincompress` bilan ovoz ostiga "duck" qilinadi — outro'da ovoz
tugagach musiqa o'z-o'zidan ko'tariladi.

## Brend tizimi

- Fon `#080706`, oltin `#C9A961`/`#E8CE86`, qizil urg'u `#e0574e`, matn `#f5efe1`
- Sarlavha serif: Playfair Display · Sarlavhachalar: Montserrat 800/900 · Matn: Inter · Raqamlar: JetBrains Mono
- Doira (krujok) — oltin halqa + aylanuvchi nur; pastda aylanuvchi "AI STRATEG · REALITY" muhri

## Ssenariy tayanchi (krujok ovozidan)

Ovoz vaqtlari faster-whisper (large-v3) bilan olindi va subtitrlar prodyuser nutqiga
sinxronlangan. Subtitr matni — toza o'zbekcha (ASR xatolari qo'lda tuzatilgan).
