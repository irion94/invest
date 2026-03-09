---
name: grok-consult
description: Druga opinia od Grok (xAI) — alternatywna analiza portfela, strategii lub konkretnego instrumentu. Użyj gdy użytkownik chce konsultacji z Grok, drugiego punktu widzenia od xAI, lub porównania ocen między modelami.
---

# /grok-consult — Druga opinia od Grok (xAI)

## Instrukcje

1. Przeczytaj:
   - `memory/portfolio.md` — aktualne pozycje
   - `memory/strategy.md` — strategia i cele
   - `memory/macro-risk.md` — aktualny Recession Risk Score
   - `memory/watchlist.md` — obserwowane instrumenty

2. Sprawdź czy `GROK_API_KEY` jest skonfigurowany:
   - Uruchom: `grep GROK_API_KEY .env`
   - Jeśli brak klucza lub wartość to placeholder — poinformuj użytkownika:
     > "Aby użyć Grok, dodaj `GROK_API_KEY=twój_klucz` do pliku `.env`."
     > "Klucz API uzyskasz na: https://console.x.ai"
   - Zakończ działanie skilla.

3. Ustal temat konsultacji:
   - Jeśli użytkownik podał ticker (np. `/grok-consult NVO`) — analiza konkretnego instrumentu
   - Jeśli podał temat (np. `/grok-consult makro`) — analiza makroekonomiczna
   - Jeśli brak argumentu — ogólna ocena portfela i strategii

4. Przygotuj prompt dla Grok (po angielsku — lepsze wyniki modelu):

```
You are an experienced investment analyst. Analyze the following portfolio and provide a second opinion.

PORTFOLIO:
[zawartość memory/portfolio.md]

INVESTMENT STRATEGY:
[zawartość memory/strategy.md — cele, horyzont, filozofia]

MACRO RISK (current):
[Recession Risk Score z memory/macro-risk.md]

QUESTION:
[konkretne pytanie na podstawie tematu konsultacji]

Please provide:
1. Your assessment of the portfolio (strengths, weaknesses, risks)
2. Key concerns given the current macro environment
3. 2-3 specific, actionable suggestions
4. Your overall risk rating (Low / Medium / High)

Be direct and concise. This is a second opinion, not financial advice.
```

5. Wywołaj Grok API przez Bash (kompatybilny z OpenAI):

```bash
source .env
PROMPT="[przygotowany prompt — escapuj cudzysłowy]"

curl -s https://api.x.ai/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${GROK_API_KEY}" \
  -d "{
    \"model\": \"grok-3-latest\",
    \"messages\": [
      {
        \"role\": \"system\",
        \"content\": \"You are a sharp, independent investment analyst. Give direct, data-driven assessments. No fluff.\"
      },
      {
        \"role\": \"user\",
        \"content\": $(echo "$PROMPT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')
      }
    ],
    \"max_tokens\": 1000,
    \"temperature\": 0.3
  }" | python3 -c "import json,sys; data=json.load(sys.stdin); print(data['choices'][0]['message']['content'])"
```

6. Wyświetl odpowiedź w sekcji:

### Grok (xAI) — Druga opinia
[odpowiedź Grok]

### Claude vs Grok — Porównanie ocen
| Aspekt | Claude | Grok |
|--------|--------|------|
| [kluczowy punkt 1] | [ocena Claude] | [ocena Grok] |
| [kluczowy punkt 2] | [ocena Claude] | [ocena Grok] |
| [kluczowy punkt 3] | [ocena Claude] | [ocena Grok] |

### Moje wnioski po konsultacji
- [gdzie modele się zgadzają — silny sygnał]
- [gdzie się różnią — warto przemyśleć]
- [co rekomenduje do dalszej analizy]

7. Zaznacz: "Ani Claude, ani Grok nie są doradcami finansowymi. Decyzja zawsze należy do Ciebie."
