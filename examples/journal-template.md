# Trade Journal Template

Copy this block per trade. Keep it terse — the value is in the *patterns* you see across 50–100 entries, not in any single one.

A spreadsheet works equally well; the markdown form below is convenient when you're already editing this repo.

---

## Trade #___ — `YYYY-MM-DD` — `SYMBOL` `TIMEFRAME`

| Field | Value |
|---|---|
| Setup #            | 1 / 2 / 3 / 4 |
| HTF bias           | Bullish / Bearish (D1 BOS direction) |
| Liquidity swept    | EQH / EQL / PDH / PDL / Asia-H / Asia-L |
| POI                | OB / FVG / breaker — price range |
| LTF trigger        | M5 CHoCH↑ / CHoCH↓ / FVG-tap / Silver Bullet FVG |
| In kill zone?      | London KZ / NY AM KZ / NY PM KZ / SB / outside |
| Entry              | `1.2345` |
| Stop loss          | `1.2300` (45 pips, anchored to: sweep low / OB body / Judas wick) |
| TP1                | `1.2415` (R:R `1.6`, target: `Asia high`) |
| TP2                | `1.2475` (R:R `2.9`, target: `PDH`) |
| Size               | `0.42 lots` (account `$10,000`, risk `0.5 %` = `$50`) |
| Result             | `+1.15 R` (TP1 hit, runner stopped at BE) |
| Mistakes           | None / Entered too early / SL too tight / FOMO / Revenge / No bias |
| Screenshot         | `../guide/diagrams/{symbol}-{tf}-{date}.png` |
| Lesson             | One-line takeaway you can act on next time |

---

## Weekly review block (copy once per week)

| Field | Value |
|---|---|
| Trades | 7 |
| Wins / Losses / Skips | 3 / 3 / 1 |
| Win rate | 50 % |
| Gross R | +5.4 R |
| Avg win | +1.8 R |
| Avg loss | −1.0 R |
| Expectancy | +0.42 R / trade |
| Best setup this week | #1 |
| Worst setup this week | #4 (1 of 2 lost — small sample) |
| #1 mistake category | Tried to enter before LTF CHoCH (twice) |
| One change for next week | Wait for the M5 close above LH **before** placing the limit order |

---

## Monthly aggregation (copy once per month)

| Field | Value |
|---|---|
| Trades | 28 |
| Win rate | 46 % |
| Expectancy | +0.36 R |
| Net R | +10.1 R |
| Max DD | −3.2 R |
| Setup that lost money this month | (none / #2 / #3 / etc.) |
| Setup that made the most | #1 (+8.2 R, 18 trades) |
| Action for next month | (e.g. "drop setup #3 from rotation until I can swing-trade it on D1") |

---

> Template inspired by the guidance in [`../guide/09-risk-management.md`](../guide/09-risk-management.md#journaling--the-boring-magic). Keep it boring; that is the point.
