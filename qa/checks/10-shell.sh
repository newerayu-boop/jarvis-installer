#!/usr/bin/env bash
# Проверка bash-скриптов: синтаксис + типичные грабли установщиков.
source "$QA_ROOT/lib/harness.sh"

section "1. Bash-скрипты"

mapfile -t SCRIPTS < <(project_files | grep -E '\.sh$' | grep -v '^qa/' || true)
if [ ${#SCRIPTS[@]} -eq 0 ]; then skip "в проекте нет .sh файлов"; return 0 2>/dev/null || exit 0; fi

for f in "${SCRIPTS[@]}"; do
    p="$PROJECT_ROOT/$f"

    # 1.1 Синтаксис
    if err=$(bash -n "$p" 2>&1); then
        pass "$f — синтаксис"
    else
        fail_with BLOCKER "$f" "Синтаксическая ошибка в скрипте" \
            "bash -n сообщает: $err" \
            "Исправить синтаксис — сейчас скрипт не запустится вообще."
    fi

    # 1.2 shellcheck, если установлен
    if ! command -v shellcheck >/dev/null 2>&1; then
        [ -z "${SHELLCHECK_WARNED:-}" ] && {
            finding MINOR "окружение" "Проверка неполная: нет shellcheck" \
                "Линтер bash не установлен, поэтому часть проблем в .sh не искалась. Прогон выглядит чище, чем он есть." \
                "Поставить: apt-get install -y shellcheck (в macOS: brew install shellcheck). На GitHub он ставится сам."
            SHELLCHECK_WARNED=1
        }
    fi
    if command -v shellcheck >/dev/null 2>&1; then
        if out=$(shellcheck -S warning -f gcc "$p" 2>&1); then
            pass "$f — shellcheck"
        else
            fail_with MAJOR "$f" "shellcheck нашёл проблемы" \
                "$(printf '%s' "$out" | head -c 500)" \
                "Разобрать вывод shellcheck: $f"
        fi
    fi

    # 1.3 set -e без ловушки ошибок → ученик увидит обрыв без объяснения
    if grep -q '^set -e' "$p" && ! grep -q 'trap .* ERR' "$p"; then
        finding QUESTION "$f" "Скрипт падает молча при первой ошибке" \
            "Есть 'set -e', но нет 'trap ... ERR'. Если apt или npm упадёт, ученик увидит обрыв без объяснения и напишет вам «ничего не работает»." \
            "Добавить: trap 'echo \"Ошибка на строке \$LINENO. Пришлите этот текст в поддержку\"' ERR"
    fi

    # 1.4 sudo/root
    if grep -qE '^\s*(apt-get|apt|useradd|systemctl)' "$p" && ! grep -qE 'EUID|id -u' "$p"; then
        fail_with MAJOR "$f" "Нет проверки на root" \
            "Скрипт выполняет системные команды, но не проверяет, что запущен от root. Ученик запустит без sudo и получит гору 'Permission denied'." \
            "Добавить в начало: [ \"\$EUID\" -ne 0 ] && { echo 'Запусти: sudo bash $f'; exit 1; }"
    fi

    # 1.5 Захардкоженные пути в node_modules (ломаются на другом дистрибутиве).
    # Комментарии пропускаем: строка, объясняющая, почему так делать нельзя,
    # сама не является кодом.
    hits=$(grep -nE '/usr/(lib|local/lib)/node_modules' "$p" | grep -vE '^[0-9]+:\s*#' | head -3)
    if [ -n "$hits" ]; then
        fail_with MAJOR "$f" "Захардкожен путь к глобальным node_modules" \
            "$(printf '%s' "$hits" | tr '\n' ' ')" \
            "Использовать \$(npm root -g) вместо жёсткого пути — иначе на части VPS файл не найдётся."
    fi

    # 1.6 curl | bash без проверки скачанного
    if grep -qE 'curl .*\|\s*(bash|sh)' "$p"; then
        finding MINOR "$f" "curl | bash без проверки" \
            "Скачанный скрипт выполняется сразу. Если GitHub недоступен или отдал HTML-ошибку, ученик получит непонятный мусор." \
            "Скачивать в файл, проверять, что он непустой и начинается с #!, и только потом запускать."
    fi

    # 1.7 Переменные из env-файла подставляются в heredoc без экранирования
    if grep -qE "cat > .* << ?EOF" "$p" && grep -q 'source .*\.env' "$p"; then
        finding QUESTION "$f" "Токены подставляются в конфиг без экранирования" \
            "Значения из env-файла попадают в JSON/сервис-файл напрямую. Если ученик вставит токен с кавычкой, пробелом или скопирует его вместе с текстом — получится битый конфиг и непонятная ошибка." \
            "Проверять формат каждого ключа регуляркой до записи конфига."
    fi
done

# 1.8 Исполняемый бит
for f in "${SCRIPTS[@]}"; do
    if [ ! -x "$PROJECT_ROOT/$f" ] && head -1 "$PROJECT_ROOT/$f" | grep -q '^#!'; then
        finding MINOR "$f" "Нет исполняемого бита" \
            "Файл с shebang, но без chmod +x. Ученик напишет ./$f и получит 'Permission denied'." \
            "git update-index --chmod=+x $f  (или запускать строго через 'bash $f' и так и писать в инструкции)"
    fi
done
