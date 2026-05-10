# 07 — Setup #3: Power of 3 (AMD)

The **Power of 3** (PO3) — also called **AMD** for **A**ccumulation, **M**anipulation, **D**istribution — is less of a trade and more of a *day model*. You use it to predict where the daily candle will close, and then you take entries on lower TFs in the predicted Distribution direction.

## The three phases of the day

| Phase | Typical session | What price does |
|---|---|---|
| **A** — Accumulation | Asia (≈19:00–02:00 NY) | Builds a tight range |
| **M** — Manipulation | Early London (≈02:00–05:00 NY) | Wicks one side of the range to grab stops (the Judas) |
| **D** — Distribution | NY AM/PM (≈07:00–16:00 NY) | Sustained move in the *opposite* direction of M |

```
   00:00 NY     03:00 NY        10:00 NY        16:00 NY
       │          │                │                │
       │   A      │   M (Judas)    │   D            │
       │          │   wicks below  │   sustained up │
       │  ▢▢▢▢▢   │      ↓         │       ↑↑       │   ← a typical bullish PO3 day
       │  range   │                │                │
       │  forms   │                │                │
       
       Daily candle (00:00 → 24:00 NY) in this case will look like:
       
              ┌──┐         long bullish body
              │██│         (the Distribution)
              │██│
              │██│
              ├──┤
              │  │
              │  │         lower wick
              │  │         (the Manipulation / Judas)
              ▼
```

The **wick** of the daily candle is almost always created in the Manipulation phase. The **body** of the daily candle is the Distribution phase. The **open** of the daily candle is where Accumulation began.

## How to predict the day's direction

This is where HTF bias (chapter 04, step 1) earns its keep.

| HTF bias (Daily / H4) | Expected M direction | Expected D direction |
|---|---|---|
| Bullish | M wicks **below** the open | D drives **up** for the body |
| Bearish | M wicks **above** the open | D drives **down** for the body |
| No clear bias | PO3 is **not** tradable today — stand aside |

> The HTF bias decides which side the wick goes. Without it, you are guessing.

## Visual templates

### Bullish PO3 day

```
   ──── PDH                                                ★ TP = HTF liquidity
                                                         ╱
                                                       ╱
                                                     ╱
              ◄── Asia high ──◄                    ╱
              │     A          │                 ╱
              │  range forms   │               ╱   D — bullish push
              ◄── Asia low  ──◄ ╲             ╱       (entry on FVG/OB)
                                  ╲         ╱
                                    ╲     ╱
                                      ╲ ╱  ★ enter the FVG/OB on
                                       ╳     M5 CHoCH up after sweep
                                       │  
                                      ╳   M — Judas wick below Asia low
   ───── SSL (Asia low / PDL) ──────────  (sweep, then reverse)
```

### Bearish PO3 day

Mirror image — wick above Asia high, body down for NY.

## Trade rules

The PO3 is a *day* model, but the **entry** is a setup-#1-style trade (sweep + CHoCH + OB). The PO3 just gives you the **bias and the rough timing** with extreme clarity.

| # | Condition |
|---|---|
| 1 | Daily bias is set; you have an expected M direction |
| 2 | Asia range has formed and is marked |
| 3 | Wait for **early London** to wick the Asia extreme on the M-side |
| 4 | After the wick closes back inside the range, look for a **CHoCH** in the bias direction on M5 |
| 5 | Identify the displacement OB / FVG; enter on retest |
| 6 | SL = beyond the Judas wick; TPs = nearest opposite session liquidity, then PDH/PDL, then weekly |

## Step-by-step playbook (bullish PO3)

### Pre-day (the night before / on Asia open)

1. Identify Daily bias (chapter 04).
2. Mark **Asia high / Asia low** as they form.
3. Note **PDH / PDL** and any HTF unmitigated levels.

### London open (~02:00 NY)

4. Watch for a wick **below** Asia low or PDL.
5. Confirm the wick reverses — candle closes back inside the Asia range.

### NY open (~07:00 NY)

6. Drop to M5 / M3 and look for a bullish CHoCH.
7. Identify the OB or FVG that produced the CHoCH.
8. Enter on retest of the POI.
9. SL = below the Judas wick (the *day's* low, not just the M5 sweep candle).
10. TP1 = Asia high. TP2 = PDH.

### Day management

11. Once TP1 hits, move SL to BE.
12. Hold the runner through NY PM session if possible — full Distribution often unfolds across the whole NY day.

## Why PO3 is powerful

- It makes you **patient**. You cannot front-run the M phase; you must wait.
- It **filters trade days**. If London does not produce a clean Judas, the day was not PO3 — skip it.
- It **enlarges the R:R** dramatically. Because SL goes beyond the day's extreme, the runner can often reach 5R+ if you let it.

## Why PO3 is hard for beginners

- The bias call is judgmental. Two equally serious traders can disagree on Daily direction.
- The Judas can be fast — if you blink, it's gone.
- It demands you *not* trade Asia. Many beginners cannot resist Asia "scalps" and ruin their bias clarity.

## How the indicator helps

The hybrid indicator labels:

- The **Asia range box** (faint gray, drawn at 02:00 NY).
- The **Daily Open line**.
- A **PDH / PDL line**.
- A "Judas detected" alert when a wick beyond Asia high or Asia low closes back inside in the first 90 minutes of London.

The PO3 is **not** in the strategy backtest file because the bias step is judgment, not code.

## Common mistakes

- ❌ Trading Asia. The Asia range is data, not a setup.
- ❌ Calling Judas before it confirms (a wick + close back inside is required, not just a wick).
- ❌ Holding through every Daily candle. Some days are not PO3 — they range all session, or distribute against your bias call. Stop out and move on.
- ❌ Setting TP at the *next minute* swing high. Use **session** liquidity, which is bigger.

## Worked example — GBPUSD Daily

| Phase | Window | Observation |
|---|---|---|
| Bias | Daily | HHs+HLs since last Friday's BOS up — **bullish** |
| A | 19:00 → 02:00 NY (Asia) | GBPUSD oscillates 1.2510 – 1.2535 |
| M | 02:30 NY (London open) | Spike to 1.2497, then closes 1.2522 — **Judas** ✓ |
| D | 07:30 NY (NY open) | Bullish OB at 1.2520; M5 CHoCH up at 1.2535 — **enter on retest** |
| Entry | 1.2532 | SL 1.2493 (below Judas), TP1 1.2580, TP2 1.2620 |
| Result | TP1 by 10:30 NY (+1.2 R), runner +2.7 R at NY PM |

→ Continue to [`08-setup-breaker-fvg.md`](08-setup-breaker-fvg.md).
