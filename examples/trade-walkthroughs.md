# Trade Walkthroughs — 8 Worked Examples

Two annotated examples per setup, with ASCII charts and step-by-step framework attribution. The numbers are illustrative (not historical signals); they are calibrated to feel like real EURUSD / GBPUSD / NQ / BTCUSD price action.

> **Reading guide:** for each walkthrough, the columns `Step`, `Observation`, `Decision`, and `R` map to the framework in [`../guide/04-hybrid-framework.md`](../guide/04-hybrid-framework.md). Skim the chart, then read the table.

---

## Setup #1A — EURUSD M15, London open long

```
                                                ╳ TP2 = PDH @ 1.0871
                                              ╱
                                            ╱
                                          ╱
                                        ╳   TP1 = Asia high @ 1.0843
                                      ╱
                                    ╱
                                  ╱
                            ╱╲   ╱
                          ╱   ╲ ╱
                        ╱      ╳     ★ M5 CHoCH↑ at 1.0820
                      ╱       ╱       enter on retest of OB top 1.0815
                    ╱       ╱
   ────╳───────────────────╳ ──── bullish OB 1.0810–1.0815
        ╲               ╱
          ╲           ╱
            ╲       ╱
              ╲   ╱
                ╳   ★ wick to 1.0808 sweeps PDL @ 1.0805
   ───── PDL 1.0805 ────────  SL anchor: 1.0803
```

