---
name: raport-tygodniowy
description: Wyślij tygodniowy raport portfela na Telegram — aktualne ceny, P&L wszystkich pozycji, makro risk score, priorytety na kolejny tydzień. Użyj gdy użytkownik chce wysłać tygodniowy raport, podsumowanie tygodnia, raport na Telegram.
---

# /raport-tygodniowy — Tygodniowy raport na Telegram

## Instrukcje

1. Uruchom skrypt raportu:
   ```
   bash tools/weekly-report.sh
   ```

2. Jeśli skrypt się powiedzie — potwierdź:
   "Raport tygodniowy wysłany na Telegram."
   Podaj datę i numer tygodnia.

3. Jeśli skrypt zwróci błąd:
   - Sprawdź czy `.env` istnieje i zawiera `TELEGRAM_BOT_TOKEN` i `TELEGRAM_CHAT_ID`
   - Sprawdź połączenie z Telegramem: `bash tools/telegram-notify.sh "test"`
   - Zaproponuj `/portfel` jako alternatywę (podgląd w Claude bez Telegrama)

## Harmonogram automatyczny
Skrypt jest uruchamiany automatycznie przez cron: **każdy piątek o 17:00**

## Uwaga
Raport bazuje na cenach zakupu z `tools/weekly-report.sh` (hardcoded przy ostatniej aktualizacji).
Po każdej transakcji (`/kup` lub `/sprzedaj`) wartości w skrypcie wymagają ręcznej aktualizacji lub
użyj `/portfel` dla aktualnego P&L z bieżącymi cenami rynkowymi.
