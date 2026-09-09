#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
#  НАБОРЫ ДЛЯ CLAUDE CODE (агенты, навыки, папки-отделы)
#  Проверяет то, что ломается именно в таких продуктах:
#  битый frontmatter, ссылки за пределы открытой папки, забытые
#  плейсхолдеры, разъехавшиеся копии одного файла.
# ══════════════════════════════════════════════════════════════
source "$QA_ROOT/lib/harness.sh"

# grep -c печатает 0 И возвращает 1 при отсутствии совпадений, поэтому
# конструкция "grep -c ... || echo 0" даёт две строки и ломает сравнение.
count_matches() { local n; n=$(grep -c "$1" "$2" 2>/dev/null) || n=0; printf '%s' "${n:-0}"; }

mapfile -t SKILLS < <(project_files | grep -E '\.claude/skills/[^/]+/SKILL\.md$' || true)
mapfile -t AGENTS < <(project_files | grep -E '\.claude/agents/[^/]+\.md$' || true)

if [ ${#SKILLS[@]} -eq 0 ] && [ ${#AGENTS[@]} -eq 0 ]; then
    return 0 2>/dev/null || exit 0
fi

section "6. Навыки и агенты Claude Code"

# --- frontmatter: без него навык просто не включится -----------
check_front() {   # check_front <файл> <ожидаемое имя> <что это>
    local f="$1" want="$2" kind="$3" p="$PROJECT_ROOT/$1"
    if [ "$(head -1 "$p")" != "---" ]; then
        fail_with BLOCKER "$f" "$kind не запустится: нет frontmatter" \
            "Файл должен начинаться со строки '---' и блока с полями name и description. Без этого Claude Code его не увидит, и ученик напишет команду, а в ответ будет тишина." \
            "Добавить в самое начало файла: --- / name: $want / description: когда использовать / ---"
        return
    fi
    local front name desc
    front=$(sed -n '2,/^---$/p' "$p")
    name=$(printf '%s\n' "$front" | grep -m1 '^name:' | sed 's/^name:[[:space:]]*//' | tr -d '"'"'"'')
    desc=$(printf '%s\n' "$front" | grep -m1 '^description:' | sed 's/^description:[[:space:]]*//')
    if [ -z "$name" ]; then
        fail_with BLOCKER "$f" "$kind без поля name" \
            "Claude Code не сможет его вызвать." "Добавить в frontmatter: name: $want"
    elif [ "$name" != "$want" ]; then
        fail_with MAJOR "$f" "Имя в файле не совпадает с папкой: '$name' вместо '$want'" \
            "Ученик напечатает то, что написано в инструкции, а сработает другое имя или ничего." \
            "Привести к одному виду: либо name: $want, либо переименовать папку в '$name'."
    fi
    if [ -z "$desc" ]; then
        fail_with MAJOR "$f" "$kind без описания" \
            "Без description Claude не поймёт, когда его включать, и навык не сработает сам." \
            "Добавить description: одной фразой, когда использовать."
    elif [ ${#desc} -lt 40 ]; then
        finding MINOR "$f" "Слишком короткое описание" \
            "Описание из $((${#desc})) символов. Чем оно короче, тем реже навык включается сам." \
            "Перечислить в description слова, которыми ученик реально попросит."
    fi
    [ -n "$name" ] && [ "$name" = "$want" ] && [ -n "$desc" ] && pass "$f — frontmatter в порядке"
}

for f in "${SKILLS[@]}"; do
    dir=$(basename "$(dirname "$f")")
    check_front "$f" "$dir" "Навык"
done
for f in "${AGENTS[@]}"; do
    check_front "$f" "$(basename "$f" .md)" "Агент"
done

# --- ссылки за пределы папки, которую ученик откроет ----------
# Инструкция сама учит: Claude Code видит только открытую папку.
# «Открываемая папка» — корень проекта и любая папка со своим .claude/.
# Ссылка ../ считается ловушкой, только если выводит за такую границу.
mapfile -t ROOTS < <( { echo "."; project_files | grep -oE '^.*(?=/\.claude/)' 2>/dev/null \
    || project_files | sed -n 's|^\(.*\)/\.claude/.*|\1|p'; } | sort -u )

nearest_root() {  # nearest_root <папка-документа> -> самая близкая открываемая папка
    local d="$1" best="." r
    for r in "${ROOTS[@]}"; do
        [ "$r" = "." ] && continue
        case "$d/" in "$r"/*) [ ${#r} -gt ${#best} ] && best="$r" ;; esac
    done
    printf '%s' "$best"
}

while IFS= read -r doc; do
    [ -z "$doc" ] && continue
    d=$(dirname "$doc"); [ "$d" = "." ] && continue
    case "$d" in *_шаблон*|*шаблон*) continue ;; esac
    root=$(nearest_root "$d")
    [ "$root" = "." ] && continue          # файл в корне: границы нет
    root_abs="$PROJECT_ROOT/$root"
    escaping=""
    while IFS= read -r ref; do
        [ -z "$ref" ] && continue
        abs=$(realpath -m "$PROJECT_ROOT/$d/$ref" 2>/dev/null) || continue
        case "$abs" in "$root_abs"|"$root_abs"/*) continue ;; esac
        escaping="$escaping $ref"
    done < <(grep -oE '\.\./[^ `)"]*' "$PROJECT_ROOT/$doc" 2>/dev/null | sort -u)
    [ -z "$escaping" ] && { pass "$doc — все ссылки внутри своей папки"; continue; }
    fail_with MAJOR "$doc" "Ссылки выводят за папку, которую ученик откроет в Claude Code" \
        "Файл лежит в '$root' и ссылается на$escaping. Инструкция велит открыть в Claude Code именно '$root', а оттуда Claude этих файлов не видит. Ученик попросит «возьми шаблон» и получит «файла нет» — и решит, что демо сломано." \
        "Либо положить копии нужных файлов внутрь '$root', либо написать прямым текстом: «эти файлы копируйте руками в проводнике, Claude их отсюда не видит»."
done < <(project_files | grep -E '\.md$' | grep -v '^\.claude/')

# --- забытые плейсхолдеры вне шаблонов ------------------------
while IFS= read -r doc; do
    [ -z "$doc" ] && continue
    case "$doc" in *_шаблон*|*шаблон*|*ШАБЛОН*) continue ;; esac
    n=$(count_matches '‹[^›]*›' "$PROJECT_ROOT/$doc")
    [ "$n" -eq 0 ] && continue
    finding MINOR "$doc" "Осталось незаполненных мест: $n" \
        "В готовом файле остались метки вида ‹…›. Ученик решит, что продукт недоделан." \
        "Заполнить или перенести файл в папку с шаблонами."
done < <(project_files | grep -E '\.md$')

# --- разъехавшиеся копии одного файла -------------------------
while IFS= read -r base; do
    [ -z "$base" ] && continue
    mapfile -t copies < <(project_files | grep -E "(^|/)$base\$")
    [ ${#copies[@]} -lt 2 ] && continue
    first_sum=$(md5sum "$PROJECT_ROOT/${copies[0]}" | cut -d' ' -f1)
    for c in "${copies[@]:1}"; do
        if [ "$(md5sum "$PROJECT_ROOT/$c" | cut -d' ' -f1)" != "$first_sum" ]; then
            finding MAJOR "$c" "Копии одного файла разъехались" \
                "Файл '$base' лежит в нескольких местах с разным содержимым: ${copies[0]} и $c. Ученики в разных папках получат разное поведение, а вы будете чинить по очереди." \
                "Оставить один источник правды, остальные копии генерировать или удалить."
            break
        fi
    done
    pass "копии $base совпадают"
done < <(project_files | grep -E '\.claude/skills/[^/]+/SKILL\.md$' | xargs -r -n1 dirname 2>/dev/null | xargs -r -n1 basename 2>/dev/null | sort -u | sed 's|$|/SKILL.md|')

# --- ссылки на разделы других файлов --------------------------
# «см. ФАЙЛ.md, раздел 7» — проверяем, что раздел 7 там есть.
while IFS= read -r doc; do
    [ -z "$doc" ] && continue
    while IFS= read -r hit; do
        [ -z "$hit" ] && continue
        target=$(printf '%s' "$hit" | grep -oE '[A-ZА-Я0-9ЁЙ_-]+\.md' | head -1)
        num=$(printf '%s' "$hit" | grep -oE 'раздел[а-я]* [0-9]+' | grep -oE '[0-9]+' | head -1)
        [ -z "$target" ] || [ -z "$num" ] && continue
        path=$(project_files | grep -E "(^|/)$target\$" | head -1)
        [ -z "$path" ] && continue
        have=$(count_matches "^#\+ $num\." "$PROJECT_ROOT/$path")
        [ "$have" -gt 0 ] && continue
        fail_with MAJOR "$doc" "Ссылка на несуществующий раздел: $target, раздел $num" \
            "В тексте написано «$hit», но в $path такого раздела нет. Ученик откроет файл и не найдёт то, что ему велели прочитать." \
            "Исправить номер раздела или добавить раздел в $path."
    done < <(grep -oE '[A-ZА-Я0-9ЁЙ_-]+\.md[^.]{0,20}раздел[а-я]* [0-9]+' "$PROJECT_ROOT/$doc" 2>/dev/null | head -10)
done < <(project_files | grep -E '\.md$')
