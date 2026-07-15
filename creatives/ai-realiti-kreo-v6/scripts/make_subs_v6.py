# -*- coding: utf-8 -*-
"""Фразовые титры (выверенный узбекский) для крео v6.
Whisper на разговорном узбекском врёт в словах → пословные субтитры нельзя,
фразы кладём по сегментным таймкодам. Мягкая тень — двухслойный приём."""
from pathlib import Path

OUT = Path("/tmp/claude-0/-home-user-jarvis-installer/100a0701-297d-51f6-a717-b796d20bf655/scratchpad/subs.ass")

W, H = 1080, 1920
CY = 1235                # центр титра (под кружком)
GOLD = r"{\1c&H61A9C9&}"   # C9A961 в BGR
WHITE = r"{\1c&HFFFFFF&}"

# (start, end, text) — глобальное время (кружок начинается на 2.6 c)
CAPS = [
    (2.80, 5.90,  "PRODYUSER? EKSPERT?\\NMARKETOLOG?", 60),
    (7.10, 9.10,  "O'ZBEKISTON BOZORIDA", 56),
    (9.20, 11.95, "KADRLAR NARXI —\\N{G}JUDA BALAND{W}", 60),
    (20.30, 24.20, "SIFATSIZ KADRLARDAN\\NCHARCHAB —", 60),
    (24.40, 28.20, "{G}O'ZIMGA AI-AGENTLAR\\NYARATDIM{W}", 60),
    (28.60, 31.30, "MANA — MENING\\N{G}AI-JAMOAM{W}", 60),
    (45.95, 47.45, "{G}BU — REALITY.{W}", 76),
]

def fmt(t):
    h = int(t // 3600); m = int((t % 3600) // 60); s = t - h*3600 - m*60
    return f"{h}:{m:02d}:{s:05.2f}"

header = f"""[Script Info]
ScriptType: v4.00+
PlayResX: {W}
PlayResY: {H}
WrapStyle: 2
ScaledBorderAndShadow: yes
YCbCr Matrix: TV.709

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Sub,Unbounded Bold,60,&H00FFFFFF,&H00FFFFFF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,0,0,5,40,40,40,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
"""

lines = []
for st, en, txt, size in CAPS:
    body = txt.replace("{G}", GOLD).replace("{W}", WHITE)
    common = (f"\\an5\\bord0\\shad0\\fs{size}\\fscx112\\fscy112"
              "\\t(0,110,\\fscx100\\fscy100)\\fad(50,60)")
    shadow_body = txt.replace("{G}", "").replace("{W}", "")
    lines.append(f"Dialogue: 0,{fmt(st)},{fmt(en)},Sub,,0,0,0,,"
                 f"{{{common}\\pos({W//2},{CY+7})\\blur9\\1c&H000000&\\alpha&H28&}}{shadow_body}")
    lines.append(f"Dialogue: 1,{fmt(st)},{fmt(en)},Sub,,0,0,0,,"
                 f"{{{common}\\pos({W//2},{CY})}}{body}")

OUT.write_text(header + "\n".join(lines) + "\n", encoding="utf-8")
print("captions:", len(CAPS))
for st, en, txt, _ in CAPS:
    print(f"  {st:5.1f}-{en:5.1f}  {txt.replace(chr(92)+'N', ' / ')}")
