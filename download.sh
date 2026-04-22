#!/bin/bash
# download.sh — скачивает установщик Jarvis на сервер
# Использование: curl -sSL URL | bash

set -e
G='\033[0;32m'; Y='\033[1;33m'; N='\033[0m'

echo -e "${Y}Скачиваю Jarvis Installer...${N}"

# Скачать архив с GitHub (замени на свой URL после публикации)
REPO_URL="https://github.com/ТВОЙ_GITHUB/jarvis-installer"

if command -v git &>/dev/null; then
    git clone "$REPO_URL" jarvis-installer
else
    apt-get install -y -q git
    git clone "$REPO_URL" jarvis-installer
fi

cd jarvis-installer
chmod +x install.sh patch-voice.sh

echo -e "${G}✓ Установщик готов!${N}"
echo ""
echo "Следующий шаг:"
echo "  cd jarvis-installer"
echo "  cp jarvis.env.example jarvis.env"
echo "  nano jarvis.env        # заполни свои токены"
echo "  bash install.sh"
