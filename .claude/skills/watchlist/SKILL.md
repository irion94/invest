---
name: watchlist
description: Zarządzaj listą obserwowanych instrumentów — dodawaj, usuwaj, przeglądaj. Użyj gdy użytkownik chce obserwować instrument, dodać do watchlisty, lub sprawdzić obserwowane.
---

# /watchlist — Obserwowane instrumenty

## Użycie
- `/watchlist` — pokaż listę obserwowanych z aktualnymi cenami
- `/watchlist + NVDA 800` — dodaj NVDA z alertem na cenę > 800$
- `/watchlist + BTC 100000` — dodaj BTC z alertem na > 100000$
- `/watchlist - NVDA` — usuń NVDA z listy

## Instrukcje

### Pokaż listę
1. Przeczytaj `memory/watchlist.md`
2. Dla każdego instrumentu pobierz aktualną cenę (tools/fetch-prices.sh)
3. Wyświetl tabelę z aktualną ceną i odległością od alertu

### Dodaj instrument (+ TICKER cena)
1. Parsuj ticker i opcjonalny próg cenowy
2. Określ rynek (US/GPW/krypto)
3. Pobierz aktualną cenę
4. Dodaj wiersz do `memory/watchlist.md`
5. Zapytaj o powód obserwacji — zapisz
6. Potwierdź: "Dodano TICKER do watchlisty. Aktualna cena: X"

### Usuń instrument (- TICKER)
1. Usuń wiersz z `memory/watchlist.md`
2. Potwierdź: "Usunięto TICKER z watchlisty"
