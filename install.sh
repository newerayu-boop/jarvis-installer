#!/bin/bash
# ══════════════════════════════════════════════════════════════
#  JARVIS AI ASSISTANT — Автоустановщик v1.0
#  Запуск: bash install.sh
# ══════════════════════════════════════════════════════════════
set -e

# ─── Цвета ────────────────────────────────────────────────────
R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'
B='\033[0;34m'; C='\033[0;36m'; N='\033[0m'

ok()   { echo -e "${G}✓ $1${N}"; }
warn() { echo -e "${Y}⚠ $1${N}"; }
err()  { echo -e "${R}✗ $1${N}"; exit 1; }
step() { echo -e "\n${B}━━━ $1 ━━━${N}"; }

echo -e "${C}"
cat << 'BANNER'
  ╔═══════════════════════════════════════════════╗
  ║      🤖  JARVIS AI ASSISTANT INSTALLER        ║
  ╚═══════════════════════════════════════════════╝
BANNER
echo -e "${N}"

# ─── Проверки ─────────────────────────────────────────────────
[ "$EUID" -ne 0 ] && err "Запусти от root: sudo bash install.sh"

[ ! -f "./jarvis.env" ] && err "Файл jarvis.env не найден!\nСкопируй: cp jarvis.env.example jarvis.env\nЗатем заполни все поля и снова запусти установщик."

source ./jarvis.env

for var in BOT_USERNAME TELEGRAM_TOKEN OWNER_TELEGRAM_ID OWNER_NAME BOT_NAME OPENROUTER_KEY GROQ_KEY; do
    [ -z "${!var}" ] && err "Не заполнено: $var в файле jarvis.env"
done
ok "Конфиг проверен"

# Дефолты
AI_MODEL="${AI_MODEL:-openrouter/openai/gpt-4o-mini}"
BOT_LANGUAGE="${BOT_LANGUAGE:-ru}"

# ─── 1. Системные пакеты ──────────────────────────────────────
step "1/8 Системные пакеты"
apt-get update -q
apt-get install -y -q curl git python3 python3-pip ffmpeg nodejs npm
pip3 install -q edge-tts telethon
ok "Пакеты установлены"

# ─── 2. OpenCLAW ──────────────────────────────────────────────
step "2/8 OpenCLAW"
npm install -g openclaw@latest
OPENCLAW_DIST=$(npm root -g)/openclaw/dist
[ ! -d "$OPENCLAW_DIST" ] && err "OpenCLAW не найден в $OPENCLAW_DIST"
ok "OpenCLAW установлен: $OPENCLAW_DIST"

# ─── 3. Пользователь aibot ────────────────────────────────────
step "3/8 Пользователь aibot"
if ! id "aibot" &>/dev/null; then
    useradd -m -s /bin/bash aibot
    ok "Пользователь aibot создан"
else
    ok "Пользователь aibot уже существует"
fi
loginctl enable-linger aibot
mkdir -p /run/user/$(id -u aibot)
chown aibot:aibot /run/user/$(id -u aibot)

# ─── 4. Структура директорий ──────────────────────────────────
step "4/8 Структура директорий"
BASE="/home/aibot/.openclaw"
mkdir -p "$BASE"/{workspace/skills,tools,credentials,hooks}
chown -R aibot:aibot "$BASE"
ok "Директории созданы"

# ─── 5. openclaw.json ─────────────────────────────────────────
step "5/8 Конфигурация OpenCLAW"
cat > "$BASE/openclaw.json" << EOF
{
  "version": 1,
  "defaultModel": "$AI_MODEL",
  "openRouterApiKey": "$OPENROUTER_KEY",
  "workspace": "$BASE/workspace",
  "platforms": {
    "telegram": {
      "enabled": true,
      "token": "$TELEGRAM_TOKEN"
    }
  }
}
EOF
chown aibot:aibot "$BASE/openclaw.json"
chmod 600 "$BASE/openclaw.json"
ok "openclaw.json создан"

# ─── 6. IDENTITY.md ───────────────────────────────────────────
step "6/8 Личность ассистента"

if [ "$BOT_LANGUAGE" = "uz" ]; then
LANG_INSTRUCTION="- Юсуфбай ёзган тилда жавоб бер (рус/ўзб)"
VOICE_FORMAT="[Ovozli xabar (matnga o'girildi): \"matn\"]"
else
LANG_INSTRUCTION="- Отвечай на том языке, на котором пишет $OWNER_NAME (рус/узб)"
VOICE_FORMAT="[Голосовое сообщение пользователя (расшифровка): \"текст\"]"
fi

cat > "$BASE/workspace/IDENTITY.md" << EOF
# Ты — $BOT_NAME, персональный AI-ассистент $OWNER_NAME

