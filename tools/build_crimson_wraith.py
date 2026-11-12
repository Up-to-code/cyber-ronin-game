"""Deterministic chroma extraction and mask-anchor registration; no painted art."""
from PIL import Image
from pathlib import Path
import json, sys, shutil
source=Path(sys.argv[1]); raw=Path('assets/crimson-wraith'); out=Path('game/art/crimson-wraith')
shutil.copy2(source,raw/'hover-source.png')
im=Image.open(source).convert('RGBA'); frames=[]; measurements=[]
for row in range(3):
 for col in range(3):
  f=im.crop((round(col*im.width/3),round(row*im.height/3),round((col+1)*im.width/3),round((row+1)*im.height/3)))
  px=f.load()
  for y in range(f.height):
   for x in range(f.width):
    r,g,b,a=px[x,y]
    if r>130 and b>100 and g<130 and min(r,b)>g*1.6: px[x,y]=(0,0,0,0)
  frames.append(f)
# One shared scale preserves body size across frames. Anchor mask, not fluttering cloth.
scale=64/max(f.getbbox()[3]-f.getbbox()[1] for f in frames)
processed=[]
for index,f in enumerate(frames):
 f=f.resize((round(f.width*scale),round(f.height*scale)),Image.Resampling.NEAREST)
 mask=[(x,y) for y in range(f.height) for x in range(f.width) if f.getpixel((x,y))[3]>128 and min(f.getpixel((x,y))[:3])>125 and f.getpixel((x,y))[0]>f.getpixel((x,y))[2]]
 assert mask, 'ivory mask missing'
 mx=sum(x for x,y in mask)/len(mask); my=sum(y for x,y in mask)/len(mask)
 canvas=Image.new('RGBA',(128,128)); dx=round(64-mx); dy=round(68-my); canvas.paste(f,(dx,dy))
 box=canvas.getbbox(); assert box[0]>0 and box[1]>0 and box[2]<128 and box[3]<128
 processed.append(canvas);measurements.append({'frame':index,'bounds':box,'mask_center':[mx+dx,my+dy]})
atlas=Image.new('RGBA',(1152,128))
for i,f in enumerate(processed):atlas.paste(f,(128*i,0))
atlas.save(out/'hover.png')
processed[0].save(out/'hover.webp',save_all=True,append_images=processed[1:],duration=90,loop=0,lossless=True)
(raw/'alignment.json').write_text(json.dumps(measurements,indent=2))
p=Path('game/animation/profiles/wraith_pixel.json'); profile=json.loads(p.read_text()); (raw/'previous-profile.json').write_text(json.dumps(profile,indent=2))
clip={'atlas':'res://art/crimson-wraith/hover.png','frames':[{'rect':[i*128,0,128,128],'duration_ms':90} for i in range(9)],'loop':True}
for state in ['idle','float','walk']:profile['clips'][state]=clip.copy()
profile['status']='Nine generated mask-registered crimson hover cels; original combat and reaction poses preserved.'
profile['movement_status']='Nine distinct cloth ripple cels, 810ms loop, shared scale and ivory-mask anchor at (64,68).'
p.write_text(json.dumps(profile,indent=2)+'\n')
