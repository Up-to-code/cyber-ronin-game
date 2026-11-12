from pathlib import Path
from PIL import Image,ImageOps
import json,statistics
root=Path(__file__).resolve().parents[1]
im=Image.open(root/'assets/pixel/ashen-enemies/raw.png').convert('RGBA')
im.putalpha(im.getchannel('A').point(lambda a:255 if a>=210 else 0))
cw,ch=im.width//8,im.height//2
out=Image.new('RGBA',(1024,256))
for row in range(2):
 cells=[im.crop((x*cw,row*ch,(x+1)*cw,(row+1)*ch)) for x in range(8)]
 scale=58/statistics.median(c.getbbox()[3]-c.getbbox()[1] for c in cells[:4])
 for x,c in enumerate(cells):
  bottom=c.getbbox()[3];c=ImageOps.mirror(c).resize((round(cw*scale),round(ch*scale)),Image.Resampling.NEAREST)
  frame=Image.new('RGBA',(128,128));frame.alpha_composite(c,(round(64-cw*.37*scale),round(112-bottom*scale)));out.alpha_composite(frame,(x*128,row*128))
a=out.getchannel('A');out=out.convert('RGB').quantize(colors=48,dither=Image.Dither.NONE).convert('RGBA');out.putalpha(a);out.save(root/'game/art/pixel/ashen-enemies.png')
for row,kind in enumerate(['lancer','sentinel']):
 p=json.loads((root/'game/animation/profiles/guard_pixel.json').read_text());p['id']=kind+'_pixel';p['atlas']='res://art/pixel/ashen-enemies.png';p['display_name']=kind.title()
 mapping={'idle':[0],'walk':[1,2,3,2],'float':[0],'windup':[4],'attack':[4,5,5,0],'hurt':[6],'death':[7],'air':[2]}
 for name,cols in mapping.items():
  p['clips'][name]={'frames':[{'rect':[c*128,row*128,128,128],'duration_ms':80} for c in cols],'loop':name in ['walk','float','idle']}
  if name=='walk':p['clips'][name]['stride_world']=76
 for spec in p['attacks'].values():spec.update(duration=.58 if row else .40,damage=25 if row else 18,reach=105 if row else 155)
 (root/f'game/animation/profiles/{kind}_pixel.json').write_text(json.dumps(p,indent=2)+'\n')
