@echo off
REM Установка окружения для узбекской транскрибации на Windows
REM Требуется заранее установленный Python 3.10/3.11 (https://www.python.org/downloads/)
REM и ffmpeg (https://www.gyan.dev/ffmpeg/builds/ -> добавить bin в PATH).

echo ==^> Проверяю Python...
python --version || (echo Python не найден. Установи с https://www.python.org/downloads/ и включи "Add to PATH" & pause & exit /b 1)

echo ==^> Проверяю ffmpeg...
ffmpeg -version >nul 2>&1 || (echo ВНИМАНИЕ: ffmpeg не найден в PATH. Скачай с https://www.gyan.dev/ffmpeg/builds/ ^(ffmpeg-release-essentials^), распакуй и добавь папку bin в PATH.)

echo ==^> Создаю виртуальное окружение .venv...
python -m venv .venv
call .venv\Scripts\activate.bat

echo ==^> Ставлю зависимости...
python -m pip install --upgrade pip
pip install -r requirements.txt

echo.
echo Готово! Теперь запусти:
echo   .venv\Scripts\activate.bat
echo   python transcribe.py "C:\Users\ТВОЁ_ИМЯ\Downloads\yusuf sotuv.mp4"
pause
