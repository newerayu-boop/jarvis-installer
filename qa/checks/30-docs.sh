#!/usr/bin/env bash
# Проверка инструкций глазами ученика: всё ли, что написано в README, существует.
source "$QA_ROOT/lib/harness.sh"

section "3. Инструкции для учеников (README)"

# Документацию самой QA-системы не проверяем как инструкцию для ученика:
# она адресована автору курса, а не новичку.
mapfile -t DOCS < <(project_files | grep -E '\.md$' \
    | grep -v '^qa/' | grep -v '^\.claude/' | grep -vx 'QA.md' || true)
if [ ${#DOCS[@]} -eq 0 ]; then skip "нет .md файлов"; return 0 2>/dev/null || exit 0; fi

ALL_FILES="$(project_files)"

for doc in "${DOCS[@]}"; do
    p="$PROJECT_ROOT/$doc"

    # 3.1 Файлы, упомянутые в командах (bash file.sh / cp a b / nano file), существуют
    while IFS= read -r ref; do
        [ -z "$ref" ] && continue
        case "$ref" in
            /*) continue ;;                               # абсолютный путь на сервере, не файл репозитория
            *'$'*|*'*'*|*ВАШ*|*your*|*'<'*) continue ;;   # плейсхолдеры
        esac
        # файл, который ученик создаёт сам из шаблона (jarvis.env ← jarvis.env.example)
        printf '%s\n' "$ALL_FILES" | grep -q "\(^\|/\)$ref\.example$" && continue
        if ! printf '%s\n' "$ALL_FILES" | grep -qx -e "$ref" -e "./$ref" && [ ! -e "$PROJECT_ROOT/$ref" ]; then
            # может лежать в подпапке
            printf '%s\n' "$ALL_FILES" | grep -q "/$ref$" || \
            fail_with MAJOR "$doc" "В инструкции упомянут несуществующий файл: $ref" \
                "Ученик выполнит команду из README и получит 'No such file or directory'." \
                "Либо добавить файл $ref в репозиторий, либо убрать команду из инструкции."
        fi
    done < <(grep -oE '(bash|sh|nano|cat|source|cp) +[A-Za-z0-9_./-]+\.(sh|md|env|json|js|py|txt|example)' "$p" \
             | awk '{print $2}' | sort -u)

    # 3.2 Ссылки на папки/файлы вида `extras/xxx.md`
    while IFS= read -r ref; do
        [ -z "$ref" ] && continue
        [ -e "$PROJECT_ROOT/$ref" ] && continue
        printf '%s\n' "$ALL_FILES" | grep -q -e "^$ref" -e "/$ref\$" && continue
        printf '%s\n' "$ALL_FILES" | grep -q "\(^\|/\)$ref\.example\$" && continue
        fail_with MAJOR "$doc" "Инструкция ссылается на отсутствующий файл: $ref" \
            "В тексте есть путь '$ref', но такого файла в репозитории нет. Ученик пойдёт туда и не найдёт ничего." \
            "Создать $ref или убрать упоминание."
    done < <(grep -oE '`[a-z0-9_-]+/[A-Za-z0-9_./-]+\.(md|json|sh|js|py|txt)`' "$p" | tr -d '`' | sort -u)

    # 3.3 Переменные из env-примера рядом с этим документом объяснены в тексте
    docdir=$(dirname "$doc")
    for ex in $(printf '%s\n' "$ALL_FILES" | grep -E 'env\.example$'); do
        [ "$(dirname "$ex")" = "$docdir" ] || continue
        missing=""
        while IFS= read -r var; do
            [ -z "$var" ] && continue
            grep -q "$var" "$p" || missing="$missing $var"
        done < <(grep -oE '^[A-Z][A-Z0-9_]+=' "$PROJECT_ROOT/$ex" | tr -d '=' | sort -u)
        if [ -n "$missing" ]; then
            finding QUESTION "$doc" "Переменные из $ex не объяснены в инструкции:$missing" \
                "Ученик открывает конфиг, видит эти строки и не понимает, что вписывать. Это самый частый вопрос в поддержку." \
                "Для каждой: что это, где взять, обязательна или нет. Лучше таблицей." 
        else
            pass "$doc — все переменные $ex объяснены"
        fi
    done

    # 3.4 Опасные команды без предупреждения
    if grep -qE 'rm -rf|mkfs|dd if=' "$p"; then
        finding MAJOR "$doc" "В инструкции есть разрушающая команда" \
            "$(grep -nE 'rm -rf|mkfs|dd if=' "$p" | head -2 | tr '\n' ' ')" \
            "Ученик копирует команды не глядя. Добавить явное предупреждение или убрать команду."
    fi

    # 3.5 Команды с плейсхолдерами — понятно ли, что менять?
    if grep -qE 'ВАШ_|YOUR_|<your|xxxx' "$p"; then
        pass "$doc — плейсхолдеры помечены явно"
    fi

    # 3.6 Есть ли раздел «что делать, если не работает»
    if grep -qiE 'не работает|не отвечает|ошибка|troubleshoot|FAQ|Часто задаваемые' "$p"; then
        pass "$doc — есть раздел про проблемы"
    else
        finding QUESTION "$doc" "Нет раздела «что делать, если не работает»" \
            "У ученика обязательно что-то пойдёт не так, и он напишет вам лично вместо того, чтобы решить сам." \
            "Добавить в конец 5–7 частых проблем с готовыми командами для диагностики."
    fi
done

# 3.7 Команды из README, которые выполняются от другого пользователя
if grep -rqs 'journalctl --user' "$PROJECT_ROOT"/*.md 2>/dev/null; then
    finding MAJOR "README" "Команда логов не сработает у ученика" \
        "'journalctl --user-unit=...' от root показывает логи root, а сервис крутится под другим пользователем. Ученик увидит пустоту и решит, что бот мёртв." \
        "Дать команду вида: journalctl _UID=\$(id -u aibot) -u openclaw-gateway -n 50  — или su под нужного пользователя."
fi
