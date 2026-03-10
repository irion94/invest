---
name: rebalans
description: Kalkulator rebalansowania portfela — porównaj aktualną alokację z docelową, oblicz co kupić/sprzedać aby wrócić do strategii. Użyj gdy użytkownik pyta jak zrebalansować portfel, co kupić lub sprzedać, jak zmniejszyć GPW lub zwiększyć VWCE.
---

# /rebalans — Kalkulator rebalansowania

## Instrukcje

### Krok 1 — Pobierz dane

Przeczytaj `memory/portfolio.md`:
- Łączna wartość portfela rodzinnego (PLN)
- Aktualna alokacja sektorowa (%)
- Wszystkie pozycje z wartościami PLN

Przeczytaj `memory/strategy.md`:
- Docelowy model portfela (tabela Core-Satellite)
- Zasady (max 15-16% w jedną pozycję, GPW max 20% itd.)

### Krok 2 — Oblicz odchylenia

Dla każdego segmentu:
- Aktualna wartość PLN = % × łączna wartość
- Docelowa wartość PLN = docelowy % × łączna wartość
- Delta PLN = docelowa - aktualna (+ = należy dokupić, - = należy sprzedać)
- Delta % = odchylenie w punktach procentowych

### Krok 3 — Wyświetl tabelę odchyleń

| Segment | Aktualna % | Docelowa % | Delta pp | Delta PLN | Akcja |
|---------|-----------|-----------|---------|-----------|-------|
| Core VWCE | X% | 35% | +Xpp | +X PLN | KUP |
| BigTech AI | X% | 20% | Xpp | X PLN | OK/SPRZEDAJ |
| Energia jądrowa | X% | 18% | Xpp | X PLN | KUP/OK |
| Polska/GPW | X% | 20% | -Xpp | -X PLN | REDUKUJ |
| Healthcare GLP-1 | X% | 7% | Xpp | X PLN | KUP |
| ETF tematyczne | X% | 0-5% | Xpp | X PLN | OK/REDUKUJ |

### Krok 4 — Plan działania

Wygeneruj konkretny plan:

**Do sprzedaży (największe odchylenia "+" od celu):**
- "Sprzedaj X szt. DNP (~X PLN) → przesuń do VWCE"
- Sprawdź alerty w `memory/alerts-config.md` — czy ceny są w Sell Zone

**Do kupna (największe odchylenia "-" od celu):**
- "Kup VWCE za X PLN (brakuje X PLN do celu 35%)"
- Uwzględnij pozostały limit IKE z portfolio.md

**Ograniczenia:**
- Nie sprzedawaj SNT przed spin-offem Syn2bio (kwiecień 2026) — sprawdź uwagi w portfolio.md
- Respektuj zasadę "NIE sprzedawać gwałtownie" — rozłóż na 12-18 miesięcy
- Max 15-16% portfela w jedną pozycję

### Krok 5 — Priorytetyzacja

Wskaż 3 najważniejsze ruchy teraz, biorąc pod uwagę:
- Dostępny limit IKE
- Wolne środki na kontach
- Aktualne ceny vs Buy/Sell Zones (z strategy.md)
- Macro Risk Score z `memory/macro-risk.md` — przy wysokim ryzyku ostrożniej z kupnem

### Krok 6 — Zaproponuj

"Użyj `/kup` lub `/sprzedaj` aby zarejestrować transakcję. `/strategia` aby przejrzeć cele."
