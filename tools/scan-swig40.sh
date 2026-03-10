#!/bin/bash
# scan-swig40.sh — Skaner okazji inwestycyjnych w sWIG40
# Pobiera 12 miesięcy danych ze stooq i oblicza pozycję 52W dla każdej spółki
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

# Parsuj argumenty
while [[ $# -gt 0 ]]; do
  case "$1" in
    --top) TOP_N="$2"; shift 2 ;;
    --ticker) SINGLE_TICKER="${2^^}"; shift 2 ;;
    *) shift ;;
  esac
done

mkdir -p "$CACHE_DIR"

# Daty: dziś i rok temu
DATE_TO=$(date '+%Y%m%d')
DATE_FROM=$(date -d '12 months ago' '+%Y%m%d' 2>/dev/null || date -v-12m '+%Y%m%d')

# Pobierz dane historyczne ze stooq (12 miesięcy)
fetch_history() {
  local ticker="${1,,}"  # stooq wymaga małych liter
  local cache_file="$CACHE_DIR/${ticker}.csv"
  local cache_age=0

  # Cache: odśwież jeśli starszy niż 4 godziny
  if [ -f "$cache_file" ]; then
    cache_age=$(( $(date +%s) - $(date -r "$cache_file" +%s 2>/dev/null || echo 0) ))
  fi

  if [ ! -f "$cache_file" ] || [ "$cache_age" -gt 14400 ]; then
    curl -s "https://stooq.pl/q/d/l/?s=${ticker}&d1=${DATE_FROM}&d2=${DATE_TO}&i=d" \
      -H "User-Agent: Mozilla/5.0" \
      > "$cache_file" 2>/dev/null || true
  fi

  cat "$cache_file"
}

# Analizuj dane — zwraca jedną linię CSV z wynikami
analyze_ticker() {
  local ticker="$1"
  local csv_data="$2"

  python3 - "$ticker" <<PYEOF
import sys, csv, io

ticker = sys.argv[1]
data = """$csv_data"""

rows = []
try:
    reader = csv.DictReader(io.StringIO(data))
    for row in reader:
        try:
            # Stooq zwraca nagłówki po polsku: Data,Otwarcie,Najwyzszy,Najnizszy,Zamkniecie,Wolumen
            rows.append({
                'date': row.get('Date', row.get('Data', '')),
                'close': float(row.get('Close', row.get('Zamkniecie', 0)) or 0),
                'high':  float(row.get('High',  row.get('Najwyzszy',  0)) or 0),
                'low':   float(row.get('Low',   row.get('Najnizszy',  0)) or 0),
                'vol':   float(row.get('Volume', row.get('Wolumen',   0)) or 0),
            })
        except (ValueError, KeyError):
            pass
except Exception:
    pass

rows = [r for r in rows if r['close'] > 0]

if len(rows) < 5:
    print(f"{ticker}|BRAK DANYCH|0|0|0|0|0|0|?")
    sys.exit(0)

# Sortuj wg daty
rows.sort(key=lambda r: r['date'])

current = rows[-1]['close']
w52_high = max(r['high'] for r in rows)
w52_low  = min(r['low']  for r in rows if r['low'] > 0)
avg_vol  = sum(r['vol'] for r in rows) / len(rows)

# Procent od 52W low i high
pct_from_low  = ((current - w52_low)  / w52_low  * 100) if w52_low  > 0 else 0
pct_from_high = ((current - w52_high) / w52_high * 100) if w52_high > 0 else 0

# YTD (od początku roku)
year_start = next((r['close'] for r in rows if r['date'] >= '2026-01-01'), rows[0]['close'])
ytd = ((current - year_start) / year_start * 100) if year_start > 0 else 0

# Sygnał okazji
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

print(f"{ticker}|{current:.2f}|{w52_low:.2f}|{w52_high:.2f}|{pct_from_low:.1f}|{pct_from_high:.1f}|{ytd:.1f}|{avg_vol/1000:.0f}k|{signal}")
PYEOF
}

# Nagłówek tabeli
print_header() {
  echo ""
  echo "╔══════════════════════════════════════════════════════════════════════════════╗"
  echo "║           SKANER OKAZJI sWIG40 — $(date '+%Y-%m-%d %H:%M')                    ║"
  echo "╚══════════════════════════════════════════════════════════════════════════════╝"
  echo ""
  printf "%-6s %8s %8s %8s %9s %9s %7s %8s  %s\n" \
    "Ticker" "Cena" "52W Low" "52W High" "%od Low" "%od High" "YTD%" "Vol avg" "Sygnał"
  printf "%-6s %8s %8s %8s %9s %9s %7s %8s  %s\n" \
    "------" "--------" "--------" "--------" "---------" "---------" "-------" "--------" "-------"
}

# Formatuj wiersz wyniku
format_row() {
  local line="$1"
  IFS='|' read -r ticker cena low high pct_low pct_high ytd vol signal <<< "$line"

  local emoji="  "
  case "$signal" in
    STRONG_BUY) emoji="🚨" ;;
    BUY_ZONE)   emoji="🟢" ;;
    SELL_ZONE)  emoji="🔴" ;;
    OVERSOLD)   emoji="⚠️ " ;;
    neutral)    emoji="  " ;;
  esac

  printf "%-6s %8s %8s %8s %+9s %+9s %+7s %8s  %s %s\n" \
    "$ticker" "$cena" "$low" "$high" "${pct_low}%" "${pct_high}%" "${ytd}%" "$vol" "$emoji" "$signal"
}

# --- MAIN ---

if [ ! -f "$COMPONENTS_FILE" ]; then
  echo "BŁĄD: Brak pliku $COMPONENTS_FILE"
  echo "Utwórz go z listą tickerów sWIG40 (jeden na linię)"
  exit 1
fi

mapfile -t TICKERS < <(grep -v '^#' "$COMPONENTS_FILE" | grep -v '^$')

if [ -n "$SINGLE_TICKER" ]; then
  TICKERS=("$SINGLE_TICKER")
fi

echo "Pobieranie danych dla ${#TICKERS[@]} spółek..." >&2

results=()
for ticker in "${TICKERS[@]}"; do
  csv=$(fetch_history "$ticker")
  row=$(analyze_ticker "$ticker" "$csv")
  results+=("$row")
  printf "." >&2
done
echo "" >&2

# Sortuj wg % od 52W low (najtańsze względem rocznego minimum = najlepsza okazja)
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
echo "Źródło: stooq.pl | Cache: 4h | Lista komponentów: memory/swig40-components.txt"
echo ""
