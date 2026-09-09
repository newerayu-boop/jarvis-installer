#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
#  QA HARNESS — общие функции для всех проверок
#  Подключается так:  source "$QA_ROOT/lib/harness.sh"
# ══════════════════════════════════════════════════════════════

# --- Пути ------------------------------------------------------
QA_ROOT="${QA_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$QA_ROOT/.." && pwd)}"
QA_REPORT_DIR="${QA_REPORT_DIR:-$QA_ROOT/report}"
QA_FINDINGS="${QA_FINDINGS:-$QA_REPORT_DIR/findings.tsv}"
mkdir -p "$QA_REPORT_DIR"

# --- Цвета (отключаются, если вывод не в терминал) -------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    C_R='\033[0;31m'; C_G='\033[0;32m'; C_Y='\033[1;33m'
    C_B='\033[0;34m'; C_D='\033[0;90m'; C_N='\033[0m'
else
    C_R=''; C_G=''; C_Y=''; C_B=''; C_D=''; C_N=''
fi

# --- Уровни серьёзности ---------------------------------------
#  BLOCKER  — ученик не сможет пользоваться вообще, релиз стоп
#  MAJOR    — сломается у части учеников или в частом сценарии
#  MINOR    — косметика, неудобство, но продукт работает
#  QUESTION — не баг: ученик обязательно спросит, нужен ответ в FAQ

_esc() { printf '%s' "$1" | tr '\t\n' '  ' ; }

# finding <SEVERITY> <AREA> <TITLE> <DETAIL> <FIX>
finding() {
    printf '%s\t%s\t%s\t%s\t%s\n' \
        "$(_esc "$1")" "$(_esc "$2")" "$(_esc "$3")" "$(_esc "$4")" "$(_esc "$5")" \
        >> "$QA_FINDINGS"
    case "$1" in
        BLOCKER)  printf "${C_R}  ✗ [BLOCKER] %s${C_N}\n" "$3" ;;
        MAJOR)    printf "${C_R}  ✗ [MAJOR]   %s${C_N}\n" "$3" ;;
        MINOR)    printf "${C_Y}  ⚠ [MINOR]   %s${C_N}\n" "$3" ;;
        QUESTION) printf "${C_B}  ? [ВОПРОС]  %s${C_N}\n" "$3" ;;
        *)        printf "  · [%s] %s\n" "$1" "$3" ;;
    esac
}

# --- Счётчики проверок ----------------------------------------
QA_PASS=0; QA_FAIL=0; QA_SKIP=0

pass() { QA_PASS=$((QA_PASS+1)); printf "${C_G}  ✓${C_N} %s\n" "$1"; }
skip() { QA_SKIP=$((QA_SKIP+1)); printf "${C_D}  – пропущено: %s${C_N}\n" "$1"; }
fail() { QA_FAIL=$((QA_FAIL+1)); }

# fail_with <SEVERITY> <AREA> <TITLE> <DETAIL> <FIX>
fail_with() { fail; finding "$@"; }

section() { printf "\n${C_B}━━━ %s ━━━${C_N}\n" "$1"; }

# --- Детект типа проекта --------------------------------------
# Возвращает список: node, shell, python, next, vercel, docker, telegram-bot
detect_stack() {
    local d="${1:-$PROJECT_ROOT}" stack=""
    [ -n "$(find "$d" -maxdepth 3 -name package.json -not -path '*/node_modules/*' -print -quit 2>/dev/null)" ] && stack="$stack node"
    [ -n "$(find "$d" -maxdepth 3 -name '*.sh' -not -path '*/node_modules/*' -print -quit 2>/dev/null)" ] && stack="$stack shell"
    [ -n "$(find "$d" -maxdepth 3 -name '*.py' -not -path '*/node_modules/*' -print -quit 2>/dev/null)" ] && stack="$stack python"
    [ -n "$(find "$d" -maxdepth 3 -name 'next.config.*' -print -quit 2>/dev/null)" ] && stack="$stack next"
    [ -n "$(find "$d" -maxdepth 3 -name 'vercel.json' -print -quit 2>/dev/null)" ] && stack="$stack vercel"
    [ -n "$(find "$d" -maxdepth 3 -name 'Dockerfile' -print -quit 2>/dev/null)" ] && stack="$stack docker"
    grep -rqsl --include='*.js' --include='*.ts' --include='*.py' -e 'telegraf' -e 'api.telegram.org' -e 'python-telegram-bot' "$d" 2>/dev/null && stack="$stack telegram-bot"
    printf '%s' "${stack# }"
}

# --- Список файлов проекта (без мусора) -----------------------
project_files() {
    if git -C "$PROJECT_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
        git -C "$PROJECT_ROOT" ls-files
    else
        (cd "$PROJECT_ROOT" && find . -type f \
            -not -path './.git/*' -not -path '*/node_modules/*' \
            -not -path './qa/report/*' | sed 's|^\./||')
    fi
}
