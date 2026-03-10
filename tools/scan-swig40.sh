#!/bin/bash
# scan-swig40.sh — Skaner okazji inwestycyjnych w sWIG40
# Źródło danych: Yahoo Finance (.WA suffix) — JSON, bez problemów z lokalizacją
# 52W Low/High pobierane bezpośrednio z meta, YTD obliczane z historii rocznej
#
# Użycie:
#   ./tools/scan-swig40.sh              — pełny skan, sortuj wg okazji
#   ./tools/scan-swig40.sh --top 10     — top 10 okazji
#   ./tools/scan-swig40.sh --ticker KRU — sprawdź jedną spółkę
#
# Lista komponentów: memory/swig40-components.txt (aktualizuj kwartalnie)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
COMPONENTS_FILE="$PROJECT_DIR/memory/swig40-components.txt"
CACHE_DIR="$PROJECT_DIR/memory/.swig40-cache"

TOP_N=0
SINGLE_TICKER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --top)    TOP_N="$2"; shift 2 ;;
    --ticker) SINGLE_TICKER="${2^^}"; shift 2 ;;
    *)        shift ;;
  esac
done

mkdir -p "$CACHE_DIR"

# Pobierz dane spółki z Yahoo Finance (.WA = GPW Warsaw)
# Zwraca JSON z ceną, 52W low/high i historią roczną (YTD)
fetch_and_analyze() {
  local ticker="${1^^}"
  local cache_file="$CACHE_DIR/${ticker}.json"
  local cache_age=0

  if [ -f "$cache_file" ]; then
    cache_age=$(( $(date +%s) - $(date -r "$cache_file" +%s 2>/dev/null || echo 0) ))
  fi

  if [ ! -f "$cache_file" ] || [ "$cache_age" -gt 14400 ]; then
    curl -s "https://query1.finance.yahoo.com/v8/finance/chart/${ticker}.WA?interval=1d&range=1y" \
      -H "User-Agent: Mozilla/5.0" \
      > "$cache_file" 2>/dev/null || echo '{}' > "$cache_file"
  fi

  python3 - "$ticker" "$cache_file" <<'PYEOF'
import sys, json, datetime

ticker = sys.argv[1]
cache_file = sys.argv[2]

try:
    with open(cache_file) as f:
        data = json.load(f)
    result = data['chart']['result'][0]
    meta = result['meta']

    price     = float(meta['regularMarketPrice'])
    w52_low   = float(meta['fiftyTwoWeekLow'])
    w52_high  = float(meta['fiftyTwoWeekHigh'])
    avg_vol   = float(meta.get('averageDailyVolume3Month', 0) or 0)

    # YTD: porównaj z pierwszą ceną w 2026 roku
    closes     = result['indicators']['quote'][0].get('close', [])
    timestamps = result.get('timestamp', [])
    ytd_base   = None
    for i, ts in enumerate(timestamps):
        if closes[i] is None:
            continue
        dt = datetime.datetime.fromtimestamp(ts)
        if dt.year >= 2026:
            ytd_base = float(closes[i])
            break
    ytd = ((price - ytd_base) / ytd_base * 100) if ytd_base else 0.0

    pct_from_low  = ((price - w52_low)  / w52_low  * 100) if w52_low  > 0 else 0
    pct_from_high = ((price - w52_high) / w52_high * 100) if w52_high > 0 else 0

    if pct_from_low <= 10:
        signal = "STRONG_BUY"
    elif pct_from_low <= 20:
        signal = "BUY_ZONE"
    elif pct_from_high >= -10:
        signal = "SELL_ZONE"
    elif ytd <= -15:
        signal = "OVERSOLD"
    else:
        signal = "neutral"

    vol_str = f"{avg_vol/1000:.0f}k" if avg_vol >= 1000 else f"{avg_vol:.0f}"
    print(f"{ticker}|{price:.2f}|{w52_low:.2f}|{w52_high:.2f}|{pct_from_low:.1f}|{pct_from_high:.1f}|{ytd:.1f}|{vol_str}|{signal}")

except Exception as e:
    print(f"{ticker}|BRAK DANYCH|0|0|0|0|0|0|?")
PYEOF
}

print_header() {
  echo ""
  echo "╔══════════════════════════════════════════════════════════════════════════════╗"
  printf "║  SKANER OKAZJI sWIG40 — %-51s║\n" "$(date '+%Y-%m-%d %H:%M')"
  echo "╚══════════════════════════════════════════════════════════════════════════════╝"
  echo ""
  printf "%-6s %8s %8s %8s %9s %9s %7s %9s  %s\n" \
    "Ticker" "Cena" "52W Low" "52W High" "%od Low" "%od High" "YTD%" "Vol 3M" "Sygnał"
  printf "%-6s %8s %8s %8s %9s %9s %7s %9s  %s\n" \
    "------" "--------" "--------" "--------" "---------" "---------" "-------" "---------" "-------"
}

format_row() {
  local line="$1"
  IFS='|' read -r ticker cena low high pct_low pct_high ytd vol signal <<< "$line"

  local emoji="  "
  case "$signal" in
    STRONG_BUY) emoji="🚨" ;;
    BUY_ZONE)   emoji="🟢" ;;
    SELL_ZONE)  emoji="🔴" ;;
    OVERSOLD)   emoji="⚠️ " ;;
  esac

  printf "%-6s %8s %8s %8s %+9s %+9s %+7s %9s  %s %s\n" \
    "$ticker" "$cena" "$low" "$high" "${pct_low}%" "${pct_high}%" "${ytd}%" "$vol" "$emoji" "$signal"
}

# --- MAIN ---

if [ ! -f "$COMPONENTS_FILE" ]; then
  echo "BŁĄD: Brak pliku $COMPONENTS_FILE" >&2
  exit 1
fi

mapfile -t TICKERS < <(grep -v '^#' "$COMPONENTS_FILE" | grep -v '^$')

[ -n "$SINGLE_TICKER" ] && TICKERS=("$SINGLE_TICKER")

echo "Pobieranie danych dla ${#TICKERS[@]} spółek (Yahoo Finance)..." >&2

results=()
for ticker in "${TICKERS[@]}"; do
  row=$(fetch_and_analyze "$ticker")
  results+=("$row")
  printf "." >&2
done
echo "" >&2

sorted=()
while IFS= read -r line; do
  sorted+=("$line")
done < <(printf "%s\n" "${results[@]}" | sort -t'|' -k5 -n)

print_header

count=0
for row in "${sorted[@]}"; do
  [[ "$row" == *"BRAK DANYCH"* ]] && continue
  format_row "$row"
  count=$(( count + 1 ))
  [ "$TOP_N" -gt 0 ] && [ "$count" -ge "$TOP_N" ] && break
done

echo ""
echo "Legenda: 🚨 STRONG_BUY (≤10% od 52W low)  🟢 BUY_ZONE (≤20%)  ⚠️  OVERSOLD (YTD ≤-15%)  🔴 SELL_ZONE (≥-10% od 52W high)"
echo "Źródło: Yahoo Finance (.WA) | Cache: 4h | Lista: memory/swig40-components.txt"
echo ""
