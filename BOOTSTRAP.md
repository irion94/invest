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
git clone git@github.com:irion94/invest.git
cd invest
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
- Poniedziałek-piątek 8:00 — poranny przegląd rynku
- Poniedziałek-piątek 9:00/13:00/17:00 — monitoring newsów
- Poniedziałek-piątek 18:00 — dzienny raport portfela
- Sobota 10:00 — tygodniowe podsumowanie
- Co 30 minut — sprawdzanie alertów cenowych

## Problemy?

- **"Claude nie zna moich komend"** — upewnij się że uruchomiłeś `claude` z katalogu `invest-plan/`
- **"Telegram nie działa"** — sprawdź czy `.env` ma poprawny token i chat ID
- **"Brak danych cenowych"** — sprawdź połączenie z internetem; darmowe API mają limity zapytań
- **Chcesz więcej pomocy?** — po prostu napisz Claude po polsku czego potrzebujesz
