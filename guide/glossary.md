# Glossary

Every term used in this guide, in plain English. Sorted alphabetically. Curl up here whenever something looks like alphabet soup.

---

**AMD** — Accumulation, Manipulation, Distribution. ICT's three-phase model of how a single trading day (or any session) is delivered. See [`03-ict-essentials.md`](03-ict-essentials.md#power-of-3) and [`07-setup-power-of-3.md`](07-setup-power-of-3.md).

**Asia session** — Roughly 19:00–03:00 New York time. Often produces a tight range that becomes the day's accumulation phase.

**ATR (Average True Range)** — A volatility indicator. Useful for sizing stop losses adaptively (e.g. SL = OB extreme + 0.5 × ATR).

**Bias** — Your high-confidence directional lean for the day or week. Set on the HTF (Daily / H4); not changed casually.

**BOS (Break of Structure)** — A close beyond the most recent swing high (in an uptrend) or swing low (in a downtrend). Confirms trend continuation.

**Breaker block** — An order block that **failed** (price broke through it). When price returns to a former breaker, it tends to reject — often used as a trend-change POI. See [`08-setup-breaker-fvg.md`](08-setup-breaker-fvg.md).

**Buy-side liquidity (BSL)** — A pool of stop losses sitting **above** the market (typically buy stops above EQH and breakout buy entries). Smart money "runs" the BSL by spiking up before reversing.

**Candle** — One OHLC bar. Body = open→close; wicks = high/low extremes.

**CHoCH (Change of Character)** — A close beyond the most recent **opposite** swing point. Confirms trend reversal. Bullish CHoCH = first higher high after a downtrend; bearish CHoCH = first lower low after an uptrend.

**Confluence** — Multiple unrelated reasons all pointing the same way. We require at least 2-3 confluences before entering.

**Daily Open** — 00:00 New York / midnight ET. Reference price for the AMD model.

**Discount** — The lower 50% of a marked range. Bullish-biased buys belong here.

**Displacement** — A strong, fast move with multiple consecutive same-color candles and an obvious imbalance (FVG). Indicates institutional participation.

**Draw on liquidity** — The next big stop pool the market is "drawing toward." Used as TP target.

**EQH / EQL (Equal Highs / Equal Lows)** — Two or more highs (or lows) at the same price. Stop pools live above EQH and below EQL.

**Fair Value Gap (FVG)** — A 3-candle pattern where candle 1's wick and candle 3's wick do not overlap, leaving an "imbalance" gap on candle 2. See [`02-smc-core.md`](02-smc-core.md#fair-value-gap).

**Fibonacci OTE (Optimal Trade Entry)** — The 0.62–0.79 retracement zone of an impulse leg. ICT's preferred entry pocket within a POI.

**Higher High (HH) / Higher Low (HL)** — Sequence defining an uptrend.

**HTF (Higher Timeframe)** — Above your trading TF. If you trade M15, your HTF is H1 / H4 / D1.

**Imbalance** — Same idea as FVG: one-sided price delivery, unfilled on the way.

**Inner Circle Trader (ICT)** — Michael J. Huddleston's trading methodology. Source of kill zones, Silver Bullet, AMD, OTE, IPDA, etc.

**IPDA (Interbank Price Delivery Algorithm)** — ICT's mental model: price is delivered by an algorithm seeking liquidity.

**Judas swing** — The early-session false move that sweeps liquidity before the real session move. Often the "M" in AMD.

**Kill zone** — High-probability time window: London KZ ≈ 02:00–05:00 NY, NY AM KZ ≈ 07:00–10:00 NY, NY PM KZ ≈ 13:00–16:00 NY.

**Liquidity** — Resting orders. We trade *into* liquidity (target) and *from* liquidity (entry, after a sweep).

**Liquidity sweep** — Price wicks beyond a stop pool (EQH/EQL/PDH/PDL) and closes back inside. The smoking-gun "stop hunt."

**Lower High (LH) / Lower Low (LL)** — Sequence defining a downtrend.

**LTF (Lower Timeframe)** — Below your trading TF. If you trade M15, your LTF is M5 / M3 / M1 — used to time entries.

**Magic Number** — In MetaTrader, an integer that tags an EA's positions so it can manage them without touching manual trades.

**Manipulation** — The "M" in AMD. The Judas swing that fakes one direction before the real move.

**Mitigation** — When price returns to a POI (OB / FVG) and is rejected (or filled). After full mitigation, the POI loses its edge.

**MQL4 / MQL5** — The programming languages of MetaTrader 4 / MetaTrader 5.

**MT4 / MT5** — MetaTrader 4 and 5, the most popular retail forex platforms.

**NY (New York) session** — Roughly 07:00–16:00 NY time. The most volatile session for forex / indices.

**OB (Order Block)** — The last opposing-direction candle (or candle cluster) before a strong impulsive move. Acts as a high-probability return-to-POI zone.

**OHLC** — Open, High, Low, Close. The four prices that define a candle.

**OTE (Optimal Trade Entry)** — See *Fibonacci OTE*.

**PDH / PDL (Previous Day High / Low)** — Yesterday's H/L. Major liquidity magnets.

**Pine Script** — TradingView's domain-specific language for indicators and strategies. We use **v5**.

**Pivot** — A local swing high or swing low (Pine: `ta.pivothigh` / `ta.pivotlow`).

**POI (Point of Interest)** — A price zone we plan to enter from: OB / FVG / breaker. See [`02-smc-core.md`](02-smc-core.md).

**Position size** — Number of lots / units / contracts. Always derived from risk% and stop distance — never set arbitrarily.

**Power of 3 (PO3)** — ICT's name for AMD applied to the daily candle: Accumulation forms the open, Manipulation forms the wick, Distribution forms the body.

**Premium** — The upper 50% of a marked range. Bearish-biased sells belong here.

**Range** — A bounded price territory between a recent swing high and swing low. Premium = top half, discount = bottom half.

**R / R-multiple / R:R** — "R" = the dollar amount you risked. A trade that makes 3× what you risked = +3R. **R:R 1:2** = SL distance × 2 = TP distance.

**Sell-side liquidity (SSL)** — Stop pool **below** the market.

**Session** — A defined trading window — Asia, London, NY AM, NY PM.

**Silver Bullet** — ICT's tightly-defined 60-minute (or even 15-minute) windows: 10:00–11:00 NY (NY AM SB), 14:00–15:00 NY (NY PM SB), 03:00–04:00 NY (London SB). Trades inside these windows hit higher win rates statistically (per ICT's lessons).

**SL (Stop Loss)** — The price at which the trade is automatically closed for a loss. *Always* placed before entry, *always* respected.

**SMC (Smart Money Concepts)** — A retail synthesis of order-flow / liquidity / institutional-style trading. Heavily overlaps with ICT.

**Strategy Tester** — MetaTrader's built-in backtesting engine.

**Sweep** — Short for *liquidity sweep*.

**Swing High / Swing Low** — A local price extreme — a high (or low) with `n` lower (or higher) bars on each side.

**TF (Timeframe)** — The candle length you're looking at.

**TP (Take Profit)** — The price at which you (partially) close a winning trade.

**TradingView** — Web-based charting platform used to host Pine indicators and strategies.

**Trend** — Sequence of HH+HL (uptrend), LH+LL (downtrend), or neither (ranging).

**Wick** — The thin line above / below the body of a candle. Liquidity sweeps usually appear as long wicks.

---

→ Back to [`README.md`](../README.md) or jump to the framework: [`04-hybrid-framework.md`](04-hybrid-framework.md).
