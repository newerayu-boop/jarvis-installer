#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
#  QA RUN — один запуск = полная проверка продукта перед выдачей ученикам
#
#  Запуск:   bash qa/run.sh
#  Результат: qa/report/BUGS.md  +  код выхода (0 = можно отдавать)
#
#  Коды выхода:
#    0 — блокеров нет, продукт можно отдавать ученикам
#    1 — есть BLOCKER или MAJOR, отдавать нельзя
# ══════════════════════════════════════════════════════════════
set -uo pipefail

QA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$QA_ROOT/.." && pwd)"
export QA_ROOT PROJECT_ROOT

source "$QA_ROOT/lib/harness.sh"

: > "$QA_FINDINGS"
START=$(date +%s)

printf "${C_B}"
cat <<'BANNER'
╔══════════════════════════════════════════════════╗
║   QA-АГЕНТ · проверка продукта перед учениками   ║
╚══════════════════════════════════════════════════╝
BANNER
printf "${C_N}"
echo "Проект: $PROJECT_ROOT"
echo "Стек:   $(detect_stack)"
echo "Файлов: $(project_files | wc -l | tr -d ' ')"

# ── Прогон всех проверок ──────────────────────────────────────
ONLY="${1:-}"
for check in "$QA_ROOT"/checks/*.sh; do
    [ -f "$check" ] || continue
    name=$(basename "$check" .sh)
    if [ -n "$ONLY" ] && [[ "$name" != *"$ONLY"* ]]; then continue; fi
    # каждая проверка в подоболочке: падение одной не роняет прогон
    # shellcheck disable=SC1090
    ( source "$check" ) || printf "${C_Y}  ⚠ проверка %s завершилась с ошибкой${C_N}\n" "$name"
done

# ── Сводка ────────────────────────────────────────────────────
count() { local n; n=$(grep -c "^$1	" "$QA_FINDINGS" 2>/dev/null) || n=0; printf '%s' "${n:-0}"; }
N_BLOCK=$(count BLOCKER); N_MAJOR=$(count MAJOR); N_MINOR=$(count MINOR); N_Q=$(count QUESTION)
ELAPSED=$(( $(date +%s) - START ))

section "ИТОГ"
printf "  ${C_R}Блокеры:${C_N}          %s\n" "$N_BLOCK"
printf "  ${C_R}Серьёзные:${C_N}        %s\n" "$N_MAJOR"
printf "  ${C_Y}Мелкие:${C_N}           %s\n" "$N_MINOR"
printf "  ${C_B}Вопросы учеников:${C_N} %s\n" "$N_Q"
printf "  Время: %s c\n" "$ELAPSED"

# ── Отчёт в Markdown ──────────────────────────────────────────
REPORT="$QA_REPORT_DIR/BUGS.md"
{
    echo "# Отчёт QA-агента"
    echo
    echo "**Проект:** \`$(basename "$PROJECT_ROOT")\` · **Дата:** $(date '+%Y-%m-%d %H:%M') · **Проверка заняла:** ${ELAPSED} с"
    echo
    if [ "$N_BLOCK" -gt 0 ] || [ "$N_MAJOR" -gt 0 ]; then
        echo "## ❌ Отдавать ученикам ещё нельзя"
    else
        echo "## ✅ Блокеров нет — можно отдавать ученикам"
    fi
    echo
    echo "| | Найдено |"
    echo "|---|---|"
    echo "| 🔴 Блокеры (ученик вообще не сможет) | $N_BLOCK |"
    echo "| 🟠 Серьёзные (сломается у части учеников) | $N_MAJOR |"
    echo "| 🟡 Мелкие (неудобно, но работает) | $N_MINOR |"
    echo "| 🔵 Вопросы, которые задаст ученик | $N_Q |"
    echo

    n=0
    emit_section() {   # emit_section <SEVERITY> <заголовок>
        grep "^$1	" "$QA_FINDINGS" >/dev/null 2>&1 || return 0
        echo "---"; echo; echo "## $2"; echo
        while IFS=$'\t' read -r sev area title detail fix; do
            [ "$sev" = "$1" ] || continue
            n=$((n+1))
            printf '### %s. %s\n\n' "$n" "$title"
            printf '**Где:** `%s`\n\n' "$area"
            printf '**Что произойдёт у ученика:** %s\n\n' "$detail"
            printf '**Как чинить:** %s\n\n' "$fix"
        done < "$QA_FINDINGS"
    }
    emit_section BLOCKER "🔴 Блокеры — чинить до выдачи"
    emit_section MAJOR   "🟠 Серьёзные — сломается у части учеников"
    emit_section MINOR   "🟡 Мелкие"

    if grep -q "^QUESTION	" "$QA_FINDINGS" 2>/dev/null; then
        echo "---"; echo
        echo "## 🔵 Вопросы, которые ученики зададут — подготовьте ответы заранее"
        echo
        while IFS=$'\t' read -r sev area title detail fix; do
            [ "$sev" = "QUESTION" ] || continue
            printf -- '- **%s** (`%s`)\n  - Почему спросят: %s\n  - Что сделать заранее: %s\n' "$title" "$area" "$detail" "$fix"
        done < "$QA_FINDINGS"
        echo
    fi

    echo "---"; echo
    echo "_Сформировано автоматически: \`bash qa/run.sh\`_"
} > "$REPORT"

echo
printf "  Отчёт: ${C_G}%s${C_N}\n" "$REPORT"

if [ "$N_BLOCK" -gt 0 ] || [ "$N_MAJOR" -gt 0 ]; then
    printf "\n${C_R}✗ Продукт отдавать ученикам рано — сначала почините список выше.${C_N}\n\n"
    exit 1
fi
printf "\n${C_G}✓ Блокеров нет — продукт можно отдавать ученикам.${C_N}\n\n"
exit 0
