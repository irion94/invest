# Investment Assistant — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Zbudować przenośny setup Claude Code jako osobisty asystent inwestycyjny — gotowy do sklonowania i uruchomienia przez nietechnicznego klienta.

**Architecture:** Claude-first — pliki memory jako baza danych, project skills jako komendy użytkownika, MCP servery do danych rynkowych i Telegrama, scheduled tasks do monitoringu. Wszystko w git repo z BOOTSTRAP.md.

**Tech Stack:** Claude Code, SKILL.md (project skills), MCP servers (Telegram), bash scripts (curl do Yahoo Finance/CoinGecko/Stooq), scheduled tasks (cron)

---

### Task 1: Inicjalizacja repo i struktura katalogów

**Files:**
- Create: `invest-plan/.gitignore`
- Create: `invest-plan/.env.example`

**Step 1: Zainicjalizuj git repo**

Run: `cd /Users/irion94/invest-plan && git init`
Expected: Initialized empty Git repository

**Step 2: Utwórz strukturę katalogów**

Run:
```bash
mkdir -p .claude/skills/portfel
mkdir -p .claude/skills/kup
mkdir -p .claude/skills/rynek
mkdir -p .claude/skills/watchlist
mkdir -p .claude/skills/strategia
mkdir -p .claude/skills/alert
mkdir -p memory
mkdir -p tools
```

**Step 3: Utwórz .gitignore**

```
.env
.claude/scheduled-tasks/
*.log
node_modules/
```

**Step 4: Utwórz .env.example**

```bash
# Telegram Bot
TELEGRAM_BOT_TOKEN=your_telegram_bot_token_here
TELEGRAM_CHAT_ID=your_telegram_chat_id_here

# Opcjonalne
GEMINI_API_KEY=your_gemini_api_key_here
```

**Step 5: Commit**

```bash
git add .gitignore .env.example docs/ .claude/skills/ memory/ tools/
git commit -m "feat: initialize project structure"
```

---

### Task 2: CLAUDE.md — instrukcje asystenta

**Files:**
- Create: `CLAUDE.md`

**Step 1: Utwórz CLAUDE.md**

```markdown
# Asystent Inwestycyjny

Jesteś osobistym asystentem inwestycyjnym. Mówisz po polsku.

## Zasady
- Przed każdą odpowiedzią sprawdź memory/ — portfel, strategia, watchlist, alerty
- Sugeruj, nie naciskaj — decyzja zawsze należy do użytkownika
- Uwzględniaj nastroje polityczne i informacje ze świata przy analizie
- Loguj każdą decyzję inwestycyjną w memory/decisions-log.md z datą i uzasadnieniem
- Przy analizie podawaj źródła danych i datę pobrania
- Nie jesteś doradcą finansowym — przedstawiasz analizę danych, nie rekomendacje

## Dostępne skille (slash komendy)
- `/portfel` — sprawdź aktualny stan portfela, zyski/straty, zmianę dzienną
- `/kup [ilość] [ticker] [cena]` — zarejestruj zakup instrumentu
- `/sprzedaj [ilość] [ticker] [cena]` — zarejestruj sprzedaż
- `/rynek` — co się dzieje na rynkach (indeksy, nagłówki, sentyment)
- `/watchlist` — zarządzaj listą obserwowanych instrumentów
- `/alert` — konfiguruj alerty cenowe na Telegram
- `/strategia` — przegląd strategii inwestycyjnej

## Źródła danych
- Akcje US/EU: Yahoo Finance (tools/fetch-prices.sh)
- Kryptowaluty: CoinGecko API (tools/fetch-prices.sh)
- Akcje GPW: Stooq.pl (tools/fetch-prices.sh)
- Newsy: WebSearch + WebFetch

## Alerty
- Telegram bot — skonfigurowany przez tools/telegram-notify.sh
- Konfiguracja alertów w memory/alerts-config.md

## Multi-model
- `/gemini-consult` — druga opinia, analiza sentymentu, alternatywna perspektywa

## Memory
- memory/portfolio.md — aktualny portfel
- memory/strategy.md — strategia i cele
- memory/watchlist.md — obserwowane instrumenty
- memory/decisions-log.md — historia decyzji
- memory/alerts-config.md — konfiguracja alertów
- memory/news-log.md — istotne newsy
```

**Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "feat: add CLAUDE.md with assistant instructions"
```

---

### Task 3: Memory templates

**Files:**
- Create: `memory/portfolio.md`
- Create: `memory/strategy.md`
- Create: `memory/watchlist.md`
- Create: `memory/decisions-log.md`
- Create: `memory/alerts-config.md`
- Create: `memory/news-log.md`

**Step 1: Utwórz portfolio.md**

```markdown
# Portfel Inwestycyjny

Ostatnia aktualizacja: —

## Pozycje

| Ticker | Nazwa | Ilość | Cena zakupu | Data zakupu | Rynek |
|--------|-------|-------|-------------|-------------|-------|
| — | Brak pozycji | — | — | — | — |

## Podsumowanie
- Łączna wartość: —
- Łączny zysk/strata: —

## Instrukcja
Użyj `/kup` lub `/sprzedaj` aby dodać transakcje. Claude automatycznie zaktualizuje tę tabelę.
```

**Step 2: Utwórz strategy.md**

```markdown
# Strategia Inwestycyjna

Ostatnia aktualizacja: —

## Cele
- (opowiedz Claude o swoich celach inwestycyjnych)

## Horyzont czasowy
- (krótkoterminowy / średnioterminowy / długoterminowy)

## Tolerancja ryzyka
- (niska / średnia / wysoka)

## Zasady
- (np. max 10% portfela w jedną pozycję)
- (np. stop loss na -15%)

## Preferowane sektory/rynki
- (np. tech US, krypto, surowce)

## Instrukcja
Powiedz Claude o swoich celach i preferencjach — zostanie to zapisane tutaj.
Użyj `/strategia` aby przejrzeć czy Twoje działania są spójne ze strategią.
```

**Step 3: Utwórz watchlist.md**

```markdown
# Watchlist — Obserwowane Instrumenty

Ostatnia aktualizacja: —

## Obserwowane

| Ticker | Nazwa | Rynek | Alert cenowy | Powód obserwacji |
|--------|-------|-------|-------------|------------------|
| — | Brak | — | — | — |

## Instrukcja
Użyj `/watchlist + TICKER cena` aby dodać instrument.
Użyj `/watchlist - TICKER` aby usunąć.
```

**Step 4: Utwórz decisions-log.md**

```markdown
# Log Decyzji Inwestycyjnych

## Historia transakcji

| Data | Akcja | Ticker | Ilość | Cena | Powód |
|------|-------|--------|-------|------|-------|
| — | — | — | — | — | — |

## Instrukcja
Log jest uzupełniany automatycznie przy każdym użyciu `/kup` lub `/sprzedaj`.
Claude zapyta o powód decyzji i zapisze go tutaj.
```

**Step 5: Utwórz alerts-config.md**

```markdown
# Konfiguracja Alertów

## Aktywne alerty

| Ticker | Warunek | Próg | Status | Utworzony |
|--------|---------|------|--------|----------|
| — | — | — | — | — |

## Status: active / triggered / disabled

## Instrukcja
Użyj `/alert TICKER < cena` lub `/alert TICKER > cena` aby dodać alert.
Użyj `/alert list` aby zobaczyć alerty.
Użyj `/alert off TICKER` aby wyłączyć.
```

**Step 6: Utwórz news-log.md**

```markdown
# Log Newsów

Istotne wiadomości powiązane z portfelem.

## Ostatnie newsy

| Data | Ticker/Sektor | Nagłówek | Wpływ | Priorytet |
|------|---------------|----------|-------|-----------|
| — | — | — | — | — |

## Priorytet: PILNE / WAŻNE / INFO
```

**Step 7: Commit**

```bash
git add memory/
git commit -m "feat: add memory templates for portfolio, strategy, watchlist, decisions, alerts, news"
```

---

### Task 4: Narzędzia — fetch-prices.sh

**Files:**
- Create: `tools/fetch-prices.sh`

**Step 1: Utwórz fetch-prices.sh**

Skrypt bash który pobiera ceny z trzech źródeł w zależności od argumentu.

```bash
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
```

**Step 2: Nadaj uprawnienia**

Run: `chmod +x tools/fetch-prices.sh`

**Step 3: Przetestuj**

Run: `./tools/fetch-prices.sh coingecko bitcoin`
Expected: JSON z ceną BTC w USD i PLN

Run: `./tools/fetch-prices.sh stooq kgh`
Expected: CSV z danymi KGHM

**Step 4: Commit**

```bash
git add tools/fetch-prices.sh
git commit -m "feat: add fetch-prices.sh for Yahoo Finance, CoinGecko, Stooq"
```

---

### Task 5: Narzędzia — telegram-notify.sh

**Files:**
- Create: `tools/telegram-notify.sh`

**Step 1: Utwórz telegram-notify.sh**

```bash
#!/bin/bash
# telegram-notify.sh — Wysyłka wiadomości na Telegram
# Użycie: ./tools/telegram-notify.sh "treść wiadomości"
# Wymaga: TELEGRAM_BOT_TOKEN i TELEGRAM_CHAT_ID w .env

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Załaduj .env jeśli istnieje
if [ -f "$PROJECT_DIR/.env" ]; then
  set -a
  source "$PROJECT_DIR/.env"
  set +a
