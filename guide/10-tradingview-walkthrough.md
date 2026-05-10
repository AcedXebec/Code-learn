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
