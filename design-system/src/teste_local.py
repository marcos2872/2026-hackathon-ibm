"""Monta uma página local com todas as prévias (só para conferência; não é publicada)."""

import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
P = RAIZ / "project"
tema = sys.argv[1] if len(sys.argv) > 1 else "noite"
saida = Path(sys.argv[2]) if len(sys.argv) > 2 else RAIZ / "teste.html"

t = json.loads((P / "tokens.json").read_text(encoding="utf-8"))
css = [":root {"]
for c in t["color"]["tokens"]:
    v = c["value"] if isinstance(c["value"], str) else c["value"].get(tema, c["value"]["noite"])
    css.append(f"--{c['name']}: {v};")
for fam in ("spacing", "radius"):
    for s in t[fam]["tokens"]:
        css.append(f"--{s['name']}: {s['value']};")
for s in t["shadow"]["tokens"]:
    v = s["value"] if isinstance(s["value"], str) else s["value"][tema]
    css.append(f"--{s['name']}: {v};")
for k, v in t["type"]["families"].items():
    css.append(f"--font-{k}: {v};")
css.append("}")

bundle_css = (P / "components" / "bundle.css").read_text(encoding="utf-8")
imp = re.search(r'@import url\("([^"]+)"\);', bundle_css).group(1)
bundle_css = bundle_css.split("\n", 1)[1]
bundle_js = (P / "components" / "bundle.js").read_text(encoding="utf-8")

partes = []
for prev in sorted((P / "components").glob("*/preview.html")):
    nome = prev.parent.name
    corpo = re.search(r"render\((.*)\);\n</script>", prev.read_text(encoding="utf-8"), re.S).group(1)
    partes.append(f"<h2 style='font:12px monospace;color:#888;margin:24px 16px 0'>{nome}</h2><div id='r-{nome}'></div>"
                  f"<script>ReactDOM.createRoot(document.getElementById('r-{nome}')).render({corpo});</script>")

html = f"""<!doctype html><html data-theme="{tema}"><head><meta charset="utf-8">
<link rel="stylesheet" href="{imp}">
<style>{' '.join(css)}{bundle_css}</style>
<script src="https://cdn.jsdelivr.net/npm/react@18.3.1/umd/react.production.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/react-dom@18.3.1/umd/react-dom.production.min.js"></script>
<script>{bundle_js}</script>
<script>var C = window.CasaQuest, h = React.createElement;</script>
</head><body style="width:1000px">{''.join(partes)}</body></html>"""
saida.write_text(html, encoding="utf-8")
print(saida)
