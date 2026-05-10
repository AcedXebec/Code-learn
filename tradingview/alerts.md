# TradingView Alerts Cookbook

Wire the indicator's `alertcondition()` outputs into push notifications, Discord, and Telegram.

## All available alert names

From `pa_smc_ict_hybrid.pine`:

| Alert name | Fires when | Setup |
|---|---|---|
| `Sweep+CHoCH long` | bullish liquidity sweep + close above structure inside a kill zone | #1 long |
| `Sweep+CHoCH short` | mirror | #1 short |
| `SilverBullet FVG bull` | bullish FVG forms inside a SB window | #2 long |
| `SilverBullet FVG bear` | bearish FVG forms inside a SB window | #2 short |
| `Breaker tagged long` | failed bearish OB tagged from below | #4 long |
| `Breaker tagged short` | failed bullish OB tagged from above | #4 short |
| `BOS / CHoCH up` | any structural break up | (informational) |
| `BOS / CHoCH down` | any structural break down | (informational) |

From `pa_smc_ict_strategy.pine`:

| Alert name | Fires when |
|---|---|
| `S1 long entry`  | strategy emits S1 long  |
| `S1 short entry` | strategy emits S1 short |
| `S4 long entry`  | strategy emits S4 long  |
| `S4 short entry` | strategy emits S4 short |

## Creating an alert

1. Right-click on the chart → **Add alert** (or `Alt+A`).
2. **Condition**: select the indicator, then the sub-condition (e.g. `Sweep+CHoCH long`).
3. **Options**: `Once Per Bar Close` (recommended).
4. **Expiration**: Open-ended (free plan: 24h max).
5. **Notifications**: enable webhook / push / email / popup.
6. **Message**: see templates below.

## Webhook payload templates

### Discord (incoming webhook)

```json
{
  "content": "🚨 **{{exchange}}:{{ticker}}** — `{{plot_0}}` setup — {{interval}} — close `{{close}}` at {{time}}"
}
```

### Telegram (via webhook bridge — e.g. webhook → IFTTT/Make)

```json
{
  "symbol": "{{ticker}}",
  "tf": "{{interval}}",
  "setup": "{{plot_0}}",
  "price": {{close}},
  "time": "{{time}}"
}
```

### Generic (TradingView placeholder reference)

| Placeholder | Meaning |
|---|---|
| `{{ticker}}` | Symbol code |
| `{{exchange}}` | Exchange |
| `{{interval}}` | Timeframe |
| `{{close}}` `{{open}}` `{{high}}` `{{low}}` | Last bar OHLC |
| `{{time}}` | Bar time, ISO 8601 |
| `{{volume}}` | Last bar volume |
| `{{plot_0}}` | First plot value |

## Multi-symbol alert workflow

1. Build a watchlist (e.g. *FX Majors*: EURUSD, GBPUSD, USDJPY, AUDUSD, NZDUSD, USDCAD).
2. Apply the indicator + a saved input template to each chart.
3. For each symbol+TF, create one alert per setup you want pinged.
4. Pro/Premium TradingView accounts let you create alerts on a watchlist with `(symbol)` placeholders, but the free plan caps you at ~5 alerts — use the **Strategy alert** trick: the strategy script's `S1 long entry` covers all bias-confirmed S1 longs in one alert.

## Throttling

Repeating alerts can be noisy. Two tactics:

- Use `Once Per Bar Close` instead of `Once Per Bar`.
- Add a **min-interval** filter in your webhook receiver (e.g. drop duplicates within 5 min).

## Known gotchas

- Alerts defined inside a strategy script consume the same alert slot as indicator alerts; if a chart has both, you can hit the limit fast.
- Alerts attached to a script that **uses request.security with `lookahead_on`** can repaint. Our scripts use `lookahead_off` deliberately.
- TradingView free plan limits: 1 alert per script, 1 alert per chart total. Strategy alerts count too. Pro+ plan recommended.
