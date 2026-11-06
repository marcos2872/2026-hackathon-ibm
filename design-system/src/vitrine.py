"""Gera design-system/vitrine.html: o design system inteiro numa página só.

Uso: python design-system/src/vitrine.py   (rode build.py antes se mudou algo)
A página carrega React 18 e as fontes por CDN; todo o resto vai embutido.
"""

import base64
import html
import json
import re
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
P = RAIZ / "project"
C = P / "components"

tokens = json.loads((P / "tokens.json").read_text(encoding="utf-8"))
temas = [t["id"] for t in tokens["color"]["themes"]]


# ----------------------------------------------------------- tokens → CSS
def valor(v, tema):
    return v if isinstance(v, str) else v.get(tema, v[temas[0]])


def bloco(tema):
    linhas = [f"--{c['name']}: {valor(c['value'], tema)};" for c in tokens["color"]["tokens"]]
    linhas += [f"--{s['name']}: {valor(s['value'], tema)};" for s in tokens["shadow"]["tokens"]]
    return " ".join(linhas)


fixos = [f"--{s['name']}: {s['value']};" for fam in ("spacing", "radius") for s in tokens[fam]["tokens"]]
fixos += [f"--font-{k}: {v};" for k, v in tokens["type"]["families"].items()]
css_tokens = f":root, [data-theme='{temas[0]}'] {{ {bloco(temas[0])} {' '.join(fixos)} }}\n"
css_tokens += "".join(f"[data-theme='{t}'] {{ {bloco(t)} }}\n" for t in temas[1:])

bundle_css = (C / "bundle.css").read_text(encoding="utf-8")
fontes = re.search(r'@import url\("([^"]+)"\);', bundle_css).group(1)
bundle_css = re.sub(r'@import url\("[^"]+"\);\n', "", bundle_css)
bundle_js = (C / "bundle.js").read_text(encoding="utf-8")


# ---------------------------------------------------------- markdown mínimo
def inline(t):
    t = html.escape(t)
    t = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", t)
    t = re.sub(r"`(.+?)`", r"<code>\1</code>", t)
    return t


def md(texto):
    out, lista = [], False
    for linha in texto.splitlines():
        if linha.startswith("# "):
            continue
        if re.match(r"^(- |\d+\. )", linha):
            if not lista:
                out.append("<ul>")
                lista = True
            out.append("<li>" + inline(re.sub(r"^(- |\d+\. )", "", linha)) + "</li>")
            continue
        if lista:
            out.append("</ul>")
            lista = False
        if linha.startswith("## "):
            out.append(f"<h3>{inline(linha[3:])}</h3>")
        elif linha.strip():
            out.append(f"<p>{inline(linha)}</p>")
    if lista:
        out.append("</ul>")
    return "\n".join(out)


# ---------------------------------------------------------------- seções
def secao(id_, titulo, corpo, sub=""):
    sub = f"<p class='v-sub'>{sub}</p>" if sub else ""
    return f"<section id='{id_}' class='v-sec'><h2>{titulo}</h2>{sub}{corpo}</section>"


nav = []

# Capa
capa_html = (C / "Cover" / "preview.html").read_text(encoding="utf-8")
capa_css = re.search(r"<style>(.*?)</style>", capa_html, re.S).group(1)
capa_css = re.sub(r"html, body \{[^}]*\}\s*body \{[^}]*\}", "", capa_css)
capa_body = re.search(r'<div class="cover">.*</div>\s*</div>', capa_html, re.S).group(0)
partes = [f"<div class='v-capa'>{capa_body}</div>"]

# Manual da marca
readme = (P / "README.md").read_text(encoding="utf-8")
partes.append(secao("manual", "Manual da marca", f"<div class='v-prose'>{md(readme)}</div>"))
nav.append(("manual", "Manual"))

# Cores
cards = []
for c in tokens["color"]["tokens"]:
    vals = c["value"] if isinstance(c["value"], dict) else {temas[0]: c["value"]}
    hexes = " · ".join(f"<span>{t}: <code>{v}</code></span>" for t, v in vals.items())
    cards.append(f"<div class='v-cor'><div class='v-amostra' style='background:var(--{c['name']})'></div>"
                 f"<div class='v-cor-info'><b>{c['name']}</b><div class='v-hex'>{hexes}</div>"
                 f"<p>{html.escape(c['usage'])}</p></div></div>")
partes.append(secao("cores", "Cores", f"<div class='v-cores'>{''.join(cards)}</div>",
                    "A amostra segue o tema escolhido no topo. Os valores dos dois temas estão listados em cada cor."))
