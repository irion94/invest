---
name: makro
description: Global Macro Risk Monitoring — ocena ryzyka recesji, kryzysu i euforii na podstawie 5 kategorii wskaźników makroekonomicznych. Użyj gdy użytkownik pyta o ryzyko recesji, kondycję globalnej gospodarki, macro risk, lub chce wiedzieć jaki jest sentyment makroekonomiczny.
---

# /makro — Global Macro Risk Monitor

## Instrukcje

### Krok 1 — Pobierz aktualne dane (WebSearch)

Szukaj następujących wskaźników:

**Rynek obligacji:**
- `"US 10Y 2Y yield curve spread 2026"` — Yield Curve (10Y–2Y)
- `"ICE BofA US High Yield spread 2026"` — Credit Spread HY
- `"US 10 year treasury yield today"` — rentowność 10Y

**Aktywność gospodarcza:**
- `"Global Manufacturing PMI March 2026"` — PMI przemysłowy
- `"Global Services PMI March 2026"` — PMI usługowy
- `"Conference Board Leading Economic Index 2026"` — LEI

**Rynek pracy:**
- `"US unemployment rate latest 2026"` — bezrobocie USA
- `"US nonfarm payrolls latest 2026"` — NFP

**Rynki finansowe:**
- `"VIX volatility index today"` — VIX
- `"MSCI World index performance 2026"` — MSCI World
- `"S&P 500 today"` — S&P 500

**Polityka monetarna:**
- `"Federal Reserve interest rate 2026"` — stopy Fed
- `"US CPI inflation March 2026"` — inflacja CPI

### Krok 1b — Geopolityka (Reuters)

Pobierz aktualne nagłówki geopolityczne z Reuters:
- Użyj `WebFetch` na `https://www.reuters.com/world/` — wyciągnij top 5 nagłówków geopolitycznych
- Szukaj sygnałów: konflikty zbrojne, sankcje, zmiany władzy, kryzysy energetyczne, napięcia handlowe
- Oceń wpływ na rynki: ⚠️ Podwyższone ryzyko / 🔴 Aktywny kryzys / ✅ Spokój geopolityczny
- Uwzględnij znaleziska przy ocenie Credit Spread HY, VIX i ogólnego Recession Risk Score

### Krok 2 — Odczytaj ostatni snapshot

Przeczytaj `memory/macro-risk.md` — porównaj z poprzednim odczytem.

### Krok 3 — Przypisz sygnały

Dla każdego wskaźnika oznacz: ✅ Pozytywny / ⚠️ Neutralny / 🔴 Negatywny

| Kategoria | Wskaźnik | Wartość | Sygnał | Próg alertu |
|-----------|----------|---------|--------|-------------|
| Obligacje | Yield Curve 10Y–2Y | | | <0 = 🔴 |
| Obligacje | Credit Spread HY | | | >500bp = 🔴 |
| Obligacje | US 10Y Yield | | | >5% = ⚠️ |
| Aktywność | Global Mfg PMI | | | <50 = 🔴 |
| Aktywność | Global Services PMI | | | <50 = 🔴 |
| Aktywność | LEI (m/m zmiana) | | | 3+ miesięcy spadek = 🔴 |
| Rynek pracy | Bezrobocie USA | | | >5% = 🔴 |
| Rynek pracy | NFP (m/m) | | | <0 = 🔴 |
| Rynki fin. | VIX | | | >30 = 🔴, 20–30 = ⚠️ |
| Rynki fin. | MSCI World (YTD) | | | <-15% = 🔴 |
| Rynki fin. | S&P 500 (YTD) | | | <-20% = 🔴 |
| Monetarne | Stopa Fed | | | >5.5% = ⚠️ |
| Monetarne | CPI YoY | | | >4% = ⚠️, >6% = 🔴 |

### Krok 4 — Oblicz Recession Risk Score

Policz liczbę sygnałów 🔴:

| Wynik | Poziom ryzyka | Kolor |
|-------|---------------|-------|
| 0–2 | Niskie — ekspansja | 🟢 |
| 3–5 | Średnie — spowolnienie | 🟡 |
| 6–8 | Wysokie — prawdopodobna recesja | 🟠 |
| 9+ | Krytyczne — kryzys | 🔴 |

### Krok 5 — Wyświetl raport

```
## GLOBAL MACRO RISK MONITOR — [DATA]

### Recession Risk Score: X/13 — [POZIOM] [KOLOR]

#### 1. Rynek obligacji
...

#### 2. Aktywność gospodarcza
...

#### 3. Rynek pracy
...

#### 4. Rynki finansowe
...

#### 5. Płynność i polityka monetarna
...

### Implikacje dla portfela
- [co oznacza obecny poziom ryzyka dla Twoich pozycji]
- [które pozycje są najbardziej narażone]
- [co warto monitorować]
```

### Krok 6 — Zapisz snapshot

Zaktualizuj `memory/macro-risk.md` z datą i wynikiem.

### Krok 7 — Zaproponuj

"Chcesz głębszej analizy konkretnego wskaźnika lub `/gemini-consult` po drugą opinię makro?"
