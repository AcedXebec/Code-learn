# 03 — ICT Essentials

This chapter adds the **time** dimension. SMC tells us *where* to trade; ICT tells us *when*.

Concepts covered:

- [Sessions](#sessions)
- [Kill zones](#kill-zones)
- [Silver Bullet](#silver-bullet)
- [Power of 3 (AMD)](#power-of-3)
- [Judas swing](#judas-swing)
- [Displacement](#displacement)
- [OTE (Optimal Trade Entry)](#ote)
- [IPDA](#ipda)

> Time references in this chapter are **New York time** (America/New_York). For DST-aware code in Pine and MQL, see the platform READMEs — both calculate session boundaries from the broker server clock + GMT offset.

---

## Sessions

The forex / futures day is divided into three primary sessions. Crypto trades 24/7 but still respects these volatility windows.

| Session | NY time (rough) | What it is |
|---|---|---|
| **Asia** | 19:00 – 03:00 | Tokyo + Sydney. Often a tight range. The day's *accumulation* phase. |
| **London** | 02:00 – 11:00 | London + Frankfurt. The day's first volatility burst. *Manipulation* often here. |
| **New York** | 07:00 – 16:00 | New York + Chicago. The day's largest moves. *Distribution* often here. |

Overlaps (London + NY 07:00 – 11:00) are the most volatile windows.

**The hybrid indicator** shades each session in a different background color and labels them. Toggle off any session you don't trade.

---

## Kill zones

A **kill zone** is a tighter sub-window within a session where price tends to make its move. ICT's canonical kill zones (NY time):

| Kill zone | Window | Typical character |
|---|---|---|
| Asia KZ | 20:00 – 00:00 | Range formation |
| London KZ | 02:00 – 05:00 | London open expansion / Judas |
| NY AM KZ | 07:00 – 10:00 | Real distribution if NYO model |
| NY PM KZ | 13:30 – 16:00 | Afternoon expansion / liquidity raid |

> **Use the kill zones as a time filter, not a hard rule.** The framework's setups become higher-probability when triggered inside a kill zone, but the framework is not invalid outside one.

---

## Silver Bullet

**ICT's Silver Bullet** is an even tighter sub-window — a 60-minute slot where ICT statistics suggest the next-hour move is most predictable.

| Silver Bullet | Window (NY) |
|---|---|
| London SB | 03:00 – 04:00 |
| NY AM SB | 10:00 – 11:00 |
| NY PM SB | 14:00 – 15:00 |

**The Silver Bullet rule (simplified):**

1. Identify the **directional bias** for the day on Daily / H4.
2. Wait for the Silver Bullet window to begin.
3. Look for an **FVG** on M5 / M3 inside the window, on the bias-aligned side.
4. Enter on retest of the FVG. SL just past it. TP at the next obvious liquidity pool.

This is the basis of [`06-setup-silver-bullet.md`](06-setup-silver-bullet.md).

---

## Power of 3

Also called **AMD** — Accumulation / Manipulation / Distribution. The day's price delivery in three acts:

```
    A — Accumulation:     C — Distribution: real move
    Asia builds a tight   in the trend direction
    range                 (often NY session)
                                
    A:  ─────── Asia range ──╲                        
                              ╲    ╱╲                  
        ─────── Asia high ─────╲ ╱    ╲                
        ─────── Asia low  ─────────────╲              
                                        ╲             
                                        ╲             
        M — Manipulation: London open    ★             
        wicks the Asia low (Judas)       │             
                                       D — sustained NY move
                                          forms the body
                                          of the daily candle
```

**Mapping to a daily candle:**

- **Open** = where Accumulation began (00:00 NY).
- **Wick (one side)** = the Manipulation move (Judas).
- **Body** = the Distribution direction.
- **Close** = end of Distribution.

If you can guess **on which side of the open the Manipulation will occur**, you have your bias for the Distribution leg. This is the basis of [`07-setup-power-of-3.md`](07-setup-power-of-3.md).

**How to guess?** Use HTF bias from the framework (chapter 04). If Daily bias is bullish, the Manipulation will likely sweep stops *below* the open before driving up.

---

## Judas swing

The **Judas swing** is the early-session false move that traps retail traders before reversing into the real direction. It is the **M** of AMD.

Beginner heuristic: **never trust the first 30 minutes of London open** in a vacuum. Wait for it to print, identify what was swept, and then look for entries in the opposite direction.

---

## Displacement

A **displacement** is a strong, fast, one-directional price move. Visually:

- 3+ same-color candles in a row.
- Each candle has a meaningful body.
- An FVG is left behind on the way.
- Often accompanied by a BOS or CHoCH at its end.

```
                                  ★ displacement leg
                                ╱
                              ╱╱  candle bodies stack
                            ╱╱     with FVGs left between them
                          ╱╱
                         FVG
                          ╱
                         FVG
                          ╱
   ────────── start of displacement
```

**Why we care:**

- Displacement *out of* a POI confirms that POI's strength.
- Displacement *into* a POI tells us where to look for our next entry (the POI we displaced from is now a target on the next pullback).

The hybrid indicator flags displacement legs with a "▰▰▰" marker.

---

## OTE — Optimal Trade Entry

The **OTE** is a tightened entry pocket: the **62 %–79 % Fibonacci retracement** of an impulse leg.

```
                  ★ swing high (impulse end)
                ╱╲
              ╱    ╲
            ╱        ╲  ── 79 %  ┐
           ╱          ╲           │ OTE
                       ╲ ── 62 %  ┘
                        ╲
                         ╲
                          ★ swing low (impulse start = 100 %)
```

**Rules:**

- Set Fib from impulse start (= 100 %) to impulse end (= 0 %).
- The 62-79 % zone is the OTE.
- Best when the OTE coincides with an OB or FVG.

The indicator draws the OTE automatically when "Show OTE" is on.

---

## IPDA

**Interbank Price Delivery Algorithm.** ICT's mental model that price is *delivered* by an algorithm seeking liquidity, not by aggregate human supply/demand. Whether or not you buy the literal claim, the model is *useful*: it forces you to ask "where would an algorithm hunt next?" — and that question maps cleanly onto liquidity sweeps.

You don't need to know any IPDA mechanics to use this guide. Treat it as ICT's name for what we already do in step 2 (liquidity mapping) of the framework.

---

## Time-zone reference

For practical use you only need three things:

| Need | Look up | Notes |
|---|---|---|
| When is London open in my zone? | NY 02:00 = London 07:00 = your local | DST shifts this twice a year |
| Is the broker showing GMT or NY? | Most MT brokers show GMT+2 / GMT+3 | Indicator inputs let you override |
| Crypto traders | Use **NY time** anyway | Bitcoin still respects NY session bursts |

The Pine indicator uses TradingView's `time(timeframe.period, "0700-1000:1234567", "America/New_York")` to define the NY AM kill zone — DST is handled automatically. The MQL5/MQL4 indicators do the equivalent with `TimeToStruct` and a GMT-offset input.

---

## Putting it together with chapter 02

The five-step framework now has both halves of its toolkit:

| Step | Where (chapter 02) | When (chapter 03) |
|---|---|---|
| 1. HTF bias | Last BOS / structure on Daily | — |
| 2. Liquidity map | EQH/EQL, PDH/PDL | Asia high/low, prior session highs |
| 3. POI selection | OB / FVG / breaker | Inside the bias-aligned half of the range |
| 4. Entry trigger | LTF CHoCH | Inside a kill zone — preferably Silver Bullet |
| 5. Risk & mgmt | SL beyond POI | Move SL at session opens |

→ Re-read [`04-hybrid-framework.md`](04-hybrid-framework.md) (the spine) now that all primitives are defined, then continue to [`05-setup-liquidity-choch-ob.md`](05-setup-liquidity-choch-ob.md).
