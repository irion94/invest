#!/bin/bash
# fetch-prices.sh — Pobieranie cen instrumentów
# Użycie: ./tools/fetch-prices.sh <source> <ticker>
# Źródła: yahoo, coingecko, stooq

set -euo pipefail

SOURCE="${1:-}"
TICKER="${2:-}"

if [ -z "$SOURCE" ] || [ -z "$TICKER" ]; then
  echo "Użycie: $0 <yahoo|coingecko|stooq> <ticker>"
  echo "Przykłady:"
  echo "  $0 yahoo AAPL"
  echo "  $0 coingecko bitcoin"
  echo "  $0 stooq kgh"
  exit 1
fi

case "$SOURCE" in
  yahoo)
    # Yahoo Finance — akcje US/EU
    URL="https://query1.finance.yahoo.com/v8/finance/chart/${TICKER}?interval=1d&range=5d"
    curl -s "$URL" \
      -H "User-Agent: Mozilla/5.0" \
      2>/dev/null
    ;;
  coingecko)
    # CoinGecko — kryptowaluty (darmowe API, bez klucza)
    URL="https://api.coingecko.com/api/v3/simple/price?ids=${TICKER}&vs_currencies=usd,pln&include_24hr_change=true"
    curl -s "$URL" 2>/dev/null
    ;;
  stooq)
    # Stooq — GPW (dane CSV)
    URL="https://stooq.pl/q/l/?s=${TICKER}&f=sd2t2ohlcv&h&e=csv"
    curl -s "$URL" 2>/dev/null
    ;;
  *)
    echo "Nieznane źródło: $SOURCE"
    echo "Dostępne: yahoo, coingecko, stooq"
    exit 1
    ;;
esac
