#!/usr/bin/env bash
# Установка окружения для узбекской транскрибации (macOS / Linux)
set -e

echo "==> Проверяю ffmpeg..."
if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg не найден."
  if command -v brew >/dev/null 2>&1; then
    echo "Ставлю через brew..."
    brew install ffmpeg
  else
    echo "Установи ffmpeg вручную: https://ffmpeg.org/download.html"
    exit 1
  fi
fi

echo "==> Создаю виртуальное окружение .venv..."
python3 -m venv .venv
# shellcheck disable=SC1091
source .venv/bin/activate

echo "==> Обновляю pip и ставлю зависимости..."
pip install --upgrade pip
pip install -r requirements.txt

echo ""
echo "Готово! Теперь запусти:"
echo "  source .venv/bin/activate"
echo "  python3 transcribe.py \"/Users/ТВОЁ_ИМЯ/Downloads/yusuf sotuv.mp4\""
