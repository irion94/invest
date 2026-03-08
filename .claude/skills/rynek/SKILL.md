---
name: rynek
description: Przegląd sytuacji na rynkach finansowych — indeksy, krypto, nagłówki newsów, sentyment. Użyj gdy użytkownik pyta co się dzieje na rynku, giełdzie, z kursami lub chce przegląd rynkowy.
---

# /rynek — Przegląd rynków

## Instrukcje

1. Pobierz główne indeksy i ceny:
   - `bash tools/fetch-prices.sh yahoo ^GSPC` (S&P 500)
   - `bash tools/fetch-prices.sh yahoo ^IXIC` (NASDAQ)
   - `bash tools/fetch-prices.sh stooq wig20` (WIG20)
   - `bash tools/fetch-prices.sh coingecko bitcoin` (BTC)
   - `bash tools/fetch-prices.sh coingecko ethereum` (ETH)

2. Użyj WebSearch aby pobrać najnowsze nagłówki:
   - Szukaj: "stock market news today"
   - Szukaj: "giełda GPW dzisiaj"
   - Szukaj: "crypto market news today"

3. Przeanalizuj sentyment nagłówków:
   - Pozytywny / Neutralny / Negatywny
   - Kluczowe tematy (polityka, dane makro, earnings, regulacje)

4. Sprawdź `memory/watchlist.md` — czy coś z obserwowanych się rusza

5. Wyświetl podsumowanie:

### Indeksy
| Indeks | Wartość | Zmiana dzienna | Trend |
|--------|---------|----------------|-------|

### Krypto
| Coin | Cena USD | Zmiana 24h |
|------|----------|------------|

### Sentyment rynkowy
- Ogólny sentyment: [pozytywny/neutralny/negatywny]
- Kluczowe tematy: ...

### Co warto wiedzieć
- [najważniejsze 2-3 informacje]

6. Opcjonalnie: zaproponuj `/gemini-consult` dla głębszej analizy
