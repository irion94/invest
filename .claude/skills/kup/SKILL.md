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