fi

if [ -z "${TELEGRAM_BOT_TOKEN:-}" ] || [ -z "${TELEGRAM_CHAT_ID:-}" ]; then
  echo "Błąd: Ustaw TELEGRAM_BOT_TOKEN i TELEGRAM_CHAT_ID w pliku .env"
  echo "Instrukcja: skopiuj .env.example do .env i uzupełnij wartości"
  exit 1
fi

MESSAGE="${1:-}"
if [ -z "$MESSAGE" ]; then
  echo "Użycie: $0 \"treść wiadomości\""
  exit 1
fi

# Wyślij na Telegram (parse_mode=Markdown dla formatowania)
curl -s -X POST \
  "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  -d chat_id="$TELEGRAM_CHAT_ID" \
  -d text="$MESSAGE" \
  -d parse_mode="Markdown" \
  2>/dev/null

echo "Wysłano na Telegram."
```

**Step 2: Nadaj uprawnienia**

Run: `chmod +x tools/telegram-notify.sh`

**Step 3: Commit**

```bash
git add tools/telegram-notify.sh
git commit -m "feat: add telegram-notify.sh for sending alerts"
```

---

### Task 6: Skill — /portfel

**Files:**
- Create: `.claude/skills/portfel/SKILL.md`

**Step 1: Utwórz SKILL.md**

```yaml
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
```

**Step 2: Commit**

```bash
git add .claude/skills/portfel/
git commit -m "feat: add /portfel skill for portfolio check"
```

---

### Task 7: Skill — /kup i /sprzedaj

**Files:**
- Create: `.claude/skills/kup/SKILL.md`

**Step 1: Utwórz SKILL.md**

```yaml
---
name: kup
description: Zarejestruj zakup lub sprzedaż instrumentu finansowego. Użyj gdy użytkownik mówi że kupił, sprzedał, dodaje pozycję, zamyka pozycję, lub używa /kup albo /sprzedaj.
---

# /kup i /sprzedaj — Rejestracja transakcji

## Użycie
- `/kup 10 AAPL 185.50` — kupiłem 10 akcji Apple po 185.50$
- `/sprzedaj 5 BTC 98000` — sprzedałem 5 BTC po 98000$
- Naturalny język: "Kupiłem 100 akcji KGHM po 120 zł"

## Instrukcje

1. Parsuj z wiadomości użytkownika:
   - Typ: kupno (kup/kupiłem/buy) lub sprzedaż (sprzedaj/sprzedałem/sell)
   - Ilość
   - Ticker (symbol instrumentu)
   - Cena za sztukę
   - Waluta (domyślnie: USD dla US, PLN dla GPW, USD dla krypto)
2. Określ rynek: US/EU (Yahoo), krypto (CoinGecko), GPW (Stooq)
3. Zapytaj użytkownika: "Jaki jest powód tej decyzji?" — zapisz odpowiedź
4. Zaktualizuj `memory/portfolio.md`:
   - KUPNO: dodaj nowy wiersz lub zwiększ ilość istniejącej pozycji
   - SPRZEDAŻ: zmniejsz ilość lub usuń wiersz jeśli ilość = 0
   - Zaktualizuj datę "Ostatnia aktualizacja"
5. Zapisz w `memory/decisions-log.md`:
   - Data, Akcja (KUP/SPRZEDAJ), Ticker, Ilość, Cena, Powód
6. Potwierdź operację:
   - "Zarejestrowano: KUPNO 10x AAPL po 185.50$ (powód: ...)"
   - Pokaż aktualną pozycję w tym instrumencie

