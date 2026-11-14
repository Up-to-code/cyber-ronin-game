from PIL import Image
from pathlib import Path
import shutil
base=Path('/Users/ahmedmansour/.codex/generated_images/01a1d419-ace7-79d3-996d-9f2a0333500c')
sources={'background':'exec-05d52c3d-d905-41a8-97b3-69bc2f8656f8.png','fire':'exec-4948e04d-64ab-4c01-8547-9078a2985fb3.png'}
for key,path in sources.items():shutil.copy2(base/path,Path('assets/environments/living-marsh/source')/(key+'.png'))
Image.open(base/sources['background']).resize((640,360),Image.Resampling.NEAREST).save('game/art/living-marsh/background.png')
im=Image.open(base/sources['fire']).convert('RGBA');w,h=im.size
for i in range(4):
 cell=im.crop(((i%2)*w//2,(i//2)*h//2,((i%2)+1)*w//2,((i//2)+1)*h//2))
 bbox=cell.getchannel('A').point(lambda a:255 if a>24 else 0).getbbox();cell=cell.crop(bbox)
 cell.thumbnail((34,48),Image.Resampling.NEAREST)
 frame=Image.new('RGBA',(40,52));frame.alpha_composite(cell,((40-cell.width)//2,52-cell.height));frame.save('game/art/living-marsh/fire%d.png'%i)
