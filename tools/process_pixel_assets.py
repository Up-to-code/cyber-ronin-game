"""Deterministic pixel export, chroma cleanup and atlas registration; no raw artwork creation."""
from pathlib import Path
from PIL import Image
import json,math
SRC=Path('assets/pixel/source');OUT=Path('game/art/pixel');OUT.mkdir(parents=True,exist_ok=True)
def pixel(im,size,colors=32):
    im=im.convert('RGBA').resize(size,Image.Resampling.NEAREST)
    a=im.getchannel('A').point(lambda v:255 if v>=96 else 0)
    rgb=im.convert('RGB').quantize(colors=colors,dither=Image.Dither.NONE).convert('RGBA');rgb.putalpha(a)
    return rgb
for name in ['sky','monastery']:
    im=Image.open(SRC/(name+'.raw.png'))
    pixel(im,(640,360),32).save(OUT/(name+'.png'))
im=Image.open(SRC/'platform.raw.png').convert('RGBA');im.putalpha(im.getchannel('A').point(lambda v:255 if v>=96 else 0));im=im.crop(im.getbbox())
pixel(im,(256,64),24).save(OUT/'platform.png')
ui=Image.open(SRC/'ui.raw.png').convert('RGBA')
data=ui.load()
for y in range(ui.height):
 for x in range(ui.width):
  r,g,b,a=data[x,y]
  if r>150 and b>130 and g<110 and r-g>70 and b-g>70:data[x,y]=(0,0,0,0)
names=['heart','heart_empty','pause','resume','button','button_selected','health_empty','health_full','left','right','attack','jump']
for i,name in enumerate(names):
 x=i%4;y=i//4
 cell=ui.crop((round(x*ui.width/4),round(y*ui.height/3),round((x+1)*ui.width/4),round((y+1)*ui.height/3)))
 box=cell.getbbox();cell=cell.crop(box)
 size=(128,32) if i in [4,5] else ((144,32) if i in [6,7] else (32,32))
 pixel(cell,size,24).save(OUT/(name+'.png'))
fx=Image.open(SRC/'fx.raw.png').convert('RGBA')
for row,name in enumerate(['slash','dust','impact']):
 sheet=Image.new('RGBA',(256,64))
 for col in range(4):
  cell=fx.crop((round(col*fx.width/4),round(row*fx.height/3),round((col+1)*fx.width/4),round((row+1)*fx.height/3)))
  sheet.paste(pixel(cell,(64,64),16),(col*64,0))
 sheet.save(OUT/(name+'_fx.png'))
for name in ['last-ronin','tracer']:
 folder=Path('assets/characters/cyber_ronin/CyberRonin_SpritePack')/name
 d=json.loads((folder/(name+'.json')).read_text());frames=d['frames'];source=Image.open(folder/(name+'.png')).convert('RGBA')
 atlas=Image.new('RGBA',(8*96,math.ceil(len(frames)/8)*96))
 for i,frame in enumerate(frames):
  r=frame['frame'];cell=source.crop((r['x'],r['y'],r['x']+r['w'],r['y']+r['h']))
  # Every source frame shares the source foot pivot. Scale whole cells identically.
  scale=.5;w=round(r['w']*scale);h=round(r['h']*scale)
  cell=pixel(cell,(w,h),32)
  pivot=d['meta']['pivot'];px=pivot['x'] if isinstance(pivot,dict) else pivot[0];py=pivot['y'] if isinstance(pivot,dict) else pivot[1]
  # Wider weapon poses may extend beyond96; contain all pixels uniformly if needed.
  left=48-round(px*scale);top=88-round(py*scale)
  atlas.paste(cell,(i%8*96+left,i//8*96+top),cell)
 atlas_path=OUT/(name+'_sheet.png');atlas.save(atlas_path)
 lines=['[gd_resource type="SpriteFrames" load_steps=%d format=3]'%(len(frames)+2),'','[ext_resource type="Texture2D" path="res://art/pixel/'+name+'_sheet.png" id="1"]','']
 for i in range(len(frames)):
  lines+=['[sub_resource type="AtlasTexture" id="%d"]'%(i+2),'atlas = ExtResource("1")','region = Rect2(%d, %d, 96, 96)'%(i%8*96,i//8*96),'']
 anims=[]
 for tag in d['meta']['frameTags']:
  n=tag['name'];start=tag['from'];end=tag['to'];duration=frames[start].get('duration',80)
  frame_list=', '.join('{"duration":1.0,"texture":SubResource("%d")}'%(i+2) for i in range(start,end+1))
  loop=n in ['idle','walk','run','fly','walk2']
  anims.append('{"name":&"%s","speed":%s,"loop":%s,"frames":[%s]}'%(n,1000/duration,str(loop).lower(),frame_list))
 lines+=['[resource]','animations = ['+',\n'.join(anims)+']']
 (Path('game/art')/name/(name+'.tres')).write_text('\n'.join(lines)+'\n')
print('Exported pixel backgrounds, platform, 12 UI sprites, 3 FX strips and 2 registered character atlases')
