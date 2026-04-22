#!/bin/bash
# patch-voice.sh — восстанавливает патч голосовых после обновления openclaw
# Запускать: bash patch-voice.sh  (после npm update openclaw)

set -e
G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; N='\033[0m'

MEDIA_JS=$(find /usr/lib/node_modules/openclaw/dist -name "media-understanding.runtime-*.js" 2>/dev/null | head -1)
[ -z "$MEDIA_JS" ] && echo -e "${R}Файл media-understanding.runtime-*.js не найден${N}" && exit 1

# Проверяем — уже пропатчен?
if grep -q "transcribe.py" "$MEDIA_JS" 2>/dev/null; then
    echo -e "${Y}Патч уже применён: $MEDIA_JS${N}"
    exit 0
fi

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

echo -e "${G}✓ Патч применён: $MEDIA_JS${N}"

# Перезапуск
AIBOT_UID=$(id -u aibot 2>/dev/null || echo "1001")
su -s /bin/bash aibot -c "XDG_RUNTIME_DIR=/run/user/$AIBOT_UID systemctl --user restart openclaw-gateway" 2>/dev/null \
    && echo -e "${G}✓ Gateway перезапущен${N}" \
    || echo -e "${Y}⚠ Перезапусти gateway вручную${N}"
