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
