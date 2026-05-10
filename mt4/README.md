# MetaTrader 4 (MQL4)

| File | Type | Purpose |
|---|---|---|
| [`PA_SMC_ICT_Hybrid.mq4`](PA_SMC_ICT_Hybrid.mq4) | Indicator | MT4 port — same OB / FVG / BOS / CHoCH / liquidity / sweeps. |
| [`PA_SMC_ICT_EA.mq4`](PA_SMC_ICT_EA.mq4) | Expert Advisor | Reads the indicator via `iCustom`; trades setups #1 and #4. |

## Install

1. **MT4** → File → **Open Data Folder**.
2. Copy `PA_SMC_ICT_Hybrid.mq4` to `MQL4/Indicators/`.
3. Copy `PA_SMC_ICT_EA.mq4` to `MQL4/Experts/`.
4. Open **MetaEditor** (F4 in MT4).
5. Compile each file (F7) — 0 errors expected.
6. Refresh MT4 Navigator. Drag onto chart.

## Differences vs MT5 version

- **No struct arrays** — uses parallel arrays (e.g. `g_obTop[]`, `g_obBot[]`, `g_obDir[]`, `g_obBrk[]`, `g_obT[]`).
- **No CTrade library** — uses raw `OrderSend()` with `OP_BUY` / `OP_SELL`.
- **Single ticket per order** (MT4 model) — partial closes are emulated by opening **two** orders (TP1 and TP2 chunks).
- **No native session shading** — kill zones are detected for the buffer logic but not visualized as backgrounds (MT4's object model makes per-day shading expensive). Toggle is reserved for a future enhancement.
- **iATR** etc. return values directly — no handle / `CopyBuffer`.

## Inputs

Same names as the MT5 version. Most importantly: `InpBrokerGmtOffset` controls how the indicator translates broker server time to NY time for kill-zone detection. Default `2` works for typical Eastern-European brokers in winter; bump to `3` in summer (or use a broker whose server is at `GMT+3` year-round, like ICMarkets).

## Backtest in MT4 Strategy Tester

1. **View → Strategy Tester** (Ctrl+R).
2. Expert Advisor: `PA_SMC_ICT_EA`.
3. Symbol: e.g. EURUSD. Period: M15.
4. Model: **Every tick** (slow but accurate) or **Open prices only** (fast).
5. Period: at least 6 months.
6. **Start**.
7. View **Graph** + **Report** tabs.

> Note: the MT4 backtest engine attaches the EA but **not** the indicator unless you also add the indicator from the EA via `iCustom`. The EA already does this — make sure the indicator file is compiled (`.ex4` exists) before running the test.

## Limitations specific to MT4

- The indicator's drawing object count cap on MT4 is lower than MT5; setting `InpMaxOBs > 12` may slow the chart.
- `Bars` / `Time[]` are series-indexed (0 = current) which the code respects, but if you customize, watch for off-by-one in pivot detection — MT5 uses `ArraySetAsSeries(true)` which we mirror by keeping the same idx convention.
- MT4's `iCustom` returns `EMPTY_VALUE` for buffers that have no data; the EA checks for this.

## Read this before live use

- [`../guide/04-hybrid-framework.md`](../guide/04-hybrid-framework.md) — the spine.
- [`../guide/09-risk-management.md`](../guide/09-risk-management.md) — sizing, journaling, drawdowns.
- [`../guide/11-metatrader-walkthrough.md`](../guide/11-metatrader-walkthrough.md) — install & use both MT4 and MT5.
