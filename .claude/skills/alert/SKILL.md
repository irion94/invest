---
name: alert
description: Konfiguruj alerty cenowe wysyłane na Telegram — ustaw próg cenowy, wyświetl aktywne alerty, wyłącz alert. Użyj gdy użytkownik chce ustawić powiadomienie o cenie, alert, notyfikację.
---

# /alert — Alerty cenowe

## Użycie
- `/alert AAPL < 170` — alert gdy AAPL spadnie poniżej 170$
- `/alert BTC > 100000` — alert gdy BTC przekroczy 100000$
- `/alert list` — pokaż aktywne alerty
- `/alert off AAPL` — wyłącz alert dla AAPL

## Instrukcje

### Dodaj alert (TICKER < lub > cena)
1. Parsuj: ticker, warunek (</>), próg cenowy
2. Pobierz aktualną cenę — potwierdź odległość od progu
3. Dodaj wiersz do `memory/alerts-config.md`:
   - Ticker, Warunek (< lub >), Próg, Status: active, Data utworzenia
4. Potwierdź: "Alert ustawiony: AAPL < 170$ (aktualna cena: 185$, odległość: -8.1%)"

### Pokaż alerty (list)
1. Przeczytaj `memory/alerts-config.md`
2. Dla każdego aktywnego alertu pobierz aktualną cenę
3. Wyświetl tabelę z odległością od progu

### Wyłącz alert (off TICKER)
1. Zmień status na "disabled" w `memory/alerts-config.md`
2. Potwierdź: "Alert dla TICKER wyłączony"

### Sprawdzanie alertów (wywoływane przez scheduled task)
1. Przeczytaj `memory/alerts-config.md` — aktywne alerty
2. Dla każdego: pobierz cenę, sprawdź warunek
3. Jeśli warunek spełniony:
   - Wyślij: `bash tools/telegram-notify.sh "ALERT: TICKER osiągnął CENA (próg: PRÓG)"`
   - Zmień status na "triggered" w alerts-config.md
