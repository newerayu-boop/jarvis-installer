# -*- coding: utf-8 -*-
"""Ассеты для крео v6 «AI Strateg / AI-Realiti» — чёрный + золото.
Всё рисуется в 2-4x и уменьшается (гладкие края)."""
import math
import random
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont

A = Path("/tmp/claude-0/-home-user-jarvis-installer/100a0701-297d-51f6-a717-b796d20bf655/scratchpad/assets")
F = Path("/tmp/claude-0/-home-user-jarvis-installer/100a0701-297d-51f6-a717-b796d20bf655/scratchpad/fonts")
A.mkdir(exist_ok=True)

W, H = 1080, 1920
GOLD = (201, 169, 97)          # C9A961
GOLD_HI = (232, 200, 122)      # E8C87A
GOLD_DIM = (140, 116, 66)
WHITE = (245, 245, 245)
GRAY = (185, 181, 172)
INK = (10, 10, 8)
RED = (214, 69, 69)

UNB_BLACK = str(F / "Unbounded-Black.ttf")
UNB_BOLD = str(F / "Unbounded-Bold.ttf")
UNB_MED = str(F / "Unbounded-Medium.ttf")
INTER_R = str(F / "Inter-Regular.ttf")
INTER_SB = str(F / "Inter-SemiBold.ttf")
INTER_XB = str(F / "Inter-ExtraBold.ttf")
PLAY_BI = str(F / "Playfair-BlackItalic.ttf")

def font(path, size):
    return ImageFont.truetype(path, size)

def rounded(draw, xy, r, **kw):
    draw.rounded_rectangle(xy, radius=r, **kw)

# ---------------------------------------------------------------- фон
def bg_gradient():
    """Чёрный фон с тёплым золотым свечением снизу-центра и лёгкой виньеткой."""
    img = Image.new("RGB", (W, H), INK)
    glow = Image.new("L", (W, H), 0)
    gd = ImageDraw.Draw(glow)
    # тёплое пятно внизу (как в референсе)
    gd.ellipse([W/2 - 900, H - 700, W/2 + 900, H + 900], fill=70)
    # слабое пятно за кружком сверху
    gd.ellipse([W/2 - 750, 100, W/2 + 750, 1250], fill=34)
    glow = glow.filter(ImageFilter.GaussianBlur(220))
    tint = Image.new("RGB", (W, H), (64, 50, 24))
    img = Image.composite(tint, img, glow)
    img.save(A / "bg.png")

