# Asystent Inwestycyjny

Osobisty asystent inwestycyjny oparty na Claude Code. Śledzenie portfela, analiza rynków, alerty cenowe na Telegram — wszystko sterowane rozmową po polsku.

## Funkcje

- **Portfel** — rejestracja transakcji, śledzenie wartości i zysków/strat
- **Przegląd rynku** — indeksy (S&P500, NASDAQ, WIG20), krypto (BTC, ETH), sentyment newsów
- **Alerty cenowe** — powiadomienia Telegram gdy instrument osiągnie zadany próg
- **Monitoring newsów** — automatyczne śledzenie wiadomości powiązanych z Twoim portfelem
- **Strategia** — analiza spójności działań z celami inwestycyjnymi
- **Multi-model** — konsultacja z Gemini AI dla drugiej opinii

## Komendy

| Komenda | Opis |
|---------|------|
| `/portfel` | Sprawdź wartość portfela |
| `/kup 10 AAPL 185` | Zarejestruj zakup |
| `/sprzedaj 5 AAPL 200` | Zarejestruj sprzedaż |
| `/rynek` | Przegląd rynków |
| `/watchlist` | Obserwowane instrumenty |
| `/alert BTC > 100000` | Ustaw alert cenowy |
| `/strategia` | Przegląd strategii |

## Szybki start

Szczegółowa instrukcja krok po kroku: [BOOTSTRAP.md](BOOTSTRAP.md)

```bash
git clone git@github.com:irion94/invest.git
cd invest
cp .env.example .env   # uzupełnij klucze Telegram
claude
```

## Źródła danych

| Źródło | Rynki | Koszt |
|--------|-------|-------|
| Yahoo Finance | Akcje US/EU | Darmowe |
| CoinGecko | Kryptowaluty | Darmowe |
| Stooq.pl | GPW | Darmowe |

## Struktura

```
├── CLAUDE.md           # Instrukcje asystenta
├── BOOTSTRAP.md        # Przewodnik setup
├── memory/             # Portfel, strategia, watchlist, logi
├── tools/              # Skrypty do pobierania danych i alertów
└── .claude/skills/     # Komendy slash (/portfel, /kup, /rynek...)
```

## Licencja

Projekt prywatny.