nav.append(("cores", "Cores"))

# Tipografia
linhas = []
for g in tokens["type"]["groups"]:
    linhas.append(f"<h3>{g['name']} <small>{html.escape(tokens['type']['families'][g['family']])}</small></h3>")
    for s in g["styles"]:
        fam = f"var(--font-{s.get('family', g['family'])})"
        estilo = f"font-family:{fam};font-size:{s['fontSize']};line-height:{s['lineHeight']};font-weight:{s['fontWeight']}"
        linhas.append(f"<div class='v-tipo'><div class='v-tipo-meta'><b>{s['name']}</b><br>{s['fontSize']} / {s['lineHeight']} · {s['fontWeight']}"
                      f"<p>{html.escape(s['usage'])}</p></div><div style='{estilo}'>{html.escape(s['sample'])}</div></div>")
partes.append(secao("tipografia", "Tipografia", "".join(linhas)))
nav.append(("tipografia", "Tipografia"))

# Espaço, cantos, sombras
esp = "".join(f"<div class='v-esp'><code>{s['name']}</code><span>{s['value']}</span><i style='width:{s['value']}'></i><p>{html.escape(s['usage'])}</p></div>"
              for s in tokens["spacing"]["tokens"])
som = "".join(f"<div class='v-som'><div class='v-som-box' style='box-shadow:var(--{s['name']})'></div><div><b>{s['name']}</b><p>{html.escape(s['usage'])}</p></div></div>"
              for s in tokens["shadow"]["tokens"])
rad = "".join(f"<li><code>{s['name']}</code> {s['value']}: {html.escape(s['usage'])}</li>" for s in tokens["radius"]["tokens"])
partes.append(secao("espaco", "Espaço, cantos e sombras",
                    f"<h3>Espaço</h3>{esp}<h3>Cantos</h3><p>{html.escape(tokens['radius']['note'])}</p><ul>{rad}</ul>"
                    f"<div class='v-row'><div class='cq-px v-moldura'>Moldura pixel (contorno em cruz de 4 px)</div></div>"
                    f"<h3>Sombras</h3><div class='v-row'>{som}</div>"))
nav.append(("espaco", "Espaço"))

# Ícones
ic_nomes = list(json.loads(re.search(r"var SPRITES = (\{.*?\});", bundle_js, re.S).group(1)).keys())
ic_desc = dict(re.findall(r"- `(\w+)\.svg` — (.+)", (P / "assets" / "Icones" / "README.md").read_text(encoding="utf-8")))
ic = "".join(f"<figure class='v-icone'><div class='js-icon' data-name='{n}'></div><figcaption><b>{n}</b><br>{html.escape(ic_desc.get(n, ''))}</figcaption></figure>"
             for n in ic_nomes)
partes.append(secao("icones", "Ícones", f"<div class='v-icones'>{ic}</div>",
                    "Pixel art 12×12, mostrados a 48 px (4×). Em código: <code>&lt;CasaQuest.Icon name=\"moeda\" size={24} /&gt;</code>."))
nav.append(("icones", "Ícones"))

# Logos
logos = []
for f in ("casa-quest-logo-horizontal", "casa-quest-logo-empilhado", "casa-quest-brasao", "casa-quest-app-icon", "casa-quest-favicon"):
    b64 = base64.b64encode((P / "assets" / "Logos" / f"{f}.svg").read_bytes()).decode()
    escala = {"casa-quest-favicon": 6}.get(f, 4)
    logos.append(f"<figure class='v-logo'><img src='data:image/svg+xml;base64,{b64}' alt='{f}' style='zoom:{escala}'><figcaption>{f}.svg</figcaption></figure>")
partes.append(secao("logos", "Logos", f"<div class='v-logos'>{''.join(logos)}</div>",
                    "Ampliar só em escala inteira, sem recolorir. O brasão é a fonte da paleta do sistema."))
nav.append(("logos", "Logos"))

# Componentes
ordem = json.loads(re.search(r"/\* @ds-bundle: (\{.*?\}) \*/", bundle_js).group(1))["components"]
comps = []
for item in ordem:
    nome = item["name"]
    prev = (C / nome / "preview.html").read_text(encoding="utf-8")
    grupo = re.search(r'group="([^"]+)"', prev).group(1)
    corpo = re.search(r"render\((.*)\);\n</script>", prev, re.S).group(1)
    guia = md((C / nome / "README.md").read_text(encoding="utf-8"))
    comps.append(f"<article class='v-comp' id='c-{nome}'><header><span class='v-grupo'>{grupo}</span><h3>{nome}</h3></header>"
                 f"<div class='v-comp-grid'><div class='v-stage' id='r-{nome}'></div><div class='v-prose v-guia'>{guia}</div></div>"
                 f"<script>window.__r.push(['{nome}', function () {{ return {corpo}; }}]);</script></article>")