## Характер
- Умный, краткий, дружелюбный
- Помогаешь с задачами, напоминаниями, информацией
- Не добавляешь лишнего — отвечаешь по делу
- $LANG_INSTRUCTION

## ГОЛОСОВЫЕ СООБЩЕНИЯ

Ты УМЕЕШЬ обрабатывать голосовые сообщения.

Когда $OWNER_NAME отправляет голосовое сообщение, система автоматически расшифровывает его,
и ты видишь текст в формате:
\`$VOICE_FORMAT\`

Ты ДОЛЖЕН:
- Читать расшифровку и отвечать на неё как на обычный текстовый запрос
- НЕ говорить "не могу обработать аудио" — это НЕПРАВДА, ты уже получил текст
- НЕ просить повторить текстом — расшифровка уже есть
- Просто ответить по смыслу голосового, как будто пользователь написал это текстом

## Твой хозяин
- Имя: $OWNER_NAME
- Telegram ID: $OWNER_TELEGRAM_ID
EOF

chown aibot:aibot "$BASE/workspace/IDENTITY.md"
ok "IDENTITY.md создан"

# ─── 7. Python скрипт транскрипции ───────────────────────────
step "7/8 Транскрипция голосовых"

AISHA_BLOCK=""
if [ -n "$AISHA_KEY" ]; then
AISHA_BLOCK='
def transcribe_aisha(audio_path: str):
    """Aisha STT — специализирован для узбекского и русского."""
    r = subprocess.run([
        "curl", "-s", "-X", "POST", AISHA_POST,
        "-H", f"X-API-Key: {AISHA_API_KEY}",
        "-F", f"audio=@{audio_path}",
    ], capture_output=True, text=True, timeout=30)
    try:
        data = json.loads(r.stdout)
        task_id = data.get("id")
    except Exception:
        return None
    if not task_id:
        return None
    for _ in range(15):
        time.sleep(2)
        poll = subprocess.run([
            "curl", "-s", f"{AISHA_GET}{task_id}/",
            "-H", f"X-API-Key: {AISHA_API_KEY}",
        ], capture_output=True, text=True, timeout=15)
        try:
            result = json.loads(poll.stdout)
            if result.get("status") == "SUCCESS":
                return result.get("transcript", "").strip() or None
            elif result.get("status") == "FAILED":
                return None
        except Exception:
            continue
    return None
'
fi

cat > "$BASE/transcribe.py" << PYEOF
#!/usr/bin/env python3
"""Транскрипция аудио: $([ -n "$AISHA_KEY" ] && echo "Aisha STT (первый) + " || echo "")Groq Whisper."""
import sys, os, subprocess, json, time

GROQ_API_KEY  = "$GROQ_KEY"
$([ -n "$AISHA_KEY" ] && echo "AISHA_API_KEY = \"$AISHA_KEY\"" || echo "AISHA_API_KEY = \"\"")
AISHA_POST = "https://back.aisha.group/api/v2/stt/post/"
AISHA_GET  = "https://back.aisha.group/api/v2/stt/get/"


def transcribe_groq(audio_path: str):
    r = subprocess.run([
        "curl", "-s", "-X", "POST",
        "https://api.groq.com/openai/v1/audio/transcriptions",
        "-H", f"Authorization: Bearer {GROQ_API_KEY}",
        "-F", "model=whisper-large-v3-turbo",
        "-F", "response_format=text",
        "-F", f"file=@{audio_path}",
    ], capture_output=True, text=True, timeout=60)
    text = r.stdout.strip()
    if text and not text.startswith("{"):
        return text
    return None


$([ -n "$AISHA_KEY" ] && echo "$AISHA_BLOCK" || echo "")

def transcribe(audio_path: str):
    if not os.path.exists(audio_path):
        sys.exit(1)
$([ -n "$AISHA_KEY" ] && cat << 'AISHA_LOGIC'
    text = transcribe_aisha(audio_path)
    if text:
        print(text)
        return
AISHA_LOGIC
)
    text = transcribe_groq(audio_path)
    if text:
        print(text)
        return
    sys.exit(1)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(1)
    transcribe(sys.argv[1])
PYEOF

chmod +x "$BASE/transcribe.py"
chown aibot:aibot "$BASE/transcribe.py"
ok "transcribe.py создан"

# ─── Патч медиа-транскрипции (КРИТИЧНО) ───────────────────────
MEDIA_JS=$(find /usr/lib/node_modules/openclaw/dist -name "media-understanding.runtime-*.js" 2>/dev/null | head -1)

if [ -n "$MEDIA_JS" ]; then
    cp "$MEDIA_JS" "${MEDIA_JS}.bak"
    cat > "$MEDIA_JS" << 'JSEOF'
import { execSync } from 'child_process';
import path from 'path';

async function transcribeFirstAudio(params) {
  try {
    const ctx = params.ctx;
    const mediaPaths = Array.isArray(ctx.MediaPaths) ? ctx.MediaPaths : [];
    const mediaTypes = Array.isArray(ctx.MediaTypes) ? ctx.MediaTypes : [];
    const audioExtensions = ['.ogg','.mp3','.wav','.m4a','.webm','.mpeg','.mp4','.oga','.opus'];
    let audioPath = null;
    for (let i = 0; i < mediaPaths.length; i++) {
      const p = mediaPaths[i];
      const mime = mediaTypes[i] || '';
      const ext = path.extname(p || '').toLowerCase();
      if (audioExtensions.includes(ext) || mime.startsWith('audio/')) {
        audioPath = p;
        break;
      }
    }
    if (!audioPath) return undefined;
    const transcript = execSync(
      `python3 /home/aibot/.openclaw/transcribe.py "${audioPath}"`,
      { timeout: 60000, encoding: 'utf8', shell: '/bin/bash' }
    ).trim();
    if (transcript && transcript.length > 1) {
      return `[Голосовое сообщение пользователя (расшифровка): "${transcript}"]`;
    }
    return undefined;
  } catch (e) {
    return undefined;
  }
}

export { transcribeFirstAudio };
JSEOF
    ok "Голосовые сообщения: патч применён → $MEDIA_JS"
    # Сохраняем путь для будущего восстановления
    echo "$MEDIA_JS" > "$BASE/tools/.media_js_path"
else
    warn "media-understanding.runtime-*.js не найден — запусти patch-voice.sh после первого старта бота"
fi

# ─── 8. Systemd сервис ────────────────────────────────────────
step "8/8 Systemd сервис"

AIBOT_UID=$(id -u aibot)
mkdir -p /home/aibot/.config/systemd/user

cat > /home/aibot/.config/systemd/user/openclaw-gateway.service << EOF
[Unit]
Description=OpenCLAW Gateway (Jarvis)
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/openclaw gateway start
Restart=always
RestartSec=5
Environment="OPENROUTER_API_KEY=$OPENROUTER_KEY"
Environment="GROQ_API_KEY=$GROQ_KEY"
$([ -n "$AISHA_KEY" ] && echo "Environment=\"AISHA_API_KEY=$AISHA_KEY\"")
WorkingDirectory=/home/aibot/.openclaw

[Install]
WantedBy=default.target
EOF

chown -R aibot:aibot /home/aibot/.config
su -s /bin/bash aibot -c "XDG_RUNTIME_DIR=/run/user/$AIBOT_UID systemctl --user daemon-reload"
su -s /bin/bash aibot -c "XDG_RUNTIME_DIR=/run/user/$AIBOT_UID systemctl --user enable openclaw-gateway"
su -s /bin/bash aibot -c "XDG_RUNTIME_DIR=/run/user/$AIBOT_UID systemctl --user start openclaw-gateway"

sleep 3
STATUS=$(su -s /bin/bash aibot -c "XDG_RUNTIME_DIR=/run/user/$AIBOT_UID systemctl --user is-active openclaw-gateway" 2>/dev/null || echo "unknown")

if [ "$STATUS" = "active" ]; then
    ok "Сервис запущен!"
else
    warn "Сервис не активен (статус: $STATUS) — проверь: journalctl --user -u openclaw-gateway -n 30"
fi

# ─── Готово! ──────────────────────────────────────────────────
echo ""
echo -e "${G}╔═══════════════════════════════════════════════╗"
echo -e "║     ✅  ДЖАРВИС УСТАНОВЛЕН УСПЕШНО!           ║"
echo -e "╚═══════════════════════════════════════════════╝${N}"
echo ""
echo -e "  Бот:     @$BOT_USERNAME"
echo -e "  Хозяин:  $OWNER_NAME (ID: $OWNER_TELEGRAM_ID)"
echo -e "  Модель:  $AI_MODEL"
echo ""
echo -e "${Y}Следующий шаг:${N}"
echo -e "  1. Напиши своему боту в Telegram: /start"
echo -e "  2. Отправь голосовое сообщение — проверь что расшифрует"
echo ""
echo -e "${C}Управление сервисом (от root):${N}"
echo -e "  Статус:     su -s /bin/bash aibot -c \"XDG_RUNTIME_DIR=/run/user/$AIBOT_UID systemctl --user status openclaw-gateway\""
echo -e "  Рестарт:    su -s /bin/bash aibot -c \"XDG_RUNTIME_DIR=/run/user/$AIBOT_UID systemctl --user restart openclaw-gateway\""
echo -e "  Логи:       journalctl --user-unit=openclaw-gateway -f"
echo ""
