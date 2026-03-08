---
name: portfel
description: Sprawdź aktualny stan portfela inwestycyjnego — wartość pozycji, zyski/straty, zmianę dzienną. Użyj gdy użytkownik pyta o portfel, pozycje, zyski, straty lub wartość inwestycji.
---

# /portfel — Sprawdź portfel

## Instrukcje

1. Przeczytaj `memory/portfolio.md` — pobierz listę pozycji (tickery, ilości, ceny zakupu, rynki)
2. Dla każdej pozycji pobierz aktualną cenę:
   - Rynek US/EU: `bash tools/fetch-prices.sh yahoo TICKER`
   - Krypto: `bash tools/fetch-prices.sh coingecko TICKER`
   - GPW: `bash tools/fetch-prices.sh stooq TICKER`
3. Oblicz dla każdej pozycji:
   - Aktualna wartość = ilość × cena aktualna
   - Zysk/strata = aktualna wartość - (ilość × cena zakupu)
   - Zmiana % = ((cena aktualna - cena zakupu) / cena zakupu) × 100
4. Wyświetl tabelę:

| Ticker | Ilość | Cena zakupu | Cena aktualna | Wartość | Zysk/Strata | % |
|--------|-------|-------------|---------------|---------|-------------|---|

5. Podsumowanie:
   - Łączna wartość portfela
   - Łączny zysk/strata (kwota i %)
6. Jeśli jakaś pozycja spadła >5% od zakupu — zasugeruj przegląd
7. Podaj datę i źródło danych

## Jeśli portfel jest pusty
Powiedz: "Portfel jest pusty. Użyj `/kup` aby zarejestrować pierwszą transakcję."