## Walidacja
- Przy sprzedaży: sprawdź czy mamy wystarczającą ilość w portfolio
- Jeśli nie: "Nie masz tylu sztuk TICKER w portfelu. Aktualna ilość: X"
```

**Step 2: Commit**

```bash
git add .claude/skills/kup/
git commit -m "feat: add /kup and /sprzedaj skill for transaction logging"
```

---

### Task 8: Skill — /rynek

**Files:**
- Create: `.claude/skills/rynek/SKILL.md`

**Step 1: Utwórz SKILL.md**

```yaml
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
```

**Step 2: Commit**

```bash
git add .claude/skills/rynek/
git commit -m "feat: add /rynek skill for market overview"
```

---

### Task 9: Skill — /watchlist

**Files:**
- Create: `.claude/skills/watchlist/SKILL.md`

**Step 1: Utwórz SKILL.md**

```yaml
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
```

**Step 2: Commit**

```bash
git add .claude/skills/watchlist/
git commit -m "feat: add /watchlist skill for tracking instruments"
```

---

### Task 10: Skill — /strategia

**Files:**
- Create: `.claude/skills/strategia/SKILL.md`

**Step 1: Utwórz SKILL.md**

```yaml
---
name: strategia
description: Przegląd strategii inwestycyjnej — analiza spójności działań z celami, ocena portfela względem strategii. Użyj gdy użytkownik chce omówić strategię, cele, alokację, lub pyta czy jego działania mają sens.
---

# /strategia — Przegląd strategii

## Instrukcje

1. Przeczytaj:
   - `memory/strategy.md` — cele, horyzont, tolerancja ryzyka, zasady
   - `memory/portfolio.md` — aktualne pozycje
   - `memory/decisions-log.md` — ostatnie decyzje

2. Jeśli `strategy.md` jest pusty:
   - Przeprowadź wywiad z użytkownikiem:
     - Jakie są Twoje cele inwestycyjne?
     - Jaki masz horyzont czasowy?
     - Jaka jest Twoja tolerancja ryzyka?
     - Jakie masz zasady (max % w jedną pozycję, stop lossy)?
     - Jakie sektory/rynki Cię interesują?
   - Zapisz odpowiedzi w `memory/strategy.md`

3. Jeśli `strategy.md` jest wypełniony — analiza:
   - Czy alokacja portfela jest spójna ze strategią?
   - Czy ostatnie decyzje (decisions-log) wpisują się w strategię?
   - Czy dywersyfikacja jest odpowiednia?
   - Czy nie ma pozycji przekraczających limit na jedną pozycję?

4. Wyświetl raport:

### Spójność ze strategią
- [ocena: wysoka/średnia/niska]
- [co jest spójne]
- [co wymaga uwagi]

### Sugestie
- [max 3 sugestie do rozważenia]

5. Zaproponuj: "Chcesz skonsultować strategię z Gemini? (/gemini-consult)"
```

**Step 2: Commit**

```bash
git add .claude/skills/strategia/
git commit -m "feat: add /strategia skill for strategy review"
```

---

### Task 11: Skill — /alert

**Files:**
- Create: `.claude/skills/alert/SKILL.md`

**Step 1: Utwórz SKILL.md**

```yaml
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
   - Wyślij: `bash tools/telegram-notify.sh "🔔 ALERT: TICKER osiągnął CENA (próg: PRÓG)"`
   - Zmień status na "triggered" w alerts-config.md
