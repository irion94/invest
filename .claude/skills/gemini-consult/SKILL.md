---
name: gemini-consult
description: Druga opinia od Gemini AI — alternatywna analiza portfela, strategii lub konkretnego instrumentu. Użyj gdy użytkownik chce skonsultować decyzję z Gemini, uzyskać drugi punkt widzenia, lub porównać oceny.
---

# /gemini-consult — Druga opinia od Gemini

## Instrukcje

1. Przeczytaj:
   - `memory/portfolio.md` — aktualne pozycje
   - `memory/strategy.md` — strategia i cele
   - `memory/watchlist.md` — obserwowane instrumenty

2. Sprawdź czy `GEMINI_API_KEY` jest skonfigurowany:
   - Uruchom: `grep GEMINI_API_KEY .env`
   - Jeśli brak klucza lub wartość to placeholder — poinformuj użytkownika:
     > "Aby użyć Gemini, dodaj `GEMINI_API_KEY=twój_klucz` do pliku `.env`."
     > "Klucz możesz uzyskać bezpłatnie na: https://aistudio.google.com/apikey"
   - Zakończ działanie skilla.

3. Jeśli klucz istnieje — przygotuj prompt dla Gemini zawierający:
   - Aktualny portfel (wartości, alokacja sektorowa, P&L)
   - Cele i strategię (horyzont, tolerancja ryzyka, zasady)
   - Konkretne pytanie (patrz krok 4)

4. Ustal temat konsultacji:
   - Jeśli użytkownik podał ticker (np. `/gemini-consult NVO`) — analiza konkretnego instrumentu
   - Jeśli brak argumentu — ogólna ocena portfela i strategii

5. Wywołaj Gemini API przez Bash:

```bash
source .env
curl -s \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{
    \"contents\": [{
      \"parts\": [{
        \"text\": \"${PROMPT}\"
      }]
    }]
  }"
```

6. Wyświetl odpowiedź Gemini w sekcji:

### Gemini — Druga opinia
[odpowiedź Gemini]

### Moja ocena vs Gemini
- [gdzie się zgadzamy]
- [gdzie się różnimy]
- [co warto przemyśleć]

7. Zaznacz: "Ani Claude, ani Gemini nie są doradcami finansowymi. Decyzja należy do Ciebie."
