#!/bin/bash
# market-report.sh — Dzienny raport rynkowy na Telegram
# Uruchamiany przez cron o 9:30 i 16:00 w dni robocze
# Użycie: ./tools/market-report.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Załaduj .env
if [ -f "$PROJECT_DIR/.env" ]; then
  set -a
  source "$PROJECT_DIR/.env"
  set +a
fi

# Pomocnik: pobierz cenę z Yahoo (akcje/ETF)
fetch_yahoo() {
  local ticker="$1"
  curl -s "https://query1.finance.yahoo.com/v8/finance/chart/${ticker}?interval=1d&range=5d" \
    -H "User-Agent: Mozilla/5.0" 2>/dev/null | \
  python3 -c "
import sys, json
data = json.load(sys.stdin)
try:
    meta = data['chart']['result'][0]['meta']
    price = meta['regularMarketPrice']
    prev  = meta['chartPreviousClose']
    chg   = ((price - prev) / prev) * 100
    print(f'{price:.2f}|{chg:+.2f}')
except:
    print('N/A|N/A')
" 2>/dev/null
}

# Pomocnik: pobierz cenę z CoinGecko (krypto)
fetch_coingecko() {
  local coin="$1"
  curl -s "https://api.coingecko.com/api/v3/simple/price?ids=${coin}&vs_currencies=usd&include_24hr_change=true" \
    2>/dev/null | \
  python3 -c "
import sys, json
data = json.load(sys.stdin)
try:
    coin = list(data.keys())[0]
    price = data[coin]['usd']
    chg   = data[coin]['usd_24h_change']
    print(f'{price:.0f}|{chg:+.2f}')
except:
    print('N/A|N/A')
" 2>/dev/null
}

# Pomocnik: pobierz cenę z Stooq (GPW)
fetch_stooq() {
  local symbol="$1"
  curl -s "https://stooq.pl/q/l/?s=${symbol}&f=sd2t2ohlcv&h&e=csv" 2>/dev/null | \
  python3 -c "
import sys
lines = sys.stdin.read().strip().split('\n')
if len(lines) >= 2:
    cols = lines[1].split(',')
    try:
        close = float(cols[4])
        open_ = float(cols[1])
        chg   = ((close - open_) / open_) * 100
        print(f'{close:.2f}|{chg:+.2f}')
    except:
        print('N/A|N/A')
else:
    print('N/A|N/A')
" 2>/dev/null
}

# Emoji trendu
trend_emoji() {
  local chg="$1"
  python3 -c "
chg = '$chg'
try:
    v = float(chg.replace('+',''))
    if v >= 1: print('🟢')
    elif v <= -1: print('🔴')
    else: print('🟡')
except:
    print('⚪')
" 2>/dev/null
}

SESSION=$(date +%H:%M)
DATE=$(date '+%Y-%m-%d')
if [ "$SESSION" \< "12:00" ]; then
  SESJA_LABEL="Otwarcie"
else
  SESJA_LABEL="Zamknięcie"
fi

# --- Pobierz dane ---
SP500=$(fetch_yahoo "^GSPC")
NASDAQ=$(fetch_yahoo "^IXIC")
WIG20=$(fetch_stooq "wig20")
BTC=$(fetch_coingecko "bitcoin")
ETH=$(fetch_coingecko "ethereum")

SP500_P=$(echo "$SP500" | cut -d'|' -f1)
SP500_C=$(echo "$SP500" | cut -d'|' -f2)
NASDAQ_P=$(echo "$NASDAQ" | cut -d'|' -f1)
NASDAQ_C=$(echo "$NASDAQ" | cut -d'|' -f2)
WIG20_P=$(echo "$WIG20" | cut -d'|' -f1)
WIG20_C=$(echo "$WIG20" | cut -d'|' -f2)
BTC_P=$(echo "$BTC" | cut -d'|' -f1)
BTC_C=$(echo "$BTC" | cut -d'|' -f2)
ETH_P=$(echo "$ETH" | cut -d'|' -f1)
ETH_C=$(echo "$ETH" | cut -d'|' -f2)

E_SP=$(trend_emoji "$SP500_C")
E_NQ=$(trend_emoji "$NASDAQ_C")
E_WIG=$(trend_emoji "$WIG20_C")
E_BTC=$(trend_emoji "$BTC_C")
E_ETH=$(trend_emoji "$ETH_C")

# --- Zbuduj wiadomość ---
MSG="📊 *Raport Rynkowy — ${SESJA_LABEL}*
📅 ${DATE} ${SESSION}

*Indeksy*
${E_SP} S\&P 500:  \`${SP500_P}\`  (${SP500_C}%)
${E_NQ} NASDAQ:   \`${NASDAQ_P}\`  (${NASDAQ_C}%)
${E_WIG} WIG20:   \`${WIG20_P}\`  (${WIG20_C}%)

*Krypto*
${E_BTC} Bitcoin: \`\$${BTC_P}\`  (${BTC_C}%)
${E_ETH} Ethereum: \`\$${ETH_P}\`  (${ETH_C}%)

*Watchlist*"

# Watchlist — dynamiczne ceny
add_watchlist_item() {
  local label="$1"
  local source="$2"
  local ticker="$3"
  local alert_note="$4"
  local price chg emoji

  case "$source" in
    yahoo)
      data=$(fetch_yahoo "$ticker")
      ;;
    stooq)
      data=$(fetch_stooq "$ticker")
      ;;
    *)
      data="N/A|N/A"
      ;;
  esac

  price=$(echo "$data" | cut -d'|' -f1)
  chg=$(echo "$data" | cut -d'|' -f2)
  emoji=$(trend_emoji "$chg")

  MSG="${MSG}
${emoji} ${label}: \`${price}\` (${chg}%) — ${alert_note}"
}

add_watchlist_item "VWCE" "yahoo" "VWCE.DE"   "docelowo 35% portfela"
add_watchlist_item "NVO"  "yahoo" "NVO"        "< 36 = Strong Buy"
add_watchlist_item "AMZN" "yahoo" "AMZN"       "< 195 = Buy Zone"
add_watchlist_item "CCJ"  "yahoo" "CCJ"        "< 105 = dokup"
add_watchlist_item "DNP"  "stooq" "dnp"        "> 60 PLN = redukuj"
add_watchlist_item "SNT"  "stooq" "snt"        "spin-off Syn2bio kwiecień 2026"

MSG="${MSG}

_Dane pobrane automatycznie. Nie stanowią rekomendacji inwestycyjnej._"

# --- Wyślij ---
bash "$SCRIPT_DIR/telegram-notify.sh" "$MSG"
echo "$(date '+%Y-%m-%d %H:%M') — Raport rynkowy wysłany" >> "$PROJECT_DIR/memory/alerts-log.txt"