def particles(name, n, seed, size_rng=(2, 7), maxa=200):
    """Слой золотых частиц-бокэ 1080x2400 (RGBA), бесшовный по вертикали."""
    PH = 2400
    s = 2
    img = Image.new("RGBA", (W*s, PH*s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    rnd = random.Random(seed)
    for _ in range(n):
        x, y = rnd.uniform(0, W*s), rnd.uniform(0, PH*s)
        r = rnd.uniform(size_rng[0]*s, size_rng[1]*s)
        a = int(rnd.uniform(60, maxa))
        c = GOLD_HI if rnd.random() < 0.35 else GOLD
        for yy in (y, y - PH*s, y + PH*s):   # копии сверху/снизу = бесшовный цикл
            d.ellipse([x-r, yy-r, x+r, yy+r], fill=c + (a,))
    img = img.filter(ImageFilter.GaussianBlur(s*1.2))
    img = img.resize((W, PH), Image.LANCZOS)
    img.save(A / name)

def glow_disc():
    """Мягкое золотое свечение за кружком (1400x1400), слегка асимметричное для вращения."""
    S = 1400
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx = cy = S/2
    d.ellipse([cx-560, cy-560, cx+560, cy+560], fill=GOLD + (46,))
    d.ellipse([cx-440, cy-470, cx+500, cy+430], fill=GOLD_HI + (34,))
    img = img.filter(ImageFilter.GaussianBlur(130))
    img.save(A / "glow.png")

# ---------------------------------------------------------------- кольцо и дуги
KRUG = 900          # диаметр кружка в кадре

def ring():
    """Золотое кольцо вокруг кружка с внешним свечением."""
    pad = 80
    S4 = (KRUG + pad*2) * 4
    img = Image.new("RGBA", (S4, S4), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    c = S4/2
    r_in = KRUG*4/2
    # свечение
    gl = Image.new("RGBA", (S4, S4), (0, 0, 0, 0))
    gd = ImageDraw.Draw(gl)
    gd.ellipse([c-r_in-26, c-r_in-26, c+r_in+26, c+r_in+26],
               outline=GOLD + (150,), width=64)
    gl = gl.filter(ImageFilter.GaussianBlur(48))
    img = Image.alpha_composite(img, gl)
    # само кольцо: двойное — тонкое яркое + чуть шире тёмное
    d = ImageDraw.Draw(img)
    d.ellipse([c-r_in-34, c-r_in-34, c+r_in+34, c+r_in+34],
              outline=GOLD_DIM + (200,), width=8)
    d.ellipse([c-r_in-16, c-r_in-16, c+r_in+16, c+r_in+16],
              outline=GOLD + (255,), width=14)
    img = img.resize(((KRUG + pad*2), (KRUG + pad*2)), Image.LANCZOS)
    img.save(A / "ring.png")

def arc_layer(name, r_off, spans, width, color, alpha):
    """Партиал-дуги вокруг кольца (вращаются в ffmpeg). spans: [(start_deg, end_deg)]"""
    pad = 140
    S = KRUG + pad*2
    S4 = S*4
    img = Image.new("RGBA", (S4, S4), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    c = S4/2
    r = (KRUG/2 + r_off)*4
    box = [c-r, c-r, c+r, c+r]
    for a0, a1 in spans:
        d.arc(box, a0, a1, fill=color + (alpha,), width=width*4)
    img = img.resize((S, S), Image.LANCZOS)
    img.save(A / name)

# ---------------------------------------------------------------- бейдж
def badge():
    """Бейдж двумя слоями: вращающееся кольцо текста + статичный центр AI."""
    S = 260
    S4 = S*4
    c = S4/2
    # --- кольцо (вращается)
    ring_img = Image.new("RGBA", (S4, S4), (0, 0, 0, 0))
    txt = "AI STRATEG · REALITY · 20 KUN · "
    fnt = font(UNB_MED, 66)
    R = S4/2 - 90
    n = len(txt)
    for i, ch in enumerate(txt):
        ang = 2*math.pi*i/n - math.pi/2
        x = c + R*math.cos(ang)
        y = c + R*math.sin(ang)
        ch_img = Image.new("RGBA", (120, 120), (0, 0, 0, 0))
        cd = ImageDraw.Draw(ch_img)
        cd.text((60, 60), ch, font=fnt, fill=GOLD + (215,), anchor="mm")
        ch_img = ch_img.rotate(-math.degrees(ang) - 90, resample=Image.BICUBIC, center=(60, 60))
        ring_img.alpha_composite(ch_img, (int(x-60), int(y-60)))
    d = ImageDraw.Draw(ring_img)
    r2 = R - 110
    d.ellipse([c-r2, c-r2, c+r2, c+r2], outline=GOLD + (120,), width=6)
    ring_img.resize((S, S), Image.LANCZOS).save(A / "badge_ring.png")
    # --- статичный центр
    ai_img = Image.new("RGBA", (S4, S4), (0, 0, 0, 0))
    ImageDraw.Draw(ai_img).text((c, c), "AI", font=font(UNB_BOLD, 150),
                                fill=GOLD + (235,), anchor="mm")
    ai_img.resize((S, S), Image.LANCZOS).save(A / "badge_ai.png")

# ---------------------------------------------------------------- REC-пилюля
def rec_pill():
    """Пилюля без точки (точка отдельным слоем — мигает в ffmpeg)."""
    txt = "REALITY · JONLI EFIR"
    fnt = font(UNB_MED, 30*3)
    tmp = Image.new("RGBA", (10, 10)); tw = ImageDraw.Draw(tmp).textlength(txt, font=fnt)
    ph, pw = 62*3, int(tw) + 150*3
    img = Image.new("RGBA", (pw, ph), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    rounded(d, [0, 0, pw-1, ph-1], ph//2, fill=(14, 12, 8, 200), outline=GOLD + (160,), width=4)
    d.text((44*3 + 30*3, ph/2), txt, font=fnt, fill=WHITE + (235,), anchor="lm")
    img = img.resize((pw//3, ph//3), Image.LANCZOS)
    img.save(A / "rec_pill.png")
    print("rec_pill size:", pw//3, ph//3)
    # мигающая точка
    s = 4
    dot = Image.new("RGBA", (26*s, 26*s), (0, 0, 0, 0))
    dd = ImageDraw.Draw(dot)
    dd.ellipse([4*s, 4*s, 22*s, 22*s], fill=RED + (255,))
    dot = dot.filter(ImageFilter.GaussianBlur(s)).resize((26, 26), Image.LANCZOS)
    dot.save(A / "rec_dot.png")

# ---------------------------------------------------------------- штампы-цифры
def stamp(name, big, sub=None, big_font=UNB_BLACK, big_size=150, sub_size=44,
          big_color=GOLD, glow_amt=26):
    """Большой золотой штамп с мягким свечением (по центру canvas 1080)."""
    s = 3
    fnt = font(big_font, big_size*s)
    tmp = Image.new("RGBA", (10, 10))
    td = ImageDraw.Draw(tmp)
    tw = td.textlength(big, font=fnt)
    sw = td.textlength(sub, font=font(UNB_MED, sub_size*s)) if sub else 0
    ph = int(big_size*s*1.5) + (int(sub_size*s*2.2) if sub else 0)
    pw = min(int(max(tw, sw)) + 140, W*s)
    img = Image.new("RGBA", (pw, ph), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy = pw/2, big_size*s*0.72
    # свечение-слой
    gl = Image.new("RGBA", (pw, ph), (0, 0, 0, 0))
    gd = ImageDraw.Draw(gl)
    gd.text((cx, cy), big, font=fnt, fill=big_color + (160,), anchor="mm")
    gl = gl.filter(ImageFilter.GaussianBlur(glow_amt*s/2))
    img = Image.alpha_composite(img, gl)
    d = ImageDraw.Draw(img)
    # тень
    d.text((cx+5*s, cy+7*s), big, font=fnt, fill=(0, 0, 0, 140), anchor="mm")
    d.text((cx, cy), big, font=fnt, fill=big_color + (255,), anchor="mm")
    if sub:
        d.text((cx, big_size*s*1.35 + sub_size*s*0.6), sub,
               font=font(UNB_MED, sub_size*s), fill=WHITE + (230,), anchor="mm")
    img = img.resize((pw//s, ph//s), Image.LANCZOS)
    img.save(A / name)

# ---------------------------------------------------------------- нижняя карточка
def lower_card(name, head, sub, head_color=WHITE, w=980):
    """Плашка как в v5: тёмная, золотая рамка, слева золотая полоска."""
    s = 3
    hf = font(UNB_BOLD, 47*s)
    sf = font(INTER_SB, 34*s)
    # автоперенос заголовка вручную не нужен — тексты короткие
    tmp = Image.new("RGBA", (10, 10)); td = ImageDraw.Draw(tmp)
    hw = td.textlength(head, font=hf)
    sw = td.textlength(sub, font=sf) if sub else 0
    pw = w*s
    ph = (176 if sub else 128)*s
    img = Image.new("RGBA", (pw, ph), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    rounded(d, [0, 0, pw-1, ph-1], 34*s, fill=(16, 14, 10, 216), outline=GOLD + (170,), width=4)
    # золотая полоска слева
    bar = Image.new("RGBA", (10*s, ph - 36*s), GOLD + (255,))
    img.paste(bar, (0 + 0, 18*s), bar)
    x = 42*s
    if sub:
        d.text((x, 30*s), head, font=hf, fill=head_color + (255,), anchor="la")
        d.text((x, (30 + 47*1.45)*s), sub, font=sf, fill=GRAY + (230,), anchor="la")
    else:
        d.text((x, ph/2), head, font=hf, fill=head_color + (255,), anchor="lm")
    img = img.resize((pw//s, ph//s), Image.LANCZOS)
    img.save(A / name)

# ---------------------------------------------------------------- интро
def intro_serif():
    """«Jamoasiz. Prodyusersiz.» — Playfair Black Italic, как в статичном крео."""
    s = 3
    f1 = font(PLAY_BI, 110*s)
    lines = ["Jamoasiz.", "Prodyusersiz."]
    pw, ph = 1000*s, 330*s
    img = Image.new("RGBA", (pw, ph), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    y = 80*s
    for ln in lines:
        d.text((pw/2+4*s, y+6*s), ln, font=f1, fill=(0, 0, 0, 160), anchor="mm")
        d.text((pw/2, y), ln, font=f1, fill=WHITE + (255,), anchor="mm")
        y += 150*s
    img = img.resize((pw//s, ph//s), Image.LANCZOS)
    img.save(A / "intro_serif.png")

def kicker(name, txt):
    """Маленький верхний киккер: — REALITY · 20 KUN («статичный» стиль)."""
    s = 3
    fnt = font(UNB_MED, 34*s)
    tmp = Image.new("RGBA", (10, 10)); tw = ImageDraw.Draw(tmp).textlength(txt, font=fnt)
    pw, ph = int(tw) + 40*s, 70*s
    img = Image.new("RGBA", (pw, ph), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.text((pw/2, ph/2), txt, font=fnt, fill=GOLD + (235,), anchor="mm")
    img = img.resize((pw//s, ph//s), Image.LANCZOS)
    img.save(A / name)

# ---------------------------------------------------------------- CTA
def cta_button():
    s = 3
    txt = "Joy band qilish →"
    fnt = font(INTER_XB, 52*s)
    tmp = Image.new("RGBA", (10, 10)); tw = ImageDraw.Draw(tmp).textlength(txt, font=fnt)
    pw, ph = int(tw) + 170*s, 124*s
    img = Image.new("RGBA", (pw, ph), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # свечение
    gl = Image.new("RGBA", (pw, ph), (0, 0, 0, 0))
    gd = ImageDraw.Draw(gl)
    rounded(gd, [10*s, 10*s, pw-10*s, ph-10*s], ph//2, fill=GOLD + (150,))
    gl = gl.filter(ImageFilter.GaussianBlur(14*s))
    img = Image.alpha_composite(img, gl)
    d = ImageDraw.Draw(img)
    rounded(d, [12*s, 12*s, pw-12*s, ph-12*s], (ph-24*s)//2, fill=(226, 191, 110, 255))
    d.text((pw/2, ph/2 - 2*s), txt, font=fnt, fill=(26, 22, 12, 255), anchor="mm")
    img = img.resize((pw//s, ph//s), Image.LANCZOS)
    img.save(A / "cta_button.png")

def cta_pill():
    s = 3
    txt = "200 ta joy · ataylab cheklangan · Telegramda"
    fnt = font(INTER_SB, 34*s)
    tmp = Image.new("RGBA", (10, 10)); tw = ImageDraw.Draw(tmp).textlength(txt, font=fnt)
    pw, ph = int(tw) + 110*s, 88*s
    img = Image.new("RGBA", (pw, ph), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    rounded(d, [2*s, 2*s, pw-2*s, ph-2*s], ph//2, fill=(20, 17, 11, 190), outline=GOLD + (150,), width=4)
    d.text((pw/2, ph/2), txt, font=fnt, fill=(230, 226, 216, 240), anchor="mm")
    img = img.resize((pw//s, ph//s), Image.LANCZOS)
    img.save(A / "cta_pill.png")

def url_line():
    s = 3
    txt = "aistrateg-reality.vercel.app"
    fnt = font(INTER_SB, 36*s)
    tmp = Image.new("RGBA", (10, 10)); tw = ImageDraw.Draw(tmp).textlength(txt, font=fnt)
    pw, ph = int(tw) + 20*s, 60*s
    img = Image.new("RGBA", (pw, ph), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.text((pw/2, ph/2), txt, font=fnt, fill=GOLD_HI + (235,), anchor="mm")
    img = img.resize((pw//s, ph//s), Image.LANCZOS)
    img.save(A / "url.png")

# ---------------------------------------------------------------- чипы инструментов
def chip(name, txt):
    s = 3
    fnt = font(INTER_SB, 33*s)
    tmp = Image.new("RGBA", (10, 10)); tw = ImageDraw.Draw(tmp).textlength(txt, font=fnt)
    pw, ph = int(tw) + 76*s, 74*s
    img = Image.new("RGBA", (pw, ph), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    rounded(d, [2*s, 2*s, pw-2*s, ph-2*s], ph//2, fill=(18, 15, 10, 205), outline=GOLD + (140,), width=3)
    d.text((pw/2, ph/2), txt, font=fnt, fill=GOLD_HI + (240,), anchor="mm")
    img = img.resize((pw//s, ph//s), Image.LANCZOS)
    img.save(A / name)

# ---------------------------------------------------------------- маска кружка
def circle_mask():
    S4 = KRUG*4
    img = Image.new("L", (S4, S4), 0)
    d = ImageDraw.Draw(img)
    d.ellipse([0, 0, S4-1, S4-1], fill=255)
    img = img.resize((KRUG, KRUG), Image.LANCZOS)
    Image.merge("RGBA", (img, img, img, img)).save(A / "mask.png")

if __name__ == "__main__":
    bg_gradient()
    particles("part_a.png", 90, 7, (2, 6), 190)
    particles("part_b.png", 45, 21, (5, 12), 110)
    glow_disc()
    ring()
    arc_layer("arc1.png", 62, [(300, 30), (120, 210)], 3, GOLD, 190)
    arc_layer("arc2.png", 88, [(20, 80), (200, 260)], 2, GOLD_HI, 140)
    badge()
    rec_pill()
    circle_mask()
    intro_serif()
    kicker("kicker_intro.png", "—  REALITY · 20 KUN")
    stamp("stamp_100k.png", "$100 000", None, big_size=165)
    stamp("stamp_price.png", "$1 000 – $1 500", "bitta mutaxassis narxi", big_size=100)
    stamp("stamp_4odam.png", "4 ODAM", "20 kishining ishini qilyapti", big_size=130)
    stamp("stamp_20kun.png", "20 KUN", "jonli · montajsiz · ichkaridan", big_size=130)
    lower_card("card1.png", "Tajriba bor", "Rossiya bozorida jamoa bilan ishlaganman")
    lower_card("card2.png", "AI-agent jamoa", "marketolog · prodyuser · dizayner · SMM")
    lower_card("card3.png", "Hammasi — ochiq", "jarayon · promptlar · raqamlar · xatolar")
    cta_button()
    cta_pill()
    url_line()
    chip("chip_claude.png", "Claude")
    chip("chip_nlm.png", "NotebookLM")
    chip("chip_jarvis.png", "Jarvis")
    chip("chip_20.png", "AI-jamoa · $20/oy")
    print("assets done:", len(list(A.glob('*.png'))))
