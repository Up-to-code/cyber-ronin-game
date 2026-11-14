"""Deterministically split generated sheets; retain originals and alpha."""
from PIL import Image
from pathlib import Path
src=Path('assets/archive/crimson-gold/source');out=Path('game/art/crimson-gold')
def split(source, boxes):
 im=Image.open(src/(source+'.png')).convert('RGBA')
 for name,box,size in boxes:
  part=im.crop(box);bounds=part.getchannel('A').point(lambda a:255 if a>24 else 0).getbbox()
  if bounds:part=part.crop(bounds)
  part.resize(size,Image.Resampling.NEAREST).save(out/(name+'.png'))
split('ui', [('button',(0,0,627,600),(192,60)),('button_selected',(627,0,1254,600),(192,60)),('panel',(0,600,627,1254),(192,180)),('button_pressed',(627,600,1254,1254),(192,60))])
split('machine',[('cockpit',(0,0,632,650),(128,160)),('sentinel',(632,0,1263,650),(144,160)),('piston',(0,650,632,1246),(96,112)),('glass',(632,650,1263,1246),(100,128))])
split('terrain',[('cap',(0,0,656,520),(256,96)),('fill',(656,0,1312,520),(192,160)),('support',(0,520,656,1199),(96,160)),('end',(656,520,1312,1199),(144,160))])
im=Image.open(src/'fx.png')
for i in range(4):
 x=(i%2)*631;y=(i//2)*623
 im.crop((x,y,x+631,y+623)).resize((128,128),Image.Resampling.NEAREST).save(out/('impact%d.png'%i))
