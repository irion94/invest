#!/bin/bash
# weekly-report.sh — Tygodniowy raport portfela na Telegram
# Uruchamiany przez cron: każdy piątek o 17:00
# Pobiera aktualne ceny, liczy P&L, wysyła podsumowanie tygodnia

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Załaduj .env
if [ -f "$PROJECT_DIR/.env" ]; then
  set -a
  source "$PROJECT_DIR/.env"
  set +a
fi

send_telegram() {
  bash "$SCRIPT_DIR/telegram-notify.sh" "$1" 2>/dev/null || true
}

fetch_yahoo() {
  local sym="$1"
  curl -s "https://query1.finance.yahoo.com/v8/finance/chart/${sym}?interval=1d&range=5d" \
    -H "User-Agent: Mozilla/5.0" 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
try:
    meta = data['chart']['result'][0]['meta']
    price = meta['regularMarketPrice']
    prev  = meta.get('chartPreviousClose', price)
    closes = data['chart']['result'][0]['indicators']['quote'][0].get('close', [])
    closes = [c for c in closes if c is not None]
    week_open = closes[0] if len(closes) >= 2 else prev
    week_chg = round((price - week_open) / week_open * 100, 2) if week_open else 0
    print(f'{price},{week_chg}')
except Exception as e:
    print(',')
" 2>/dev/null
}

fetch_stooq() {
  local sym="$1"
  # Pobierz 5 dni danych
  local csv
  csv=$(curl -s "https://stooq.pl/q/l/?s=${sym}&f=sd2t2ohlcv&h&e=csv" 2>/dev/null)
  local price
  price=$(echo "$csv" | tail -1 | cut -d',' -f5)
  echo "${price},"
}

DATE=$(date '+%Y-%m-%d')
WEEK=$(date '+%V')

# --- Portfel (dane z memory/portfolio.md jako baza kosztów) ---
declare -A AVG_COST=(
  [AMZN]=201.07  [CCJ]=92.18   [NXE]=10.69   [NVO]=243.41
  [QUTM]=20.98   [VWCE]=145.16 [MSF]=350.30
)
declare -A SHARES=(
  [AMZN]=8.7331  [CCJ]=14.2441  [NXE]=42.6203  [NVO]=17.0933
  [QUTM]=50.5788 [VWCE]=2.6344  [MSF]=2.0110
)
declare -A GPW_COST=([ACP]=172.20 [KRU]=462.06 [DNP]=39.868 [SNT]=289.80 [ATD]=3.180)
declare -A GPW_SHARES=([ACP]=40.4419 [KRU]=12.3868 [DNP]=80.4299 [SNT]=13.2731 [ATD]=158)

# Pobierz ceny US/EU
RESULTS=""
TOTAL_VALUE=0
TOTAL_COST=0

for TICKER in AMZN CCJ NXE NVO QUTM VWCE; do
  SYM="$TICKER"
  [ "$TICKER" = "QUTM" ] && SYM="QUTM.DE"
  [ "$TICKER" = "VWCE" ] && SYM="VWCE.DE"

  DATA=$(fetch_yahoo "$SYM")
  PRICE=$(echo "$DATA" | cut -d',' -f1)
  WCHG=$(echo "$DATA"  | cut -d',' -f2)

  if [ -z "$PRICE" ] || [ "$PRICE" = "None" ]; then
    RESULTS="${RESULTS}${TICKER}: brak danych\n"
    continue
  fi

  COST="${AVG_COST[$TICKER]}"
  SH="${SHARES[$TICKER]}"
  PNL=$(python3 -c "print(round(($PRICE - $COST) / $COST * 100, 2))")
  ARROW="➡️"
  [ "$(python3 -c "print('up' if float('${WCHG:-0}') > 0 else 'dn')")" = "up" ] && ARROW="📈"
  [ "$(python3 -c "print('up' if float('${WCHG:-0}') < 0 else 'dn')")" = "dn" ] && ARROW="📉"

  RESULTS="${RESULTS}${ARROW} *${TICKER}*: ${PRICE} USD (tydz: ${WCHG}% | P\&L: ${PNL}%)\n"
done

# MSF.DE osobno (EUR)
DATA=$(fetch_yahoo "MSF.DE")
PRICE=$(echo "$DATA" | cut -d',' -f1)
WCHG=$(echo "$DATA"  | cut -d',' -f2)
if [ -n "$PRICE" ] && [ "$PRICE" != "None" ]; then
  PNL=$(python3 -c "print(round(($PRICE - 350.30) / 350.30 * 100, 2))")
  ARROW="➡️"
  [ "$(python3 -c "print('up' if float('${WCHG:-0}') > 0 else 'dn')")" = "up" ] && ARROW="📈"
  RESULTS="${RESULTS}${ARROW} *MSF.DE*: ${PRICE} EUR (tydz: ${WCHG}% | P\&L: ${PNL}%)\n"
fi

# GPW
GPW_RESULTS=""
for TICKER in ACP KRU DNP SNT; do
  SYM="${TICKER,,}"
  DATA=$(fetch_stooq "$SYM")
  PRICE=$(echo "$DATA" | cut -d',' -f1)
  if [ -z "$PRICE" ] || [ "$PRICE" = "N/D" ]; then
    GPW_RESULTS="${GPW_RESULTS}${TICKER}: brak danych\n"
    continue
  fi
  COST="${GPW_COST[$TICKER]}"
  PNL=$(python3 -c "print(round(($PRICE - $COST) / $COST * 100, 2))")
  ARROW="➡️"
  GPW_RESULTS="${GPW_RESULTS}${ARROW} *${TICKER}*: ${PRICE} PLN (P\&L: ${PNL}%)\n"
done

# Makro snapshot
MACRO_SCORE=$(grep "Recession Risk Score" "$PROJECT_DIR/memory/macro-risk.md" 2>/dev/null | head -1 | grep -oP '\d+/\d+' || echo "?")
MACRO_LEVEL=$(grep "Recession Risk Score" "$PROJECT_DIR/memory/macro-risk.md" 2>/dev/null | head -1 | grep -oP '(NISKIE|ŚREDNIE|WYSOKIE|KRYTYCZNE)' || echo "?")

# Priorytety ze strategii
PRIORITIES=$(grep -A5 "Top 3 priorytety" "$PROJECT_DIR/memory/strategy.md" 2>/dev/null | tail -3 | sed 's/^[0-9]*\. //' | head -3 || echo "")

# Zbuduj wiadomość
MSG="📊 *Tygodniowy Raport Portfela*
Tydzień ${WEEK} | ${DATE}

*US / EU*
${RESULTS}
*GPW 🇵🇱*
${GPW_RESULTS}
*Makro:* Recession Risk Score ${MACRO_SCORE} ${MACRO_LEVEL}

*Priorytety na kolejny tydzień:*
${PRIORITIES}

_Użyj /portfel w Claude Code po aktualizacji cen w XTB_"

send_telegram "$MSG"
echo "$(date '+%Y-%m-%d %H:%M') weekly-report: wysłano" >> "$PROJECT_DIR/memory/alerts-log.txt"
