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
