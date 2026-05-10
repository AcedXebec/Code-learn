# TradingView (Pine Script v5)

| File | Type | Purpose |
|---|---|---|
| [`pa_smc_ict_hybrid.pine`](pa_smc_ict_hybrid.pine) | `indicator()` | Visualizes OB / FVG / BOS / CHoCH / liquidity / sessions / kill zones / Silver Bullet / OTE — and emits alerts. |
| [`pa_smc_ict_strategy.pine`](pa_smc_ict_strategy.pine) | `strategy()` | Backtestable variant for setups #1 (sweep + CHoCH + OB) and #4 (breaker + FVG). |
| [`alerts.md`](alerts.md) | docs | Alert cookbook + webhook templates. |

## Install

1. Open TradingView → click the **{}** Pine Editor at the bottom.
2. Paste the file contents into the editor.
3. **Save** → name e.g. `PA_SMC_ICT_Hybrid`.
4. **Add to chart**.

## Defaults you may want to change

| Input | Default | Suggested per market |
|---|---|---|
| `Pivot left/right` | 5 / 5 | M5 FX: 5/5 — H1 FX: 3/3 — D1: 2/2 — H4 crypto: 3/3 |
| `EQ tolerance pips` | 3 | FX majors: 3 — JPY pairs: 5 — Crypto: 0 (use ATR) |
| `Min FVG size (× ATR)` | 0.30 | Lower (0.2) for tight FX; higher (0.5) for crypto |
| `Broker GMT offset` | n/a | Pine handles this via `sessTz` — set to `America/New_York` |

## Inputs panel groups

- **Structure** — pivot detection, BOS / CHoCH labels.
- **Order Blocks** — toggle, max count, colors, breaker color.
- **Fair Value Gaps** — toggle, min size, max count, colors.
- **Liquidity** — EQH/EQL toggle, sweep markers, PDH/PDL.
- **Sessions & Kill Zones** — Asia/London/NY shading, kill zones, Silver Bullet windows, timezone.
- **Range / OTE** — 50% midpoint, 62-79% Fibonacci OTE, range lookback bars.

## Verify it's working

After adding the indicator on EURUSD M15, you should see:

- Faint background bands across Asia / London / NY hours.
- A **gold** band at 10:00–11:00 NY (NY AM Silver Bullet).
- HH/HL/LH/LL labels at swing pivots.
- Green and red dotted lines + `BOS↑` / `CHoCH↓` labels.
- Green / red faded boxes for OBs (orange when broken → breaker).
- Lime / fuchsia faded boxes for FVGs.
- `🩸 SSL` and `🩸 BSL` flags when wicks pierce equal-low / equal-high levels.
- A status table top-right with current bias and session.

## Backtesting (strategy file)

1. Add `pa_smc_ict_strategy.pine` to a chart.
2. Open **Strategy Tester** (bottom panel).
3. Look at **Performance Summary** → Profit Factor, Avg Trade R, Max Drawdown.
4. Adjust inputs (especially `riskPct`, `slBufferATR`, `rrTP1`/`rrTP2`).
5. Run on multiple symbols / TFs — robust strategies survive small input changes.

> A backtest with < 50 trades is **not** statistically meaningful. If you need more trades, broaden the time filter (uncheck `Trade only in kill zones`) for the test only — but accept that real-world expectancy will be lower outside kill zones.

## Limitations

- Pine Script cannot subscribe to multiple symbols natively — bias is local to the chart symbol.
- Pine `request.security` is used only for PDH/PDL with `lookahead_off`; no repaint on confirmed bars.
- Drawing limits: `max_boxes_count=500`. With aggressive pivot settings, OB/FVG boxes hit the cap on long histories — old ones are pruned automatically.
- The strategy implements setups #1 and #4 only. #2 (Silver Bullet) and #3 (Power of 3) require judgment-based bias and are alerts-only.

## Read this before live use

- [`../guide/04-hybrid-framework.md`](../guide/04-hybrid-framework.md) — the spine.
- [`../guide/09-risk-management.md`](../guide/09-risk-management.md) — sizing, journaling, drawdowns.
- [`../guide/10-tradingview-walkthrough.md`](../guide/10-tradingview-walkthrough.md) — install + alerts walkthrough.
