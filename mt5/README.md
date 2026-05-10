# MetaTrader 5 (MQL5)

| File | Type | Purpose |
|---|---|---|
| [`PA_SMC_ICT_Hybrid.mq5`](PA_SMC_ICT_Hybrid.mq5) | Indicator | Visualizes OB / FVG / BOS / CHoCH / liquidity / sessions / kill zones / Silver Bullet. Exposes 10 buffers for EAs. |
| [`PA_SMC_ICT_EA.mq5`](PA_SMC_ICT_EA.mq5) | Expert Advisor | Reads the indicator via `iCustom` and trades setups #1 and #4. |
| [`Include/PASMC_Utils.mqh`](Include/PASMC_Utils.mqh) | Header | Shared helpers (pivots, FVG/sweep detection, drawing, sizing, NY-time conversion). |

## Install

1. **MT5** → File → **Open Data Folder**.
2. Copy `PA_SMC_ICT_Hybrid.mq5` to `MQL5/Indicators/`.
3. Copy `Include/PASMC_Utils.mqh` to `MQL5/Include/`.
4. Copy `PA_SMC_ICT_EA.mq5` to `MQL5/Experts/`.
5. Open **MetaEditor** (F4 in MT5).
6. Compile the indicator first (F7) — 0 errors expected. Then compile the EA.
7. Back in MT5, refresh the Navigator and drag onto a chart.

## Indicator inputs

| Group | Input | Default | Notes |
|---|---|---|---|
| Pivots | `InpPivotN` | 5 | Higher = cleaner swings, fewer signals |
| OB | `InpMaxOBs` | 8 | Cap to keep chart readable |
| FVG | `InpMaxFVGs`, `InpFVGMinAtrFrac` | 6, 0.30 | Filter tiny gaps |
| Liquidity | `InpEqTolPips` | 3 | EQH/EQL tolerance |
| Time | `InpBrokerGmtOffset` | 2 | Match your broker's server time vs GMT |
| Drawing | `InpShowSessions`, `InpShowKillzones`, `InpShowSilverBullet` | true | Background shading toggles |
| Range | `InpShowOTE`, `InpRangeBars` | true, 60 | 50% midpoint + OTE band |
| Alerts | `InpUsePopup` / `InpUsePush` / `InpUseEmail` | true / false / false | Alert channels |

### Verify it works

Apply on EURUSD M15. You should see:

- BOS / CHoCH dotted trend lines + labels.
- OB rectangles (lime / crimson). They turn orange when broken (= breaker).
- FVG rectangles (aquamarine / magenta).
- "🩸 SSL" / "🩸 BSL" texts on sweep candles.
- "EQH" / "EQL" dashed lines at equal-highs / lows.
- Background tinting on Asia / London / NY (and yellow on Silver Bullet hours).

## EA inputs

| Input | Default | Meaning |
|---|---|---|
| `InpRiskPct` | 0.5 | Risk per trade as % of equity |
| `InpRRTP1` / `InpRRTP2` | 1.5 / 3.0 | Reward multiples |
| `InpTP1Frac` | 0.5 | Fraction of position closed at TP1 |
| `InpSlBufferAtrFrac` | 1.0 | SL = OB extreme ± this × ATR(14) |
| `InpAllowS1` / `InpAllowS4` | true | Setup toggles |
| `InpOnlyKillzones` | true | Time filter |
| `InpBrokerGmtOffset` | 2 | Broker → GMT offset (h) |
| `InpMagic` | 770401 | Trade tag |

### Run live (after demo testing)

1. Drop EA on a chart. Make sure **Allow Algo Trading** is on (toolbar).
2. Smiley face = running. Sad face = blocked (check Common tab → Allow live trading).
3. Logs in **Experts** tab and `Tools → Toolbox → Journal`.
4. The EA does not interfere with manual trades — they are tagged with different magic numbers.

### Backtest in Strategy Tester

1. **View → Strategy Tester** (Ctrl+R).
2. Expert: `PA_SMC_ICT_EA`. Symbol: e.g. EURUSD. TF: M15.
3. Date range: at least 6 months.
4. Modeling: **Every tick based on real ticks** (best) or **1 minute OHLC** (fast).
5. **Start**.
6. Read Report tab. Aim for: profit factor > 1.3, max DD < 15 %, > 50 trades.

> The EA places **two market orders** per setup (one TP1 chunk, one TP2 chunk). Some brokers don't support partial closes — if so, set `InpTP1Frac` to `1.0` (single TP1 exit) or `0.0` (single TP2 exit).

## Buffer reference (for custom EAs)

The indicator exposes 10 buffers, indexed via the constants in [`Include/PASMC_Utils.mqh`](Include/PASMC_Utils.mqh):

| Buffer | Symbolic name | Meaning |
|---|---|---|
| 0 | `PASMC_BUF_BIAS` | +1 bull / -1 bear / 0 none |
| 1 | `PASMC_BUF_LASTPH` | Last confirmed swing high (price) |
| 2 | `PASMC_BUF_LASTPL` | Last confirmed swing low (price) |
| 3 | `PASMC_BUF_BULLOB_TOP` | Most recent bullish OB top |
| 4 | `PASMC_BUF_BULLOB_BOT` | …bottom |
| 5 | `PASMC_BUF_BEAROB_TOP` | Most recent bearish OB top |
| 6 | `PASMC_BUF_BEAROB_BOT` | …bottom |
| 7 | `PASMC_BUF_FVG_BULL` | 1.0 if a bullish FVG printed on this bar |
| 8 | `PASMC_BUF_FVG_BEAR` | mirror |
| 9 | `PASMC_BUF_SETUP` | `ENUM_PASMC_SETUP` cast to double |

Read with `iCustom(_Symbol, _Period, "PA_SMC_ICT_Hybrid")` and `CopyBuffer`.

## Known limitations

- The indicator's session-shading code in this MQL5 version draws a single bounding rectangle — it does not pixel-perfectly mark every Asia/London/NY band like the Pine version. If you want per-session shading, edit the `OnCalculate` block that handles `InpShowSessions` and add per-day rectangles (TODO marked in code).
- DST is approximated — the `InpBrokerGmtOffset` is static. Adjust manually twice a year, or extend `PASMC_InNySession` in `PASMC_Utils.mqh` to read host timezone.
- Drawing 100s of OB/FVG boxes on slow machines is OK but use `InpMaxOBs` and `InpMaxFVGs` to cap.
- The EA is intentionally simple. It does **not** trail or move SL to break-even — add that yourself in `OnTick` if needed.

## Read this before live use

- [`../guide/04-hybrid-framework.md`](../guide/04-hybrid-framework.md)
- [`../guide/09-risk-management.md`](../guide/09-risk-management.md)
- [`../guide/11-metatrader-walkthrough.md`](../guide/11-metatrader-walkthrough.md)
