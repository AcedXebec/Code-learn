% Price Action + SMC/ICT Hybrid — A Beginner's Guide
% Code-learn repo
% May 2026

# Price Action + SMC/ICT Hybrid

*A beginner-friendly synthesis of classical price action, Smart Money Concepts, and Inner Circle Trader methodology, with companion code for TradingView, MetaTrader 5, and MetaTrader 4.*

---



# 00 — Overview

Welcome. This guide will teach you **one** way to read a price chart that combines three traditions: classical price action, Smart Money Concepts (SMC), and Inner Circle Trader (ICT) methodology. It is written for someone who has **never** opened a chart before, but it does not waste your time if you have.

## How to use this guide

- **Read in order** the first time. Each chapter builds on the previous one.
- **Skim the [glossary](glossary.md)** before chapter 01. Don't memorize — just see what's there.
- **Re-read [04 — The Hybrid Framework](04-hybrid-framework.md) twice.** It is the spine of everything.
- **After chapter 09**, install the code on your platform of choice and try the indicator on a chart you already follow.

## Time budget

| Pace | Total reading | Total practice |
|---|---|---|
| Casual | 4–6 hours | 2 weeks of demo |
| Focused | 1 weekend | 1 week of demo |
| Sprint | 1 evening | Skip to backtest |

## What this guide is **not**

- **Not financial advice.** You are responsible for your own decisions.
- **Not a get-rich scheme.** No edge wins every trade. Plan to lose ~40% of trades even on a great setup.
- **Not platform-locked.** TradingView and MetaTrader are both first-class.
- **Not dogmatic.** ICT and SMC communities have many internal disagreements. Where we pick a side, we say why.

## Mental model: what is "smart money"?

When traders say **smart money**, they mean: the desks at investment banks, hedge funds, and proprietary trading firms that move enough size to actually move prices. These desks cannot just "buy" a billion dollars of EURUSD at market — they would slip through their own order books. They have to **build positions slowly, hide their intent, and trigger retail traders to take the other side** so they can fill.

Three things follow from that:

1. **Stops get hunted.** If you can see equal highs at 1.0850 with stops above, so can the algos. Wicking through them is how big positions get filled.
2. **Imbalances get filled.** When price moves fast in one direction, it leaves "fair value gaps" — the algos tend to revisit those gaps later.
3. **Time matters.** Major participants are most active at session opens (London 02:00 NY, NY 07:00 NY). Outside those windows, the tape is mostly noise.

If you accept those three premises, the rest of this guide is just *systematizing* them.

## What you'll build

By the end you will have:

- A **mental model** for analyzing any chart in 5 steps.
- A **Pine Script v5 indicator** that highlights the structures automatically on TradingView.
- A **Pine strategy** that can backtest 2 of the 4 setups.
- An **MQL5 indicator + EA stub** that does the same on MetaTrader 5.
- An **MQL4 port** for legacy brokers.
- A **PDF reference** of this guide that you can read offline.

→ Continue to [`01-price-action-foundations.md`](01-price-action-foundations.md).


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


# 02 — SMC Core Concepts

This chapter formalizes the building blocks of **Smart Money Concepts**. You will meet them again and again in the four setups (chapters 05-08) and inside the indicator code.

Concepts covered:

