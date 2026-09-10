#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
#  СИМУЛЯТОР УЧЕНИКА
#  Проигрываем реальные ошибки новичка и смотрим, что он увидит.
#  Правило: если ученик ошибся, а продукт не объяснил ЧТО именно —
#  это баг продукта, а не ученика.
# ══════════════════════════════════════════════════════════════
source "$QA_ROOT/lib/harness.sh"

section "5. Симулятор ученика (сценарии типичных ошибок)"

INSTALLER="$PROJECT_ROOT/install.sh"
ENV_EXAMPLE="$PROJECT_ROOT/jarvis.env.example"

if [ ! -f "$INSTALLER" ] || [ ! -f "$ENV_EXAMPLE" ]; then
    skip "нет install.sh + jarvis.env.example — сценарии установщика неприменимы"
else

SANDBOX=$(mktemp -d)
trap 'rm -rf "$SANDBOX"' EXIT

# Вырезаем блок валидации конфига (всё до строки «Конфиг проверен»),
# чтобы прогонять его без реальной установки пакетов.
# Проверку на root убираем: она тестируется отдельно (сценарий 6), а здесь
# мешает — иначе на CI, где сборка идёт не от root, скрипт выходил бы сразу
# и все сценарии ниже «проходили» бы вхолостую.
sed -n '1,/Конфиг проверен/p' "$INSTALLER" \
    | grep -v 'EUID' > "$SANDBOX/validate.sh"

# Страховка: если блок валидации вырезался пустым или всё равно выходит
# раньше проверки конфига — сценарии ниже бессмысленны, и молчать об этом нельзя.
if ! grep -q 'Конфиг проверен' "$SANDBOX/validate.sh"; then
    fail_with MAJOR "qa/checks/50-student.sh" "Не удалось вырезать блок проверки конфига" \
        "Симулятор ученика не может прогнать сценарии установщика и молча пропустил бы их." \
        "Проверить, что в install.sh осталась строка ok \"Конфиг проверен\"."
    return 0 2>/dev/null || exit 0
fi

# run_student <файл-конфига> → печатает то, что увидит ученик
run_student() {
    (cd "$SANDBOX" && cp "$1" jarvis.env && timeout 20 bash validate.sh 2>&1 | tail -3)
}

# ── Сценарий 1: забыл переименовать jarvis.env.example ────────
out=$( (cd "$SANDBOX" && rm -f jarvis.env && timeout 20 bash validate.sh 2>&1 | tail -3) )
case "$out" in
    *"jarvis.env"*) pass "сценарий: забыл создать jarvis.env — сообщение понятное" ;;
    *) fail_with MAJOR "install.sh" "Не объяснено, что делать без jarvis.env" \
            "Ученик увидит: $(printf '%s' "$out" | head -c 200)" \
            "Показать точную команду: cp jarvis.env.example jarvis.env" ;;
esac

# ── Сценарий 2: оставил примеры-заглушки как есть ─────────────
cp "$ENV_EXAMPLE" "$SANDBOX/placeholders.env"
out=$(run_student "$SANDBOX/placeholders.env")
case "$out" in
    *"xxxx"*|*"заглушк"*|*"пример"*|*"замени"*|*"Заполни"*|*"не заполнен"*)
        pass "сценарий: оставил заглушки — установщик поймал" ;;
    *"Конфиг проверен"*)
        fail_with BLOCKER "install.sh" "Установщик принимает ключи-заглушки из примера" \
            "Ученик скопировал jarvis.env.example, ничего не поменял, и установка прошла «успешно». Бот установится и будет молчать. Ученик напишет: «всё установилось, но бот не отвечает» — и вы будете искать причину вслепую." \
            "Проверять формат каждого ключа: TELEGRAM_TOKEN по маске ^[0-9]{8,10}:AA, OPENROUTER_KEY по ^sk-or-v1-, GROQ_KEY по ^gsk_, OWNER_TELEGRAM_ID только цифры. И явно ругаться на значения с 'xxxx'." ;;
    *) finding QUESTION "install.sh" "Непонятная реакция на заглушки" "Вывод: $(printf '%s' "$out" | head -c 200)" "Проверить вручную." ;;
esac

# ── Сценарий 3: сохранил файл в Windows (CRLF) ────────────────
sed -e 's/my_jarvis_bot/realbot/' "$ENV_EXAMPLE" | sed 's/$/\r/' > "$SANDBOX/crlf.env"
out=$(run_student "$SANDBOX/crlf.env")
case "$out" in
    *"Конфиг проверен"*)
        fail_with MAJOR "install.sh" "Файл из Windows (CRLF) проходит проверку" \
            "Ученик редактировал jarvis.env в Блокноте на Windows и залил на сервер. В конце каждого значения останется символ \\r, токен станет битым, бот не запустится — а установщик скажет «успешно»." \
            "В начале install.sh: sed -i 's/\\r\$//' jarvis.env  (или проверять и явно сообщать про CRLF)." ;;
    *) pass "сценарий: CRLF-файл отловлен" ;;
