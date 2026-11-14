"""Deterministic extraction/pixel-grid cleanup of image-generated assets."""
from pathlib import Path
from PIL import Image
import shutil,zipfile
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'game/art/pixel-redesign'
SRC=ROOT/'assets/archive/pixel-redesign'
PALETTE=['0b101d','151d30','253349','3e526b','697d8b','a8b5b1','f3e4bb','cdb68b','712a3d','a83d40','d45d40','f39b46','37645d','5c8e76','332337','504052','872b36','da5247','1c1827','eeeacb','8d7180','9c6247','57342f','283f4c']
pal=Image.new('P',(1,1));pal.putpalette([v for h in PALETTE for v in bytes.fromhex(h)]+[0]*(768-len(PALETTE)*3))
def pixel(im, factor=2):
 size=im.size
 im=im.convert('RGBA').resize((max(1,size[0]//factor),max(1,size[1]//factor)),Image.Resampling.NEAREST)
 alpha=im.getchannel('A').point(lambda x:255 if x>=128 else 0)
 im=im.convert('RGB').quantize(palette=pal,dither=Image.Dither.NONE).convert('RGBA');im.putalpha(alpha)
 return im.resize(size,Image.Resampling.NEAREST)
def extract(source,names):
 im=Image.open(source).convert('RGBA');w,h=im.size
 for i,name in enumerate(names):
  cell=im.crop(((i%3)*w//3+5,(i//3)*h//2+5,(i%3+1)*w//3-5,(i//3+1)*h//2-5))
  data=cell.load()
  for y in range(cell.height):
   for x in range(cell.width):
    r,g,b,a=data[x,y]
    if r>150 and b>140 and g<110:data[x,y]=(0,0,0,0)
  bbox=cell.getbbox();cell=cell.crop(bbox)
  # Quantize generated source to a strict small pixel grid, preserving alpha.
  cell.thumbnail((128,96) if i<3 else (128,128),Image.Resampling.NEAREST)
  pixel(cell,1).save(OUT/(name+'.png'))
extract(SRC/'world.png',['stone','balcony','rock','castle','bamboo','mountain'])
extract(SRC/'ui.png',['button','button_selected','panel','dpad','sword','jump'])
print('Extracted generated assets; existing gameplay textures are preserved')
