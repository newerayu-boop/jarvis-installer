# 🤖 Jarvis AI Assistant — Установка за 3 шага

Персональный AI-ассистент в Telegram с голосовыми сообщениями, памятью и интеграциями.

---

## Что умеет Джарвис

- 💬 Отвечает на текстовые и **голосовые** сообщения (русский + узбекский)
- 🧠 Помнит контекст разговора
- 📅 Подключается к Google Calendar, Sheets, Trello (опционально)
- 🗣 Отвечает голосом (опционально)
- Работает 24/7 на твоём сервере

---

## ШАГ 1 — Получи API ключи (10 минут)

### Обязательные (все бесплатные):

| Сервис | Где получить | Что брать |
|--------|-------------|-----------|
| **Telegram Bot** | Напиши [@BotFather](https://t.me/BotFather) → `/newbot` | Токен вида `123456:AAF...` |
| **Твой Telegram ID** | Напиши [@userinfobot](https://t.me/userinfobot) | Число вида `123456789` |
| **OpenRouter** | [openrouter.ai](https://openrouter.ai) → Sign Up → Keys | Ключ `sk-or-v1-...` |
| **Groq** | [console.groq.com](https://console.groq.com) → API Keys | Ключ `gsk_...` |

### Опциональные:

| Сервис | Зачем | Где получить |
|--------|-------|-------------|
| **Aisha STT** | Лучше распознаёт узбекский | [aisha.group](https://aisha.group) |

---

## ШАГ 2 — Арендуй сервер (5 минут)

Нужен VPS сервер Ubuntu 22.04:
- Минимум: 1 CPU, 1 GB RAM, 10 GB SSD
- Рекомендую: [Timeweb](https://timeweb.cloud) или [Selectel](https://selectel.ru) или [DigitalOcean](https://digitalocean.com)
- Стоимость: ~3–5$/месяц

> После создания сервера у тебя будет: **IP адрес**, **root пароль**

---

## ШАГ 3 — Запусти установщик (5 минут)

### 3.1 Подключись к серверу

**Windows:** скачай [PuTTY](https://putty.org), вставь IP и подключись  
**Mac/Linux:** открой Терминал и напиши:
```bash
ssh root@ВАШ_IP_АДРЕС
```

### 3.2 Скачай установщик на сервер
```bash
curl -sSL https://raw.githubusercontent.com/ТВОЙ_GITHUB/jarvis-installer/main/download.sh | bash
cd jarvis-installer
```

### 3.3 Заполни конфиг
```bash
cp jarvis.env.example jarvis.env
nano jarvis.env
```

Заполни все поля со звёздочкой `★` (токены из шага 1).  
Сохрани: `Ctrl+O` → Enter → `Ctrl+X`

### 3.4 Запусти установку
```bash
bash install.sh
```

⏳ Установка занимает 3–5 минут. В конце увидишь:
```
✅ ДЖАРВИС УСТАНОВЛЕН УСПЕШНО!
```

### 3.5 Проверь!
1. Открой Telegram
2. Найди своего бота по username
3. Напиши `/start`
4. Отправь голосовое сообщение 🎤

---

## Управление ботом

```bash
# Посмотреть статус
su -s /bin/bash aibot -c "XDG_RUNTIME_DIR=/run/user/1001 systemctl --user status openclaw-gateway"

# Перезапустить
su -s /bin/bash aibot -c "XDG_RUNTIME_DIR=/run/user/1001 systemctl --user restart openclaw-gateway"

# Логи в реальном времени
journalctl --user-unit=openclaw-gateway -f
```

---

## После обновления OpenCLAW

Если ты обновил openclaw (`npm update -g openclaw`), нужно восстановить патч голосовых:

```bash
bash patch-voice.sh
```

---

## Часто задаваемые вопросы

**Бот не отвечает?**
→ Проверь логи: `journalctl --user-unit=openclaw-gateway -n 50`

**Голосовые не распознаются?**
→ Запусти: `bash patch-voice.sh`

**Хочу изменить характер бота?**
→ Отредактируй: `nano /home/aibot/.openclaw/workspace/IDENTITY.md`  
→ Перезапусти бота

**Хочу подключить Google Calendar?**
→ Смотри инструкцию в папке `extras/google-calendar.md`

---

## Структура файлов на сервере

```
/home/aibot/.openclaw/
├── openclaw.json          # Основной конфиг
├── transcribe.py          # Транскрипция голосовых
├── workspace/
│   ├── IDENTITY.md        # Личность бота (редактируй здесь!)
│   └── skills/            # Дополнительные навыки
└── tools/                 # Вспомогательные скрипты
```

---

*Сделано с ❤️ — собрано из боевого опыта, без лишних шагов*
