"""Crop, quantize and split generated sources; no procedural raw artwork."""
from PIL import Image,ImageEnhance
from pathlib import Path
src=Path('assets/pixel/refinement');out=Path('game/art/pixel')
def px(im,size,colors=24):
 im=im.convert('RGBA').resize(size,Image.Resampling.NEAREST)
 a=im.getchannel('A').point(lambda v:255 if v>=110 else 0)
 rgb=im.convert('RGB').quantize(colors=colors,dither=Image.Dither.NONE).convert('RGBA');rgb.putalpha(a);return rgb
im=Image.open(src/'flat-terrain.raw.png').convert('RGBA');im.putalpha(im.getchannel('A').point(lambda v:255 if v>=110 else 0));im=im.crop(im.getbbox())
base=px(im,(256,32),24);base.save(out/'platform.png')
a=base.getchannel('A');cool=ImageEnhance.Color(base.convert('RGB')).enhance(.65).convert('RGBA');cool.putalpha(a);cool.save(out/'rampart.png')
fx=Image.open(src/'restrained-fx.raw.png').convert('RGBA')
for row,name in enumerate(['slash','dust','impact']):
 atlas=Image.new('RGBA',(256,64))
 for col in range(4):
  cell=fx.crop((round(col*fx.width/4),round(row*fx.height/3),round((col+1)*fx.width/4),round((row+1)*fx.height/3)))
  atlas.paste(px(cell,(64,64),12),(col*64,0))
 if name=='slash':
  pixels=atlas.load()
  for y in range(atlas.height):
   for x in range(atlas.width):
    r,g,b,a=pixels[x,y]
    if a:
     luminance=(r+g+b)/3
     color=(237,244,220) if luminance>200 else ((164,218,211) if luminance>150 else ((82,126,134) if luminance>85 else (38,62,86)))
     pixels[x,y]=(*color,a)
 atlas.save(out/(name+'_fx.png'))
print('Exported flat tileable masonry and restrained slash/dust/impact effects')