| Step | Observation | Decision |
|---|---|---|
| 1 — HTF bias | Daily BOS up last week; price in lower 40% of weekly range | Bullish |
| 2 — Liquidity | PDL at 1.0805, Asia low 1.0820 | SSL targets |
| 3 — POI | Bullish OB at 1.0810–1.0815 (last bear M15 candle before yesterday's NY rally) | Pick this OB |
| 4 — Trigger | London open: wick to 1.0808 sweeps PDL; M5 CHoCH at 1.0820 | Long limit @ 1.0815 |
| 5 — Risk | SL 1.0803 (12 pip risk). TP1 1.0843 (2.3R). TP2 1.0871 (4.6R). 0.5% risk → 0.42 lots | Send |
| Result | TP1 hits at 09:42 NY (50% off, SL → BE). Runner stops at BE around 11:00 NY | **+1.15 R** |

**Lessons**: textbook setup; SL anchored to sweep low (not OB body); TP1 within reach of the next session high.

---

## Setup #1B — GBPUSD H1, NY AM short

```
   ──── PDH 1.2710 (BSL pool) ─────                 
                ╲                                    
                  ╲   ★ wick to 1.2715 sweeps PDH    
                    ╳   then closes back below      
                  ╱   ╲                              
                ╱       ╲                            
              ╱           ╲   ★ H1 CHoCH↓ at 1.2680  
            ╱               ╲     enter on retest    
          ╱                   ╲                      
        ╱                       ╲                    
      ╱  ┌──────────────────┐    ╲                   
   ────╱  │  bearish OB      │     ╲                  
       ╲  └──────────────────┘       ╲                
         ╲                            ╲              
           ╲                            ╲            
             ╲                            ╳ TP1 = Asia low 1.2625
                                          ╱
                                        ╱
                                      ╳   TP2 = PDL 1.2580
```

| Step | Observation | Decision |
|---|---|---|
| 1 — Bias | D1 BOS down two days ago; price in upper half H4 range | Bearish |
| 2 — Liquidity | PDH 1.2710, Asia high 1.2702 | BSL pool |
| 3 — POI | Bearish H1 OB at 1.2685–1.2695 (last bull H1 before the down impulse) | This OB |
| 4 — Trigger | 09:30 NY: wick to 1.2715 (PDH swept), candle closes 1.2693; H1 CHoCH at 1.2680 close | Short @ 1.2690 |
| 5 — Risk | SL 1.2722 (32 pip risk). TP1 Asia low 1.2625 (2.0R). TP2 PDL 1.2580 (3.4R) | Send |
| Result | TP1 hits at 13:00 NY (50% off, SL → BE). Runner stops at BE | **+1.0 R** |

**Lesson**: H1 setups exhibit the same anatomy as M15 — only the SL distance changes. Lot size scales down accordingly.

---

## Setup #2A — NQ futures M5, NY AM Silver Bullet long

```
                                          ★ TP = 09:30 high 18,260
                                        ╱
                                      ╱
                                    ╱
                                  ╱
                                ╱     ┌──────────────┐
                              ╱       │ bull FVG     │ ← entry zone
                            ╱         │ 18,222–18,232│
                          ╱           └──────────────┘
                        ╱
                      ╱
                    ╱
   ────╳ ─── 10:00 NY (window opens) ──────────
        ╲           ★ 10:05 NY: wick to 18,205
          ╲           sweeps 09:30 low (SSL)
            ╲       ╱
              ╲   ╱
                ╳ ╳
   ──── SSL: 09:30 low 18,210 ────
```

| Step | Observation | Decision |
|---|---|---|
| 1 — Bias | Daily BOS up; price in discount on H4 | Bullish |
| 2 — Pre-window | 09:30 NY low at 18,210, PDL at 18,180 | SSL targets |
| 3 — Window opens | 10:00 NY → start watching | … |
| 4 — Sweep + FVG | 10:05 wick to 18,205; M3 FVG forms 18,222–18,232 inside the window | Long limit @ 18,232 |
| 5 — Risk | SL 18,201 (4 pts below sweep low). TP 18,260. R:R ≈ 2.4 | Send |
| Result | Filled at 10:15. TP hit 10:38. | **+2.4 R** |

**Lesson**: discipline. The trade is "set and wait" — there is no managing in a 30-minute window. If the window closes without a fill, do nothing.

---

## Setup #2B — BTCUSDT M5, NY PM Silver Bullet short

```
                                                       
   ──── BSL: 09:30 NY high 70,420 ────                  
                  ╳                                      
                ╱   ╲                                    
              ╱       ╳   ★ 14:08 NY: wick to 70,440      
            ╱       ╱   ╲   sweeps NY 09:30 high         
          ╱       ╱       ╲                              
        ╱       ╱           ╲                            
   ────╳ ── 14:00 NY window opens ─────────────────       
        ╲                       ╲                        
          ╲                       ┌──────────────┐       
            ╲                     │ bear FVG     │       
              ╲                   │ 70,265–70,255│       
                ╲                 └──────────────┘       
                  ╲                                      
                    ╳ TP1 = pre-window low 70,090        
                                                         
```

| Step | Observation | Decision |
|---|---|---|
| 1 — Bias | BTC daily made LH+LL last 3 days; H4 in premium | Bearish |
| 2 — Pre-window | 09:30 NY high at 70,420 | BSL target |
| 3 — Window | 14:00 NY → watch | … |
| 4 — Sweep + FVG | 14:08 wick to 70,440; M5 bear FVG 70,255–70,265 inside the window | Short limit @ 70,265 |
| 5 — Risk | SL 70,460 (above sweep + buffer = 195 USD risk). TP 70,090 → 175 / 195 ≈ 1.8R | Send (just above min R) |
| Result | Filled 14:21. TP1 hit 15:14. | **+1.8 R** |

**Lesson**: crypto requires bigger absolute SLs but the structure is identical. Use ATR sizing for the buffer.

---

## Setup #3A — Bullish PO3 day, GBPUSD

```
   00:00 NY     03:00 NY        10:00 NY        16:00 NY
       │          │                │                │
       │   A      │   M (Judas)    │   D            │
       │          │   wicks below  │   sustained up │
       │  ▢▢▢▢▢   │      ↓         │       ↑↑       │
       │  range   │                │                │
       │  forms   │                │                │
       
   Asia range: 1.2510 – 1.2535
   M:  02:30 NY (London) wicks to 1.2497, closes 1.2522 → Judas confirmed
   D:  07:30 NY: M5 CHoCH up at 1.2535. Bullish OB at 1.2520 from displacement
       Entry at retest 1.2525.
```

| Phase | Window | Observation |
|---|---|---|
| Bias | Daily | HHs+HLs since last Friday's BOS up — bullish |
| A | 19:00 → 02:00 NY | Range 1.2510 – 1.2535 |
| M | 02:30 NY | Wick to 1.2497, closes 1.2522. Judas ✓ |
| D | 07:30 NY | M5 CHoCH up at 1.2535; OB at 1.2520 — enter retest |
| Entry | 1.2525 | SL 1.2493 (32 pips), TP1 1.2580 (1.7R), TP2 1.2620 (2.9R) |
| Result | TP1 hit 10:30 NY (+0.85R after 50% off). Runner +2.7R at 14:00 NY | **+1.55 R** total |

**Lesson**: PO3 days run for the full session. The runner is what makes the math work — partials only at clearly defined liquidity, not arbitrary R levels.

---

## Setup #3B — Bearish PO3 day, USDJPY

```
   Asia: 156.10 – 156.40 range
   M:  02:00 NY London open wicks to 156.55 (above Asia high), closes 156.32
   D:  NY session sustained down to PDL at 155.40
   
                  M (Judas wick)
                  ↑
      ╱╲       ╱
    ╱   ╲   ╱
  ╱       ╳ ─── ──── 156.55 swept BSL
                  ╲
                    ╲           D — bearish push
                      ╲       ╱╲
                        ╲   ╱    ╲
                          ╳        ╲
                          ↓          ╲          ★ TP at PDL 155.40
                                       ╲       ╱
                                         ╲   ╱
                                           ╳
```

| Phase | Window | Observation |
|---|---|---|
| Bias | Daily | LH+LL twice this week; price in premium H4 — bearish |
| A | Asia range | 156.10 – 156.40 |
| M | 02:00 NY | Wick to 156.55, closes 156.32 — Judas above Asia high ✓ |
| D | 08:00 NY | M5 CHoCH down at 156.10; bearish OB at 156.20 — enter retest |
| Entry | 156.18 | SL 156.62 (44 pips); TP1 155.85 (33 pips, 0.75R) — too low |
| Decision | TP1 < 1.5R → **skip** the trade |
| Lesson | Sometimes the math doesn't work even on a clean PO3 day. **Skipping is a winning play** when expectancy is negative. |

**Lesson**: The framework's TP1 ≥ 1.5 R rule (chapter 09) saves you here. The setup is real, but the reward isn't.

---

## Setup #4A — BTCUSDT H1, breaker short

```
   1) bullish OB worked twice (was support)
   
                                          ╱╲          ╱
                                        ╱   ╲       ╱
                                      ╱      ╲    ╱
                                ╱╲ ╱           ╲╱
                              ╱   ╳ 
                            ╱     ┌──────────────┐
                          ╱       │ bullish OB   │  ← worked here
                                  └──────────────┘
                                                    
   2) D1 close at 69,400 = closed below the OB → broken
                                                     ╱╲
                                                   ╱   ╲
   ┌──────────────┐                          ★ CHoCH↓ on D1+H1
   │ now BREAKER  │ ────────╲                   ╱
   │ (was OB)     │          ╲                ╱
   └──────────────┘            ╲             ╱
                                 ╲          ╱
                                   ╲      ╱
                                     ╳  ╱   ★ FVG on the break leg
                                       ╳ 
                                                    
   3) Three days later, retest of the breaker
   
                                  ★ entry: tap the breaker (former OB)
                                  + the bear FVG inside it
   ┌──────────────┐               
   │ breaker      │ ── tap ──╳    
   └──────────────┘          ╳╲
                              ╳ ╲   ★ M5 CHoCH↓ — short
                                ╲
                                 ╲   target: broken 69,400, then 67,900
```

| Step | Observation |
|---|---|
| Prior trend | BTC bullish making HHs since 67k |
| The OB | H1 bullish OB 70.2k–70.5k (worked twice) |
| The break | Daily candle closes at 69.4k → **CHoCH↓** on H1 + Daily |
| The FVG | M15 bearish FVG at 70.1k–70.0k on the break leg |
| Retrace | 3 days later price rallies back to 70.05k — **tag** ✓ |
| Trigger | M5 CHoCH down at 70.05k → short at FVG top |
| SL | 70.55k (above breaker high + buffer) — risk 500 USD per BTC |
| TP1 | 69.4k (broken low). 1.3 R |
| TP2 | 67.9k (weekly low). 4.3 R |
| Result | TP1 hits overnight (50% off, SL → BE). Runner stopped at BE | **+0.65 R** |

**Lesson**: TP1 too tight (1.3R < 1.5R minimum) → trade still net positive but underwhelming. Re-evaluate `TP1 R:R` floor for crypto positions held overnight.

---

## Setup #4B — DXY (US Dollar Index) D1, breaker long

```
   1) bearish OB worked as resistance
   
                ┌──────────────┐
                │ bearish OB   │ ← rejected price twice
                └──────────────┘
              ╲             ╲
                ╲   ╱╲        ╲
                  ╳    ╲        ╲
                ╱        ╲        ╲
                          ╳         ╲
                                      ╲
   2) close above the OB on a strong daily → BOS↑ (which is also a CHoCH↑ vs the prior down structure)
   
                                              ┌──────────────┐
                                              │ breaker      │ (was OB)
                                              └──────────────┘
                                              ╱╲
                                            ╱   ╲
                                          ╱       ╲
                                        ╱          ╳
                                      ╱           ╱
                                    ╱           ╱
                                  ╱           ╱
                                ╱           ╱
                              ╱   ★ break-leg bull FVG
                            ╱   ╳
                          ╱   ╳
                                            
   3) pullback to the breaker
   
                              ★ entry: tap the breaker + bull FVG
                              + H1 CHoCH↑ at the tap
                              
                              long bias targets: prior swing high
```

| Step | Observation |
|---|---|
| Prior trend | DXY was bearish, made LL on D1 |
| The OB | Bearish D1 OB 105.40–105.80 |
| The break | Daily candle closes 106.20 — close above OB → BOS / CHoCH up |
| The FVG | H4 bull FVG 105.50–105.20 left on the break leg |
| Retrace | Two weeks later, price retraces to 105.60 — **tag** of breaker + FVG |
| Trigger | H1 CHoCH up at 105.85 |
| Entry | Long limit at 105.70 (FVG top) |
| SL | 105.10 (below breaker low + buffer) |
| TP1 | 106.40 (broken high). 1.2R |
| TP2 | 107.20 (Q1 high). 2.5R |
| Result | TP1 hits one week later. Runner +1.4R total | **+1.4 R** |

**Lesson**: D1 breakers often take days/weeks to mature. Don't blink. Set TPs as limit orders and walk away. The Pine alert `Breaker tagged + LTF CHoCH` will ping you when conditions hit.

---

## Common patterns across all 8 examples

- **TP1 was hit ~75 % of the time** (6 / 8 examples). With the 50 % partial + SL→BE rule, this is a low-stress edge.
- **Runner contributed > +1R additional** in 4 of 8 examples. Patience on the runner is where the big-R wins come from.
- **One trade was correctly skipped** (3B: TP1 < 1.5R). Skipping is a positive-expectancy action.
- **Bias was always set on D1/H4 first** — never on the trading TF.
- **Liquidity targets were always *named* levels** (PDH/PDL/Asia H/Asia L/EQH/EQL), never arbitrary R-multiples in space.

→ Practice these patterns in TradingView's Replay mode (Bar Replay button on toolbar) before going live.
