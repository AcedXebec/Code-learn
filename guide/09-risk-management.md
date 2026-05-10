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
