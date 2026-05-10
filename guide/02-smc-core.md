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
