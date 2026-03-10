#!/bin/bash
# buy-zone-monitor.sh — Monitor stref kupna z strategy.md
# Sprawdza ceny portfela i watchlisty względem Buy Zone i Strong Buy
# Uruchamiany przez cron raz dziennie (rano)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Załaduj .env
if [ -f "$PROJECT_DIR/.env" ]; then
  set -a
  source "$PROJECT_DIR/.env"
  set +a
fi

# Strefy kupna z memory/strategy.md (Buy Zone max, Strong Buy max)
# Format: TICKER BUY_MAX STRONG_BUY WALUTA RYNEK
declare -A BUY_MAX=(
  [ACP]=445   [AMZN]=205   [CCJ]=110  [KRU]=445
  [DNP]=40    [QUTM]=21    [NXE]=11   [NVO]=42
  [MSF]=360   [SNT]=265
)
declare -A STRONG_BUY=(
  [ACP]=390   [AMZN]=170   [CCJ]=85   [KRU]=390
  [DNP]=33    [QUTM]=16    [NXE]=8    [NVO]=36
  [MSF]=310   [SNT]=230
)
declare -A CURRENCY=(
  [ACP]=PLN  [AMZN]=USD  [CCJ]=USD  [KRU]=PLN
  [DNP]=PLN  [QUTM]=USD  [NXE]=USD  [NVO]=USD
  [MSF]=EUR  [SNT]=PLN
)
declare -A MARKET=(
  [ACP]=stooq  [AMZN]=yahoo  [CCJ]=yahoo  [KRU]=stooq
  [DNP]=stooq  [QUTM]=yahoo  [NXE]=yahoo  [NVO]=yahoo
  [MSF]=yahoo  [SNT]=stooq
)
declare -A STOOQ_SYM=(
  [ACP]=acp  [KRU]=kru  [DNP]=dnp  [SNT]=snt
)
declare -A YAHOO_SYM=(
  [AMZN]=AMZN  [CCJ]=CCJ  [QUTM]=QUTM.DE  [NXE]=NXE
  [NVO]=NVO    [MSF]=MSF.DE
)

fetch_price_yahoo() {
  local sym="$1"
  local json
  json=$(curl -s "https://query1.finance.yahoo.com/v8/finance/chart/${sym}?interval=1d&range=1d" \
    -H "User-Agent: Mozilla/5.0" 2>/dev/null)
  echo "$json" | python3 -c "
import sys, json
data = json.load(sys.stdin)
try:
    print(data['chart']['result'][0]['meta']['regularMarketPrice'])
except:
    print('')
" 2>/dev/null
}

fetch_price_stooq() {
  local sym="$1"
  local csv
  csv=$(curl -s "https://stooq.pl/q/l/?s=${sym}&f=sd2t2ohlcv&h&e=csv" 2>/dev/null)
  echo "$csv" | tail -1 | cut -d',' -f5
}

send_telegram() {
  bash "$SCRIPT_DIR/telegram-notify.sh" "$1" 2>/dev/null || true
}

ALERTS_STRONG=""
ALERTS_BUY=""
SKIPPED=""

for TICKER in "${!BUY_MAX[@]}"; do
  MARKET_TYPE="${MARKET[$TICKER]}"
  PRICE=""

  if [ "$MARKET_TYPE" = "stooq" ]; then
    SYM="${STOOQ_SYM[$TICKER]:-${TICKER,,}}"
    PRICE=$(fetch_price_stooq "$SYM")
  else
    SYM="${YAHOO_SYM[$TICKER]:-$TICKER}"
    PRICE=$(fetch_price_yahoo "$SYM")
  fi

  if [ -z "$PRICE" ] || [ "$PRICE" = "N/D" ]; then
    SKIPPED="$SKIPPED $TICKER"
    continue
  fi

  BUY="${BUY_MAX[$TICKER]}"
  SB="${STRONG_BUY[$TICKER]}"
  CUR="${CURRENCY[$TICKER]}"

  # Sprawdź Strong Buy
  IN_SB=$(python3 -c "print('yes' if float('$PRICE') <= float('$SB') else 'no')" 2>/dev/null)
  # Sprawdź Buy Zone
  IN_BUY=$(python3 -c "print('yes' if float('$SB') < float('$PRICE') <= float('$BUY') else 'no')" 2>/dev/null)

  if [ "$IN_SB" = "yes" ]; then
    ALERTS_STRONG="${ALERTS_STRONG}🚨 *${TICKER}* — ${PRICE} ${CUR} (Strong Buy ≤${SB})"$'\n'
  elif [ "$IN_BUY" = "yes" ]; then
    ALERTS_BUY="${ALERTS_BUY}🟢 *${TICKER}* — ${PRICE} ${CUR} (Buy Zone ≤${BUY})"$'\n'
  fi
done

# Zbuduj wiadomość
DATE=$(date '+%Y-%m-%d %H:%M')
MSG=$'📊 *Buy Zone Monitor* — '"${DATE}"$'\n\n'

if [ -n "$ALERTS_STRONG" ]; then
  MSG="${MSG}"$'🚨 *STRONG BUY — działaj!*\n'"${ALERTS_STRONG}"$'\n'
fi

if [ -n "$ALERTS_BUY" ]; then
  MSG="${MSG}"$'🟢 *Buy Zone — obserwuj*\n'"${ALERTS_BUY}"$'\n'
fi

if [ -z "$ALERTS_STRONG" ] && [ -z "$ALERTS_BUY" ]; then
  MSG="${MSG}"$'✅ Żadna spółka nie jest w strefie kupna.\nSprawdź ponownie jutro.'
fi

if [ -n "$SKIPPED" ]; then
  MSG="${MSG}"$'\n_Brak danych:'"${SKIPPED}"$'_'
fi

send_telegram "$MSG"
echo "$(date '+%Y-%m-%d %H:%M') buy-zone-monitor: OK" >> "$PROJECT_DIR/memory/alerts-log.txt"
