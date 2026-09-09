#!/usr/bin/env bash
# Проверка Node-проектов: синтаксис, зависимости, загрузка модулей, unit-тесты.
source "$QA_ROOT/lib/harness.sh"

section "2. Node.js"

mapfile -t PKGS < <(project_files | grep -E '(^|/)package\.json$' || true)
if [ ${#PKGS[@]} -eq 0 ]; then skip "нет package.json"; return 0 2>/dev/null || exit 0; fi

for pkg in "${PKGS[@]}"; do
    dir="$PROJECT_ROOT/$(dirname "$pkg")"
    name="$(dirname "$pkg")"; [ "$name" = "." ] && name="(корень)"

    # 2.1 package.json — валидный JSON
    if node -e "JSON.parse(require('fs').readFileSync('$dir/package.json','utf8'))" 2>/dev/null; then
        pass "$name — package.json валиден"
    else
        fail_with BLOCKER "$pkg" "package.json — битый JSON" \
            "node не может разобрать файл." "Проверить запятые и кавычки в package.json."
        continue
    fi

    # 2.2 Версия Node
    req=$(node -p "try{require('$dir/package.json').engines?.node||''}catch(e){''}")
    if [ -n "$req" ]; then
        pass "$name — заявлена версия Node: $req"
    else
        finding QUESTION "$pkg" "Не указана версия Node" \
            "В package.json нет engines.node. Ученик поставит Node 12 из apt, проект не запустится, а ошибка будет невнятной." \
            "Добавить: \"engines\": { \"node\": \">=18\" } и написать в README, как поставить нужную версию."
    fi

    # 2.3 Синтаксис всех js-файлов
    syntax_ok=1
    while IFS= read -r js; do
        [ -z "$js" ] && continue
        if ! err=$(node --check "$PROJECT_ROOT/$js" 2>&1); then
            syntax_ok=0
            fail_with BLOCKER "$js" "Синтаксическая ошибка в JS" "$err" "Исправить синтаксис."
        fi
    done < <(project_files | grep -E '\.(js|mjs|cjs)$' | grep -v '^qa/' | grep -v node_modules)
    [ $syntax_ok -eq 1 ] && pass "$name — синтаксис всех .js"

    # 2.4 Зависимости установлены
    if [ ! -d "$dir/node_modules" ]; then
        printf "${C_D}  … ставлю зависимости в %s${C_N}\n" "$name"
        if ! (cd "$dir" && npm install --no-audit --no-fund >/dev/null 2>&1); then
            fail_with BLOCKER "$pkg" "npm install падает" \
                "Свежая установка зависимостей завершается ошибкой. У ученика на чистом сервере будет то же самое." \
                "Запустить 'npm install' вручную и разобрать ошибку. Проверить, что package-lock.json закоммичен."
            continue
        fi
    fi
    pass "$name — зависимости ставятся"

    # 2.5 Каждый модуль загружается (ловит битые require и падение на импорте)
    load_ok=1
    entry_main=$(node -p "try{require('$dir/package.json').main||''}catch(e){''}")
    while IFS= read -r js; do
        [ -z "$js" ] && continue
        case "$js" in
            */node_modules/*|qa/*) continue ;;
            */src/index.js|index.js|*/bin/*) continue ;;   # точки входа — они и должны запускаться
        esac
        [ "$js" = "$(dirname "$pkg")/$entry_main" ] && continue
        out=$(cd "$dir" && BOT_TOKEN="${BOT_TOKEN:-test:token}" node -e "require('$PROJECT_ROOT/$js')" 2>&1) || {
            case "$out" in
                *"is not set"*|*"listen"*|*"EADDRINUSE"*) : ;;  # ожидаемо для точек входа
                *) load_ok=0
                   fail_with MAJOR "$js" "Модуль падает при загрузке" \
                        "$(printf '%s' "$out" | head -c 300)" \
                        "Убрать побочные эффекты на верхнем уровне или починить импорт." ;;
            esac
        }
    done < <(cd "$dir" && find lib src api config.js -name '*.js' -not -path '*/node_modules/*' 2>/dev/null | sed "s|^|$(dirname "$pkg")/|" | sed 's|^\./||')
    [ $load_ok -eq 1 ] && pass "$name — все модули загружаются"

    # 2.6 Точка входа падает без переменных окружения — но понятно ли это ученику?
    entry=$(node -p "try{require('$dir/package.json').main||''}catch(e){''}")
    if [ -n "$entry" ] && [ -f "$dir/$entry" ]; then
        out=$(cd "$dir" && env -u BOT_TOKEN -u TELEGRAM_TOKEN timeout 15 node "$entry" 2>&1 | head -5)
        case "$out" in
            *"is not set"*|*"required"*|*"не задан"*|*"kerak"*) pass "$name — понятная ошибка без токена" ;;
            *)  finding MAJOR "$pkg" "Непонятная ошибка при запуске без токена" \
                    "Запуск без BOT_TOKEN даёт: $(printf '%s' "$out" | head -c 200)" \
                    "Выводить человеческую подсказку: «Не задан BOT_TOKEN. Скопируйте .env.example в .env и впишите токен от @BotFather»." ;;
        esac
    fi
done

# 2.7 Unit-тесты проекта
if [ -d "$QA_ROOT/tests" ] && [ -n "$(find "$QA_ROOT/tests" -name '*.test.js' -print -quit)" ]; then
    printf "${C_D}  … запускаю unit-тесты${C_N}\n"
    if out=$(cd "$PROJECT_ROOT" && node --test "$QA_ROOT/tests/**/*.test.js" 2>&1); then
        pass "unit-тесты: $(printf '%s' "$out" | grep -E '^# (pass|fail)' | tr '\n' ' ')"
    else
        while IFS= read -r line; do
            [ -z "$line" ] && continue
            fail_with MAJOR "unit-тест" "Падает тест: $line" \
                "$(printf '%s' "$out" | grep -A6 -F "$line" | head -c 400)" \
                "Починить поведение или обновить тест, если оно изменилось намеренно."
        done < <(printf '%s' "$out" | grep -E '^not ok [0-9]+ - ' | sed -E 's/^not ok [0-9]+ - //' | head -20)
        [ -z "$(printf '%s' "$out" | grep -E '^not ok ')" ] && fail_with MAJOR "unit-тесты" "Тесты завершились с ошибкой" "$(printf '%s' "$out" | tail -c 400)" "Запустить: node --test 'qa/tests/**/*.test.js'"
    fi
fi
