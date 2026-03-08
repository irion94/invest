#!/bin/bash
# telegram-notify.sh — Wysyłka wiadomości na Telegram
# Użycie: ./tools/telegram-notify.sh "treść wiadomości"
# Wymaga: TELEGRAM_BOT_TOKEN i TELEGRAM_CHAT_ID w .env

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Załaduj .env jeśli istnieje
if [ -f "$PROJECT_DIR/.env" ]; then
  set -a
  source "$PROJECT_DIR/.env"
  set +a
fi

if [ -z "${TELEGRAM_BOT_TOKEN:-}" ] || [ -z "${TELEGRAM_CHAT_ID:-}" ]; then
  echo "Błąd: Ustaw TELEGRAM_BOT_TOKEN i TELEGRAM_CHAT_ID w pliku .env"
  echo "Instrukcja: skopiuj .env.example do .env i uzupełnij wartości"
  exit 1
fi

MESSAGE="${1:-}"
if [ -z "$MESSAGE" ]; then
  echo "Użycie: $0 \"treść wiadomości\""
  exit 1
fi

# Wyślij na Telegram (parse_mode=Markdown dla formatowania)
curl -s -X POST \
  "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  -d chat_id="$TELEGRAM_CHAT_ID" \
  -d text="$MESSAGE" \
  -d parse_mode="Markdown" \
  2>/dev/null

echo "Wysłano na Telegram."
