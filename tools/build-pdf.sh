#!/usr/bin/env bash
# build-pdf.sh — concatenate guide/*.md and render to a single PDF.
#
# Order of preference (first available wins):
#   1. weasyprint (Python, HTML+CSS engine) — preferred, no headless browser needed
#   2. pandoc (with xelatex)                 — needs LaTeX
#   3. md-to-pdf (npm/npx)                   — needs Chromium; doesn't run as root
#
# Output: dist/PriceAction_SMC_ICT_Hybrid_Guide.pdf
#         dist/PriceAction_SMC_ICT_Hybrid_Guide.md   (concatenated source)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GUIDE_DIR="$ROOT/guide"
DIST_DIR="$ROOT/dist"
mkdir -p "$DIST_DIR"

OUT_MD="$DIST_DIR/PriceAction_SMC_ICT_Hybrid_Guide.md"
OUT_PDF="$DIST_DIR/PriceAction_SMC_ICT_Hybrid_Guide.pdf"

# ---------------------------------------------------------------- concatenate
echo "==> Concatenating guide chapters into $OUT_MD"
{
  echo "% Price Action + SMC/ICT Hybrid — A Beginner's Guide"
  echo "% Code-learn repo"
  echo "% $(date +'%B %Y')"
  echo
  echo "# Price Action + SMC/ICT Hybrid"
  echo
  echo "*A beginner-friendly synthesis of classical price action, Smart Money Concepts, and Inner Circle Trader methodology, with companion code for TradingView, MetaTrader 5, and MetaTrader 4.*"
  echo
  echo "---"
  echo
  for f in \
      "$GUIDE_DIR/00-overview.md" \
      "$GUIDE_DIR/01-price-action-foundations.md" \
      "$GUIDE_DIR/02-smc-core.md" \
      "$GUIDE_DIR/03-ict-essentials.md" \
      "$GUIDE_DIR/04-hybrid-framework.md" \
      "$GUIDE_DIR/05-setup-liquidity-choch-ob.md" \
      "$GUIDE_DIR/06-setup-silver-bullet.md" \
      "$GUIDE_DIR/07-setup-power-of-3.md" \
      "$GUIDE_DIR/08-setup-breaker-fvg.md" \
      "$GUIDE_DIR/09-risk-management.md" \
      "$GUIDE_DIR/10-tradingview-walkthrough.md" \
      "$GUIDE_DIR/11-metatrader-walkthrough.md" \
      "$GUIDE_DIR/12-checklists.md" \
      "$GUIDE_DIR/glossary.md" \
      "$GUIDE_DIR/references.md"
  do
    if [[ -f "$f" ]]; then
      echo
      echo
      cat "$f"
    fi
  done
} > "$OUT_MD"

echo "==> Concatenated MD: $(wc -l < "$OUT_MD") lines"

# ---------------------------------------------------------------- render

render_with_weasyprint() {
  python3 - "$OUT_MD" "$OUT_PDF" <<'PY' 2>/dev/null
import sys
try:
    import markdown
    import weasyprint
except ImportError:
    sys.exit(2)

src, dst = sys.argv[1], sys.argv[2]
with open(src, "r", encoding="utf-8") as f:
    md_text = f.read()

html_body = markdown.markdown(
    md_text,
    extensions=["extra", "toc", "codehilite", "tables", "fenced_code", "sane_lists"],
)

CSS = """
@page { size: A4; margin: 18mm 16mm; @bottom-right { content: counter(page) " / " counter(pages); font-size: 9pt; color: #888; }}
body { font-family: 'DejaVu Sans', 'Liberation Sans', sans-serif; font-size: 10.5pt; line-height: 1.45; color: #222; }
h1 { page-break-before: always; border-bottom: 2px solid #444; padding-bottom: 6px; color: #111; font-size: 22pt; }
h1:first-of-type { page-break-before: auto; }
h2 { margin-top: 1.5em; color: #222; border-bottom: 1px solid #ccc; padding-bottom: 4px; font-size: 16pt; }
h3 { margin-top: 1.3em; color: #333; font-size: 13pt; }
h4 { margin-top: 1.1em; color: #444; }
p, li { orphans: 2; widows: 2; }
pre, code { font-family: 'DejaVu Sans Mono', 'Liberation Mono', monospace; font-size: 9pt; }
pre { background: #f5f5f5; padding: 8px 10px; border-left: 3px solid #888; white-space: pre-wrap; word-wrap: break-word; page-break-inside: avoid; }
code { background: #f0f0f0; padding: 1px 4px; border-radius: 2px; }
table { border-collapse: collapse; margin: 1em 0; width: 100%; page-break-inside: avoid; }
th, td { border: 1px solid #bbb; padding: 5px 8px; text-align: left; vertical-align: top; font-size: 9.5pt; }
th { background: #eee; }
blockquote { border-left: 4px solid #888; padding: 0.4em 1em; color: #444; background: #fafafa; margin: 1em 0; }
a { color: #06c; text-decoration: none; }
hr { border: none; border-top: 1px solid #ccc; margin: 1.5em 0; }
ul, ol { padding-left: 1.4em; }
"""

html = f"""<!doctype html><html lang="en"><head><meta charset="utf-8">
<title>Price Action + SMC/ICT Hybrid — Beginner's Guide</title>
<style>{CSS}</style></head><body>{html_body}</body></html>"""

weasyprint.HTML(string=html).write_pdf(dst)
print("OK")
PY
  return $?
}

render_with_pandoc() {
  command -v pandoc >/dev/null 2>&1 || return 1
  echo "==> Rendering with pandoc"
  pandoc "$OUT_MD" -o "$OUT_PDF" \
    --pdf-engine=xelatex --toc --toc-depth=2 \
    -V geometry:margin=1in -V mainfont="DejaVu Serif" -V monofont="DejaVu Sans Mono" \
    -V colorlinks=true 2>/dev/null && return 0
  pandoc "$OUT_MD" -o "$OUT_PDF" --toc --toc-depth=2 -V colorlinks=true && return 0
  return 1
}

render_with_md_to_pdf() {
  command -v npx >/dev/null 2>&1 || return 1
  echo "==> Rendering with npx md-to-pdf (will fail if running as root)"
  npx --yes md-to-pdf < "$OUT_MD" > "$OUT_PDF" 2>/dev/null && [[ -s "$OUT_PDF" ]] && return 0
  return 1
}

echo "==> Trying weasyprint…"
if render_with_weasyprint && [[ -s "$OUT_PDF" ]]; then
  echo "==> Done. PDF: $OUT_PDF ($(stat -c%s "$OUT_PDF") bytes)"
elif render_with_pandoc && [[ -s "$OUT_PDF" ]]; then
  echo "==> Done. PDF: $OUT_PDF"
elif render_with_md_to_pdf; then
  echo "==> Done. PDF: $OUT_PDF"
else
  echo
  echo "!! No PDF backend worked. Install ONE of:"
  echo "     pip install --user weasyprint markdown        (recommended — no LaTeX, no Chromium)"
  echo "     sudo apt-get install pandoc texlive-xetex     (cleanest output, but big install)"
  echo "     npm install -g md-to-pdf                      (needs non-root user with Chromium)"
  echo
  echo "   The concatenated markdown is at: $OUT_MD"
  exit 1
fi
