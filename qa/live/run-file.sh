#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
#  ЖИВОЙ ПРОГОН ПЕРЕДАННОГО ФАЙЛА
#
#  Берёт архив или папку, распаковывает в песочницу, читает
#  инструкцию и ВЫПОЛНЯЕТ её шаги, а не пересказывает.
#  Находит Telegram-бота — поднимает и ведёт с ним переписку.
#
#  Запуск:  bash qa/live/run-file.sh <архив-или-папка>
# ══════════════════════════════════════════════════════════════
set -uo pipefail

QA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(cd "$QA_ROOT/.." && pwd)"
SRC="${1:-}"
[ -z "$SRC" ] && { echo "Укажите файл или папку: bash qa/live/run-file.sh <путь>"; exit 2; }
[ -e "$SRC" ] || { echo "Не найдено: $SRC"; exit 2; }

C_G=$'\033[0;32m'; C_R=$'\033[0;31m'; C_Y=$'\033[1;33m'; C_B=$'\033[0;34m'; C_D=$'\033[0;90m'; C_N=$'\033[0m'
[ -n "${NO_COLOR:-}" ] && { C_G=; C_R=; C_Y=; C_B=; C_D=; C_N=; }

SANDBOX=$(mktemp -d -t livetest-XXXXXX)
REPORT="${LIVE_REPORT:-$QA_ROOT/report/ЖИВОЙ-ПРОГОН.md}"
mkdir -p "$(dirname "$REPORT")"
STEPS=$(mktemp)      # статус<TAB>команда<TAB>результат

step()  { printf '%s\t%s\t%s\n' "$1" "$2" "$(printf '%s' "$3" | tr '\t\n' '  ' | cut -c1-300)" >> "$STEPS"; }
ok()    { printf "${C_G}  ✓${C_N} %s\n" "$1"; }
bad()   { printf "${C_R}  ✗${C_N} %s\n" "$1"; }
warn()  { printf "${C_Y}  ⚠${C_N} %s\n" "$1"; }
info()  { printf "${C_D}    %s${C_N}\n" "$1"; }
title() { printf "\n${C_B}━━━ %s ━━━${C_N}\n" "$1"; }

printf "${C_B}"
cat <<'BANNER'
╔══════════════════════════════════════════════════╗
║   ЖИВОЙ ПРОГОН · выполняю инструкцию из файла    ║
╚══════════════════════════════════════════════════╝
BANNER
printf "${C_N}Файл: %s\nПесочница: %s\n" "$SRC" "$SANDBOX"

# ── 1. Распаковка ─────────────────────────────────────────────
title "1. Распаковка"
case "$SRC" in
    *.zip) unzip -q -O UTF-8 "$SRC" -d "$SANDBOX" 2>/dev/null || unzip -q "$SRC" -d "$SANDBOX" ;;
    *.tar.gz|*.tgz) tar xzf "$SRC" -C "$SANDBOX" ;;
    *.tar) tar xf "$SRC" -C "$SANDBOX" ;;
    *) if [ -d "$SRC" ]; then cp -r "$SRC" "$SANDBOX/"; else cp "$SRC" "$SANDBOX/"; fi ;;
esac
# если внутри одна папка — работаем в ней
inner=$(find "$SANDBOX" -mindepth 1 -maxdepth 1 -type d | head -2)
[ "$(printf '%s\n' "$inner" | wc -l)" = "1" ] && [ -n "$inner" ] && WORK="$inner" || WORK="$SANDBOX"
NFILES=$(find "$WORK" -type f | wc -l | tr -d ' ')
ok "распаковано, файлов: $NFILES"
step ok "распаковка" "$NFILES файлов в $WORK"

