#!/usr/bin/env bash
# Проверка утечек: реальные токены в репозитории — самая дорогая ошибка при раздаче ученикам.
source "$QA_ROOT/lib/harness.sh"

section "4. Секреты и приватные данные"

leaked=0
scan() {  # scan <regex> <название> <что делать>
    local hits
    hits=$(project_files | grep -vE '^qa/|\.example$|^\.claude/' \
        | while IFS= read -r f; do
            [ -f "$PROJECT_ROOT/$f" ] || continue
            grep -nE -- "$1" "$PROJECT_ROOT/$f" 2>/dev/null | sed "s|^|$f:|" | head -2
          done | head -5)
    if [ -n "$hits" ]; then
        leaked=1
        fail_with BLOCKER "секреты" "В репозитории лежит $2" \
            "$(printf '%s' "$hits" | cut -c1-200 | tr '\n' ' ')" \
            "$3"
    fi
}

scan '[0-9]{8,10}:AA[A-Za-z0-9_-]{30,}' "настоящий токен Telegram-бота" \
     "Немедленно: @BotFather → /revoke → новый токен. Старый уже скомпрометирован, его видит весь GitHub."
scan 'sk-or-v1-[A-Za-z0-9]{40,}'        "настоящий ключ OpenRouter" \
     "Удалить ключ на openrouter.ai и выпустить новый. Списания идут на вашу карту."
scan 'gsk_[A-Za-z0-9]{40,}'             "настоящий ключ Groq" \
     "Отозвать ключ в console.groq.com и выпустить новый."
scan 'sk-[A-Za-z0-9]{40,}'              "настоящий ключ OpenAI" \
     "Отозвать ключ на platform.openai.com."
scan 'AIza[A-Za-z0-9_-]{30,}'           "настоящий ключ Google API" \
     "Отозвать в Google Cloud Console."
scan 'BEGIN [A-Z ]*PRIVATE KEY' "приватный ключ" \
     "Удалить файл, перевыпустить ключ, добавить в .gitignore."

[ $leaked -eq 0 ] && pass "реальных токенов в коде не найдено"

# 4.2 .env под гитом
while IFS= read -r f; do
    [ -z "$f" ] && continue
    fail_with BLOCKER "секреты" "Файл $f закоммичен в git" \
        "Это личный конфиг с токенами — он не должен попадать в репозиторий." \
        "git rm --cached $f && echo '$f' >> .gitignore  — и обязательно перевыпустить все токены оттуда."
done < <(project_files | grep -E '(^|/)\.env$|(^|/)jarvis\.env$' || true)

# 4.3 .gitignore защищает конфиги
for ex in $(project_files | grep -E 'env\.example$'); do
    real="${ex%.example}"
    dir=$(dirname "$ex"); [ "$dir" = "." ] && gi=".gitignore" || gi="$dir/.gitignore"
    base=$(basename "$real")
    if [ -f "$PROJECT_ROOT/$gi" ] && grep -q "$base" "$PROJECT_ROOT/$gi"; then
        pass "$base защищён в $gi"
    else
        fail_with MAJOR "секреты" "$base не защищён в .gitignore" \
            "Есть $ex, значит рядом будет живой $base с токенами. Если ученик или вы запушите репозиторий — токены утекут." \
            "Добавить строку '$base' в $gi"
    fi
done

# 4.4 Права на файлы с секретами в скриптах
if project_files | grep -qE '\.sh$' && ! grep -rqs 'chmod 600' "$PROJECT_ROOT"/*.sh 2>/dev/null; then
    if grep -rqsE 'TOKEN|API_KEY' "$PROJECT_ROOT"/*.sh 2>/dev/null; then
        finding MINOR "секреты" "Конфиг с токенами создаётся без chmod 600" \
            "Файл с токенами будет доступен всем пользователям сервера." \
            "После записи конфига: chmod 600 <файл>"
    fi
fi
