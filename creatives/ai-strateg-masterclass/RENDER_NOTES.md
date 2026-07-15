# Render eslatmalari

- Spiker tezligi: `SPEED=1.1 node render.js full frames` — vizual va subtitrlar
  ovoz bilan birga 1.1x tez ijro etiladi (kadrlar 44s sahna-vaqtidan 40s realga siqiladi).
- Audio: `build_audio.sh` — ovoz atempo=1.1, musiqa fon rejimida (volume 0.26 + sidechain duck).
- Kodlash: `bash encode.sh` (30fps, crf 18).
