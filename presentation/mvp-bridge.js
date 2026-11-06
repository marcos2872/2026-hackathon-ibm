/* Presentation navigation delegates to the real prototype's actions. */
(() => {
  const CHANNEL = 'casaquest-pitch';
  const member = () => S.membros.find(m => m.nome === 'Bruno') || S.membros.find(m => !m.admin) || S.membros[0];
  function snapshot() {
    const m = member();
    const task = S.atribuicoes.find(a => a.membroId === m.id && a.atividadeId === 'banheiro' && a.data === hoje());
    return {name:m.nome,xp:m.xp,season:m.pts,credits:m.cred,minutes:m.minutos,status:task?.status || 'a_fazer'};
  }
  function navigate(step) {
    const allowed = ['mission','register','approval','evolution','treasure','screen','goal'];
    if (!allowed.includes(step)) return;
    const m = member();
    const evaluator = S.membros.find(a => a.admin && a.id !== m.id) || S.membros.find(a => a.id !== m.id);
    ui.sheet = null; ui.draft = null; ui.toast = null; ui.onb = null;
    setWho(step === 'approval' && evaluator ? evaluator.id : m.id);
    ui.tab = {mission:'hoje',register:'hoje',approval:'admin',evolution:'evolucao',treasure:'premios',screen:'tela',goal:'meta'}[step];
    render();
    const task = S.atribuicoes.find(a => a.membroId === m.id && a.atividadeId === 'banheiro' && a.data === hoje());
    if (step === 'register' && task && !['aprovado','pendente','contestado'].includes(task.status)) ACT.registrar({id:task.id});
    if (step === 'approval' && task?.registroId) {
      const button = document.querySelector('[data-act="aprovar"][data-id="'+task.registroId+'"]');
      if (button) button.closest('article')?.scrollIntoView({block:'start'});
    }
    emit();
  }
  function emit() {
    if (window.parent !== window) window.parent.postMessage({channel:CHANNEL,type:'mvp-state',state:snapshot()},'*');
    window.dispatchEvent(new CustomEvent('cq-mvp-state',{detail:snapshot()}));
  }
  window.CasaQuestPitchBridge = {navigate,snapshot,reset(){ACT.reset();emit();}};
  if(window.__CQ_PITCH_MODE__) ACT['sair-app']=()=>{ui.sheet=null;render();};
  addEventListener('message',event => {
    if (event.source !== parent || event.data?.channel !== CHANNEL) return;
    if (event.data.type === 'navigate-mvp') navigate(event.data.step);
    if (event.data.type === 'reset-mvp') { ACT.reset(); emit(); }
  });
  document.addEventListener('click',()=>queueMicrotask(emit));
  document.addEventListener('keydown',event=>{
    if(event.key === 'Escape' && !ui.sheet && parent !== window) parent.postMessage({channel:CHANNEL,type:'close-demo'},'*');
  },true);
  emit();
})();
