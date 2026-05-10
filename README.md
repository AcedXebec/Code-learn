# Price Action + SMC/ICT Hybrid — Beginner's Repo

A complete, **beginner-friendly** learning resource that combines classical **Price Action**, **Smart Money Concepts (SMC)**, and **Inner Circle Trader (ICT)** methodology into one practical framework — with working code for **TradingView (Pine Script v5)**, **MetaTrader 5 (MQL5)**, and **MetaTrader 4 (MQL4)**.

> **Disclaimer.** This repo is educational. Nothing here is financial advice. Markets are risky, you can lose money, and no strategy is a guarantee. Backtest, demo-trade, and use proper risk management.

---

## What you get

| Pillar | Where | What |
|---|---|---|
| 📘 **Written guide** | [`guide/`](guide/) | 13 chapters of beginner-friendly markdown teaching every term from scratch + an exported [PDF](dist/) |
| 📈 **TradingView code** | [`tradingview/`](tradingview/) | One Pine Script v5 hybrid indicator + a backtestable strategy + alerts cookbook |
| 🤖 **MetaTrader 5 code** | [`mt5/`](mt5/) | MQL5 indicator + semi-auto EA stub + shared `.mqh` utils |
| 🤖 **MetaTrader 4 code** | [`mt4/`](mt4/) | MQL4 port of the indicator + EA stub |
| 🎯 **Worked examples** | [`examples/`](examples/) | 8 annotated trade walkthroughs (ASCII charts) — 2 per setup |

## The four setups taught

1. **Liquidity sweep + CHoCH + OB entry** — the SMC bread-and-butter
2. **ICT Silver Bullet** — 15-minute kill-zone windows
3. **Power of 3 (AMD)** — daily session bias model
4. **Breaker block + FVG mitigation** — failed OBs flipped

## Markets & timeframes covered

- **Forex intraday** (M5 / M15 / H1) — London + NY kill zones
- **Crypto 24/7** (M15 / H1 / H4) — BTC/ETH and majors
- **Swing trading** (H4 / Daily) — HTF order blocks, weekly bias

---

## Suggested reading order

1. [`guide/00-overview.md`](guide/00-overview.md) — orientation
2. [`guide/01-price-action-foundations.md`](guide/01-price-action-foundations.md) — candles, swings, trend
3. [`guide/02-smc-core.md`](guide/02-smc-core.md) — BOS, CHoCH, OB, FVG, liquidity, premium/discount
4. [`guide/03-ict-essentials.md`](guide/03-ict-essentials.md) — sessions, kill zones, displacement
5. [`guide/04-hybrid-framework.md`](guide/04-hybrid-framework.md) — **the spine: 5-step decision flow**
6. [`guide/05-setup-liquidity-choch-ob.md`](guide/05-setup-liquidity-choch-ob.md) → 06 → 07 → 08 — the four setups
7. [`guide/09-risk-management.md`](guide/09-risk-management.md) — sizing, stops, partials
8. [`guide/10-tradingview-walkthrough.md`](guide/10-tradingview-walkthrough.md) and [`11-metatrader-walkthrough.md`](guide/11-metatrader-walkthrough.md) — install + use the code
9. [`guide/12-checklists.md`](guide/12-checklists.md) — pre/in/post-trade checklists
10. [`guide/glossary.md`](guide/glossary.md) — definitions of every term

## Quickstart

### TradingView
1. Open Pine Editor on any chart.
2. Paste [`tradingview/pa_smc_ict_hybrid.pine`](tradingview/pa_smc_ict_hybrid.pine).
3. Click **Add to chart**. Tweak inputs.
4. For backtesting: paste [`tradingview/pa_smc_ict_strategy.pine`](tradingview/pa_smc_ict_strategy.pine) instead.

### MetaTrader 5
1. In MT5 → File → Open Data Folder → `MQL5/Indicators/`.
2. Copy `mt5/PA_SMC_ICT_Hybrid.mq5` and the `Include/PASMC_Utils.mqh` into the matching folders.
3. Compile in MetaEditor (F7). Drag indicator onto chart.

### MetaTrader 4
1. Same flow but `MQL4/Indicators/`. Compile, attach to chart.

Detailed install + parameter reference is in each platform's `README.md`.

## Build the PDF

```bash
bash tools/build-pdf.sh
# produces dist/PriceAction_SMC_ICT_Hybrid_Guide.pdf
```

## License

[MIT](LICENSE) — use freely, attribution appreciated.

## Credits

This material was synthesized from public ICT/SMC educational resources; see [`guide/references.md`](guide/references.md) for the full citation list. We thank the open-source authors who published their Pine and MQL implementations.
