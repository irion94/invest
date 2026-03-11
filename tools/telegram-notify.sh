#!/bin/bash
# telegram-notify.sh — Wysyłka wiadomości na Telegram
# Użycie: ./tools/telegram-notify.sh "treść wiadomości"
# Wymaga: TELEGRAM_BOT_TOKEN i TELEGRAM_CHAT_ID w .env

set -uo pipefail

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

# Wyślij na Telegram (JSON aby uniknąć problemów z & w treści)
RESPONSE=$(curl -s -X POST \
  "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  -H "Content-Type: application/json" \
  --data-binary "$(python3 -c "
import json, sys
msg = sys.stdin.read()
print(json.dumps({'chat_id': '$TELEGRAM_CHAT_ID', 'text': msg, 'parse_mode': 'Markdown'}))
" <<< "$MESSAGE")")

if echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if d.get('ok') else 1)" 2>/dev/null; then
  echo "Wysłano na Telegram."
else
  echo "Błąd Telegram API: $RESPONSE" >&2
  exit 1
fi
