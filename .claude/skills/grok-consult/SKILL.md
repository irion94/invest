---
name: grok-consult
description: Analiza rynku i ryzyka recesji przez Grok (xAI) — makroekonomia, sentyment rynkowy, ocena ryzyka globalnego. Użyj gdy użytkownik chce analizy rynkowej od Grok, oceny ryzyka makro, sentymentu giełdowego lub drugiej opinii o sytuacji globalnej.
---

# /grok-consult — Analiza rynku i makro przez Grok (xAI)

## Rola Groka w systemie

Grok odpowiada za:
- Analizę sytuacji rynkowej (indeksy, trendy, sentyment)
- Ocenę ryzyka recesji i globalnych zagrożeń
- Makroekonomię: stopy, inflacja, polityka monetarna
- Geopolitykę i jej wpływ na rynki

Analiza portfela i strategii — pozostaje po stronie Claude.

## Instrukcje

1. Przeczytaj kontekst makro:
   - `memory/macro-risk.md` — aktualny Recession Risk Score i snapshot wskaźników

2. Sprawdź czy `GROK_API_KEY` jest skonfigurowany:
   - Uruchom: `grep GROK_API_KEY .env`
   - Jeśli brak klucza lub wartość to placeholder — poinformuj użytkownika:
     > "Aby użyć Grok, dodaj `GROK_API_KEY=twój_klucz` do pliku `.env`."
     > "Klucz API uzyskasz na: https://console.x.ai"
   - Zakończ działanie skilla.

3. Ustal temat analizy:
   - `/grok-consult` — ogólna analiza rynku i makro
   - `/grok-consult recesja` — głęboka analiza ryzyka recesji
   - `/grok-consult [indeks/sektor]` — np. `/grok-consult SP500`, `/grok-consult energia`
   - `/grok-consult geopolityka` — wpływ geopolityki na rynki

4. Przygotuj prompt dla Groka (po angielsku):

```
You are a macroeconomic analyst and market strategist. Analyze the current market situation.

CURRENT MACRO SNAPSHOT:
[zawartość memory/macro-risk.md — Recession Risk Score + wszystkie wskaźniki]

ANALYSIS REQUEST:
[temat na podstawie argumentu użytkownika]

Please provide:
1. Current market assessment — what is driving markets right now?
2. Recession risk evaluation — how serious is the risk and why?
3. Key macro risks to watch in next 30-90 days
4. Which sectors/assets are most vulnerable? Which are defensive?
5. Your overall market sentiment: Bullish / Neutral / Bearish — and why

Be direct. Use data. No generic disclaimers.
```

5. Wywołaj Grok API przez Bash:

```bash
source .env
PROMPT="[przygotowany prompt]"

curl -s https://api.x.ai/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${GROK_API_KEY}" \
  -d "{
    \"model\": \"grok-3-latest\",
    \"messages\": [
      {
        \"role\": \"system\",
        \"content\": \"You are a sharp macroeconomic analyst. Give direct, data-driven market assessments. Focus on recession risk, market trends, and macro dynamics.\"
      },
      {
        \"role\": \"user\",
        \"content\": $(echo "$PROMPT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')
      }
    ],
    \"max_tokens\": 1200,
    \"temperature\": 0.2
  }" | python3 -c "import json,sys; data=json.load(sys.stdin); print(data['choices'][0]['message']['content'])"
```

6. Wyświetl odpowiedź w sekcji:

### Grok (xAI) — Analiza rynku i makro
[odpowiedź Groka]

### Kluczowe sygnały z analizy Groka
| Aspekt | Ocena Groka | Moja ocena (Claude) |
|--------|-------------|---------------------|
| Ryzyko recesji | | |
| Sentyment rynkowy | | |
| Największe zagrożenie | | |
| Sektory defensywne | | |

### Co to oznacza dla Twojego portfela
*(tu Claude komentuje wyniki Groka w kontekście portfela użytkownika)*

7. Zaznacz: "Grok i Claude dostarczają analizę danych — nie są doradcami finansowymi. Decyzja należy do Ciebie."
