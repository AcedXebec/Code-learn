# Diagrams

This folder is intentionally light. The guide chapters use **ASCII candlestick art** to keep the markdown / PDF self-contained — no image dependencies, no broken links, no platform-specific rendering.

## Drop your own screenshots here

If you want to enrich the PDF with real chart screenshots, save them in this folder and reference them from the guide chapters with relative paths:

```markdown
![Setup #1 example — EURUSD M15](diagrams/eurusd-m15-setup1-2026-04.png)
```

Recommended naming convention:

```
{symbol}-{timeframe}-{setup}-{YYYY-MM}.png
```

Examples:

- `eurusd-m15-setup1-2026-04.png`
- `btcusdt-h1-setup4-2026-04.png`
- `nq-m5-silverbullet-2026-04.png`

## Capturing screenshots

| Platform | How |
|---|---|
| **TradingView** | Click the camera icon → **Save chart image** → keep size at 2× for PDF |
| **MetaTrader 5** | File → Save As Picture → PNG, "Active workspace as is" |
| **MetaTrader 4** | Same menu, slightly different label |

After saving, annotate with arrows / boxes if helpful (e.g. Excalidraw, Skitch, macOS Preview's markup tools).

## Building the PDF with images

`tools/build-pdf.sh` already supports embedded images via standard markdown — `weasyprint` resolves relative paths during HTML conversion. Drop a PNG here, reference it in a chapter, rebuild:

```bash
bash tools/build-pdf.sh
```

The image will be embedded in `dist/PriceAction_SMC_ICT_Hybrid_Guide.pdf`.
