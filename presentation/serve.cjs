const http=require('node:http');
const fs=require('node:fs');
const path=require('node:path');
const root=path.resolve(__dirname,'..');
const types={'.html':'text/html; charset=utf-8','.js':'text/javascript; charset=utf-8','.css':'text/css; charset=utf-8','.svg':'image/svg+xml','.png':'image/png','.jpg':'image/jpeg','.ttf':'font/ttf','.json':'application/json; charset=utf-8'};
function start(port=4173){
 const server=http.createServer((req,res)=>{
  let url;try{url=decodeURIComponent(new URL(req.url,'http://127.0.0.1').pathname);}catch{res.writeHead(400).end();return;}
  const target=path.resolve(root,'.'+(url==='/'?'/prototipo/index.html':url));
  if(!target.startsWith(root+path.sep)||!types[path.extname(target)]||url.split('/').some(p=>p.startsWith('.'))){res.writeHead(403).end();return;}
  fs.readFile(target,(err,data)=>{if(err){res.writeHead(404).end('Arquivo não encontrado');return;}res.writeHead(200,{'Content-Type':types[path.extname(target)],'Cache-Control':'no-store'});res.end(data);});
 });
 return new Promise((resolve,reject)=>{server.once('error',reject);server.listen(port,'127.0.0.1',()=>resolve(server));});
}
module.exports=start;
if(require.main===module)start(Number(process.env.CQ_PORT)||4173).then(s=>console.log('Casa Quest: http://127.0.0.1:'+s.address().port+'/prototipo/index.html')).catch(e=>{console.error(e.message);process.exitCode=1;});
