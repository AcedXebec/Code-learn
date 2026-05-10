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
