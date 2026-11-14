from PIL import Image
from pathlib import Path
import shutil
src=Path('/Users/ahmedmansour/.codex/generated_images/01a1c895-624e-7573-b11a-af481a70fdba')
raw=Path('assets/environments/crimson-gate'); out=Path('game/art/crimson-gate')
files={'reference':'exec-05c0a886-d22e-4149-a96c-d74a442518a7.png','vortex':'exec-9840f482-a397-4af7-8ca8-b4632239b3d4.png','gate':'exec-dcc1589e-2d8c-4348-8ae1-280d4ac3fb09.png'}
for name,file in files.items(): shutil.copy2(src/file,raw/(name+'.png'))
def clean(im):
 im=im.convert('RGBA'); p=im.load()
 for y in range(im.height):
  for x in range(im.width):
   r,g,b,a=p[x,y]
   if r>150 and b>140 and g<100 and min(r,b)>g*1.5: p[x,y]=(0,0,0,0)
 return im
im=clean(Image.open(raw/'gate.png')); im=im.crop(im.getbbox()); im=im.resize((256,176),Image.Resampling.NEAREST)
atlas=Image.new('RGBA',(1024,176))
for i in range(4): atlas.paste(im,(256*i,0))
atlas.save(out/'gate.png')
im=clean(Image.open(raw/'vortex.png')); frames=[]
for y in range(3):
 for x in range(3):
  f=im.crop((round(x*im.width/3),round(y*im.height/3),round((x+1)*im.width/3),round((y+1)*im.height/3)))
  f=f.resize((128,144),Image.Resampling.NEAREST); frames.append(f)
atlas=Image.new('RGBA',(128*9,144))
for i,f in enumerate(frames): atlas.paste(f,(i*128,0))
atlas.save(out/'vortex.png')
frames[0].save(out/'vortex.webp',save_all=True,append_images=frames[1:],duration=85,loop=0,lossless=True)