- [Market structure](#market-structure)
- [BOS — Break of Structure](#bos)
- [CHoCH — Change of Character](#choch)
- [Liquidity & sweeps](#liquidity)
- [Order Blocks](#order-blocks)
- [Fair Value Gap (FVG)](#fair-value-gap)
- [Breaker blocks](#breaker-blocks)
- [Premium / Discount](#premium-discount)
- [Mitigation](#mitigation)

---

## Market structure

**Market structure** is the sequence of swing highs and swing lows. It is what tells you whether you are in an uptrend, downtrend, or range. We met it briefly in [`01`](01-price-action-foundations.md). Now we will mark it formally.

**Working definition:** the *valid* swing structure on your TF is the chain of swing points whose ordering still produces HH+HL (up) or LH+LL (down) without contradiction.

Beginner tip: **draw it.** Open a chart, click TradingView's horizontal-line tool, and mark every swing with HH/HL/LH/LL labels. The hybrid indicator will do this automatically once installed, but doing it manually for a couple of charts trains your eye.

---

## BOS

**Break of Structure (BOS)** = a candle **closes** beyond the most recent valid swing high (in an uptrend) or swing low (in a downtrend), confirming that the **same** trend continues.

```
   Bullish BOS — uptrend continues
                                                  
                              ★ new HH (BOS!)         
                            ╱╲                        
                          ╱    ╲                      
                        ╱        ╲                    
       last HH ────────────────────╲────────────────
                  ╱╲                ╲                 
                ╱    ╲                ╲   
              ╱        ╲                ╲
             HL          ╲                ╲
                          ╲                ╲
```

**Implementation note:** we use **close beyond**, not just wick beyond. A wick that pokes above and immediately closes back inside is a **sweep**, not a BOS. This distinction is critical — many beginner indicators confuse the two.

**In the indicator:** drawn as a green dotted line and "BOS↑" label.

---

## CHoCH

**Change of Character (CHoCH)** = a candle closes beyond the most recent **opposite** swing point, signaling a possible trend **reversal**.

```
   Bearish CHoCH — uptrend may be reversing
                                                  
              last HH                              
            ╱╲                                     
          ╱    ╲                                   
        ╱        ╲                                 
   ────────────────╲──────────────────────────── last HL
                    ╲                                  
                      ╲                                
                        ╲    ★ close below last HL = CHoCH↓
                          ╲ ╱                          
                            ╳                          
```

**Why it matters:** a CHoCH is the earliest credible signal that the trend has flipped. It's our entry-trigger primitive on LTF in setup #1 ([`05`](05-setup-liquidity-choch-ob.md)).

**Subtlety:** a CHoCH is only meaningful if the *prior* structure was clearly trending. CHoCHs printed inside a range are noise.

---

## Liquidity

**Liquidity** is just resting orders. We care about **stop-loss clusters**, because they:

1. Are placed at obvious levels (above EQH, below EQL, beyond yesterday's high/low).
2. Are *known* to algorithms hunting them.
3. Provide the fuel that takes price to the next level.

### Where liquidity sits

| Location | Type | Example |
|---|---|---|
| Above EQH (equal highs) | Buy-side (BSL) | EURUSD prints 1.0850 twice → stops sit above 1.0850 |
| Below EQL (equal lows) | Sell-side (SSL) | EURUSD prints 1.0820 twice → stops sit below 1.0820 |
| Above yesterday's high (PDH) | BSL | Magnet for sweeps in NY session |
| Below yesterday's low (PDL) | SSL | Same in reverse |
| Above session highs (Asia, London) | BSL | Asia high often swept in London open |
| Above / below trendlines | Both | Trendline-breaking stops |

### Liquidity sweep

A **sweep** is when price wicks beyond a known liquidity level and closes back inside. The signature pattern:

```
                                  ★ sweep wick takes EQH...
                                  │
   ───── EQH ──────╳──────────────╳───────────  ...then closes back inside
                 ╱╲              ╱            
               ╱    ╲          ╱              (this is our entry signal,
             ╱        ╲      ╱                 not a breakout)
   ───────────────────╲────────────────────── 
```

**Rules of thumb:**

1. The sweep candle should make a **new high** beyond EQH but close back **below** the EQH level.
2. The sweep should be reasonably **sharp** — a slow grind through means it might be a real breakout, not a hunt.
3. The sweep should appear during a **kill zone** (chapter 03) for the cleanest probability.

**In the indicator:** sweeps are flagged with "🩸 SSL" or "🩸 BSL" markers.

---

## Order Blocks

An **Order Block (OB)** is the **last opposing-direction candle (or candle cluster)** immediately before a strong impulsive displacement move. It marks the zone where institutional orders were filled before the move kicked off.

### Bullish OB (we want to buy from it)

```
   ★ bullish OB = the last DOWN candle before the up displacement
                                                                
                              ╱╲       ╱╲                        
                            ╱    ╲   ╱    ╲                      
                          ╱        ╳        ╲                    
                        ╱       up impulse   ╲                   
                      ╱                                          
   ┌─────────────┐  ╱                                            
   │  bearish    │╱  ← when price returns to this body / wick,   
   │  candle ★   │     it tends to react bullishly               
   └─────────────┘                                               
```

**Marking convention** (this is what the indicator does):

- **Top of OB box** = high of the bearish candle.
- **Bottom of OB box** = low of the bearish candle.
- **Validity** until price closes through it (then it becomes a *breaker*, see below).

### Bearish OB (we want to sell from it)

Mirror image. The last **bullish** candle before a strong **down** displacement.

### Why it works

Two standard explanations (both true to a degree):

1. *Order-flow story* — institutions filled their longs (or shorts) at that candle; if price returns to the area cheaply, they will defend it.
2. *Liquidity story* — those same prices have stops nested behind them; an OB tap pulls in stop-fills that fuel the next move.

You don't need to pick a side; just trade the pattern.

### What makes an OB *high quality*

- The **displacement after the OB is strong** — multiple consecutive same-color candles, ideally with an FVG.
- The **OB swept liquidity before its formation** (e.g. the candle's wick pierced an EQL).
- The **OB sits in the bias-aligned half of the range** (premium for bearish, discount for bullish).
- The **OB is unmitigated** (untouched since its formation).

The hybrid indicator scores OBs by these criteria and toggles a "★" flag when all four are present.

---

## Fair Value Gap

**FVG** = a 3-candle pattern where the wick of candle 1 and the wick of candle 3 do **not** overlap, leaving an "imbalance" gap on candle 2.

### Bullish FVG

```
                              candle 3
                            ┌─┴─┐
                            │   │  low of candle 3
                            └─┬─┘  ────── ▲
                              │           │ FVG (gap)
                  candle 2    │           │
                ┌─┴─┐         │           │
                │ ███       (huge body)   │
                │ ███                     │
                └─┬─┘                     ▼
                  │  high of candle 1     ──────
       candle 1 ┌─┴─┐
                │   │
                └───┘
```

The unfilled space between **candle 1's high** and **candle 3's low** is the bullish FVG. We expect price to **return and fill it** — that's our entry zone.

### Bearish FVG

Mirror image (gap between candle 1's low and candle 3's high).

### Mitigation rules

- **Partial mitigation** — price wicks into but not through the FVG. Still considered "active."
- **Full mitigation** — price closes through the FVG. The gap is "filled" — its edge is largely spent.

### Confluences that strengthen an FVG

- It sits inside an OB.
- It formed during the *displacement* leg out of liquidity.
- Multiple FVGs stack in the same direction ("FVG cluster").

### What FVGs are not

- Not every gap is a FVG. The 3-candle wick-overlap rule must hold.
- Weekend gaps in forex (Sunday open) are not "fair value gaps" in the SMC sense — they're calendar gaps.

---

## Breaker blocks

A **breaker block** is an OB that **failed** — i.e. price broke through it and made a new structural extreme on the other side. When price *returns* to a breaker, it tends to reject *opposite* to the original OB direction.

```
   1) original bearish OB forms              2) price breaks above it (OB fails)
                                              
                ╱╲                                  
              ╱    ╲                                ★ break above OB
   ┌────────╱──────╲────┐                          ╱
   │ bull candle (OB)   │                        ╱
   └─────────────╲──────┘                      ╱
                  ╲                          ╱
                                                
   3) price returns to former OB → BREAKER (now BULLISH POI)
                                              
                ╲                                   ★ rejection
                  ╲                              ╱
   ┌──────────────╲────┐                       ╱
   │ now a BREAKER     │ ──── price taps ───╱
   └──────────────╳────┘                     ╲
                  ╳                            ╲
```

**Rule:** a breaker is *only* tradable in the **direction of the move that broke the original OB** — i.e. if a bearish OB was broken upward, we now buy from the breaker, not sell.

**Use case:** breakers are great POIs *after* a CHoCH has confirmed trend reversal — see [`08-setup-breaker-fvg.md`](08-setup-breaker-fvg.md).

---

## Premium / Discount

Take any clear range — recent swing high to swing low. The midpoint divides it into:

- **Premium** = upper 50% — *expensive* — bears want to sell here.
- **Discount** = lower 50% — *cheap* — bulls want to buy here.

```
   ┌───────────────── swing high              
   │                                          
   │   PREMIUM (sell zone if bearish)         
   │                                          
   ├───────────────── 50% midpoint ────────── 
   │                                          
   │   DISCOUNT (buy zone if bullish)         
   │                                          
   └───────────────── swing low               
```

**Optimal Trade Entry (OTE)** is a tighter sub-zone within the bias-aligned half: the **62 %–79 %** Fibonacci retracement of the impulse leg. This is ICT's preferred entry pocket.

The hybrid indicator draws the 50 % midpoint, the OTE band, and the premium/discount shading automatically.

---

## Mitigation

When price returns to an OB or FVG and reacts (or fails to react), we say the POI has been **mitigated**.

- A **partially mitigated** POI may still produce a reaction on a second tap.
- A **fully mitigated** POI has lost most of its edge — skip it.
- A **broken** POI has had a candle close beyond it — it is gone (and may have become a breaker).

**The indicator's POI tracker:**

1. Draws the box when the POI forms.
2. Shrinks / dims it when partially mitigated.
3. Removes (or recolors as breaker) when broken.

---

## Putting it together

Here is a typical bullish setup with everything labeled:

```
                       ╳ TP2 (PDH liquidity)             
                     ╱                                   
                   ╱                                     
                 ╱   ★ TP1 (EQH liquidity)               
               ╱   ╱                                     
             ╱   ╱                                       
           ╱   ╱                                         
         ╱   ╱       ★ entry: bullish OB tap + M5 CHoCH↑ 
       ╱   ╱        ╱                                    
     ╳ ── ╳ ──────╱   ← bullish OB                       
   ╱  CHoCH↑                                             
                  ★ liquidity sweep (SSL grabbed below   
                      Asia low) — the FUEL              
   ──────── EQL/Asia low (sweep target) ───              
```

Five primitives, one chart:

1. Liquidity sweep below Asia low.
2. Bullish CHoCH on M5.
3. Bullish OB just above the sweep.
4. Entry on retest of OB.
5. Targets at EQH and PDH liquidity.

This is exactly setup #1 in chapter 05.

→ Continue to [`03-ict-essentials.md`](03-ict-essentials.md).


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


# 04 — The Price Action + SMC/ICT Hybrid Framework

> **Read this chapter twice.** It is the spine of the whole guide. Every later chapter (and every line of code in this repo) refers back to the **5-step decision flow** below.

The hybrid framework answers one question:

> **"Where, when, and why should I take a trade — and where do I get out if I'm wrong?"**

It blends three lineages:

| Lineage | What it gives you |
|---|---|
| **Classical Price Action** | The map — candles, swings, support / resistance, trend |
| **Smart Money Concepts (SMC)** | The "where" — order blocks, fair value gaps, liquidity, premium/discount |
| **ICT (Inner Circle Trader)** | The "when" — sessions, kill zones, displacement, AMD model |

You can trade with just one of them. You cannot get **confluence** (multiple unrelated reasons agreeing) without combining them.

---

## The 5-step flow

```
   ┌──────────────────────────────────────────────────────────────────┐
   │ 1. HTF BIAS         — Daily / H4 trend, premium or discount?    │
   │                                                                  │
   │ 2. LIQUIDITY MAP    — Where are the obvious stops resting?      │
   │                                                                  │
   │ 3. POI SELECTION    — Pick an OB / FVG / breaker aligned bias   │
   │                                                                  │
   │ 4. ENTRY TRIGGER    — Wait for LTF CHoCH or displacement in     │
   │                       a kill zone                               │
   │                                                                  │
   │ 5. RISK & MGMT      — SL beyond POI, partials at liquidity,     │
   │                       runner to opposing draw on liquidity      │
   └──────────────────────────────────────────────────────────────────┘
```

Every setup we teach (chapters 05–08) is just a **different shape** of these same five steps.

---

## Step 1 — HTF (Higher Timeframe) bias

**Question:** *Is price more likely to go up, down, or stay rangy from here?*

**Tools:**

- Look at the **Daily** chart first, then **H4**.
- Identify the most recent valid **swing high** and **swing low**.
- Mark the **range** — top half is **premium**, bottom half is **discount**.
- Note the most recent **BOS** (Break of Structure). The direction of the last BOS = your bias *until invalidated by a CHoCH*.

**Beginner heuristic:**

```
   Last BOS up?    → Bias = BULLISH. Look for buys in DISCOUNT.
   Last BOS down?  → Bias = BEARISH. Look for sells in PREMIUM.
   Choppy / no BOS → Stand aside. Do NOT force a setup.
```

**Why HTF first?** Because LTF (lower timeframe) signals are noisy. The HTF gives you an "edge of the river" — it tells you which direction the current is flowing so you stop trying to swim upstream.

→ *More on swings, BOS, and CHoCH:* [`02-smc-core.md`](02-smc-core.md).

---

## Step 2 — Liquidity map

**Question:** *Where are the obvious clusters of stop losses?*

**Tools:**

- **Equal highs (EQH)** and **equal lows (EQL)** — retail traders place stops just above/below these.
- **Previous Day High / Low (PDH / PDL)** — the day's "extreme" — magnets for sweeps.
- **Asia session high/low** — Asia is often the **accumulation** range; its extremes are stop pools.
- Trendline / range boundary touches.

**Why this matters:** Smart money fills big orders by hunting these stops. A move *above* EQH that immediately comes back inside is not a breakout — it is a **liquidity sweep**.

```
                                  liquidity sweep
                                       ▼
                       ╱╲          ────╲ wick takes EQH
                      ╱  ╲     ╱╲ ╱     ╲ then closes back inside
   ─────EQH ─────────╱────╲───╱──╲──────╲ ─── (stops above EQH grabbed)
                    ╱      ╲ ╱    ╲      ╲
                   ╱        ╳      ╲      ╲
   ─────EQL ───────────────────────────────
```

We trade **with** the sweep — into the direction it reverses.

→ *More on liquidity:* [`02-smc-core.md`](02-smc-core.md#liquidity).

---

## Step 3 — POI (Point of Interest) selection

A **POI** is a price zone you intend to enter from. We use three kinds:

| POI | What it is | Best when |
|---|---|---|
| **Order Block (OB)** | The last opposite-color candle before a strong displacement move | Trend continuation after pullback |
| **Fair Value Gap (FVG)** | A 3-candle imbalance gap | Fast / aggressive entries |
| **Breaker block** | A failed OB whose role flipped | Trend-change confirmation |

**Selection rules:**

1. The POI must be on the **HTF-bias side** of the range (bullish bias → POI in discount, bearish bias → POI in premium).
2. The POI must sit between current price and the **draw on liquidity** (the next big stop pool).
3. The POI must be **unmitigated** — price has not yet returned and reacted to it.

→ *More on OBs, FVGs, breakers:* [`02-smc-core.md`](02-smc-core.md#order-blocks).

---

## Step 4 — Entry trigger

**Question:** *Has price actually arrived at the POI and shown a reason to turn?*

This is where price action and ICT timing combine.

**Required conditions (all of):**

1. **Price taps the POI** — a wick or body inside the OB / FVG / breaker.
2. **LTF CHoCH** (Change of Character) on M1 / M3 / M5 — the LTF trend flips against the move that brought price into the POI.
3. **Time filter** — for intraday setups, we prefer the **kill zones** (London 02–05 NY time, NY AM 07–10, NY PM 13–16), and ideally the **Silver Bullet** sub-windows (10–11 AM NY, 14–15 NY).

The entry itself: a limit order at the POI, **or** a market order on the LTF CHoCH after the sweep.

→ *More on kill zones and Silver Bullet:* [`03-ict-essentials.md`](03-ict-essentials.md).

---

## Step 5 — Risk & management

**Stop loss (SL):**

- Just **beyond** the POI — past the high of a bearish OB or the low of a bullish OB, plus a small buffer (1× ATR or a few pips).
- Never inside the POI. If you are inside it and wrong, you have no edge to defend.

**Position size:**

- Risk a **fixed percentage** of account per trade — beginner default: **0.5–1%**.
- Position size = `(Account × Risk%) / SL distance in pips × pip value`. The Pine and MQL code do this for you.

**Take profit (TP):**

- **TP1**: opposing minor liquidity (e.g., next EQH / EQL) — take 50% off, move SL to break-even.
- **TP2**: opposing major liquidity (PDH / PDL, weekly high/low) — take 25%.
- **Runner**: the remaining 25% trails to a HTF structure level.

```
                                        ── TP2 (PDH) ─── 25% out
                                   ╱
                              ╱
                         ╱
                    ╱── TP1 (EQH) ────────────── 50% out, SL → BE
               ╱
          ╱
     ╱
   entry (OB tap + CHoCH)
   SL just below OB ────────────── if hit: -1R, accept and move on
```

**Beginner rule:** Skip trades where TP1 is closer than 2× the SL distance. We want at least a **1:2 risk-reward** baseline.

→ *Full risk module:* [`09-risk-management.md`](09-risk-management.md).

---

## A worked example in 5 steps

EURUSD, M15, on a Tuesday morning London open.

| Step | What you observe | Decision |
|---|---|---|
| 1 — HTF bias | Daily made a BOS up last Friday; price now in lower half of D1 range | **Bullish bias, look for buys in discount** |
| 2 — Liquidity | EQL at 1.0820 (Asia low); PDL at 1.0805 | **Stops resting below 1.0820 / 1.0805** |
| 3 — POI | M15 bullish OB at 1.0810–1.0815, formed before yesterday's NY rally; unmitigated | **POI = M15 OB at 1.0810** |
| 4 — Trigger | London open: price wicks to 1.0808 (sweeps PDL), closes back above 1.0815, M1 CHoCH up | **Enter at 1.0815** |
| 5 — Risk | SL 1.0803 (5 pips below sweep low). TP1 1.0840 (Asia high). TP2 1.0870 (yesterday's NY high). | **Risk 0.5%; size = 0.5%/12 pips. R:R to TP1 ≈ 2.0** |

That is the entire framework. Repeat. Forever.

---

## What to do when nothing lines up

**Stand aside.** A real edge exists only when most of the steps agree. If you are at step 3 and you cannot find a clean POI on the bias side, the setup does not exist today. Forcing it is the #1 reason beginners blow accounts.

> **The market pays you to wait, not to trade.**

---

## Where this framework comes from

The framework is our synthesis. The components have well-known origins:

- *Price action* — Wyckoff, Al Brooks, Bob Volman.
- *Smart Money Concepts* — popularized in the retail forex community 2018-onward.
- *ICT* — Michael J. Huddleston ("Inner Circle Trader") public mentorships, 2014-present.

See [`references.md`](references.md) for full citations and recommended further reading.

---

**Next:** [`05-setup-liquidity-choch-ob.md`](05-setup-liquidity-choch-ob.md) puts this framework into a concrete, mechanical setup.


# 05 — Setup #1: Liquidity Sweep + CHoCH + OB Entry

**The bread-and-butter SMC setup.** It works on every market, every timeframe, and is the most mechanical of the four. Master this one before touching the others.

## The story in one paragraph

In a clear HTF uptrend, price pulls back into a discount zone, dips beyond a recent low to **sweep sell-side liquidity**, then prints a **bullish CHoCH** on the LTF as institutions buy the dip. We enter on the retest of the **bullish OB** that produced the CHoCH. SL goes just below the sweep low; TPs are the prior EQH and PDH.

Mirror the entire thing for shorts in downtrends.

## Visual anatomy

```
                                                ╳ TP2 = PDH liquidity
                                              ╱
                                            ╱
                                          ╱
                                        ╳   TP1 = EQH (old liquidity)
                                      ╱
                                    ╱
                                  ╱
                            ╱╲   ╱
                          ╱   ╲ ╱   
                        ╱      ╳     ★ entry: tap the bullish OB,
                      ╱       ╱        confirmed by M5 CHoCH↑
                    ╱       ╱
   ────╳───────────────────╳ ──── bullish OB box
        ╲               ╱  
          ╲           ╱    
            ╲       ╱      ★ M5 CHoCH↑ here = trigger
              ╲   ╱
                ╲ ╱        
                ╳   ★ liquidity sweep — wick takes Asia low / EQL
   ───── EQL / Asia low ────────────── (stops below grabbed)
```

## Required conditions (every box must check)

| # | Condition | How to verify |
|---|---|---|
| 1 | HTF bias is bullish | Last D1/H4 BOS is up; price in lower half of HTF range |
| 2 | A clear sell-side liquidity pool exists below | EQL, Asia low, PDL within reach |
| 3 | Price sweeps the SSL | Wick takes the level, candle closes back above it |
| 4 | Sweep happens in a kill zone (preferred) | London KZ or NY AM KZ |
| 5 | LTF CHoCH (M1/M3/M5) | Close above the most recent LTF lower-high |
| 6 | A bullish OB formed at the sweep | Last bearish candle before the CHoCH-up displacement |
| 7 | OB is unmitigated | Price has not yet revisited it |
| 8 | TP1 to SL distance ≥ 1.5R, TP2 ≥ 3R | Calculate before entry |

(Mirror for shorts.)

## Step-by-step playbook

### Pre-trade (do this once per session)

1. Open the Daily chart. Identify the most recent BOS direction → that's your bias.
2. Switch to H4. Mark the active range (last clean swing high to swing low). Identify which half (premium or discount) price is in.
3. Mark the obvious liquidity: EQH, EQL, PDH, PDL, Asia high, Asia low.
4. Drop to your trading TF (M15 default). Identify the **closest** liquidity pool *opposite* to your bias direction (e.g. for longs, the closest SSL pool *below* current price).
5. Mark unmitigated bullish OBs near that liquidity pool.

### In-session

6. Wait for the kill zone to start.
7. Wait for price to **sweep** the liquidity pool — wick beyond, close back inside. **Do not enter on the sweep itself.**
8. Drop to M1/M3 looking for a **CHoCH** in the bias direction. The CHoCH must close beyond the most recent LTF opposite swing.
9. Identify the **OB on the displacement leg that produced the CHoCH** — this is the last bearish candle before the up-impulse for longs.
10. Place a **buy limit** at the OB top (or 50 % of the OB body for tighter fill).
11. SL = `low_of_sweep_candle − 1×ATR_M5` (or fixed pip buffer per symbol).
12. TP1 = nearest opposing liquidity (EQH / Asia high). TP2 = next major (PDH / weekly high).

### Post-entry management

13. At TP1: take **50 %**, move SL to break-even.
14. At TP2: take **25 %**, leave 25 % runner with a trailing SL behind each new HL.
15. If a new HTF CHoCH against you prints before TP1: close manually.

## Worked example — EURUSD M15

| Step | Observation | Numbers |
|---|---|---|
| Bias | D1 BOS up, EURUSD in lower 40 % of weekly range | Bullish |
| Liquidity | Asia low at 1.0820, PDL at 1.0805 | SSL targets |
| Sweep | London open: candle wick to 1.0808, closes 1.0817 | PDL swept |
| CHoCH | M5 closes above prior LH at 1.0820 | M5 CHoCH↑ |
| OB | M5 bearish candle 1.0810–1.0815 right before the up impulse | unmitigated |
| Entry | Buy limit at 1.0815, fill at next pullback | 1.0815 |
| SL | 1.0803 (5 pips below sweep low) | 12-pip risk |
| TP1 | Asia high 1.0843 | +28 pips, 2.3 R |
| TP2 | Yesterday NY high 1.0871 | +56 pips, 4.6 R |
| Result | TP1 hit on the next London push, runner stopped at BE | +1.15 R captured |

**Risk**: 0.5 % of account. **Position size** = 0.5 % × balance / (12 pips × pip value).

## Common mistakes

- ❌ Entering **on** the sweep without waiting for CHoCH. Sometimes the sweep keeps going. The CHoCH is the confirmation.
- ❌ Placing SL **inside** the OB. Use the **sweep low** as SL anchor, not the OB body.
- ❌ Trading against HTF bias because the LTF "looks ready." LTF CHoCH inside HTF bearish range is a counter-trend trade, not this setup.
- ❌ Skipping the time filter. London close (11:00 NY +) and pre-Asia (16:00–19:00 NY) often produce false sweeps.
- ❌ Greedy TPs. Aim for the *next* liquidity pool, not 4× away. Take partials.

## How the indicator helps

The hybrid indicator [`tradingview/pa_smc_ict_hybrid.pine`](../tradingview/pa_smc_ict_hybrid.pine) and [`mt5/PA_SMC_ICT_Hybrid.mq5`](../mt5/PA_SMC_ICT_Hybrid.mq5) automate steps 1–6 of *Pre-trade* and steps 7–9 of *In-session*. Setup-1-specific alerts:

- `Sweep+CHoCH long` — triggers when conditions 3 & 5 confirm in the same kill zone.
- `Sweep+CHoCH short` — mirror.

These alerts are wired to `alertcondition()` in Pine and `Alert()` / `SendNotification()` in MQL.

## Backtestable variant

This setup is **mechanical enough** to backtest. The strategy file [`tradingview/pa_smc_ict_strategy.pine`](../tradingview/pa_smc_ict_strategy.pine) implements:

- Long entry: `bullishSweep and bullishCHoCH and inKillzone`
- Short entry: mirror
- SL: sweep extreme ± buffer
- TP1: closest opposing liquidity pool
- TP2: next opposing pool
- Position sizing: % of equity

Run it on EURUSD / GBPUSD / BTCUSD M15 over 6 months for a baseline. Win rate **≈ 40-55 %** with average **R ≥ 1.6** is a realistic edge expectation.

→ Continue to [`06-setup-silver-bullet.md`](06-setup-silver-bullet.md).


# 06 — Setup #2: ICT Silver Bullet (15-minute Window)

The **Silver Bullet** is a tightly time-boxed setup. The rules are simple — the discipline is the hard part.

## The story in one paragraph

During a 60-minute Silver Bullet window (10:00–11:00 NY for the most popular variant), price often delivers a clean sweep + FVG + retest in the **direction of the daily bias**. We trade exactly that: take the FVG that forms inside the window, on the bias side, after a liquidity sweep, and target the next obvious liquidity pool. SL is a few pips beyond the FVG.

## The three Silver Bullet windows (NY time)

| Window | Time | Comment |
|---|---|---|
| London SB | 03:00 – 04:00 | Often *the* London-open expansion |
| NY AM SB | 10:00 – 11:00 | Most popular; classic ICT default |
| NY PM SB | 14:00 – 15:00 | After the NY lunch lull |

**Beginner advice:** start with **NY AM SB only**. One window, one symbol, one chart, one trade per day. Build muscle before adding more.

## Visual anatomy

```
                                                  ★ TP = next liquidity pool
                                                ╱
                                              ╱
                                            ╱
                                          ╱
                                        ╱      
                              ╱╲      ╱        
                            ╱   ╲    ╱         
                          ╱      ╲ ╱           ★ entry: tap the FVG
                        ╱         ╳           ╱
                      ╱          ╱
                    ╱           ╱     ┌──────────────┐
                  ╱            ╱      │ bullish FVG  │  ← we tap here
                 ╱            ╱       │  (M5/M3)     │
                ╱            ╱        └──────────────┘
              ╱             ╱
            ╱              ╱
   ────╳───────────────────╳ ── window opens (10:00 NY)
        ╲                 ╱   ★ sweep of SSL inside the window
          ╲             ╱
            ╲         ╱
              ╲     ╱
                ╳ ╳
   ──── SSL (pre-window low) ────
```

## Required conditions

| # | Condition | How to verify |
|---|---|---|
| 1 | HTF bias is set (long or short) | Daily / H4 framework as in chapter 04 |
| 2 | Now is **inside** a Silver Bullet window | Wait. Discipline. |
| 3 | A liquidity pool gets swept inside the window | wick beyond + close back inside |
| 4 | An **FVG** forms on the displacement leg out of the sweep | 3-candle imbalance, on bias side |
| 5 | Price retraces back into the FVG | partial fill at minimum |
| 6 | TP distance ≥ 1.5 R to the next liquidity pool | calc before entry |

## Step-by-step playbook (NY AM SB — bullish bias)

### Before the window opens

1. Confirm Daily bias is up (per chapter 04).
2. On M15 / M5, mark the obvious SSL below current price: **NY 09:00 low**, **London session low**, **PDL**.
3. Have a calculator / position-size function ready.

### Inside the window (10:00 – 11:00 NY)

4. Wait for a **sweep** of one of the SSL pools.
5. Wait for the **first bullish FVG** that prints **after** the sweep. This is your POI.
6. Place a **buy limit at the top of the FVG** (or use a manual market order on the M1 retrace into it).
7. SL = low of the sweep candle − buffer.
8. TP = closest BSL pool above current price (often the M15 swing high or NY 09:00 high).

### After 11:00 NY

9. If you are not in a trade, **stop hunting**. The window is closed.
10. If you are in a trade, manage it normally — SL to BE at TP1, runner trails.

## Subtleties (read these — most beginners miss them)

- **Price must be on the bias side of the day's range when the window opens.** If you're bullish but price is at the day's high already, the SB long is gone.
- **The FVG must form *inside* the window**, not before it. An FVG from 09:30 NY is *not* a Silver Bullet FVG.
- **One trade per window.** If you take the first setup and it fails, **do not** re-enter unless a clean second sweep + FVG forms. Two losses in one window is normal — three is overtrading.
- **The Silver Bullet is judgment-heavy on bias.** This is why the strategy file *does not* automate it — only the indicator highlights the window and the FVG.

## How the indicator helps

In `pa_smc_ict_hybrid.pine` (and the MQL versions):

- The window background is shaded **gold** during each Silver Bullet hour.
- New FVGs are drawn as boxes; an "SB ★" tag is added if the FVG forms inside the window.
- An alert `SilverBullet FVG formed` fires the moment a qualifying FVG is detected.

You then make the bias call yourself.

## Common mistakes

- ❌ Trading every window every day. Discipline cuts to ~3 setups per week per symbol.
- ❌ Entering before the window opens. The FVG must form inside the window.
- ❌ Ignoring HTF bias. The Silver Bullet is *not* a contrarian setup.
- ❌ Letting the SL drift to the FVG midpoint. The SL belongs *beyond* the sweep extreme.

## Worked example — NQ futures, 5-minute, NY AM SB

| Step | Observation |
|---|---|
| Bias | Daily HH last week, price in discount on H4 → long bias |
| Pre-window | NY 09:30 open low at 18,210; PDL at 18,180 |
| 10:05 NY | Spike down to 18,205 wicks the 09:30 low — **SSL sweep ✓** |
| 10:10 NY | Three M3 candles up; second-candle gap from 18,222 to 18,232 is a **bullish FVG ✓** |
| 10:15 NY | Price retraces to 18,232 (top of FVG) — **entry ✓** |
| SL | 18,201 (4 ticks below sweep low) |
| TP1 | NY 09:30 high at 18,260 |
| Result | TP1 hits at 10:38 NY for +2.6 R |

→ Continue to [`07-setup-power-of-3.md`](07-setup-power-of-3.md).


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


# 08 — Setup #4: Breaker Block + FVG Mitigation

This is the **trend-reversal** workhorse. While setups #1-#3 trade *with* HTF bias, the breaker setup catches the moment when bias is **flipping** — and rides the new direction.

## The story in one paragraph

A clean OB on the *current* trend side **fails**: price closes through it on a strong opposite move. That failed OB has now flipped role — it is a **breaker**. We wait for price to retrace back to the breaker, ideally tagging an FVG that formed on the breaking move, and we enter in the **direction of the break**, against the prior trend.

## Anatomy

```
   1) Up-trend in progress with bullish OB providing support
   
                                          ╱╲          ╱
                                        ╱   ╲       ╱
                                      ╱      ╲    ╱
                                ╱╲ ╱           ╲╱
                              ╱   ╳ 
                            ╱     ┌──────────────┐
                          ╱       │ bullish OB   │ → was working
                                  └──────────────┘
                                                    
   2) OB FAILS — price closes hard through it (CHoCH↓ on HTF)
   
                                                     ╱╲
                                                   ╱   ╲
   ┌──────────────┐                          ★ CHoCH↓ (close beyond
   │ now BREAKER  │ ────────╲                   prior swing low)
   │  (was OB)    │          ╲                ╱
   └──────────────┘            ╲             ╱
                                 ╲          ╱
                                   ╲      ╱
                                     ╳  ╱   ★ FVG on the break leg
                                       ╳ 
                                                    
   3) Price retraces UP into the breaker — we now SHORT the retest
   
                                  ★ entry: tap the breaker (former OB)
   ┌──────────────┐               + the FVG inside it
   │ breaker      │ ── tap ──╳    short setup
   └──────────────┘          ╳╲
                              ╳ ╲
                                ╲
                                 ╲   target: the broken support /
                                  ╲   the next downside liquidity
                                   ╲
```

The ASCII shows a *bearish* breaker (failed bullish OB → now we short). For a bullish breaker, mirror everything (failed bearish OB → now we long).

## Required conditions

| # | Condition |
|---|---|
| 1 | A previously valid OB (bullish or bearish) was breached by a strong opposite move |
| 2 | The breaching move printed a **HTF CHoCH** (D1 → H4 → H1 cascade preferred) |
| 3 | The breach left a clear **FVG** on the breaking leg |
| 4 | Price retraces to the former OB (now the breaker) |
| 5 | An LTF CHoCH confirms the new direction at the breaker tap |
| 6 | TP distance ≥ 2R to the next major liquidity in the new direction |

## Step-by-step playbook (bearish breaker — i.e. you are shorting)

### Pre-trade

1. Identify the most recent valid bullish OB on H1 / H4.
2. Look for evidence the OB has **failed** — a candle closes well below it, a HTF swing low is broken, the M15 / H1 trend has flipped.
3. Mark the **FVG** left on the breaking leg.
4. Mark the **breaker zone** = the original OB box. (The hybrid indicator changes the box color from green to orange when an OB becomes a breaker.)
5. Identify the **next major liquidity** below — PDL, weekly low, prior month low.

### In-session

6. Wait for price to retrace upward into the breaker zone.
7. Inside the breaker, look for the **FVG** to be tagged.
8. Confirm with an **M5 / M3 CHoCH down** at the tap (close below the most recent LTF higher low).
9. Place a **sell limit** at the FVG top, or sell market on the M5 CHoCH.
10. SL = above the breaker high + 1×ATR.
11. TP1 = the **broken low** (where the original OB failed). TP2 = the next major liquidity.

## Why the breaker matters

Breakers are how *trend reversals* unfold without you having to predict the top or bottom. You let the market itself do the trend-flip work (the CHoCH, the broken OB, the FVG) and you simply **react to the retest**. This is much higher probability than countertrend trading off arbitrary levels.

## Bullish breaker (you are buying)

Same logic, mirrored:

1. A bearish OB fails — price closes hard above it.
2. CHoCH up on HTF, FVG on the breaking leg.
3. Price retraces to the breaker.
4. M5 CHoCH up at the tap.
5. Buy the FVG inside the breaker. SL below breaker low.
6. TP1 = broken high, TP2 = next major BSL pool.

## Common mistakes

- ❌ Trading every "wick through" an OB as a breaker. The OB must **close** beyond, with HTF CHoCH evidence.
- ❌ Confusing setup-#1 with this. In setup #1 you trade *with* the OB; in setup #4 you trade *against* the OB (because it failed).
- ❌ Entering at the breaker without LTF CHoCH confirmation. A wick into a breaker that holds is not the same as a tagged FVG + LTF CHoCH.
- ❌ Setting TP at "infinity." TP1 should be the broken structure level — that's a high-probability magnet.

## How the indicator helps

The hybrid indicator handles the mechanical parts:

- OBs that get broken automatically **recolor as breakers**.
- The **FVG on the breaking leg** is highlighted with a "★ break-FVG" label.
- An alert `Breaker tagged + LTF CHoCH` fires when conditions 4 and 5 occur in the same kill zone.

Setup #4 **is** included in the strategy backtest file (alongside setup #1) because its entry conditions are mechanical enough.

## Worked example — BTCUSDT H1

| Step | Observation |
|---|---|
| Prior trend | Bullish, BTC making HHs since 67k |
| The OB | H1 bullish OB at 70.2k–70.5k held twice, providing dip support |
| The break | Daily candle closes at 69.4k (below 70.2k OB) → **CHoCH↓** on H1 + Daily |
| The FVG | M15 bearish FVG at 70.1k–70.0k on the break leg |
| Retrace | Three days later price rallies to 70.05k — tags FVG and breaker |
| Trigger | M5 CHoCH down at 70.05k → **sell** at FVG top |
| SL | 70.55k (above breaker high + buffer) |
| TP1 | 69.4k (the broken low) |
| TP2 | 67.9k (weekly low) |
| Result | TP1 hit overnight (+1.6R), runner stopped at TP1 BE |

→ Continue to [`09-risk-management.md`](09-risk-management.md).


# 09 — Risk Management

A perfect setup with sloppy risk management still ruins your account. This chapter is the most important one in this guide, even though it is the least exciting.

## The two rules

1. **Risk a fixed percentage of equity per trade.** Beginner default: **0.5 %**. Aggressive ceiling: **1 %**. Never more.
2. **Never move your stop loss further from price.** You can only move it closer (to break-even, or trailing).

If you cannot internalize these two rules, no setup will save you.

## Position sizing — the formula

```
   risk_$         = account_equity × risk_pct
   sl_distance    = entry_price − sl_price          (longs)
                  = sl_price    − entry_price       (shorts)
   pip_distance   = sl_distance / pip_size          (forex / metals)
   contracts      = risk_$ / (pip_distance × pip_value)
```

Examples:

| Asset | account | risk% | entry | SL | size |
|---|---|---|---|---|---|
| EURUSD M15 | $10,000 | 0.5 % | 1.0815 | 1.0803 | (50 / 12) / 10 = **0.42 lots** |
| BTCUSDT H1 | $10,000 | 0.5 % | 70,050 | 70,550 | 50 / 500 = **0.10 BTC** |
| NQ 5-min | $10,000 | 0.5 % | 18,232 | 18,201 | 50 / (31×5) ≈ **0.32 contracts** (round to 0) |

> If `contracts` rounds to zero or below your broker's minimum, **the SL is too wide** for your account size on this instrument. Skip the trade.

## Where to place the stop

| Setup | SL anchor | Buffer |
|---|---|---|
| 1 — Sweep + CHoCH + OB | Below sweep low (long) / above sweep high (short) | 1× ATR(M5) or 5–10 pips |
| 2 — Silver Bullet | Below FVG low − sweep low extreme | 0.5–1× ATR |
| 3 — Power of 3 | Below the day's Judas extreme | a few pips |
| 4 — Breaker + FVG | Beyond the breaker's far edge | 1× ATR |

**Never** put the SL inside the POI you're entering from. If price *fills* your POI and you're wrong, you need room to be obviously wrong (i.e. price closes through the POI).

## Where to place targets

The hybrid framework says: **target the next significant liquidity pool**. Targets are not arbitrary R-multiples — they are *places where stops actually rest*.

| TP # | Target | Action |
|---|---|---|
| TP1 | Closest opposing liquidity (EQH/EQL, session high/low) | Take 50 %; SL → BE |
| TP2 | Next major liquidity (PDH/PDL, weekly H/L) | Take 25 % |
| Runner | Trail behind each new HL/LH on the trading TF | Let it ride |

> **Minimum acceptable trade**: TP1 must be at least **1.5 R** away. Below that, skip — the math doesn't work over a sample.

## Expectancy math

A profitable system needs:

```
   E  =  win_rate × avg_R_win  −  loss_rate × avg_R_loss   >   0
```

With the hybrid framework, realistic baselines on a 6-month backtest of EURUSD M15:

- Win rate: **42–55 %**
- Avg win: **+1.7 R**
- Avg loss: **−1.0 R**
- Expectancy: ≈ **+0.4 R per trade**

That means: **you lose almost half of all trades and still make money**, *if* you risk-size correctly.

## Drawdown — what to expect

Even with a +0.4 R expectancy, a streak of 6 losses is **completely normal** and will happen ~once every 60 trades. A streak of 10 losses is plausible. At 1 % risk per trade:

| streak | drawdown |
|---|---|
| 6 losses | 6 % |
| 10 losses | 10 % |
| 15 losses | 15 % |

If a 15 % drawdown would make you panic-quit, **lower your risk per trade**. 0.5 % per trade halves all of the above.

## Risk per day / week

In addition to the per-trade rule, set guards:

- **Daily loss limit**: 2 R (i.e. two full losers). Hit it → close the laptop.
- **Weekly loss limit**: 5 R. Hit it → spend the rest of the week reviewing journals.
- **Max consecutive losses without review**: 4. Hit it → stop, journal, then re-engage.

These guardrails prevent the **revenge-trade death spiral**, which is the #1 killer of demo-graduated traders.

## Correlated trades

If you take EURUSD long *and* GBPUSD long *and* EURJPY long at the same time, you are not in three trades — you are in **one big USD-short trade with leverage**. Account for it:

- If you hold ≥ 2 highly correlated trades, **halve the risk** on each.
- If you hold ≥ 3, halve again.

Crypto: BTC and ETH count as one when both long or both short. Most alts correlate to BTC.

## Spreads, slippage, fees

For lower-liquidity TFs (M1–M5) and exotic pairs, spread can eat 20-50 % of a typical 1.5 R win. Build it in:

- Test your strategy with `slippage = 1 tick` and `commission = your broker's spread + commission`.
- Reject trades where TP1 doesn't survive a 2× normal spread.

The Pine strategy file lets you set `commission_value` and `slippage`. The MQL5 EA reads `SymbolInfoInteger(SYMBOL_SPREAD, ...)` at order open.

## When to stop using the system

Reasons to **pause** trading and review (not necessarily to give up):

- 5+ consecutive losing weeks on a system that previously worked.
- Win rate falls below 30 % for 30+ trades — a regime change has likely occurred.
- You are taking trades that don't satisfy all framework conditions ("FOMO trades").

Reasons to **discard** a setup:

- A 200-trade backtest produces **negative** expectancy across multiple symbols.
- The setup only "works" on cherry-picked screenshots.

## Journaling — the boring magic

A trading journal is the single highest-ROI habit you can build. Minimum fields per trade:

| Field | Example |
|---|---|
| Symbol / TF | EURUSD M15 |
| Setup # | 1 / 2 / 3 / 4 |
| HTF bias | Bullish (D1 BOS up) |
| Liquidity swept | PDL |
| POI | M15 OB 1.0810-1.0815 |
| Trigger | M5 CHoCH up at 10:34 NY |
| Entry / SL / TP1 / TP2 | 1.0815 / 1.0803 / 1.0843 / 1.0871 |
| Risk % | 0.5 % |
| Result | +2.3 R |
| Mistakes | None / Entered too early / SL too tight / etc. |

After 50 trades, sort by setup # and look at the expectancy of each. After 100 trades, sort by mistake type. The patterns are usually obvious in retrospect — and *that* is the journal's value.

→ Continue to [`10-tradingview-walkthrough.md`](10-tradingview-walkthrough.md).


# 10 — TradingView Walkthrough

End-to-end: from copying the Pine code to setting alerts to running a backtest.

## Prerequisites

- A TradingView account (free tier is fine; some alert features need Pro).
- A clear chart you want to apply the indicator to (EURUSD M15 is a good first try).

## Install the indicator

1. Open the chart, click the **{} Pine Editor** tab at the bottom of TradingView.
2. Click **Open** → **New blank indicator** to clear the editor.
3. Open [`tradingview/pa_smc_ict_hybrid.pine`](../tradingview/pa_smc_ict_hybrid.pine) in this repo, copy its full contents.
4. Paste into the Pine Editor.
5. Click **Save** → name it `PA_SMC_ICT_Hybrid`.
6. Click **Add to chart**.

You should see (defaults):

- Faint background shading on Asia / London / NY sessions.
- Gold shading on Silver Bullet windows.
- HH/HL/LH/LL labels at swing pivots.
- Green dotted lines at BOS, red dotted lines at CHoCH.
- Boxes for OBs, FVGs, breakers.
- "🩸 SSL" / "🩸 BSL" tags at sweeps.
- A 50% midpoint line and OTE band on the active range.

If the chart looks **too busy**, that's expected — every input is on by default. Right-click → Settings → toggle off whatever you don't want.

## Inputs you should know

| Group | Input | Default | Meaning |
|---|---|---|---|
| Structure | `Pivot left/right` | 5 / 5 | Swing detection sensitivity. Lower for more signals. |
| Order Blocks | `Show OBs` | true | Toggle box drawing |
| Order Blocks | `Max OBs` | 8 | Cap visible boxes |
| FVG | `Show FVGs` | true | |
| FVG | `Min FVG % of ATR` | 30% | Filter tiny gaps |
| Liquidity | `EQ tolerance pips` | 3 | How "equal" two highs/lows must be |
| Sessions | `Show Asia/London/NY` | true | |
| Kill zones | `Show kill zones` | true | |
| Silver Bullet | `Show SB windows` | true | |
| OTE | `Show OTE band` | true | |
| Alerts | (Various) | — | One alertcondition per setup |

## Setting alerts

For each `alertcondition()` in the script, TradingView lets you create an alert via right-click → **Add alert**.

1. Right-click on the chart → **Add alert**.
2. **Condition** dropdown → select `PA_SMC_ICT_Hybrid`.
3. Sub-condition → choose e.g. `Sweep+CHoCH long` or `SilverBullet FVG formed`.
4. **Options** → "Once Per Bar Close" (recommended — prevents repaint).
5. **Notifications** → enable webhook/email/mobile push.
6. Click **Create**.

Repeat for each setup you want pinged.

The alerts cookbook in [`tradingview/alerts.md`](../tradingview/alerts.md) has webhook payload templates for forwarding to Discord / Telegram.

## Backtesting — the strategy script

For mechanical setups (#1 sweep+CHoCH+OB, #4 breaker+FVG), use [`tradingview/pa_smc_ict_strategy.pine`](../tradingview/pa_smc_ict_strategy.pine).

1. Pine Editor → **Open** → **New blank strategy**.
2. Paste the strategy file. Save as `PA_SMC_ICT_Strategy`.
3. Add to chart.
4. Open the **Strategy Tester** tab (bottom panel).
5. Set:
   - **Initial capital**: 10000
   - **Default qty**: % of equity → 0.5 %
   - **Commission**: your broker's value (e.g. 0.5 pips for major FX)
   - **Slippage**: 1–2 ticks
6. Adjust strategy inputs (the same as the indicator).
7. Read the **Performance Summary** tab — focus on **Profit Factor**, **Max Drawdown**, **Avg Trade**.

Do **not** trust a backtest with < 50 trades. Run on 6 months of history minimum. Sanity-check by changing input parameters slightly — if results explode, the system is over-fit.

## Multi-timeframe workflow on TradingView

The most efficient way to use the hybrid:

1. Open a 4-window layout (Profile → Layouts → 1×4 vertical).
2. Top-left: Daily, indicator on. Set HTF bias.
3. Top-right: H4, indicator on. Mark active range.
4. Bottom-left: M15, indicator on. Find POIs.
5. Bottom-right: M5, indicator on. Wait for trigger.

Lock the symbol across panes (toolbar gear → "Sync symbol on all charts"). Lock crosshair too — it makes price-tracking instant.

## Saving a template

Once you've toggled inputs to your taste:

1. Right-click chart → **Save Indicator Template As…** → e.g. "PA SMC FX M15".
2. Reapply on any chart with **Templates → PA SMC FX M15**.

Make different templates for forex / crypto / indices since the EQ tolerance and ATR multipliers differ.

## Troubleshooting

| Symptom | Likely fix |
|---|---|
| "Too many drawings" error | Lower `Max OBs` and `Max FVGs`, or reduce `Lookback bars` |
| Indicator shows nothing | Bigger pivot left/right values; clear chart and re-add |
| Strategy reports 0 trades | Inputs too strict — relax kill-zone filter or reduce confluence requirements |
| Alerts misfiring on every bar | Make sure "Once Per Bar Close" is selected |
| Boxes misaligned on log scale | Switch chart to linear scale; SMC boxes are price-anchored |

→ Continue to [`11-metatrader-walkthrough.md`](11-metatrader-walkthrough.md).


# 11 — MetaTrader Walkthrough (MT5 + MT4)

The MetaTrader equivalent of chapter 10. Covers MT5 first (recommended for new users) and then MT4 specifics.

## Prerequisites

- A demo account at any MT5 / MT4 broker.
- The MT5 / MT4 desktop client installed.
- The MetaEditor (bundled with the client).

## MT5 install

1. Launch MT5. Click **File → Open Data Folder**. A folder window opens.
2. Navigate into `MQL5/Indicators/`. Copy [`mt5/PA_SMC_ICT_Hybrid.mq5`](../mt5/PA_SMC_ICT_Hybrid.mq5) here.
3. Navigate into `MQL5/Include/`. Copy [`mt5/Include/PASMC_Utils.mqh`](../mt5/Include/PASMC_Utils.mqh) here.
4. Navigate into `MQL5/Experts/`. Copy [`mt5/PA_SMC_ICT_EA.mq5`](../mt5/PA_SMC_ICT_EA.mq5) here.
5. In MT5, press **Ctrl+N** to open the Navigator (or use the View menu).
6. Right-click the **Indicators** branch → **Refresh**.
7. Open MetaEditor (F4 from MT5).
8. In MetaEditor's Navigator, find `PA_SMC_ICT_Hybrid.mq5`, double-click, then press **F7** (Compile). 0 errors expected.
9. Compile `PA_SMC_ICT_EA.mq5` the same way.

Switch back to MT5. The compiled `.ex5` files now appear in the Navigator.

## MT5 attach the indicator

1. In MT5's Navigator, double-click `PA_SMC_ICT_Hybrid` (or drag onto chart).
2. The inputs dialog opens. Match what you used on TradingView (or accept defaults).
3. Click **OK**.
4. Save the chart template via **Charts → Template → Save Template** → e.g. `PA_SMC_FX_M15`. Apply to other charts via **Template → Load Template**.

## MT5 GMT-offset input

Most brokers feed candles in **GMT+2** or **GMT+3** (server time). The indicator's session calculations need to know your broker's offset to align kill zones with NY time.

1. In the indicator inputs, find `Broker GMT offset (hours)`.
2. Default is `2`. If your kill-zone boxes look 1-2 hours misplaced, set to `3` (during US DST).
3. **Sanity check**: the London KZ shading should start at 09:00 broker time during NY winter (EST), 08:00 during NY summer (EDT).

## MT5 alerts

The indicator emits alerts via the standard `Alert()`, `SendNotification()`, and `SendMail()` functions. Configure each:

| Channel | How | Setting in indicator inputs |
|---|---|---|
| In-app popup | always on | `Use popup` = `true` |
| MT5 mobile push | Tools → Options → Notifications → Enable + your MetaQuotes ID | `Use push` = `true` |
| Email | Tools → Options → Email → SMTP creds | `Use email` = `true` |

The same alert names appear as in Pine: `Sweep+CHoCH long`, `SilverBullet FVG formed`, `Breaker tagged + LTF CHoCH`, etc.

## MT5 — running the EA

The included EA is a **semi-auto stub**: it reads the indicator's buffers via `iCustom`, manages risk-percent sizing, places SL/TP, and logs everything to the Experts log. It is not a full alpha — read the disclaimer in [`mt5/README.md`](../mt5/README.md).

1. In MT5: drag `PA_SMC_ICT_EA` onto a chart.
2. In the inputs dialog, set:
   - `Risk %`: 0.5
   - `Magic number`: 770401 (or any unique int)
   - `Allow setup #1` / `#4`: true
   - `Trade only in kill zones`: true
3. **Common** tab → enable **Algo Trading** (also click the green Algo Trading button on the toolbar).
4. Click **OK**. A smiley face on the chart's top-right means the EA is running.
5. The Experts tab (Ctrl+T) shows logs. Setup detections + order tickets stream in.

## MT5 — Strategy Tester (backtest)

1. **View → Strategy Tester** (Ctrl+R).
2. Expert: `PA_SMC_ICT_EA`. Symbol: e.g. EURUSD. Period: M15.
3. Date: 6 months ago to today.
4. Modeling: **Every tick based on real ticks** if your broker provides them; otherwise **1 minute OHLC**.
5. Forward: `1/2`. Optimization: **Disabled** for first run.
6. **Start**.
7. Read the **Graph** + **Report** tabs. Look at: net profit, profit factor, Sharpe, max drawdown.

Same caveat as TradingView: do not trust < 50 trades and do not over-fit. Vary inputs ±20 % to test robustness.

## MT4 specifics

MT4 is similar with these differences:

| Difference | What it means |
|---|---|
| MT4 uses `MQL4/...` paths | Copy `mt4/PA_SMC_ICT_Hybrid.mq4` to `MQL4/Indicators/`, `mt4/PA_SMC_ICT_EA.mq4` to `MQL4/Experts/` |
| MQL4 has no struct arrays (in legacy mode) | The MQL4 port uses parallel arrays — same features, different internal code |
| MQL4 EA uses `OrderSend`, MQL5 uses `OrderSend(MqlTradeRequest)` | Behavior is identical to the user |
| Strategy Tester on MT4 is single-currency | Loop manually if testing multiple symbols |

The MQL4 README and code in [`mt4/`](../mt4/) describe the differences in detail.

## Troubleshooting

| Symptom | Likely fix |
|---|---|
| Compile error `'PASMC_Utils.mqh' file not found` | The `.mqh` is not in `MQL5/Include/` — re-copy |
| Indicator draws but kill zones are misaligned | Wrong `Broker GMT offset` |
| EA opens no trades in Strategy Tester | Tester time isn't inside any kill zone — disable kill-zone filter for the test, or expand date range |
| EA error `Trade is not allowed` | Algo Trading button is off in toolbar |
| EA error `No money` | Risk % too small for symbol min lot — reduce SL distance or increase % |
| Wrong session colors during DST | Adjust `Broker GMT offset` ±1 |
| `iCustom` returns 0 in EA | Indicator must be `Compiled` and *loaded* on the chart in `EMPTY_VALUE`-aware mode |

→ Continue to [`12-checklists.md`](12-checklists.md).


# 12 — Checklists

Print these. Tape them next to your monitor. Do **not** click "Buy" until every box is checked.

---

## Pre-trade checklist (every trade)

- [ ] HTF bias defined (D1/H4 BOS direction is clear and *unchanged this week*)
- [ ] Active range marked; price is in the **bias-aligned half** (discount for longs, premium for shorts)
- [ ] Liquidity pools mapped (PDH/PDL, EQH/EQL, Asia H/L)
- [ ] At least one **unmitigated POI** (OB / FVG / breaker) sits between current price and the next bias-aligned liquidity
- [ ] Time check: am I inside a kill zone, ideally Silver Bullet?
- [ ] Setup type identified (#1 / #2 / #3 / #4)
- [ ] Trigger printed on LTF (CHoCH or FVG-tap depending on setup)
- [ ] SL placement decided **before** entering — and SL is *outside* the POI
- [ ] TP1 ≥ 1.5 R away
- [ ] Position size calculated (0.5 % risk default)
- [ ] No correlated trade already open (or risk halved)
- [ ] Daily loss limit not yet hit
- [ ] I am **not tilted** from a previous loss

If **any** box is unchecked → no trade.

---

## In-trade checklist (while position is open)

- [ ] SL still where I planned (no widening, ever)
- [ ] At TP1: 50 % off, SL → BE
- [ ] At TP2: 25 % off
- [ ] If HTF CHoCH against me prints before TP1 → **close manually**
- [ ] Runner trail: behind each new HL (long) / LH (short) on trading TF
- [ ] No second trade on the same liquidity pool until current closes

---

## Post-trade checklist (within 10 minutes of close)

- [ ] Journal entry created (symbol, TF, setup, entry/SL/TPs, R result)
- [ ] Screenshot saved (chart with markings) — TradingView "Camera" icon, MT5 "File → Save As Picture"
- [ ] Mistake (if any) categorized: bad bias / bad timing / bad sizing / FOMO / revenge / discipline
- [ ] If loss → did I follow the rules? (Y/N → if Y, accept it; if N, that's the lesson)
- [ ] If win → did I take partials per plan? (Y/N → if N, that's also a lesson)

---

## Daily checklist

Before market open:

- [ ] Review yesterday's journal entries (5 min)
- [ ] Mark Daily / H4 levels on each watchlist symbol (10 min)
- [ ] Identify expected PO3 direction per symbol (5 min)
- [ ] Check macro calendar — flag high-impact news in the kill zones I'll trade

After market close:

- [ ] Sum of trades today: count, gross R, net R, win rate
- [ ] At least one screenshot annotated with "what I did right" or "what I did wrong"

---

## Weekly review checklist (every Friday after close)

- [ ] Aggregate this week's trades: count, win rate, avg R, expectancy
- [ ] Group by setup #: which setups produced positive vs negative expectancy?
- [ ] Group by symbol: which symbols are working? Which to drop?
- [ ] Group by mistake type: any pattern? (e.g. "5 out of 7 losses came from trading outside kill zone")
- [ ] One concrete change for next week — *one*, not five
- [ ] Review the indicator settings: did anything misfire? Adjust input defaults if needed

---

## "Should I trade today?" checklist

If 2 or more boxes here are checked → **no trading today**:

- [ ] Slept < 6 hours
- [ ] Drank alcohol within 12 hours
- [ ] Bad mood / argument / unrelated stress
- [ ] Hit daily loss limit yesterday
- [ ] Major economic event during my trading window (NFP, FOMC, CPI)
- [ ] Symbol is in a no-trade range (no setups confirmed in last 3 days)

The market is open every day. Your edge is not.

---

## "Should I quit and review?" checklist (any time during the day)

If 1 or more checked → **stop trading, review your journal, walk away for 24 h**:

- [ ] Took 2 trades in a row that violated the framework
- [ ] Catching a falling knife "for the bounce"
- [ ] Adding to a losing position
- [ ] Removing a stop loss
- [ ] Refreshing the chart every 30 seconds
- [ ] Doubled my risk after a loss

---

→ Continue to [`references.md`](references.md) — the curated reading list and the open-source code we studied.


# Glossary

Every term used in this guide, in plain English. Sorted alphabetically. Curl up here whenever something looks like alphabet soup.

---

**AMD** — Accumulation, Manipulation, Distribution. ICT's three-phase model of how a single trading day (or any session) is delivered. See [`03-ict-essentials.md`](03-ict-essentials.md#power-of-3) and [`07-setup-power-of-3.md`](07-setup-power-of-3.md).

**Asia session** — Roughly 19:00–03:00 New York time. Often produces a tight range that becomes the day's accumulation phase.

**ATR (Average True Range)** — A volatility indicator. Useful for sizing stop losses adaptively (e.g. SL = OB extreme + 0.5 × ATR).

**Bias** — Your high-confidence directional lean for the day or week. Set on the HTF (Daily / H4); not changed casually.

**BOS (Break of Structure)** — A close beyond the most recent swing high (in an uptrend) or swing low (in a downtrend). Confirms trend continuation.

**Breaker block** — An order block that **failed** (price broke through it). When price returns to a former breaker, it tends to reject — often used as a trend-change POI. See [`08-setup-breaker-fvg.md`](08-setup-breaker-fvg.md).

**Buy-side liquidity (BSL)** — A pool of stop losses sitting **above** the market (typically buy stops above EQH and breakout buy entries). Smart money "runs" the BSL by spiking up before reversing.

**Candle** — One OHLC bar. Body = open→close; wicks = high/low extremes.

**CHoCH (Change of Character)** — A close beyond the most recent **opposite** swing point. Confirms trend reversal. Bullish CHoCH = first higher high after a downtrend; bearish CHoCH = first lower low after an uptrend.

**Confluence** — Multiple unrelated reasons all pointing the same way. We require at least 2-3 confluences before entering.

**Daily Open** — 00:00 New York / midnight ET. Reference price for the AMD model.

**Discount** — The lower 50% of a marked range. Bullish-biased buys belong here.

**Displacement** — A strong, fast move with multiple consecutive same-color candles and an obvious imbalance (FVG). Indicates institutional participation.

**Draw on liquidity** — The next big stop pool the market is "drawing toward." Used as TP target.

**EQH / EQL (Equal Highs / Equal Lows)** — Two or more highs (or lows) at the same price. Stop pools live above EQH and below EQL.

**Fair Value Gap (FVG)** — A 3-candle pattern where candle 1's wick and candle 3's wick do not overlap, leaving an "imbalance" gap on candle 2. See [`02-smc-core.md`](02-smc-core.md#fair-value-gap).

**Fibonacci OTE (Optimal Trade Entry)** — The 0.62–0.79 retracement zone of an impulse leg. ICT's preferred entry pocket within a POI.

**Higher High (HH) / Higher Low (HL)** — Sequence defining an uptrend.

**HTF (Higher Timeframe)** — Above your trading TF. If you trade M15, your HTF is H1 / H4 / D1.

**Imbalance** — Same idea as FVG: one-sided price delivery, unfilled on the way.

**Inner Circle Trader (ICT)** — Michael J. Huddleston's trading methodology. Source of kill zones, Silver Bullet, AMD, OTE, IPDA, etc.

**IPDA (Interbank Price Delivery Algorithm)** — ICT's mental model: price is delivered by an algorithm seeking liquidity.

**Judas swing** — The early-session false move that sweeps liquidity before the real session move. Often the "M" in AMD.

**Kill zone** — High-probability time window: London KZ ≈ 02:00–05:00 NY, NY AM KZ ≈ 07:00–10:00 NY, NY PM KZ ≈ 13:00–16:00 NY.

**Liquidity** — Resting orders. We trade *into* liquidity (target) and *from* liquidity (entry, after a sweep).

**Liquidity sweep** — Price wicks beyond a stop pool (EQH/EQL/PDH/PDL) and closes back inside. The smoking-gun "stop hunt."

**Lower High (LH) / Lower Low (LL)** — Sequence defining a downtrend.

**LTF (Lower Timeframe)** — Below your trading TF. If you trade M15, your LTF is M5 / M3 / M1 — used to time entries.

**Magic Number** — In MetaTrader, an integer that tags an EA's positions so it can manage them without touching manual trades.

**Manipulation** — The "M" in AMD. The Judas swing that fakes one direction before the real move.

**Mitigation** — When price returns to a POI (OB / FVG) and is rejected (or filled). After full mitigation, the POI loses its edge.

**MQL4 / MQL5** — The programming languages of MetaTrader 4 / MetaTrader 5.

**MT4 / MT5** — MetaTrader 4 and 5, the most popular retail forex platforms.

**NY (New York) session** — Roughly 07:00–16:00 NY time. The most volatile session for forex / indices.

**OB (Order Block)** — The last opposing-direction candle (or candle cluster) before a strong impulsive move. Acts as a high-probability return-to-POI zone.

**OHLC** — Open, High, Low, Close. The four prices that define a candle.

**OTE (Optimal Trade Entry)** — See *Fibonacci OTE*.

**PDH / PDL (Previous Day High / Low)** — Yesterday's H/L. Major liquidity magnets.

**Pine Script** — TradingView's domain-specific language for indicators and strategies. We use **v5**.

**Pivot** — A local swing high or swing low (Pine: `ta.pivothigh` / `ta.pivotlow`).

**POI (Point of Interest)** — A price zone we plan to enter from: OB / FVG / breaker. See [`02-smc-core.md`](02-smc-core.md).

**Position size** — Number of lots / units / contracts. Always derived from risk% and stop distance — never set arbitrarily.

**Power of 3 (PO3)** — ICT's name for AMD applied to the daily candle: Accumulation forms the open, Manipulation forms the wick, Distribution forms the body.

**Premium** — The upper 50% of a marked range. Bearish-biased sells belong here.

**Range** — A bounded price territory between a recent swing high and swing low. Premium = top half, discount = bottom half.

**R / R-multiple / R:R** — "R" = the dollar amount you risked. A trade that makes 3× what you risked = +3R. **R:R 1:2** = SL distance × 2 = TP distance.

**Sell-side liquidity (SSL)** — Stop pool **below** the market.

**Session** — A defined trading window — Asia, London, NY AM, NY PM.

**Silver Bullet** — ICT's tightly-defined 60-minute (or even 15-minute) windows: 10:00–11:00 NY (NY AM SB), 14:00–15:00 NY (NY PM SB), 03:00–04:00 NY (London SB). Trades inside these windows hit higher win rates statistically (per ICT's lessons).

**SL (Stop Loss)** — The price at which the trade is automatically closed for a loss. *Always* placed before entry, *always* respected.

**SMC (Smart Money Concepts)** — A retail synthesis of order-flow / liquidity / institutional-style trading. Heavily overlaps with ICT.

**Strategy Tester** — MetaTrader's built-in backtesting engine.

**Sweep** — Short for *liquidity sweep*.

**Swing High / Swing Low** — A local price extreme — a high (or low) with `n` lower (or higher) bars on each side.

**TF (Timeframe)** — The candle length you're looking at.

**TP (Take Profit)** — The price at which you (partially) close a winning trade.

**TradingView** — Web-based charting platform used to host Pine indicators and strategies.

**Trend** — Sequence of HH+HL (uptrend), LH+LL (downtrend), or neither (ranging).

**Wick** — The thin line above / below the body of a candle. Liquidity sweeps usually appear as long wicks.

---

→ Back to [`README.md`](../README.md) or jump to the framework: [`04-hybrid-framework.md`](04-hybrid-framework.md).


# References & Further Reading

Curated, attributed, and grouped. Everything below is **public** and freely accessible. No course-seller affiliate links.

> The Pine and MQL code in this repo is **original** but informed by the open-source projects listed below. We thank their authors. License compatibility was checked at time of writing — re-check before redistributing derivative work.

---

## Open-source repos (Pine Script v5)

- **[Musyimi97/phase404](https://github.com/Musyimi97/phase404)** — A complete TV indicator + MT5 EA + backtest config implementing PHASE 404 (Wyckoff AMD + liquidity + MSS + OTE + Smart Money Divergence). Closest match to our scope.
- **[tsunafire/PineScript-SMC-Strategy](https://github.com/tsunafire/PineScript-SMC-Strategy)** — Pine `strategy()` script focused on order blocks + liquidity sweeps.
- **[Ahmed-GoCode/Quant-Edge-Indicators](https://github.com/Ahmed-GoCode/Quant-Edge-Indicators)** — Six TradingView indicators for SMC, market structure, RSI, Fibonacci, FVG.
- **[Smart Money Concepts (LuxAlgo) Enhanced gist](https://gist.github.com/niquedegraaff/8c2f45dc73519458afeae14b0096d719)** — Community-enhanced fork of the LuxAlgo SMC indicator.
- **[SpxGh0st — ICT Killzones+Silver Bullet (TradingView)](https://www.tradingview.com/script/InMPCLO7-ICT-Killzones-and-Sessions-W-Silver-Bullet-Macros/)** — TradingView-hosted ICT killzones script with macros.

## Open-source repos (MetaTrader 5 / 4)

- **[VelmoPk/Smart-Money-Concepts-indicator-MT5](https://github.com/VelmoPk/Smart-Money-Concepts-indicator-MT5)** — Native MQL5 SMC indicator (OB, BOS/CHoCH, liquidity sweeps, FVG, no repaint).
- **[haza79/MT5-Smart-Money-Concept-Indicator](https://github.com/haza79/MT5-Smart-Money-Concept-Indicator)** — Performance-focused MT5 SMC indicator.
- **[MQL5 article — "Elevate Your Trading With Smart Money Concepts (SMC): OB, BOS, and FVG"](https://www.mql5.com/en/articles/16340)** — Good reference for the order-block / FVG detection algorithm in MQL5.

## Python / backtesting

- **[joshyattridge/smart-money-concepts](https://github.com/joshyattridge/smart-money-concepts)** — `pip install smartmoneyconcepts`. Best Python implementation of OB / FVG / liquidity / BOS / CHoCH detection on a pandas OHLC DataFrame. Excellent for *understanding* the algorithms before you write them in Pine or MQL.
- **[backtesting.py](https://pypi.org/project/backtesting/)** — Lightweight Python backtester; pairs well with `smartmoneyconcepts` for offline strategy validation.

## ICT theory — public mentorship-grade tutorials

- [innercircletrader.net — Silver Bullet strategy](https://innercircletrader.net/tutorials/ict-silver-bullet-strategy/)
- [innercircletrader.net — Master ICT Kill Zones](https://innercircletrader.net/tutorials/master-ict-kill-zones/)
- [innercircletrader.net — Power of 3 (free PDF)](https://innercircletrader.net/tutorials/ict-power-of-3/)
- [EBC Financial — What is the ICT Silver Bullet?](https://www.ebc.com/forex/what-is-the-ict-silver-bullet-meaning-rules-and-examples)
- [Ultima Markets — ICT Silver Bullet times to trade](https://www.ultimamarkets.com/academy/ict-silver-bullet-times-to-trade/)
- [Trading Finder — ICT Silver Bullet education](https://tradingfinder.com/education/forex/ict-silver-bullet/)
- [Writofinance — Trading with ICT Power of 3 (AMD setup)](https://www.writofinance.com/ict-power-of-3/)
- [TTrades — Power of Three explained](https://ttrades.com/ict-power-of-three-amd-accumulation-manipulation-distribution-explained/)
- [Trading Finder — Power of Three strategy](https://tradingfinder.com/education/forex/ict-power-of-three/)

## Classical price action

- *Trading Price Action Trends / Reversals / Ranges* — Al Brooks (4-volume series, paid).
- *The Methodical Forex Trader* — Bob Volman.
- [Babypips School of Pipsology](https://www.babypips.com/learn/forex) — Free beginner forex curriculum (chapters 1-7 cover all the price-action primitives we use).

## Wyckoff (the OG)

- *The Wyckoff Methodology in Depth* — Rubén Villahermosa.
- [Stockcharts.com — Wyckoff Analysis (free)](https://school.stockcharts.com/doku.php?id=market_analysis:the_wyckoff_method) — short, accurate, and free.

## Backtesting / journaling apps

- [TradingView Strategy Tester](https://www.tradingview.com/support/solutions/43000561856-strategy-tester/) — Pine-native.
- [MetaTrader 5 Strategy Tester](https://www.metatrader5.com/en/terminal/help/algotrading/strategy_testing) — multi-symbol, real-tick.
- [Tradezella](https://tradezella.com/) / [Edgewonk](https://edgewonk.com/) — paid, but well-suited to journaling SMC/ICT trades.

## Misc useful

- [TradingView Pine Reference v5](https://www.tradingview.com/pine-script-reference/v5/) — official.
- [MQL5 Documentation](https://www.mql5.com/en/docs) — official.
- [MQL4 Documentation](https://docs.mql4.com/) — official.

---

## A note on attribution

The framework synthesized in chapter 04 is **our** organization, but the components are decades old:

- **Wyckoff (1900s)** — accumulation/distribution, supply/demand zones.
- **Al Brooks / Bob Volman (2000s)** — modern bar-by-bar price action.
- **Steve Mauro / "Beat the Market Maker" (2010s)** — early M/W liquidity model.
- **Michael J. Huddleston / "Inner Circle Trader" (2014–present)** — kill zones, OTE, IPDA, Silver Bullet, Power of 3, displacement, FVG terminology.
- **Retail SMC community (2018–present)** — popularized BOS/CHoCH/OB/FVG vocabulary that this guide uses.

When sharing the indicator code or this guide externally, please retain the MIT license and credit notice.
