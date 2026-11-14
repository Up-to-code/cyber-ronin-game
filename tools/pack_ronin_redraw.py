"""Alpha cleanup, uniform batch scaling and registration of model-drawn poses."""
from pathlib import Path
from PIL import Image,ImageDraw
import json
ROOT=Path(__file__).resolve().parents[1];SRC=ROOT/'assets/art/pixel/ronin-redraw';OUT=ROOT/'game/art/ronin-redraw'
def clean(im):
 im=im.convert('RGBA');w,h=im.size;pix=im.load()
 # Remove a white matte only when connected to the canvas exterior. Interior
 # ivory blade pixels remain intact. No pose artwork is drawn or transformed.
 seen=bytearray(w*h);q=[]
 def push(x,y):
  k=y*w+x
  if seen[k]:return
  seen[k]=1;r,g,b,a=pix[x,y]
  if a<180 or (min(r,g,b)>210 and max(r,g,b)-min(r,g,b)<28):q.append((x,y))
 for x in range(w):push(x,0);push(x,h-1)
 for y in range(h):push(0,y);push(w-1,y)
 for x,y in q:
  pix[x,y]=(0,0,0,0)
  for nx,ny in [(x-1,y),(x+1,y),(x,y-1),(x,y+1)]:
   if 0<=nx<w and 0<=ny<h:push(nx,ny)
 im.putalpha(im.getchannel('A').point(lambda x:255 if x>=180 else 0));return im
def components(im):
 w,h=im.size;mask=bytearray(1 if v else 0 for v in im.getchannel('A').tobytes());result=[]
 for start in range(w*h):
  if not mask[start]:continue
  mask[start]=0;q=[start];xs=[];ys=[]
  for k in q:
   x=k%w;y=k//w;xs.append(x);ys.append(y)
   for nx,ny in [(x-1,y),(x+1,y),(x,y-1),(x,y+1)]:
    if 0<=nx<w and 0<=ny<h:
     j=ny*w+nx
     if mask[j]:mask[j]=0;q.append(j)
  if len(q)>2500 and max(ys)-min(ys)>120 and max(xs)-min(xs)>40:
   result.append((min(xs),min(ys),max(xs)+1,max(ys)+1))
 return sorted(result,key=lambda b:(round(b[1]/(h/2)),b[0]))
def feet_x(im,box):
 a=im.getchannel('A');band=a.crop((box[0],box[3]-max(2,(box[3]-box[1])//40),box[2],box[3]));occupied=[]
 for x in range(band.width):
  if band.crop((x,0,x+1,band.height)).getbbox():occupied.append(x+box[0])
 groups=[]
 for x in occupied:
  if not groups or x>groups[-1][-1]+2:groups.append([x])
  else:groups[-1].append(x)
 return sum(groups[0])/len(groups[0])
def register(im,box,scale,palette=None):
 crop=im.crop(box);size=(round(crop.width*scale),round(crop.height*scale));crop=crop.resize(size,Image.Resampling.NEAREST)
 if palette:
  alpha=crop.getchannel('A');crop=crop.convert('RGB').quantize(palette=palette,dither=Image.Dither.NONE).convert('RGBA');crop.putalpha(alpha)
 x=round(58-(feet_x(im,box)-box[0])*scale);y=112-size[1]
 assert x>=0 and x+size[0]<=128 and y>=0,(x,y,size)
 out=Image.new('RGBA',(128,128));out.paste(crop,(x,y));return out
def build():
 sword=clean(Image.open(SRC/'sword-keys.raw.png'));sboxes=components(sword);assert len(sboxes)==4,sboxes
 idle=register(sword,sboxes[-1],58/(sboxes[-1][3]-sboxes[-1][1]));palette=idle.convert('RGB').quantize(colors=24,dither=Image.Dither.NONE)
 idle=register(sword,sboxes[-1],58/(sboxes[-1][3]-sboxes[-1][1]),palette);idle.save(OUT/'idle.png')
 profile=json.loads((ROOT/'game/animation/profiles/ronin_cel.json').read_text())
 for action in ['sword','kick']:
  key=clean(Image.open(SRC/(action+'-keys.raw.png')));kb=components(key);assert len(kb)==4,(action,kb)
  between=clean(Image.open(SRC/(action+'-between.raw.png')));bb=components(between)
  if action=='kick' and len(bb)==10:bb=[bb[i] for i in [0,1,2,3,4,6,7,9]]
  assert len(bb)==8,(action,bb)
  ks=58/(kb[-1][3]-kb[-1][1]);bs=58/(bb[-1][3]-bb[-1][1])
  keys=[register(key,b,ks,palette) for b in kb];tweens=[register(between,b,bs,palette) for b in bb]
  # Keep the shared-batch action anchors for this proof. The inter-between
  # candidate has inconsistent lighting, so it is not installed as final motion.
  frames=[idle.copy(),keys[0],keys[1],keys[2],keys[3],idle.copy()]
  atlas=Image.new('RGBA',(128*6,128))
  for i,f in enumerate(frames):atlas.paste(f,(i*128,0))
  atlas.save(OUT/(action+'.png'))
  name='sword1' if action=='sword' else 'kick'
  durations=[25,110,45,100,115,75]
  records=[]
  for i in range(6):
   records.append({'rect':[i*128,0,128,128],'duration_ms':durations[i]})
  records[2]['events']=['contact']
  if action=='kick':records[2]['sockets']={'foot':[91,79],'hand':[64,82],'weapon_tip':[79,98]}
  else:records[2]['sockets']={'hand':[76,84],'weapon_tip':[106,97],'foot':[85,111]}
  profile['clips'][name]={'atlas':'res://art/ronin-redraw/'+action+'.png','feet_origin':[64,112],'scale':2,'frames':records}
  profile['attacks'][name]['reach']=108 if action=='sword' else 78
  profile['attacks'][name].update(contact_frame=2,active_end_frame=2,duration=sum(durations)/1000,provisional_contact=True)
  atlas.resize((1536,256),Image.Resampling.NEAREST).save(SRC/(action+'-contact-sheet.png'))
  proof=ROOT/'docs/qa'/('redraw-'+action+'.gif')
  frames[0].save(proof,save_all=True,append_images=frames[1:],duration=durations,loop=0,disposal=2)
  print(action,'keys',len(kb),'selected between',len(bb),'duration',sum(durations),'blocking proof contactframe',2)
 profile['display_name']='Slim ronin pixel redraw — sword/kick proof'
 profile['status']='New idle/sword/kick redraw proof; movement/other actions are normalized source compatibility drawings.'
 (ROOT/'game/animation/profiles/ronin_cel.json').write_text(json.dumps(profile,indent=2)+'\n')
if __name__=='__main__':build()