partes.append(secao("componentes", "Componentes", "".join(comps), "Componentes vivos: são os mesmos de <code>components/bundle.js</code>. Clique nos botões e na tela de missões."))
nav.append(("componentes", "Componentes"))

links = "".join(f"<a href='#{i}'>{t}</a>" for i, t in nav)
links_comp = "".join(f"<a class='v-sub-link' href='#c-{c['name']}'>{c['name']}</a>" for c in ordem)

VITRINE_CSS = """
html { scroll-behavior: smooth; }
body { margin: 0; }
.v-top { position: sticky; top: 0; z-index: 10; display: flex; align-items: center; gap: var(--space-4); padding: var(--space-3) var(--space-5); background: var(--surface-100); border-bottom: 4px solid var(--outline); }
.v-top b { font-family: var(--font-display); font-size: 12px; }
.v-top .v-sp { flex: 1; }
.v-layout { display: grid; grid-template-columns: 200px 1fr; }
.v-nav { position: sticky; top: 68px; align-self: start; height: calc(100vh - 68px); overflow: auto; padding: var(--space-5) var(--space-4); border-right: 4px solid var(--outline); background: var(--surface-100); box-sizing: border-box; }
.v-nav a { display: block; padding: var(--space-1) 0; color: var(--ink); text-decoration: none; font-family: var(--font-display); font-size: 10px; line-height: 20px; }
.v-nav a:hover { color: var(--gold-ink); }
.v-nav a.v-sub-link { font-family: var(--font-text); font-size: 14px; padding-left: var(--space-3); color: var(--ink-muted); }
.v-main { min-width: 0; padding-bottom: 96px; }
.v-capa { max-width: 960px; margin: var(--space-6) auto 0; box-shadow: 0 0 0 4px var(--outline); }
.v-sec { max-width: 1080px; margin: 0 auto; padding: var(--space-6) var(--space-5) 0; }
.v-sec > h2 { font-family: var(--font-display); font-weight: 400; font-size: 16px; line-height: 24px; color: var(--gold-ink); margin: var(--space-6) 0 var(--space-2); text-transform: uppercase; }
.v-sec h3 { font-family: var(--font-display); font-weight: 400; font-size: 12px; line-height: 16px; margin: var(--space-5) 0 var(--space-3); }
.v-sec h3 small { font-family: var(--font-text); font-size: 13px; color: var(--ink-muted); }
.v-sub { color: var(--ink-muted); margin: 0 0 var(--space-4); }
.v-prose { max-width: 760px; }
.v-prose p, .v-prose li { margin: 0 0 var(--space-2); }
.v-prose ul { padding-left: var(--space-5); margin: 0 0 var(--space-3); }
code { font-family: ui-monospace, monospace; font-size: 13px; padding: 0 4px; background: var(--surface-200); color: var(--ink); }
.v-cores { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: var(--space-4); }
.v-cor { display: flex; gap: var(--space-3); padding: var(--space-3); background: var(--surface-100); box-shadow: 0 0 0 4px var(--outline); }
.v-amostra { flex: none; width: 56px; height: 56px; box-shadow: 0 0 0 2px var(--outline); }
.v-cor-info { min-width: 0; font-size: 14px; line-height: 18px; }
.v-cor-info p { margin: var(--space-1) 0 0; color: var(--ink-muted); }
.v-hex { display: flex; flex-wrap: wrap; gap: 0 var(--space-2); font-size: 12px; color: var(--ink-muted); }
.v-tipo { display: grid; grid-template-columns: 240px 1fr; gap: var(--space-4); align-items: center; padding: var(--space-3) 0; border-bottom: 2px solid var(--surface-200); }
.v-tipo-meta { font-size: 13px; line-height: 18px; color: var(--ink-muted); }
.v-tipo-meta b { color: var(--ink); }
.v-tipo-meta p { margin: var(--space-1) 0 0; }
.v-esp { display: grid; grid-template-columns: 90px 50px 60px 1fr; gap: var(--space-3); align-items: center; font-size: 14px; padding: var(--space-1) 0; }
.v-esp i { display: block; height: 16px; background: var(--gold); box-shadow: 0 0 0 2px var(--outline); }
.v-esp p { margin: 0; color: var(--ink-muted); }
.v-row { display: flex; flex-wrap: wrap; gap: var(--space-5); align-items: flex-start; margin: var(--space-4) 0; }
.v-moldura { margin: 4px; padding: var(--space-4); background: var(--surface-100); }
.v-som { display: flex; gap: var(--space-3); align-items: center; max-width: 320px; font-size: 14px; }
.v-som p { margin: 0; color: var(--ink-muted); }
.v-som-box { flex: none; width: 56px; height: 56px; background: var(--gold); }
.v-icones { display: grid; grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); gap: var(--space-4); }
.v-icone { margin: 0; display: flex; flex-direction: column; align-items: center; gap: var(--space-2); padding: var(--space-4) var(--space-2); background: var(--surface-100); text-align: center; font-size: 13px; line-height: 16px; color: var(--ink-muted); }
.v-icone b { color: var(--ink); }
.v-logos { display: flex; flex-wrap: wrap; gap: var(--space-5); align-items: flex-end; }
.v-logo { margin: 0; padding: var(--space-4); background: #20223a; box-shadow: 0 0 0 4px var(--outline); }
.v-logo img { display: block; image-rendering: pixelated; }
.v-logo figcaption { margin-top: var(--space-2); font-size: 12px; color: #b4c0d4; }
.v-comp { margin: var(--space-5) 0; background: var(--surface-100); box-shadow: 0 0 0 4px var(--outline); scroll-margin-top: 80px; }
.v-comp header { display: flex; align-items: center; gap: var(--space-3); padding: var(--space-3) var(--space-4); background: var(--heraldic-blue); color: var(--on-blue); }
.v-comp header h3 { margin: 0; color: var(--on-blue); }
.v-grupo { font-family: var(--font-display); font-size: 8px; padding: 2px 6px; background: var(--gold); color: var(--on-gold); text-transform: uppercase; }
.v-comp-grid { display: grid; grid-template-columns: minmax(0, 1fr) 320px; }
.v-stage { min-width: 0; background: var(--surface-000); overflow: auto; }
.v-guia { padding: var(--space-4); font-size: 14px; line-height: 20px; border-left: 4px solid var(--outline); }
@media (max-width: 900px) { .v-layout { grid-template-columns: 1fr; } .v-nav { display: none; } .v-comp-grid { grid-template-columns: 1fr; } .v-guia { border-left: 0; border-top: 4px solid var(--outline); } .v-tipo { grid-template-columns: 1fr; } }
"""

