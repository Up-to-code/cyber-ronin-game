from PIL import Image
from pathlib import Path
import shutil,json
B=Path('/Users/ahmedmansour/.codex/generated_images/01a1c895-624e-7573-b11a-af481a70fdba');O=Path('game/art/concept-pass');O.mkdir(exist_ok=True);S=Path('assets/concept-art/concept-pass');S.mkdir(exist_ok=True)
ids={'terrain':'a5ee694f-e748-4715-a610-8c93f5106760','skyline':'9eb181a7-ca1c-4c31-a98c-072f6708e490','gate':'167a815f-8f09-4f31-851a-3d11e8f07ab9','wraith':'485bc28b-3bdc-4768-9c31-bd9f19230126','walk':'d13df6a7-edcd-4694-894b-996aba3bf746'}
def raw(name):
 p=B/('exec-'+ids[name]+'.png');shutil.copyfile(p,S/(name+'.png'));im=Image.open(p).convert('RGBA');im.putalpha(im.getchannel('A').point(lambda a:255 if a>210 else 0));return im
im=raw('terrain')
for i,name in enumerate(['stone','rock','stairs','bridge']):
 x=i%2;y=i//2;c=im.crop((x*im.width//2,y*im.height//2,(x+1)*im.width//2,(y+1)*im.height//2));c=c.crop(c.getbbox());c.resize((128,round(c.height*128/c.width)),Image.Resampling.NEAREST).save(O/(name+'.png'))
im=raw('skyline');im.resize((768,256),Image.Resampling.NEAREST).save(O/'skyline.png')
im=raw('gate');out=Image.new('RGBA',(1024,176))
for i in range(4):
 x=i%2;y=i//2;c=im.crop((x*im.width//2,y*im.height//2,(x+1)*im.width//2,(y+1)*im.height//2));px=c.load()
 for yy in range(c.height):
  for xx in range(c.width):
   r,g,b,a=px[xx,yy]
   if min(r,g,b)>210:px[xx,yy]=(0,0,0,0)
 c=c.resize((256,176),Image.Resampling.NEAREST);out.alpha_composite(c,(256*i,0))
out.save(O/'gate.png')
for name,cols,rows,size in [('walk',4,2,80),('wraith',3,2,84)]:
 im=raw(name);out=Image.new('RGBA',(128*cols*rows,128))
 for i in range(cols*rows):
  x=i%cols;y=i//cols;c=im.crop((x*im.width//cols,y*im.height//rows,(x+1)*im.width//cols,(y+1)*im.height//rows));c=c.resize((size,size),Image.Resampling.NEAREST)
  if name=='wraith':c=c.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
  b=c.getbbox();out.alpha_composite(c,(i*128+(128-size)//2,112-b[3]))
 out.save(O/(name+'.png'))
p=Path('game/animation/profiles/ronin_cel.json');d=json.loads(p.read_text());d['clips']['walk']['atlas']='res://art/concept-pass/walk.png';d['clips']['walk']['frames']=[{'rect':[i*128,0,128,128],'duration_ms':90,**({'events':['foot_contact']} if i in [0,4] else {})} for i in range(8)];p.write_text(json.dumps(d,indent=2)+'\n')
