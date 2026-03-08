# Investment Assistant — Design Document

Data: 2026-03-08

## Cel projektu

Przenośny setup Claude Code jako osobisty asystent inwestycyjny. Przygotowanie techniczne (technical prep) przez osobę techniczną dla nietechnicznego inwestora. Klient klonuje repo, uruchamia BOOTSTRAP.md i ma gotowe narzędzie.

## Podejście

**Claude-first** — Claude Code jest głównym interfejsem. Użytkownik rozmawia po polsku, używa slash komend. Dane w plikach memory, cykliczne zadania w scheduled tasks, alerty na Telegram.

Ewentualna faza B: prosty dashboard webowy do wizualizacji.

## Rynki i instrumenty

- Akcje GPW (WIG20, mWIG40)
- Akcje zagraniczne (US: S&P500, NASDAQ, Europa)
- Kryptowaluty (BTC, ETH, altcoiny)
- ETF-y, obligacje

## Źródła danych

### Faza A (start) — darmowe
- Yahoo Finance (akcje US/EU)
- CoinGecko (krypto)
- Stooq.pl (GPW)
- Google News / RSS (Reuters, Bloomberg, Bankier, CoinDesk)

### Faza B (do decyzji później)
- Płatne API: Alpha Vantage, Polygon.io, TradingView
- Scraping: Bankier, Biznesradar, GPW

---

## Struktura projektu

```
invest-plan/
├── CLAUDE.md              # Instrukcje dla Claude — asystent inwestycyjny
├── BOOTSTRAP.md           # Przewodnik setup dla klienta (krok po kroku)
├── .env.example           # Szablon zmiennych (API keys, Telegram token)
├── .claude/
│   └── scheduled-tasks/   # Cykliczne zadania (monitoring, alerty)
├── memory/
│   ├── MEMORY.md          # Główny indeks pamięci
│   ├── portfolio.md       # Aktualny portfel (uzupełni klient)
│   ├── strategy.md        # Strategia inwestycyjna, cele
│   ├── watchlist.md       # Obserwowane instrumenty
│   ├── decisions-log.md   # Historia decyzji z uzasadnieniami
│   ├── alerts-config.md   # Konfiguracja alertów (progi, instrumenty)
│   └── news-log.md        # Historia istotnych newsów
├── tools/
│   ├── fetch-prices.sh    # Skrypt do pobierania cen
│   └── telegram-notify.sh # Wysyłka alertów na Telegram
├── skills/
│   ├── check-portfolio/   # /portfel
│   ├── market-scan/       # /rynek
│   ├── add-position/      # /kup, /sprzedaj
│   ├── strategy-review/   # /strategia
│   ├── watchlist/         # /watchlist
│   └── alert/             # /alert
└── docs/
    └── plans/             # Plany i designy
```

---

## CLAUDE.md — zachowanie asystenta

```markdown
# Asystent Inwestycyjny

Jesteś osobistym asystentem inwestycyjnym. Mówisz po polsku.

## Zasady
- Przed każdą odpowiedzią sprawdź memory/ (portfel, strategia, watchlist)
- Sugeruj, nie naciskaj — decyzja zawsze należy do użytkownika
- Uwzględniaj nastroje polityczne i informacje ze świata
- Loguj każdą decyzję inwestycyjną w decisions-log.md
- Przy analizie podawaj źródła danych i datę pobrania
- Nie jesteś doradcą finansowym — przedstawiasz analizę, nie rekomendacje

## Dostępne narzędzia
- Skille: /portfel, /rynek, /kup, /sprzedaj, /watchlist, /alert, /strategia
- Dane: Yahoo Finance, CoinGecko, Stooq (przez tools/)
- Alerty: Telegram (przez MCP server)
- Multi-model: /gemini-consult dla drugiej opinii i analizy sentymentu

## Workflow
- "Sprawdź portfel" → skill /portfel
- "Kupiłem/sprzedałem X" → skill /kup lub /sprzedaj → aktualizuj memory
- "Co na rynku?" → skill /rynek
- "Omówmy strategię" → skill /strategia
```

