"""Deterministic magenta extraction and feet-aligned engine atlas export."""
from PIL import Image
from pathlib import Path
import json
source=Path('assets/levels/crimson-levels/props.png')
out=Path('game/art/crimson-levels'); out.mkdir(parents=True,exist_ok=True)
im=Image.open(source).convert('RGBA')
for y in range(im.height):
 for x in range(im.width):
  r,g,b,a=im.getpixel((x,y))
  if r>130 and b>130 and g<120 and min(r,b)>g*1.5: im.putpixel((x,y),(0,0,0,0))
frames=[]
for row in range(2):
 for col in range(3):
  f=im.crop((round(col*im.width/3),round(row*im.height/2),round((col+1)*im.width/3),round((row+1)*im.height/2)))
  f=f.crop(f.getbbox()); f.thumbnail((56,58),Image.Resampling.NEAREST)
  cell=Image.new('RGBA',(64,64));cell.paste(f,((64-f.width)//2,62-f.height));frames.append(cell)
atlas=Image.new('RGBA',(384,64))
for i,f in enumerate(frames): atlas.paste(f,(i*64,0))
atlas.save(out/'scenery.png')
(out/'manifest.json').write_text(json.dumps({'frame_size':[64,64],'feet':[32,62],'variants':['barrels','guardian','lantern','rubble','altar','bamboo_urn'],'role':'decorative; no collision','source':str(source)},indent=2))
print('Six transparent props exported at 64x64, feet y=62')
