/* Run this source through Figma use_figma with DATA injected from pitch-scenes.json. */
const created=[],mutated=[],slidesOut=[];
const slideIds=['2:12327','2:13206','2:13251','2:13298','2:13332','2:13364'];
const assetFrame=await figma.getNodeByIdAsync('5:1073');
const components={};
for(const c of assetFrame.children){
 if(c.type!=='COMPONENT')continue;
 components[c.name.split(' / ').at(-1)]=c;
}
const collections=await figma.variables.getLocalVariableCollectionsAsync();
const collection=collections.find(c=>c.name==='CasaQuest · Noite · Pitch');
const variables={};
if(collection)for(const id of collection.variableIds){const v=await figma.variables.getVariableByIdAsync(id);variables[v.name]=v;}
const originals=await Promise.all(slideIds.map(id=>figma.getNodeByIdAsync(id)));
const fonts=new Map();
for(const s of originals)for(const t of s.findAllWithCriteria({types:['TEXT']}))for(const seg of t.getStyledTextSegments(['fontName']))fonts.set(JSON.stringify(seg.fontName),seg.fontName);
await Promise.all([...fonts.values()].map(f=>figma.loadFontAsync(f)));
await Promise.all([{family:'Pixelify Sans',style:'Regular'},{family:'Pixelify Sans',style:'Bold'},{family:'Press Start 2P',style:'Regular'}].map(f=>figma.loadFontAsync(f)));
if(!figma.root.children.some(p=>p.name==='Pitch · antes do MVP')){
 const archive=figma.createPage();archive.name='Pitch · antes do MVP';created.push(archive.id);
 for(const s of originals){const copy=s.clone();archive.appendChild(copy);created.push(copy.id);}
}
function rgb(hex){return{r:parseInt(hex.slice(1,3),16)/255,g:parseInt(hex.slice(3,5),16)/255,b:parseInt(hex.slice(5,7),16)/255};}
function paint(key){let p={type:'SOLID',color:rgb(DATA.colors[key]||DATA.colors.ink)};return variables[key]?figma.variables.setBoundVariableForPaint(p,'color',variables[key]):p;}
function draw(spec,parent,existing){
 if(spec.hidden)return;
 let n;
 if(spec.type==='text'){
  n=figma.createText();created.push(n.id);parent.appendChild(n);
  n.fontName={family:spec.display?'Press Start 2P':'Pixelify Sans',style:spec.bold?'Bold':'Regular'};
  n.fontSize=spec.size;n.lineHeight={unit:'PERCENT',value:spec.display?150:112};n.characters=String(spec.text);n.fills=[paint(spec.color||'ink')];
  if(spec.w){n.textAutoResize='HEIGHT';n.resize(spec.w,Math.max(1,n.height));}else n.textAutoResize='WIDTH_AND_HEIGHT';
  if(spec.align)n.textAlignHorizontal=spec.align;
  n.name=String(spec.text).replace(/\n/g,' ').slice(0,80);
 }else if(spec.type==='asset'){
  n=components[spec.asset].createInstance();created.push(n.id);parent.appendChild(n);n.rescale(spec.w/n.width);n.name=spec.asset;
 }else{
  n=existing||figma.createAutoLayout();if(!existing){created.push(n.id);parent.appendChild(n);}
  n.name=spec.role||'Composição '+spec.dir;n.layoutMode=spec.dir==='row'?'HORIZONTAL':'VERTICAL';n.resize(spec.w||100,spec.h||100);
  n.primaryAxisSizingMode='FIXED';n.counterAxisSizingMode='FIXED';n.itemSpacing=spec.gap||0;n.counterAxisAlignItems=spec.align||'MIN';n.primaryAxisAlignItems=spec.justify||'MIN';
  const p=Array.isArray(spec.pad)?spec.pad:[spec.pad||0,spec.pad||0,spec.pad||0,spec.pad||0];[n.paddingTop,n.paddingRight,n.paddingBottom,n.paddingLeft]=p;
  n.fills=spec.bg?[paint(spec.bg)]:[];n.clipsContent=!!spec.slide;
  n.effects=spec.border?[{x:0,y:-4},{x:0,y:4},{x:-4,y:0},{x:4,y:0}].map(offset=>({type:'DROP_SHADOW',visible:true,blendMode:'NORMAL',color:{...rgb(DATA.colors.outline),a:1},offset,radius:0,spread:0,showShadowBehindNode:false})):[];
  for(const child of spec.children)draw(child,n);
  if(spec.demoStep)for(const t of n.findAllWithCriteria({types:['TEXT']}))t.hyperlink={type:'URL',value:'http://127.0.0.1:4173/prototipo/index.html#app'};
 }
 return n;
}
for(let i=0;i<DATA.slides.length;i++){
 const s=DATA.slides[i],target=originals[i];for(const c of [...target.children])c.remove();
 draw(s.node,target.parent,target);target.name=String(i+1).padStart(2,'0')+' · CasaQuest — '+s.label;mutated.push(target.id);
 const texts=target.findAllWithCriteria({types:['TEXT']});const bounds=target.absoluteBoundingBox;
 slidesOut.push({id:target.id,name:target.name,textCount:texts.length,fonts:[...new Set(texts.map(t=>t.fontName.family))],overflow:texts.filter(t=>{const b=t.absoluteBoundingBox;return b.x<bounds.x-1||b.y<bounds.y-1||b.x+b.width>bounds.x+bounds.width+1||b.y+b.height>bounds.y+bounds.height+1;}).map(t=>t.id)});
}
return{createdNodeIds:created,mutatedNodeIds:mutated,slides:slidesOut};