---

## Pluginy do zainstalowania

### Marketplaces
```bash
claude plugin marketplace add obra/superpowers-marketplace
claude plugin marketplace add anthropics/financial-services-plugins
claude plugin marketplace add quant-sentiment-ai/claude-equity-research
```

### Pluginy
| Plugin | Komenda | Cel |
|---|---|---|
| Superpowers | `claude plugin install superpowers@superpowers-marketplace` | Brainstorming, TDD, debugging, code review |
| Financial Analysis | `claude plugin install financial-analysis@financial-services-plugins` | Analiza finansowa, modelowanie |
| Equity Research | `claude plugin install claude-equity-research@quant-sentiment-ai` | Analiza fundamentalna/techniczna, rekomendacje |

---

## MCP Servery

| Serwer | Repozytorium | Cel | Koszt |
|---|---|---|---|
| Financial Datasets | github.com/financial-datasets/mcp-server | Bilanse, cash flow, ceny, news | Darmowy tier |
| Alpha Vantage | mcp.alphavantage.co | Real-time/historyczne dane | Darmowy klucz API |
| Telegram MCP | github.com/antongsm/mcp-telegram | Wysyłka alertów | Darmowy |
| Claude Telegram Alerts | lobehub.com/mcp/anthony-potts-claude-telegram-alerts | Alerty statusu tasków | Darmowy |
| Gemini MCP | (do konfiguracji) | Second opinion, sentiment | Subskrypcja klienta |

---

## Skills (slash komendy)

### /portfel — Sprawdź aktualny portfel
1. Czytaj memory/portfolio.md
2. Pobierz aktualne ceny (Yahoo/CoinGecko/Stooq)
3. Oblicz: wartość, zysk/strata %, zmiana dzienna
4. Wyświetl tabelę z podsumowaniem
5. Jeśli coś spadło >5% — zasugeruj przegląd

### /kup i /sprzedaj — Rejestruj transakcje
Użycie: `/kup 10 AAPL 185.50`
1. Parsuj: ilość, ticker, cena
2. Zaktualizuj memory/portfolio.md
3. Zapisz w memory/decisions-log.md (data, instrument, cena, powód)
4. Zapytaj o powód decyzji — zapisz w logu

### /rynek — Co się dzieje na rynkach?
1. Pobierz indeksy: WIG20, S&P500, NASDAQ, BTC
2. Pobierz nagłówki RSS (Reuters, Bankier)
3. Analiza sentymentu nagłówków
4. Opcjonalnie: /gemini-consult dla drugiej opinii
5. Zwięzłe podsumowanie: co rośnie, co spada, dlaczego

### /watchlist — Zarządzaj obserwowanymi
- `/watchlist` → pokaż listę
- `/watchlist + NVDA 800` → dodaj alert: NVDA > 800$
- `/watchlist - NVDA` → usuń z listy

### /strategia — Przegląd strategii
1. Czytaj memory/strategy.md + portfolio.md + decisions-log.md
2. Analiza: czy działania są spójne ze strategią?
3. Podsumowanie: co idzie dobrze, co wymaga uwagi
4. Opcjonalnie: /gemini-consult dla alternatywnej perspektywy

### /alert — Konfiguruj powiadomienia Telegram
- `/alert AAPL < 170` → alert gdy AAPL spadnie poniżej 170$
- `/alert BTC > 100000` → alert gdy BTC przekroczy 100k
- `/alert list` → pokaż aktywne alerty
- `/alert off AAPL` → wyłącz alert

---

## Scheduled Tasks

### morning-market-brief — Poranny przegląd
```
Cron: 0 8 * * 1-5 (pon-pt o 8:00)
```
1. Pobierz indeksy: WIG20, S&P500, NASDAQ, BTC, ETH
2. Pobierz top nagłówki z RSS
3. Sprawdź watchlist — czy coś osiągnęło próg alertu
4. Wyślij podsumowanie na Telegram