# ── 2. Что это за продукт ─────────────────────────────────────
title "2. Что внутри"
HAS_NODE=$(find "$WORK" -name package.json -not -path '*/node_modules/*' | head -1)
HAS_SH=$(find "$WORK" -name '*.sh' | head -1)
HAS_TG=$(grep -rlsE 'telegraf|api\.telegram\.org|python-telegram-bot' "$WORK" --include='*.js' --include='*.ts' --include='*.py' 2>/dev/null | head -1)
HAS_CLAUDE=$(find "$WORK" -type d -name '.claude' | head -1)
[ -n "$HAS_NODE" ]   && ok "Node-проект: $(dirname "${HAS_NODE#$WORK/}")"
[ -n "$HAS_SH" ]     && ok "есть shell-скрипты"
[ -n "$HAS_TG" ]     && ok "есть Telegram-бот: ${HAS_TG#$WORK/}"
[ -n "$HAS_CLAUDE" ] && ok "набор агентов и навыков Claude Code"

# ── 3. Главная инструкция ─────────────────────────────────────
title "3. Инструкция, по которой пойдём"
ENTRY=""
for cand in НАЧНИ-ОТСЮДА.md НАЧНИ_ОТСЮДА.md START.md README.md ЧИТАЙ-МЕНЯ.md МИНИ-ГАЙД.md INSTALL.md; do
    f=$(find "$WORK" -maxdepth 2 -name "$cand" | head -1)
    [ -n "$f" ] && { ENTRY="$f"; break; }
done
[ -z "$ENTRY" ] && ENTRY=$(find "$WORK" -maxdepth 2 -name '*.md' | head -1)
if [ -z "$ENTRY" ]; then
    bad "инструкции не нашлось — ученику тоже не с чего начать"
    step fail "поиск инструкции" "нет ни README, ни НАЧНИ-ОТСЮДА"
else
    ok "иду по: ${ENTRY#$WORK/}"
    step ok "поиск инструкции" "${ENTRY#$WORK/}"
fi

# ── 4. Выполняем команды из инструкции ────────────────────────
title "4. Выполняю команды из инструкции"
CMDS=$(mktemp)
PROMPTS="$(dirname "$REPORT")/промпты-для-агента.txt"
: > "$PROMPTS"
if [ -n "$ENTRY" ]; then
    awk '/^```/{f=!f;next} f' "$ENTRY" | grep -vE '^\s*#|^\s*$' | head -40 > "$CMDS"
fi
NCMD=$(wc -l < "$CMDS" | tr -d ' ')
info "команд в инструкции: $NCMD"

run_safe() {   # run_safe <команда>
    local cmd="$1" out rc
    out=$(cd "$WORK" && timeout 120 bash -c "$cmd" 2>&1); rc=$?
    if [ $rc -eq 0 ]; then ok "$cmd"; step ok "$cmd" "$out"
    else bad "$cmd"; info "$(printf '%s' "$out" | tail -2 | tr '\n' ' ' | cut -c1-160)"; step fail "$cmd" "$out"; fi
}

while IFS= read -r cmd; do
    [ -z "$cmd" ] && continue
    case "$cmd" in
        # разрушающее или меняющее систему — не выполняем никогда
        *rm\ -rf*|*mkfs*|*dd\ if=*|*shutdown*|*reboot*|*:\(\)\{*)
            warn "пропущено, разрушающая команда: $cmd"; step skip "$cmd" "разрушающая, не выполняется" ;;
        apt-get*|apt\ *|sudo*|useradd*|systemctl*|loginctl*|npm\ install\ -g*|pip3\ install*|curl*\|*bash*)
            warn "пропущено, меняет систему: $cmd"
            info "такое выполняется только на отдельном сервере"
            step skip "$cmd" "меняет систему, нужен отдельный сервер" ;;
        ssh\ *|nano\ *|vim\ *|open\ *)
            info "шаг делается руками: $cmd"; step manual "$cmd" "ручной шаг ученика" ;;
        cp\ *|mkdir\ *|cd\ *|ls*|cat\ *|npm\ install|npm\ ci|npm\ start|node\ *|bash\ *|python3\ *|chmod\ *)
            run_safe "$cmd" ;;
        *)
            # Не shell-команда. Для продуктов на Claude Code это и есть
            # рабочий ввод: «диагностика», «разбери заявку: …».
            # Такие шаги выполняет агент live-runner, здесь их собираем.
            if [ -n "$HAS_CLAUDE" ]; then
                printf '%s\n' "$cmd" >> "$PROMPTS"
                info "фраза для Claude, отдаю агенту: $cmd"
                step prompt "$cmd" "выполняется агентом live-runner"
            else
                info "не распознано, пропускаю: $cmd"; step skip "$cmd" "не распознано"
            fi ;;
    esac
done < "$CMDS"

# ── 5. Node-проект: ставим и поднимаем ────────────────────────
if [ -n "$HAS_NODE" ]; then
    title "5. Поднимаю Node-проект"
    PDIR=$(dirname "$HAS_NODE")
    if (cd "$PDIR" && timeout 300 npm install --no-audit --no-fund >/dev/null 2>&1); then
        ok "зависимости ставятся на чистой машине"; step ok "npm install" "успешно"
    else
        bad "npm install падает"; step fail "npm install" "ученик встанет здесь"
    fi
fi