esac

# ── Сценарий 4: вписал @username вместо числового Telegram ID ─
sed -e 's/OWNER_TELEGRAM_ID="123456789"/OWNER_TELEGRAM_ID="@myusername"/' \
    -e 's/xxxx*/REALKEY0000000000000000000000000000000000/g' "$ENV_EXAMPLE" > "$SANDBOX/username.env"
out=$(run_student "$SANDBOX/username.env")
case "$out" in
    *"Конфиг проверен"*)
        fail_with MAJOR "install.sh" "Принимается @username вместо числового ID" \
            "Очень частая ошибка новичка: в OWNER_TELEGRAM_ID он пишет свой @ник. Установка пройдёт, но бот не узнает хозяина." \
            "Проверять: [[ \"\$OWNER_TELEGRAM_ID\" =~ ^[0-9]+\$ ]] иначе подсказать «нужно число из @userinfobot, не @ник»." ;;
    *) pass "сценарий: @username вместо ID отловлен" ;;
esac

# ── Сценарий 5: токен со случайным пробелом при копировании ───
sed -e 's/TELEGRAM_TOKEN="/TELEGRAM_TOKEN=" /' "$ENV_EXAMPLE" > "$SANDBOX/space.env"
out=$(run_student "$SANDBOX/space.env")
case "$out" in
    *"Конфиг проверен"*)
        finding MAJOR "install.sh" "Пробел в начале токена не отлавливается" \
            "При копировании из Telegram часто прилипает пробел или перевод строки. Бот не запустится, ошибка будет только в логах." \
            "Обрезать пробелы: TELEGRAM_TOKEN=\$(echo \"\$TELEGRAM_TOKEN\" | xargs) — и проверять маску." ;;
    *) pass "сценарий: лишний пробел в токене отловлен" ;;
esac

# ── Сценарий 6: запуск не от root ─────────────────────────────
if grep -q 'EUID' "$INSTALLER"; then
    pass "сценарий: запуск без root — проверка есть"
else
    fail_with MAJOR "install.sh" "Нет проверки root" "Ученик получит поток 'Permission denied'." "Добавить проверку EUID в начало."
fi

# ── Сценарий 7: повторный запуск установщика ──────────────────
if grep -qE 'id "aibot"|id aibot|if ! id' "$INSTALLER"; then
    pass "сценарий: повторный запуск — пользователь не пересоздаётся"
else
    finding MAJOR "install.sh" "Установщик не идемпотентен" \
        "Ученик почти всегда запускает установку второй раз. Если скрипт не переживает повтор — он сломает то, что уже работало." \
        "Все шаги делать безопасными для повтора (проверять, что уже создано)."
fi

fi  # конец блока установщика

# ── Сценарий 8: ученик вводит данные «как получится» ──────────
# Проверяем реальный парсер ввода, если он есть.
PARSER=$(project_files | grep -E 'lib/messages\.js$' | head -1)
if [ -n "$PARSER" ]; then
    out=$(cd "$PROJECT_ROOT" && node -e "
      const {parseInput} = require('./$PARSER');
      const cases = [
        ['Ism Familiya #13','номер со знаком #'],
        ['13 Ism Familiya','сначала номер, потом имя'],
        ['Ism Familiya - 13','имя и номер через тире'],
        ['Ism Familiya 13 🔥','тариф с эмодзи'],
      ];
      for (const [t, why] of cases) {
        const r = parseInput(t);
        if (!r) console.log('NULL\t'+t+'\t'+why);
        else if (!/^[0-9]+\$/.test(r.number) || /[-,]\$/.test(r.name)) console.log('WEIRD\t'+t+'\t'+why+'\t'+JSON.stringify(r));
      }
    " 2>/dev/null | grep -E "^(NULL|WEIRD)$(printf '\t')")
    if [ -z "$out" ]; then
        pass "сценарий: свободный ввод продавца разбирается корректно"
    else
        while IFS=$'\t' read -r kind text why got; do
            case "$kind" in NULL|WEIRD) ;; *) continue ;; esac
            [ -z "$text" ] && continue
            if [ "$kind" = NULL ]; then
                finding MAJOR "$PARSER" "Продавец напишет «$text» — бот ответит «не понял»" \
                    "Случай: $why. Формально ученик виноват, но писать он будет именно так, и придёт жаловаться вам." \
                    "Расширить парсер: убирать #, принимать порядок «номер имя», чистить тире. Либо в ответе «не понял» показывать пример правильного ввода." 
            else
                finding MAJOR "$PARSER" "Ввод «$text» разбирается неправильно" \
                    "Случай: $why. Получилось: $got — на билете будет неверное имя или номер." \
                    "Починить регулярку разбора и закрыть случай тестом."
            fi
        done <<< "$out"
    fi
fi
