# 00 — Overview

Welcome. This guide will teach you **one** way to read a price chart that combines three traditions: classical price action, Smart Money Concepts (SMC), and Inner Circle Trader (ICT) methodology. It is written for someone who has **never** opened a chart before, but it does not waste your time if you have.

## How to use this guide

- **Read in order** the first time. Each chapter builds on the previous one.
- **Skim the [glossary](glossary.md)** before chapter 01. Don't memorize — just see what's there.
- **Re-read [04 — The Hybrid Framework](04-hybrid-framework.md) twice.** It is the spine of everything.
- **After chapter 09**, install the code on your platform of choice and try the indicator on a chart you already follow.

## Time budget

| Pace | Total reading | Total practice |
|---|---|---|
| Casual | 4–6 hours | 2 weeks of demo |
| Focused | 1 weekend | 1 week of demo |
| Sprint | 1 evening | Skip to backtest |

## What this guide is **not**

- **Not financial advice.** You are responsible for your own decisions.
- **Not a get-rich scheme.** No edge wins every trade. Plan to lose ~40% of trades even on a great setup.
- **Not platform-locked.** TradingView and MetaTrader are both first-class.
- **Not dogmatic.** ICT and SMC communities have many internal disagreements. Where we pick a side, we say why.

## Mental model: what is "smart money"?

When traders say **smart money**, they mean: the desks at investment banks, hedge funds, and proprietary trading firms that move enough size to actually move prices. These desks cannot just "buy" a billion dollars of EURUSD at market — they would slip through their own order books. They have to **build positions slowly, hide their intent, and trigger retail traders to take the other side** so they can fill.

Three things follow from that:

1. **Stops get hunted.** If you can see equal highs at 1.0850 with stops above, so can the algos. Wicking through them is how big positions get filled.
2. **Imbalances get filled.** When price moves fast in one direction, it leaves "fair value gaps" — the algos tend to revisit those gaps later.
3. **Time matters.** Major participants are most active at session opens (London 02:00 NY, NY 07:00 NY). Outside those windows, the tape is mostly noise.

If you accept those three premises, the rest of this guide is just *systematizing* them.

## What you'll build

By the end you will have:

- A **mental model** for analyzing any chart in 5 steps.
- A **Pine Script v5 indicator** that highlights the structures automatically on TradingView.
- A **Pine strategy** that can backtest 2 of the 4 setups.
- An **MQL5 indicator + EA stub** that does the same on MetaTrader 5.
- An **MQL4 port** for legacy brokers.
- A **PDF reference** of this guide that you can read offline.

→ Continue to [`01-price-action-foundations.md`](01-price-action-foundations.md).
