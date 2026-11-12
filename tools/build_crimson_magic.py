from PIL import Image
from pathlib import Path
import json
raw=Path('assets/crimson-magic'); out=Path('game/art/crimson-magic')
im=Image.open(raw/'spirit-flight-source.png').convert('RGBA')
px=im.load()
for y in range(im.height):
 for x in range(im.width):
  r,g,b,a=px[x,y]
  if r>140 and b>120 and g<110 and min(r,b)>g*1.5: px[x,y]=(0,0,0,0)
frames=[]
for y in range(3):
 for x in range(3):
  f=im.crop((round(x*im.width/3),round(y*im.height/3),round((x+1)*im.width/3),round((y+1)*im.height/3)))
  # Preserve shared source-cell anchors and aspect ratio, not per-frame bbox resizing.
  f=f.resize((96,64),Image.Resampling.NEAREST); frames.append(f)
atlas=Image.new('RGBA',(96*9,64))
for i,f in enumerate(frames):atlas.paste(f,(i*96,0))
atlas.save(out/'spirit-flight.png')
frames[0].save(out/'spirit-flight.webp',save_all=True,append_images=frames[1:],duration=62,loop=0,lossless=True)
(out/'manifest.json').write_text(json.dumps({'frames':9,'frame_size':[96,64],'fps':16,'anchor':'leading tip at approximately x=88,y=32','raw':'assets/crimson-magic/spirit-flight-source.png','generated_with':'built-in imagegen'},indent=2))
