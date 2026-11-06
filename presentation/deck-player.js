/* A deck embedded in the prototype switches its host to the real app. */
(() => {
  const $ = id=>document.getElementById(id),channel='casaquest-pitch';
  let host=false,loaded=false,activeStep='mission',returnFocus=null;
  const steps={
    mission:['Missões de Bruno','Mostre o peso das tarefas, o XP, os créditos e a rotina da família.'],
    register:['Registrar com fotos','Bruno abre Limpar o banheiro. Escolha as fotos do antes e do depois e envie o registro.'],
    approval:['Ana aprova','No perfil da Ana, localize Limpar o banheiro, de Bruno. Mantenha 3 estrelas e clique em Aprovar.'],
    evolution:['Evolução e equipes','Volte ao Bruno. Mostre a evolução pessoal e a disputa entre equipes, sem ranking individual.'],
    treasure:['Resgatar uma recompensa','No Tesouro do Bruno, escolha 30 min de computador e confirme o resgate por 15 créditos.'],
    screen:['Tempo de tela','Mostre os 30 minutos liberados e o simulador de computador. O bloqueio real está fora deste MVP.'],
    goal:['Meta coletiva','Encerre mostrando como o mesmo esforço também aproxima a família da viagem.']
  };
  const decode=value=>new TextDecoder().decode(Uint8Array.from(atob(value),c=>c.charCodeAt(0)));
  function send(step){$('mvpFrame').contentWindow.postMessage({channel,type:'navigate-mvp',step},'*');}
  function select(step){activeStep=steps[step]?step:'mission';$('liveStepTitle').textContent=steps[activeStep][0];$('liveStepText').textContent=steps[activeStep][1];document.querySelectorAll('[data-live-step]').forEach(b=>b.setAttribute('aria-pressed',b.dataset.liveStep===activeStep));if(loaded)send(activeStep);}
  function open(step){
    if(host){parent.postMessage({channel,type:'open-demo',step},'*');return;}
    returnFocus=document.activeElement;$('liveDemo').hidden=false;document.body.classList.add('mvp-open');
    select(step);
    if(!loaded){$('mvpFrame').srcdoc=decode($('mvpSource').textContent.trim());loaded=true;}
    $('returnPitch').focus();
  }
  function close(){$('liveDemo').hidden=true;document.body.classList.remove('mvp-open');returnFocus?.focus();}
  document.querySelectorAll('[data-demo-step]').forEach(b=>b.addEventListener('click',()=>open(b.dataset.demoStep)));
  document.querySelectorAll('[data-live-step]').forEach(b=>b.addEventListener('click',()=>select(b.dataset.liveStep)));
  $('returnPitch').onclick=close;
  $('resetLiveDemo').onclick=()=>{$('mvpFrame').contentWindow.postMessage({channel,type:'reset-mvp'},'*');select('mission');};
  $('mvpFrame').onload=()=>{if(loaded)send(activeStep);};
  addEventListener('message',event=>{
    if(event.data?.channel!==channel)return;
    if(event.source===parent&&event.data.type==='host-ready'){host=true;return;}
    if(event.source!==$('mvpFrame').contentWindow)return;
    if(event.data.type==='close-demo')close();
    if(event.data.type==='mvp-state'){
      const s=event.data.state;$('liveState').textContent=s.name+' · XP '+s.xp+' · temporada '+s.season+' · créditos '+s.credits+' · tela '+s.minutes+' min';
    }
  });
  document.addEventListener('keydown',event=>{if(event.key==='Escape'&&!$('liveDemo').hidden){event.preventDefault();close();}});
  if(parent!==window)parent.postMessage({channel,type:'hello'},'*');
})();
