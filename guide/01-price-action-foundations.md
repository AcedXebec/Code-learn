# 01 — Price Action Foundations

Before SMC and ICT, there was **price action** — reading what the candles themselves are telling you, with no indicator overlay. This chapter is the bedrock. Skip it and the rest of the guide will feel like memorization.

> **You do not need any indicator to identify a trend, a swing point, or a support level.** Everything in chapters 02 and 03 is built on these primitives.

## 1. The candle

A **candlestick** (a "candle" or "bar") summarizes price for a fixed time window — 1 minute, 15 minutes, 1 hour, etc.

```
            ▲ wick (high)               ▲ wick (high)
            │                           │
       ┌────┴────┐                  ┌───┴────┐
       │  body   │   bullish        │  body  │   bearish
       │  open→  │                  │ ←open  │
       │ close ▲ │                  │ close▼ │
       └────┬────┘                  └───┬────┘
            │                           │
            ▼ wick (low)                ▼ wick (low)
```

- **Open** — first traded price of the period.
- **Close** — last traded price.
- **High / low** — extremes traded during the period.
- **Body** — distance between open and close.
- **Wicks** — distance from body to high (upper wick) and from body to low (lower wick).
- **Bullish candle** — close > open (typically green).
- **Bearish candle** — close < open (typically red).

**What a candle tells you in one sentence:** *who won the fight during this time window, and by how much.*

A **long body, tiny wicks** = decisive move; one side dominated.
A **tiny body, long wicks both sides** = indecision (a "doji").
A **long lower wick, body near top** = sellers tried, buyers won (rejection of lower prices).
A **long upper wick, body near bottom** = buyers tried, sellers won (rejection of higher prices).

> Long-wick rejections that occur **at a known liquidity level** (chapter 02) are the basis of the **liquidity sweep** entry signal.

## 2. Swing points

A **swing high** is a candle whose high is greater than the highs of the `n` candles before it and `n` candles after it. A **swing low** is the mirror image.

```
                            ★ swing high (n=2)
                          ╱   ╲
                       ╱        ╲
                    ╱              ╲
                  ╱                   ╲
                ╱                       ╲    ★ swing low
              ╱                           ╲ ╱
            ╱                              ╳
                                          ╱
                                        ╱
```

**Pine Script:** `ta.pivothigh(high, n, n)` and `ta.pivotlow(low, n, n)`.

**Default `n` we use:**

- M5 / M15 intraday: `n = 5`
- H1 / H4: `n = 3`
- D1: `n = 2`

You can tune `n` higher for fewer / cleaner swings, lower for more responsiveness. The Pine indicator exposes this as `pivotLeft` / `pivotRight` inputs.

> **Subtlety:** A swing high is only **confirmed** `n` bars after it forms. Live, you don't know if the candle is truly a swing until `n` more candles print. The indicators in this repo respect that — they do not repaint past confirmation.

## 3. Trend definitions

| Trend | Pattern of swings |
|---|---|
| **Uptrend** | Higher Highs (HH) **and** Higher Lows (HL) |
| **Downtrend** | Lower Highs (LH) **and** Lower Lows (LL) |
| **Range** | Mixed — neither HH+HL nor LH+LL |

```
   Uptrend:                    Downtrend:                  Range:
                                                          
            HH                  LH                                 SH
           ╱                     ╲                              ╱╲    ╱╲
        HL                        ╲                            ╱  ╲  ╱  ╲
       ╱                           LL                       ─╱────╲╱────╲─
     HL                              ╲                        SL    SL    SL
   ╱                                  LL
```

**The first sign of a trend change** is a swing in the opposite direction.

- In an uptrend: a Lower Low is a **warning** — the trend's structural integrity has cracked. (Smart money calls the close that confirms it a **CHoCH** — Change of Character.)
- In a downtrend: a Higher High does the same in reverse.

We will formalize CHoCH and BOS in chapter 02.

## 4. Support and resistance

A **support** is a horizontal price area where buying pressure has, in the past, exceeded selling pressure — price has bounced off it. **Resistance** is the mirror.

```
   resistance (price has stopped here multiple times)
   ──────────────────────────────────────────────
        ╱╲          ╱╲             ╱╲
       ╱  ╲        ╱  ╲     ╱╲    ╱  ╲
      ╱    ╲      ╱    ╲   ╱  ╲  ╱    ╲
   ──────────────────────────────────────────────
   support
```

Two simple rules retail traders learn:

1. The more times a level holds, the "stronger" it is — supposedly.
2. When a level breaks, role flips: old resistance becomes new support.

**Reality (this is where SMC adds nuance):** every "obvious" support / resistance level is also an **obvious cluster of stops**. Smart money is more interested in *taking* those stops than in respecting them. So in chapter 02 we will *redefine* the strongest S/R levels as **liquidity pools** — and we will plan to trade their **sweep**, not their **bounce**.

## 5. Trendlines and channels

A **trendline** is a diagonal line connecting two or more swing lows (uptrend) or swing highs (downtrend).

Useful, but secondary. We use trendlines mainly to spot:

- **Trendline liquidity** — stops sitting *under* an uptrend's lower trendline are a target for sweeps.
- **Channel breakouts** — combined with a CHoCH, they help confirm trend reversals.

Trendlines are *not* the entry trigger themselves in this guide. They contribute to confluence.

## 6. Volume (briefly)

For Forex, volume on retail charts is **tick volume**, not real volume — it is unreliable. We essentially ignore it.

For futures (NQ, ES, DAX) and crypto, volume is real and is a useful confirmation of displacement. The Pine and MQL indicators include an optional volume filter you can toggle on for these markets.

## 7. The "clean chart" mindset

Strip your chart down. Use:

- A naked candlestick chart.
- The hybrid indicator from this repo (or just pivots if you're learning manually).
- Maybe one moving average for HTF context. (Optional.)

Resist the urge to stack five oscillators. **The cleaner your chart, the easier it is to see structure.**

---

## What you should now be able to do

- [ ] Read any candle and say which side won the period.
- [ ] Mark the last 3–5 swing highs and swing lows on a chart by eye.
- [ ] State whether a chart is in an uptrend, downtrend, or range from those swings.
- [ ] Identify two or three obvious horizontal levels where price has reacted before.

Practice this on **one symbol** (EURUSD H1 is a good first chart) for an hour before moving on. Sketch on screenshots if it helps.

→ Continue to [`02-smc-core.md`](02-smc-core.md).
