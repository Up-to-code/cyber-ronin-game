"""Deterministic exports from generated castle sources; does not draw raw art."""
from PIL import Image
from pathlib import Path
import json
src=Path('assets/pixel/castle-source');out=Path('game/art/pixel')
def px(im,size,colors=32):
 im=im.convert('RGBA').resize(size,Image.Resampling.NEAREST)
 a=im.getchannel('A').point(lambda v:255 if v>=96 else 0)
 rgb=im.convert('RGB').quantize(colors=colors,dither=Image.Dither.NONE).convert('RGBA');rgb.putalpha(a)
 return rgb
for name in ['castle','roofs','bamboo']:
 px(Image.open(src/(name+'.raw.png')),(640,360)).save(out/(name+'.png'))
im=Image.open(src/'rampart.raw.png').convert('RGBA');im.putalpha(im.getchannel('A').point(lambda v:255 if v>=96 else 0));im=im.crop(im.getbbox());im=px(im,(256,64),24);im.save(out/'rampart.png')
surface=next(y for y in range(64) if sum(im.getpixel((x,y))[3]>128 for x in range(32,224))>180)
torch=Image.open(src/'torch.raw.png').convert('RGBA');atlas=Image.new('RGBA',(64,192))
for row in range(4):
 for col in range(2):
  cell=torch.crop((round(col*torch.width/2),round(row*torch.height/4),round((col+1)*torch.width/2),round((row+1)*torch.height/4)))
  atlas.paste(px(cell,(32,48),16),(col*32,row*48))
atlas.save(out/'torch.png')
(out/'castle-metadata.json').write_text(json.dumps({'rampart_surface_row':surface,'platform_surface_row':8,'torch_cell':[32,48],'torch_columns':2,'torch_frames':8},indent=2)+'\n')
print('Castle assets exported; rampart surface row',surface)