```

**Step 2: Commit**

```bash
git add .claude/skills/alert/
git commit -m "feat: add /alert skill for Telegram price alerts"
```

---

### Task 12: Scheduled Tasks

**Files:**
- Tworzone przez MCP tool: `mcp__scheduled-tasks__create_scheduled_task`

**Step 1: Utwórz morning-market-brief**

```
Task ID: morning-market-brief
Cron: 0 8 * * 1-5
Prompt:
Wykonaj poranny przegląd rynku:
1. Przeczytaj memory/portfolio.md i memory/watchlist.md
2. Pobierz aktualne ceny dla pozycji portfela (tools/fetch-prices.sh)
3. Pobierz indeksy: S&P500 (^GSPC), NASDAQ (^IXIC), WIG20, BTC, ETH
4. Użyj WebSearch aby znaleźć najważniejsze nagłówki rynkowe
5. Sprawdź alerts-config.md — czy jakiś alert bliski wyzwolenia
6. Wyślij podsumowanie na Telegram: bash tools/telegram-notify.sh "📊 Poranny przegląd: [podsumowanie]"
```

**Step 2: Utwórz portfolio-check**

```
Task ID: portfolio-check
Cron: 0 18 * * 1-5
Prompt:
Sprawdź stan portfela po dniu handlowym:
1. Przeczytaj memory/portfolio.md
2. Pobierz aktualne ceny (tools/fetch-prices.sh)
3. Oblicz zmianę dzienną i łączny P&L
4. Jeśli jakaś pozycja spadła >3% dzisiaj — wyślij alert na Telegram
5. Wyślij: bash tools/telegram-notify.sh "📈 Portfel dzienny: [podsumowanie]"
```

**Step 3: Utwórz price-alerts**

```
Task ID: price-alerts
Cron: */30 * * * *
Prompt:
Sprawdź alerty cenowe:
1. Przeczytaj memory/alerts-config.md — tylko aktywne alerty
2. Dla każdego alertu pobierz cenę (tools/fetch-prices.sh)
3. Sprawdź warunek (< lub >)
4. Jeśli spełniony: wyślij bash tools/telegram-notify.sh "🔔 ALERT: [szczegóły]"
5. Zmień status alertu na "triggered" w alerts-config.md
```

**Step 4: Utwórz portfolio-news-monitor**

```
Task ID: portfolio-news-monitor
Cron: 0 9,13,17 * * 1-5
Prompt:
Monitoruj newsy powiązane z portfelem:
1. Przeczytaj memory/portfolio.md — tickery, sektory, surowce
2. Dla każdej pozycji zbuduj query (np. AAPL → "Apple stock news", KGH → "KGHM copper mining")
3. Użyj WebSearch dla każdej pozycji
4. Filtruj: czy news ma realny wpływ na cenę?
5. Jeśli tak — oceń priorytet:
   - 🔴 PILNE — wymaga uwagi teraz
   - 🟡 WAŻNE — warto wiedzieć
   - 🟢 INFO — kontekst rynkowy
6. Wyślij na Telegram: bash tools/telegram-notify.sh "[priorytet] [ticker]: [nagłówek] — [analiza wpływu]"
7. Zapisz w memory/news-log.md
```

**Step 5: Utwórz weekly-review**

```
Task ID: weekly-review
Cron: 0 10 * * 6
Prompt:
Tygodniowe podsumowanie:
1. Przeczytaj memory/portfolio.md, memory/decisions-log.md, memory/news-log.md
2. Pobierz aktualne ceny — oblicz tygodniową zmianę portfela
3. Porównaj z indeksami (S&P500, WIG20, BTC)
4. Najlepsze i najgorsze pozycje tygodnia
5. Przegląd decyzji z tego tygodnia
6. 2-3 sugestie do rozważenia na przyszły tydzień
7. Wyślij na Telegram: bash tools/telegram-notify.sh "📋 Tygodniowe podsumowanie: [raport]"
```

---

### Task 13: BOOTSTRAP.md

**Files:**
- Create: `BOOTSTRAP.md`

**Step 1: Utwórz BOOTSTRAP.md**

```markdown
# Asystent Inwestycyjny — Instrukcja Uruchomienia

Witaj! Ten przewodnik pomoże Ci uruchomić osobistego asystenta inwestycyjnego
opartego na Claude Code. Nie musisz znać programowania.

## Krok 1: Zainstaluj Claude Code

1. Wejdź na: https://docs.anthropic.com/en/docs/claude-code/quickstart
2. Zainstaluj Claude Code zgodnie z instrukcją
3. Upewnij się że działa: wpisz `claude --version` w terminalu

## Krok 2: Sklonuj repozytorium

Otwórz terminal i wpisz:
```bash
git clone <URL_REPOZYTORIUM>
cd invest-plan
```

## Krok 3: Stwórz bota Telegram (dla alertów)

1. Otwórz Telegram i wyszukaj `@BotFather`
2. Wyślij mu: `/newbot`
3. Nadaj botowi nazwę (np. "Mój Asystent Inwestycyjny")
4. Nadaj username (np. "moj_invest_bot")
5. BotFather da Ci **token** — skopiuj go (wygląda jak: `123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11`)
6. Teraz musisz poznać swój Chat ID:
   - Wyślij dowolną wiadomość do swojego bota
   - Wejdź w przeglądarce na: `https://api.telegram.org/bot<TWOJ_TOKEN>/getUpdates`
   - Znajdź `"chat":{"id":TWOJ_CHAT_ID}` — skopiuj liczbę

## Krok 4: Skonfiguruj klucze API

```bash
cp .env.example .env
```

Otwórz plik `.env` w dowolnym edytorze i uzupełnij:
- `TELEGRAM_BOT_TOKEN=` — wklej token z BotFather
- `TELEGRAM_CHAT_ID=` — wklej Chat ID