### portfolio-check — Sprawdzenie portfela
```
Cron: 0 18 * * 1-5 (pon-pt o 18:00)
```
1. Pobierz aktualne ceny pozycji z portfolio.md
2. Oblicz dzienną zmianę, łączny P&L
3. Jeśli pozycja spadła >3% — wyślij alert
4. Zapisz snapshot do historii

### price-alerts — Monitoring alertów cenowych
```
Cron: */30 * * * * (co 30 minut, 24/7)
```
1. Sprawdź alerts-config.md
2. Pobierz aktualne ceny obserwowanych instrumentów
3. Jeśli próg osiągnięty → wyślij Telegram
4. Oznacz alert jako "triggered"

### portfolio-news-monitor — Monitoring newsów powiązanych z portfelem
```
Cron: 0 9,13,17 * * 1-5 (pon-pt o 9:00, 13:00, 17:00)
```
1. Czytaj portfolio.md → wyciągnij tickery, sektory, surowce
2. Dla każdej pozycji zbuduj kontekst wyszukiwania:
   - AAPL → "Apple, iPhone, Tim Cook, tech sector"
   - Miedź → "copper, KGHM, mining, commodities"
   - BTC → "bitcoin, crypto regulation, SEC, ETF"
3. Przeszukaj źródła: RSS, Google News
4. Filtruj: czy news ma realny wpływ na pozycję?
5. Jeśli tak → analiza:
   - Co się stało?
   - Jak to może wpłynąć na cenę? (krótko/długoterminowo)
   - Czy wymaga działania?
6. Wyślij na Telegram z priorytetem:
   - 🔴 Pilne — wymaga uwagi teraz
   - 🟡 Ważne — warto wiedzieć
   - 🟢 Info — kontekst rynkowy
7. Zapisz w memory/news-log.md

### weekly-review — Tygodniowe podsumowanie
```
Cron: 0 10 * * 6 (sobota o 10:00)
```
1. Podsumowanie tygodnia: najlepsze/najgorsze pozycje
2. Porównanie z indeksami (czy portfel bije rynek?)
3. Przegląd decisions-log.md — co kupiono/sprzedano
4. Sugestie do przemyślenia na przyszły tydzień
5. Wyślij na Telegram

---

## BOOTSTRAP.md — setup dla klienta

Przewodnik krok po kroku dla osoby nietechnicznej:

1. **Zainstaluj Claude Code** — link + instrukcja
2. **Sklonuj repo** — `git clone <url> && cd invest-plan`
3. **Stwórz Telegram bota:**
   - Otwórz @BotFather na Telegramie
   - `/newbot` → nazwa → zapisz token
4. **Skopiuj .env:** `cp .env.example .env`
5. **Wklej klucze API do .env:**
   - `TELEGRAM_BOT_TOKEN=...`
   - `TELEGRAM_CHAT_ID=...`
   - `GEMINI_API_KEY=...` (opcjonalnie)
6. **Zainstaluj pluginy:**
   ```bash
   claude plugin marketplace add obra/superpowers-marketplace
   claude plugin marketplace add anthropics/financial-services-plugins
   claude plugin marketplace add quant-sentiment-ai/claude-equity-research
   claude plugin install superpowers@superpowers-marketplace
   claude plugin install financial-analysis@financial-services-plugins
   claude plugin install claude-equity-research@quant-sentiment-ai
   ```
7. **Uruchom:** `claude` — Claude przywita Cię i poprowadzi dalej
8. **Wprowadź portfel:** powiedz Claude co masz w portfelu
9. **Ustaw strategię:** opowiedz o swoich celach inwestycyjnych

---

## Decyzje odłożone (faza B/C)

- [ ] Płatne API (Alpha Vantage, Polygon.io, TradingView)
- [ ] Scraping (Bankier, Biznesradar, GPW)
- [ ] Dashboard webowy (React/Next.js)
- [ ] OpenAI MCP server (kolega ma subskrypcję)
- [ ] Grok/X API do analizy sentymentu social media
- [ ] Aplikacja mobilna