# ── 6. Telegram-бот: поднимаем и переписываемся ───────────────
if [ -n "$HAS_TG" ] && [ -n "$HAS_NODE" ]; then
    title "6. Поднимаю бота и веду с ним переписку"
    PDIR=$(dirname "$HAS_NODE")
    ENTRYJS=""
    for c in src/bot.js src/index.js bot.js index.js; do
        [ -f "$PDIR/$c" ] && { ENTRYJS="$PDIR/$c"; break; }
    done
    WEBHOOK=$(find "$PDIR" -path '*api/webhook.js' -not -path '*/node_modules/*' | head -1)
    OUTDIR="$(dirname "$REPORT")/live-файл"
    if [ -n "$WEBHOOK" ]; then
        LIVE_OUT="$OUTDIR" node "$QA_ROOT/live/tg-harness.js" --webhook "$WEBHOOK" 2>&1 | grep -vE 'punycode|trace-deprecation' | tail -30
        step $([ ${PIPESTATUS[0]} -eq 0 ] && echo ok || echo fail) "живой прогон бота (вебхук)" "см. переписку"
    elif [ -n "$ENTRYJS" ]; then
        LIVE_OUT="$OUTDIR" node "$QA_ROOT/live/tg-harness.js" --polling "$ENTRYJS" 2>&1 | grep -vE 'punycode|trace-deprecation' | tail -30
        step $([ ${PIPESTATUS[0]} -eq 0 ] && echo ok || echo fail) "живой прогон бота" "см. переписку"
    else
        warn "точка входа бота не найдена"; step fail "живой прогон бота" "не нашёл, с чего запускать"
    fi
fi

# ── 7. Статические проверки поверх ────────────────────────────
title "7. Проверки по файлам"
NO_COLOR=1 bash "$QA_ROOT/run.sh" "$WORK" 2>&1 | sed -n '/ИТОГ/,+5p'

# ── 8. Отчёт ──────────────────────────────────────────────────
n_ok=$(grep -c '^ok'     "$STEPS" 2>/dev/null || true);   n_ok=${n_ok:-0}
n_fail=$(grep -c '^fail' "$STEPS" 2>/dev/null || true); n_fail=${n_fail:-0}
n_skip=$(grep -c '^skip' "$STEPS" 2>/dev/null || true); n_skip=${n_skip:-0}
n_man=$(grep -c '^manual' "$STEPS" 2>/dev/null || true); n_man=${n_man:-0}
n_pr=$(grep -c '^prompt' "$STEPS" 2>/dev/null || true); n_pr=${n_pr:-0}

{
  echo "# Живой прогон переданного файла"
  echo
  echo "**Файл:** \`$(basename "$SRC")\` · **Дата:** $(date '+%Y-%m-%d %H:%M')"
  echo
  echo "Шаги инструкции выполнялись по-настоящему в изолированной песочнице."
  echo
  echo "| | Шагов |"
  echo "|---|---|"
  echo "| Выполнено успешно | $n_ok |"
  echo "| Упало | $n_fail |"
  echo "| Пропущено (меняет систему или разрушает) | $n_skip |"
  echo "| Ручной шаг ученика | $n_man |"
  echo "| Фраз для Claude (выполняет агент) | $n_pr |"
  echo
  if [ "$n_fail" -gt 0 ]; then
    echo "## Что упало"; echo
    awk -F'\t' '$1=="fail"{print "- `" $2 "`\n  - " $3}' "$STEPS"
    echo
  fi
  echo "## Что не выполнялось и почему"; echo
  awk -F'\t' '$1=="skip"||$1=="manual"{print "- `" $2 "` — " $3}' "$STEPS"
  if [ "$n_pr" -gt 0 ]; then
    echo
    echo "## Фразы, которые ученик напечатает Claude"; echo
    echo "Их выполняет агент \`live-runner\`, потому что это работа с ассистентом, а не с терминалом."; echo
    awk -F'\t' '$1=="prompt"{print "- `" $2 "`"}' "$STEPS"
  fi
  echo
  echo "## Полный список шагов"; echo
  awk -F'\t' '{printf "%s `%s`\n", ($1=="ok"?"✅":$1=="fail"?"❌":"⏭"), $2}' "$STEPS"
  echo
  echo "_Переписка с ботом и билеты — в папке \`live-файл\` рядом с этим отчётом._"
} > "$REPORT"

title "ИТОГ"
printf "  Выполнено: %s · упало: %s · пропущено: %s · вручную: %s · фраз для Claude: %s\n" "$n_ok" "$n_fail" "$n_skip" "$n_man" "$n_pr"
[ "$n_pr" -gt 0 ] && printf "  Фразы для агента: ${C_G}%s${C_N}\n" "$PROMPTS"
printf "  Отчёт: ${C_G}%s${C_N}\n" "$REPORT"
printf "  Песочница осталась тут: %s\n\n" "$WORK"
[ "$n_fail" -gt 0 ] && exit 1 || exit 0