## Krok 5: Zainstaluj pluginy Claude Code

Wklej te komendy w terminal, jedna po drugiej:

```bash
claude plugin marketplace add obra/superpowers-marketplace
claude plugin marketplace add anthropics/financial-services-plugins
claude plugin install superpowers@superpowers-marketplace
claude plugin install financial-analysis@financial-services-plugins
```

## Krok 6: Uruchom!

```bash
claude
```

Claude przywita Cię jako asystent inwestycyjny. Możesz od razu zacząć:

### Pierwsze kroki — powiedz Claude:
1. **"Oto mój portfel:"** — opisz co masz (akcje, krypto, ETF-y)
2. **"Moja strategia to..."** — opowiedz o swoich celach
3. **"/watchlist + AAPL 200"** — dodaj instrument do obserwowania
4. **"/alert BTC > 100000"** — ustaw alert cenowy

### Dostępne komendy
| Komenda | Co robi |
|---------|---------|
| `/portfel` | Sprawdź wartość i zyski/straty |
| `/kup 10 AAPL 185` | Zarejestruj zakup |
| `/sprzedaj 5 AAPL 200` | Zarejestruj sprzedaż |
| `/rynek` | Przegląd rynków i newsów |
| `/watchlist` | Obserwowane instrumenty |
| `/alert BTC > 100000` | Ustaw alert cenowy |
| `/strategia` | Przegląd strategii |
| `/gemini-consult` | Druga opinia od Gemini AI |

### Automatyczne raporty (po skonfigurowaniu Telegrama)
- Poniedziałek-piątek 8:00 — poranny przegląd
- Poniedziałek-piątek 18:00 — dzienny raport portfela
- Poniedziałek-piątek 9:00/13:00/17:00 — monitoring newsów
- Sobota 10:00 — tygodniowe podsumowanie
- Co 30 minut — sprawdzanie alertów cenowych

## Problemy?

- **"Claude nie zna moich komend"** — upewnij się że uruchomiłeś `claude` z katalogu `invest-plan/`
- **"Telegram nie działa"** — sprawdź czy `.env` ma poprawny token i chat ID
- **"Brak danych cenowych"** — sprawdź połączenie z internetem; darmowe API mają limity zapytań
```

**Step 2: Commit**

```bash
git add BOOTSTRAP.md
git commit -m "feat: add BOOTSTRAP.md setup guide for non-technical user"
```

---

### Task 14: Finalizacja — .claude/settings.json + weryfikacja

**Files:**
- Create: `.claude/settings.json`

**Step 1: Utwórz project settings**

```json
{
  "permissions": {
    "allow": [
      "Bash(bash tools/fetch-prices.sh:*)",
      "Bash(bash tools/telegram-notify.sh:*)",
      "Read(memory/*)",
      "Edit(memory/*)"
    ]
  }
}
```

**Step 2: Weryfikacja struktury**

Run: `find . -type f | sort | head -30`
Expected: pełna struktura zgodna z design doc

**Step 3: Weryfikacja fetch-prices.sh**

Run: `bash tools/fetch-prices.sh coingecko bitcoin`
Expected: JSON z ceną BTC

**Step 4: Final commit**

```bash
git add .claude/settings.json
git commit -m "feat: add project settings with tool permissions"
```

---

## Podsumowanie tasków

| # | Task | Pliki |
|---|------|-------|
| 1 | Init repo + struktura | .gitignore, .env.example, katalogi |
| 2 | CLAUDE.md | CLAUDE.md |
| 3 | Memory templates | memory/*.md (6 plików) |
| 4 | fetch-prices.sh | tools/fetch-prices.sh |
| 5 | telegram-notify.sh | tools/telegram-notify.sh |
| 6 | Skill /portfel | .claude/skills/portfel/SKILL.md |
| 7 | Skill /kup + /sprzedaj | .claude/skills/kup/SKILL.md |
| 8 | Skill /rynek | .claude/skills/rynek/SKILL.md |
| 9 | Skill /watchlist | .claude/skills/watchlist/SKILL.md |
| 10 | Skill /strategia | .claude/skills/strategia/SKILL.md |
| 11 | Skill /alert | .claude/skills/alert/SKILL.md |
| 12 | Scheduled Tasks | 5 scheduled tasks via MCP |
| 13 | BOOTSTRAP.md | BOOTSTRAP.md |
| 14 | Settings + weryfikacja | .claude/settings.json |
