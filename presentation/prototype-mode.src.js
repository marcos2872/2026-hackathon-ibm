/* Keep the existing prototype and its state while presenting the pitch. */
(() => {
  if (window.__cqModesInstalled) return;
  window.__cqModesInstalled = true;
  const deckSource = '__CQ_DECK_BASE64__';
  const decode = value => new TextDecoder().decode(Uint8Array.from(atob(value),c=>c.charCodeAt(0)));
  const style = document.createElement('style');
  style.textContent = `
    :root{--cq-mode-height:64px}
    .cq-modebar{box-sizing:border-box;height:var(--cq-mode-height);display:flex;align-items:center;gap:16px;padding:8px 20px;background:#14152a;color:#f4f4f4;border-bottom:4px solid #0e0f1a;font-family:'Pixelify Sans',sans-serif;position:sticky;top:0;z-index:100}
    .cq-modebrand{font-family:'Press Start 2P',monospace;font-size:12px;color:#ffcd75;margin-right:auto}
    .cq-modebar button,.cq-modebar select{font:inherit;font-size:17px;border:0;border-radius:0;padding:8px 12px;min-height:40px;background:#3a3f63;color:#f4f4f4;cursor:pointer}
    .cq-modebar button[aria-pressed=true]{background:#ffcd75;color:#1a1c2c}
    .cq-modebar :focus-visible{outline:3px solid #73eff7;outline-offset:2px}
    .cq-mode-tabs,.cq-mode-demo-tools{display:flex;align-items:center;gap:8px}
    .cq-mode-demo-tools select{width:170px;margin:0;box-shadow:none}
    .cq-pitch-host{display:none;width:100%;height:calc(100dvh - var(--cq-mode-height));border:0;background:#20223a}
    body.cq-presentation-mode #root{display:none}
    body.cq-presentation-mode .cq-pitch-host{display:block}
    body.cq-presentation-mode .cq-mode-demo-tools{display:none}
    body.cq-has-modes #root{min-height:calc(100dvh - var(--cq-mode-height))}
    body.cq-has-modes.only-app .phone{height:calc(100dvh - var(--cq-mode-height) - 40px)}
    @media(max-width:1100px){.cq-modebrand{font-size:10px}.cq-mode-demo-tools #cq-reset-demo{display:none}}
    @media(max-width:760px){:root{--cq-mode-height:112px}.cq-modebar{height:112px;flex-wrap:wrap;justify-content:center;gap:8px;padding:8px 12px}.cq-modebrand{display:none}.cq-mode-tabs button{font-size:15px;padding:8px}.cq-mode-demo-tools{width:100%;justify-content:center}.cq-mode-demo-tools select{width:100%}.cq-mode-demo-tools #cq-reset-demo{display:none}.cq-modebar select{font-size:15px}body.cq-presentation-mode .cq-modebar{height:64px}body.cq-presentation-mode{--cq-mode-height:64px}body.cq-has-modes.only-app .phone{height:calc(100dvh - var(--cq-mode-height));min-height:0}}
  `;
  document.head.appendChild(style);
  const bar = document.createElement('nav');
  bar.className = 'cq-modebar';bar.setAttribute('aria-label','Modos do protótipo');
  bar.innerHTML = `<span class="cq-modebrand">CASA QUEST</span><div class="cq-mode-tabs"><button id="cq-demo-mode" aria-pressed="true">Modo demo</button><button id="cq-presentation-mode" aria-pressed="false">Modo apresentação</button></div><div class="cq-mode-demo-tools"><select id="cq-demo-step" aria-label="Etapa da demonstração"><option value="mission">Missões de Bruno</option><option value="register">Registrar com fotos</option><option value="approval">Ana aprova</option><option value="evolution">Evolução e equipes</option><option value="treasure">Tesouro</option><option value="screen">Tempo de tela</option><option value="goal">Meta coletiva</option></select><button id="cq-reset-demo">Restaurar exemplo</button></div>`;
  document.body.prepend(bar);
  const frame = document.createElement('iframe');frame.className='cq-pitch-host';frame.title='Apresentação Casa Quest';
  frame.setAttribute('allow','fullscreen');document.body.appendChild(frame);
  document.body.classList.add('cq-has-modes');
  let loaded=false;
  function setMode(mode,step){
    const presentation=mode==='presentation';
    if(presentation&&!loaded){frame.srcdoc=decode(deckSource);loaded=true;}
    document.body.classList.toggle('cq-presentation-mode',presentation);
    document.getElementById('cq-demo-mode').setAttribute('aria-pressed',!presentation);
    document.getElementById('cq-presentation-mode').setAttribute('aria-pressed',presentation);
    frame.hidden=!presentation;
    if(!presentation&&step){
      if(location.hash!=='#app'){history.replaceState(null,'',location.pathname+location.search+'#app');}
      document.getElementById('cq-demo-step').value=step;
      CasaQuestPitchBridge.navigate(step);
    }
    if(presentation)frame.focus();
  }
  document.getElementById('cq-demo-mode').onclick=()=>setMode('demo');
  document.getElementById('cq-presentation-mode').onclick=()=>setMode('presentation');
  document.getElementById('cq-demo-step').onchange=e=>setMode('demo',e.target.value);
  document.getElementById('cq-reset-demo').onclick=()=>CasaQuestPitchBridge.reset();
  addEventListener('message',event=>{
    if(event.source!==frame.contentWindow||event.data?.channel!=='casaquest-pitch')return;
    if(event.data.type==='hello')frame.contentWindow.postMessage({channel:'casaquest-pitch',type:'host-ready'},'*');
    if(event.data.type==='open-demo')setMode('demo',event.data.step||'mission');
  });
  window.CasaQuestModes={setMode};
  if(location.hash==='#apresentacao')setMode('presentation');else frame.hidden=true;
})();
