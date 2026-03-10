#!/bin/bash
# check-alerts.sh — Automatyczne sprawdzanie alertów cenowych
# Uruchamiany przez cron co godzinę w dni robocze
# Wysyła powiadomienie na Telegram gdy cena osiągnie próg

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ALERTS_FILE="$PROJECT_DIR/memory/alerts-config.md"

# Załaduj .env
if [ -f "$PROJECT_DIR/.env" ]; then
  set -a
  source "$PROJECT_DIR/.env"
  set +a
fi

# Mapowanie: ticker -> źródło danych
get_source() {
  local ticker="$1"
  case "$ticker" in
    ACP|KRU|DNP|SNT) echo "stooq" ;;
    MSF.DE)           echo "yahoo" ;;
    *)                echo "yahoo" ;;
  esac
}

# Mapowanie: ticker -> symbol dla stooq (małe litery)
get_stooq_symbol() {
  local ticker="$1"
  case "$ticker" in
    ACP)   echo "acp" ;;
    KRU)   echo "kru" ;;
    DNP)   echo "dnp" ;;
    SNT)   echo "snt" ;;
    *)     echo "${ticker,,}" ;;
  esac
}

# Pobierz cenę
fetch_price() {
  local ticker="$1"
  local source
  source=$(get_source "$ticker")

  if [ "$source" = "stooq" ]; then
    local symbol
    symbol=$(get_stooq_symbol "$ticker")
    local csv
    csv=$(curl -s "https://stooq.pl/q/l/?s=${symbol}&f=sd2t2ohlcv&h&e=csv" 2>/dev/null)
    echo "$csv" | tail -1 | cut -d',' -f5
  else
    local url="https://query1.finance.yahoo.com/v8/finance/chart/${ticker}?interval=1d&range=1d"
    local json
    json=$(curl -s "$url" -H "User-Agent: Mozilla/5.0" 2>/dev/null)
    echo "$json" | python3 -c "
import sys, json
data = json.load(sys.stdin)
try:
    price = data['chart']['result'][0]['meta']['regularMarketPrice']
    print(price)
except:
    print('')
" 2>/dev/null
  fi
}

# Wyślij alert na Telegram
send_alert() {
  local message="$1"
  bash "$SCRIPT_DIR/telegram-notify.sh" "$message" 2>/dev/null
}

# Wczytaj aktywne alerty z pliku
# Format tabeli: | TICKER | < lub > lub ≤ lub ≥ | PRÓG | STREFA | active | DATA |
process_alerts() {
  local triggered_any=false

  while IFS='|' read -r _ ticker warunek prog strefa status _; do
    # Wyczyść białe znaki (zachowaj oryginał strefy do sed)
    ticker=$(echo "$ticker" | xargs)
    warunek=$(echo "$warunek" | xargs)
    prog=$(echo "$prog" | xargs)
    strefa_raw=$(echo "$strefa" | xargs)
    strefa=$(echo "$strefa_raw" | tr -d ' ')
    status=$(echo "$status" | xargs)

    # Pomiń nagłówki i puste linie
    [[ "$status" != "active" ]] && continue
    [[ "$ticker" == "Ticker" || "$ticker" == "—" || -z "$ticker" ]] && continue

    # Pobierz cenę
    local price
    price=$(fetch_price "$ticker")

    if [ -z "$price" ] || [ "$price" = "None" ]; then
      continue
    fi

    # Sprawdź warunek (< lub ≤ dla buy, > lub ≥ dla sell)
    local triggered=false
    case "$warunek" in
      "<"|"≤")
        if python3 -c "exit(0 if float('$price') <= float('$prog') else 1)" 2>/dev/null; then
          triggered=true
        fi
        ;;
      ">"|"≥")
        if python3 -c "exit(0 if float('$price') >= float('$prog') else 1)" 2>/dev/null; then
          triggered=true
        fi
        ;;
    esac

    if [ "$triggered" = true ]; then
      local emoji="📊"
      case "$strefa" in
        *StrongBuy*|*Strong*) emoji="🚨" ;;
        *BuyZone*|*Buy*)      emoji="🟢" ;;
        *SellZone*|*Sell*)    emoji="🔴" ;;
      esac

      local msg="${emoji} *ALERT: ${ticker}*
Cena: \$${price}
Próg: ${warunek} ${prog} (${strefa_raw})
$(date '+%Y-%m-%d %H:%M')"

      send_alert "$msg"
      triggered_any=true

      # Zmień status na triggered w pliku (używamy strefa_raw ze spacjami)
      sed -i.bak "s/| ${ticker} | ${warunek} | ${prog} | ${strefa_raw} | active /| ${ticker} | ${warunek} | ${prog} | ${strefa_raw} | triggered /" "$ALERTS_FILE" 2>/dev/null || true
    fi

  done < <(grep "^|" "$ALERTS_FILE")

  if [ "$triggered_any" = false ]; then
    echo "$(date '+%Y-%m-%d %H:%M') — Brak alertów do wysłania" >> "$PROJECT_DIR/memory/alerts-log.txt"
  fi
}

process_alerts
