# References & Further Reading

Curated, attributed, and grouped. Everything below is **public** and freely accessible. No course-seller affiliate links.

> The Pine and MQL code in this repo is **original** but informed by the open-source projects listed below. We thank their authors. License compatibility was checked at time of writing — re-check before redistributing derivative work.

---

## Open-source repos (Pine Script v5)

- **[Musyimi97/phase404](https://github.com/Musyimi97/phase404)** — A complete TV indicator + MT5 EA + backtest config implementing PHASE 404 (Wyckoff AMD + liquidity + MSS + OTE + Smart Money Divergence). Closest match to our scope.
- **[tsunafire/PineScript-SMC-Strategy](https://github.com/tsunafire/PineScript-SMC-Strategy)** — Pine `strategy()` script focused on order blocks + liquidity sweeps.
- **[Ahmed-GoCode/Quant-Edge-Indicators](https://github.com/Ahmed-GoCode/Quant-Edge-Indicators)** — Six TradingView indicators for SMC, market structure, RSI, Fibonacci, FVG.
- **[Smart Money Concepts (LuxAlgo) Enhanced gist](https://gist.github.com/niquedegraaff/8c2f45dc73519458afeae14b0096d719)** — Community-enhanced fork of the LuxAlgo SMC indicator.
- **[SpxGh0st — ICT Killzones+Silver Bullet (TradingView)](https://www.tradingview.com/script/InMPCLO7-ICT-Killzones-and-Sessions-W-Silver-Bullet-Macros/)** — TradingView-hosted ICT killzones script with macros.

## Open-source repos (MetaTrader 5 / 4)

- **[VelmoPk/Smart-Money-Concepts-indicator-MT5](https://github.com/VelmoPk/Smart-Money-Concepts-indicator-MT5)** — Native MQL5 SMC indicator (OB, BOS/CHoCH, liquidity sweeps, FVG, no repaint).
- **[haza79/MT5-Smart-Money-Concept-Indicator](https://github.com/haza79/MT5-Smart-Money-Concept-Indicator)** — Performance-focused MT5 SMC indicator.
- **[MQL5 article — "Elevate Your Trading With Smart Money Concepts (SMC): OB, BOS, and FVG"](https://www.mql5.com/en/articles/16340)** — Good reference for the order-block / FVG detection algorithm in MQL5.

## Python / backtesting

- **[joshyattridge/smart-money-concepts](https://github.com/joshyattridge/smart-money-concepts)** — `pip install smartmoneyconcepts`. Best Python implementation of OB / FVG / liquidity / BOS / CHoCH detection on a pandas OHLC DataFrame. Excellent for *understanding* the algorithms before you write them in Pine or MQL.
- **[backtesting.py](https://pypi.org/project/backtesting/)** — Lightweight Python backtester; pairs well with `smartmoneyconcepts` for offline strategy validation.

## ICT theory — public mentorship-grade tutorials

- [innercircletrader.net — Silver Bullet strategy](https://innercircletrader.net/tutorials/ict-silver-bullet-strategy/)
- [innercircletrader.net — Master ICT Kill Zones](https://innercircletrader.net/tutorials/master-ict-kill-zones/)
- [innercircletrader.net — Power of 3 (free PDF)](https://innercircletrader.net/tutorials/ict-power-of-3/)
- [EBC Financial — What is the ICT Silver Bullet?](https://www.ebc.com/forex/what-is-the-ict-silver-bullet-meaning-rules-and-examples)
- [Ultima Markets — ICT Silver Bullet times to trade](https://www.ultimamarkets.com/academy/ict-silver-bullet-times-to-trade/)
- [Trading Finder — ICT Silver Bullet education](https://tradingfinder.com/education/forex/ict-silver-bullet/)
- [Writofinance — Trading with ICT Power of 3 (AMD setup)](https://www.writofinance.com/ict-power-of-3/)
- [TTrades — Power of Three explained](https://ttrades.com/ict-power-of-three-amd-accumulation-manipulation-distribution-explained/)
- [Trading Finder — Power of Three strategy](https://tradingfinder.com/education/forex/ict-power-of-three/)

## Classical price action

- *Trading Price Action Trends / Reversals / Ranges* — Al Brooks (4-volume series, paid).
- *The Methodical Forex Trader* — Bob Volman.
- [Babypips School of Pipsology](https://www.babypips.com/learn/forex) — Free beginner forex curriculum (chapters 1-7 cover all the price-action primitives we use).

## Wyckoff (the OG)

- *The Wyckoff Methodology in Depth* — Rubén Villahermosa.
- [Stockcharts.com — Wyckoff Analysis (free)](https://school.stockcharts.com/doku.php?id=market_analysis:the_wyckoff_method) — short, accurate, and free.

## Backtesting / journaling apps

- [TradingView Strategy Tester](https://www.tradingview.com/support/solutions/43000561856-strategy-tester/) — Pine-native.
- [MetaTrader 5 Strategy Tester](https://www.metatrader5.com/en/terminal/help/algotrading/strategy_testing) — multi-symbol, real-tick.
- [Tradezella](https://tradezella.com/) / [Edgewonk](https://edgewonk.com/) — paid, but well-suited to journaling SMC/ICT trades.

## Misc useful

- [TradingView Pine Reference v5](https://www.tradingview.com/pine-script-reference/v5/) — official.
- [MQL5 Documentation](https://www.mql5.com/en/docs) — official.
- [MQL4 Documentation](https://docs.mql4.com/) — official.

---

## A note on attribution

The framework synthesized in chapter 04 is **our** organization, but the components are decades old:

- **Wyckoff (1900s)** — accumulation/distribution, supply/demand zones.
- **Al Brooks / Bob Volman (2000s)** — modern bar-by-bar price action.
- **Steve Mauro / "Beat the Market Maker" (2010s)** — early M/W liquidity model.
- **Michael J. Huddleston / "Inner Circle Trader" (2014–present)** — kill zones, OTE, IPDA, Silver Bullet, Power of 3, displacement, FVG terminology.
- **Retail SMC community (2018–present)** — popularized BOS/CHoCH/OB/FVG vocabulary that this guide uses.

When sharing the indicator code or this guide externally, please retain the MIT license and credit notice.
