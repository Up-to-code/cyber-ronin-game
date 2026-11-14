from pathlib import Path
from PIL import Image
source=Path('assets/characters/rig/ronin-parts.raw.png')
im=Image.open(source).convert('RGBA');out=Image.new('RGBA',(384,288))
for i in range(12):
 x,y=i%4,i//4
 cell=im.crop((round(x*im.width/4),round(y*im.height/3),round((x+1)*im.width/4),round((y+1)*im.height/3)))
 alpha=cell.getchannel('A').point(lambda a:255 if a>=128 else 0);cell.putalpha(alpha)
 cell=cell.crop(cell.getbbox()).resize((96,96),Image.Resampling.NEAREST)
 alpha=cell.getchannel('A');cell=cell.convert('RGB').quantize(colors=24,dither=Image.Dither.NONE).convert('RGBA');cell.putalpha(alpha)
 out.paste(cell,(x*96,y*96))
out.save('game/rig/parts.png')
print('Exported 12 image-generated isolated skin parts, 384x288 RGBA')
