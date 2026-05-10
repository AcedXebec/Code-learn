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
