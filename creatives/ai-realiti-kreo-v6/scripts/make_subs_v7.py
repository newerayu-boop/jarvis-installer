# -*- coding: utf-8 -*-
"""Сплошные фразовые титры (выверенный узбекский) на ВСЮ речь — крео v7.
Тайминги — из пословных таймкодов; текст выверен вручную по смыслу
(Whisper на разговорном узбекском врёт в словах). Двухслойная мягкая тень."""
from pathlib import Path

OUT = Path("/tmp/claude-0/-home-user-jarvis-installer/100a0701-297d-51f6-a717-b796d20bf655/scratchpad/subs.ass")

W, H = 1080, 1920
CY = 1205                 # центр титра (под кружком)
GOLD = r"{\1c&H61A9C9&}"  # C9A961 в BGR
WHITE = r"{\1c&HFFFFFF&}"

# (start_global, end_global, text, fontsize). Окна штампов НЕ перекрываются.
CAPS = [
    (2.80,  6.40,  "PRODYUSER, EKSPERT,\\NMARKETOLOG BO'LSANGIZ…", 58),
    (6.85, 11.20,  "O'ZBEKISTON BOZORIDA\\NKADRLAR NARXI — {G}JUDA BALAND{W}", 56),
    # 11.4–15.6 — штамп $1000–1500
    (15.85, 19.10, "ROSSIYA JAMOASIDA\\NISHLAGANMAN — {G}BILAMAN{W}", 58),
    (19.40, 24.20, "{G}SIFATSIZ KADRLARDAN\\NCHARCHADIM{W}", 60),
    (24.40, 28.00, "{G}O'ZIMGA AI-AGENTLAR\\NYARATDIM{W}", 60),
    (28.35, 31.40, "MANA — MENING\\N{G}AI-AGENT JAMOAM{W}", 58),
    (31.70, 35.70, "MARKETOLOG · PRODYUSER ·\\NDIZAYNER — {G}HAMMASI AI{W}", 52),
    (35.90, 38.75, "KO'PCHILIGINI\\NBOSIB O'TDIM", 58),
    # 39.0–43.3 — штамп 4 ODAM
    (43.45, 46.00, "MEN — {G}REALITY{W} QILAMAN\\N20 KUN ICHIDA", 56),
    (46.20, 49.30, "ICHKARIDA HAR BIR\\NJARAYON — {G}OCHIQ{W}", 56),
    (49.55, 54.30, "PROMPT · RAQAM · XATO —\\N{G}HAMMASINI OCHIQ BERAMAN{W}", 50),
    (54.55, 56.10, "{G}PASTDA — BATAFSIL{W}", 62),
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
Style: Sub,Unbounded Bold,58,&H00FFFFFF,&H00FFFFFF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,0,0,5,40,40,40,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
"""

lines = []
for st, en, txt, size in CAPS:
    body = txt.replace("{G}", GOLD).replace("{W}", WHITE)
    common = (f"\\an5\\bord0\\shad0\\fs{size}\\fscx110\\fscy110"
              "\\t(0,110,\\fscx100\\fscy100)\\fad(45,55)")
    shadow_body = txt.replace("{G}", "").replace("{W}", "")
    lines.append(f"Dialogue: 0,{fmt(st)},{fmt(en)},Sub,,0,0,0,,"
                 f"{{{common}\\pos({W//2},{CY+7})\\blur9\\1c&H000000&\\alpha&H26&}}{shadow_body}")
    lines.append(f"Dialogue: 1,{fmt(st)},{fmt(en)},Sub,,0,0,0,,"
                 f"{{{common}\\pos({W//2},{CY})}}{body}")

OUT.write_text(header + "\n".join(lines) + "\n", encoding="utf-8")
print("captions:", len(CAPS))
tot = sum(en-st for st, en, _, _ in CAPS)
print(f"speech covered by captions/stamps ~ {tot+8.4:.1f}s of ~58s")
for st, en, txt, _ in CAPS:
    print(f"  {st:5.1f}-{en:5.1f}  {txt.replace(chr(92)+'N', ' / ')}")
