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