pagina = f"""<!doctype html>
<html lang="pt-BR" data-theme="{temas[0]}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Casa Quest — design system</title>
<link rel="stylesheet" href="{fontes}">
<style>
{css_tokens}
{bundle_css}
{capa_css}
{VITRINE_CSS}
</style>
<script src="https://cdn.jsdelivr.net/npm/react@18.3.1/umd/react.production.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/react-dom@18.3.1/umd/react-dom.production.min.js"></script>
<script>
{bundle_js}
</script>
<script>window.__r = [];</script>
</head>
<body>
<header class="v-top">
  <b>CASA QUEST</b><span>design system</span><span class="v-sp"></span>
  <div id="tema"></div>
</header>
<div class="v-layout">
<nav class="v-nav">{links}{links_comp}</nav>
<main class="v-main">
{''.join(partes)}
</main>
</div>
<script>
  var C = window.CasaQuest, h = React.createElement;
  window.__r.forEach(function (r) {{ ReactDOM.createRoot(document.getElementById('r-' + r[0])).render(r[1]()); }});
  document.querySelectorAll('.js-icon').forEach(function (el) {{ ReactDOM.createRoot(el).render(h(C.Icon, {{ name: el.dataset.name, size: 48 }})); }});
  function Tema() {{
    var s = React.useState(localStorage.getItem('cq-tema') || '{temas[0]}'), t = s[0], set = s[1];
    React.useEffect(function () {{ document.documentElement.setAttribute('data-theme', t); localStorage.setItem('cq-tema', t); }}, [t]);
    return h('div', {{ style: {{ display: 'flex', gap: 8 }} }},
      {json.dumps([[t["id"], t["name"]] for t in tokens["color"]["themes"]])}.map(function (x) {{
        return h(C.Button, {{ key: x[0], size: 'sm', variant: t === x[0] ? 'primary' : 'secondary', onClick: function () {{ set(x[0]); }} }}, x[1]);
      }}));
  }}
  ReactDOM.createRoot(document.getElementById('tema')).render(h(Tema));
</script>
</body>
</html>
"""
assert "</script" not in bundle_js
saida = RAIZ / "vitrine.html"
saida.write_text(pagina, encoding="utf-8")
print(saida)
