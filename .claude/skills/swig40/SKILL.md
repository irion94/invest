---
name: swig40
description: Skaner okazji inwestycyjnych w spółkach sWIG40 (małe spółki GPW) — 52W range, YTD, sygnały BUY/SELL. Użyj gdy użytkownik pyta o okazje na GPW, małe spółki, sWIG40, co kupić na giełdzie polskiej, lub chce przegląd small-cap.
---

# /swig40 — Skaner okazji sWIG40

## Instrukcje

### Krok 1 — Uruchom skaner

```bash
bash tools/scan-swig40.sh --top 15
```

Jeśli skrypt działa — wyniki zawierają tabelę z kolumnami:
`Ticker | Cena | 52W Low | 52W High | %od Low | %od High | YTD% | Vol avg | Sygnał`

### Krok 2 — Interpretuj wyniki

**Klasyfikacja sygnałów:**

| Sygnał | Kryterium | Interpretacja |
|--------|-----------|---------------|
| 🚨 STRONG_BUY | ≤10% od 52W low | Historycznie tanie — potencjalna okazja |
| 🟢 BUY_ZONE | ≤20% od 52W low | Atrakcyjna strefa wejścia |
| ⚠️ OVERSOLD | YTD ≤ -15% | Mocna przecena YTD — sprawdź powód |
| 🔴 SELL_ZONE | ≥ -10% od 52W high | Blisko rocznego szczytu — ostrożnie |
| neutral | poza powyższymi | Bez wyraźnego sygnału |

### Krok 3 — Analiza top okazji

Dla 3-5 najciekawszych spółek (STRONG_BUY / BUY_ZONE):

1. **WebSearch**: `"[TICKER] wyniki finansowe 2025 2026"` — sprawdź fundamenty
2. **WebSearch**: `"[Nazwa spółki] prognozy analitycy 2026"` — czy spadek ma sens
3. Sprawdź czy spółka jest w `memory/watchlist.md` lub `memory/portfolio.md`
4. Sprawdź `memory/macro-risk.md` — przy wysokim Recession Risk Score (🟠/🔴) bądź ostrożniejszy

### Krok 4 — Red flags (odfiltruj)

Pomiń spółki z następującymi sygnałami (sprawdź przez WebSearch):
- Ogłoszone postępowanie upadłościowe lub restrukturyzacja
- Zawieszony obrót przez GPW
- Drastyczny spadek przychodów bez planu naprawczego
- Spółki z głównym akcjonariuszem w konflikcie z rynkiem

### Krok 5 — Wyświetl raport

```
## SKANER sWIG40 — [DATA]

### TOP OKAZJE (BUY_ZONE / STRONG_BUY)
[tabela top 5 z komentarzami]

### SPÓŁKI PRZY 52W HIGH (uważaj)
[tabela SELL_ZONE]

### UWAGI MAKRO
[czy obecny macro risk score sprzyja zakupom small-cap?]

### REKOMENDACJA
- Które spółki warto dodać do watchlisty?
- Czy któraś pasuje do strategii (Polska/GPW max 20%)?
```

### Krok 6 — Zaproponuj

- `/watchlist` — dodaj interesujące spółki do obserwacji
- `/alert` — ustaw alert na wybraną spółkę
- `/rebalans` — sprawdź czy jest miejsce w portfelu (GPW: cel 20%, teraz ~39%)
- `/makro` — jeśli macro risk score nie był odświeżany w ostatnich 7 dniach

## Uwagi

- **Lista komponentów** w `memory/swig40-components.txt` — aktualizuj kwartalnie (marzec, czerwiec, wrzesień, grudzień)
- Skład sWIG40 zmienia się po rewizji indeksu GPW — sprawdź aktualizacje na gpw.pl
- Dane cenowe: stooq.pl (opóźnienie max 15 min w czasie sesji)
- Cache odświeżany co 4 godziny (plik memory/.swig40-cache/)
- Signal STRONG_BUY ≠ pewny zysk — zawsze sprawdź fundamenty spółki

## Polecenia zaawansowane

```bash
# Sprawdź jedną spółkę
bash tools/scan-swig40.sh --ticker KRU

# Top 5 okazji
bash tools/scan-swig40.sh --top 5

# Odśwież cache (usuń stary)
rm -rf memory/.swig40-cache/ && bash tools/scan-swig40.sh
```
