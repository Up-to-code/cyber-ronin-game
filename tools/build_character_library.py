"""Register/pack artwork and metadata. Does not draw or interpolate poses."""
from pathlib import Path
import json,re
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'game/art/ronin-redraw'
def read_tres(path):
 text=path.read_text()
 rects={m[0]:[int(float(x)) for x in m[1].split(',')] for m in re.findall(r'\[sub_resource type="AtlasTexture" id="(\d+)"\]\s*atlas = ExtResource\("1"\)\s*region = Rect2\(([^)]+)\)',text)}
 body=text.split('animations = ',1)[1].strip()
 body=re.sub(r'SubResource\("(\d+)"\)',r'"\1"',body).replace('&"','"')
 return {a['name']:{'frames':[rects[f['texture']] for f in a['frames']],'speed':a['speed'],'loop':a['loop']} for a in json.loads(body)}
def normalize_atlas(source,dest):
 im=Image.open(source).convert('RGBA');cols=im.width//96;rows=im.height//96
 out=Image.new('RGBA',(cols*128,rows*128))
 for y in range(rows):
  for x in range(cols):
   frame=im.crop((x*96,y*96,x*96+96,y*96+96)).resize((88,88),Image.Resampling.NEAREST)
   out.paste(frame,(x*128+20,y*128+32))
 out.save(dest)
def normalize_profile():
 path=ROOT/'game/animation/profiles/ronin_cel.json'
 profile=json.loads(path.read_text())
 if profile['atlas'].endswith('last-ronin_sheet.png'):
  normalize_atlas(ROOT/'game/art/pixel/last-ronin_sheet.png',OUT/'source-movement.png')
  profile['atlas']='res://art/ronin-redraw/source-movement.png';profile['feet_origin']=[64,112]
  def point(v):return [round(v[0]*88/96+20),round(v[1]*88/96+32)]
  profile['sockets']={k:point(v) for k,v in profile['sockets'].items()}
  for clip in profile['clips'].values():
   if 'atlas' in clip:continue
   if 'sockets' in clip:clip['sockets']={k:point(v) for k,v in clip['sockets'].items()}
   for frame in clip['frames']:
    x,y,w,h=frame['rect'];frame['rect']=[x//96*128,y//96*128,128,128]
    if 'sockets' in frame:frame['sockets']={k:point(v) for k,v in frame['sockets'].items()}
  profile['clips']['idle']={'atlas':'res://art/ronin-redraw/idle.png','frames':[{'rect':[0,0,128,128],'duration_ms':160}],'loop':True}
  path.write_text(json.dumps(profile,indent=2)+'\n')
def guard_profile():
 profile=json.loads((ROOT/'game/animation/profiles/ronin_cel.json').read_text())
 source=read_tres(ROOT/'game/art/tracer/tracer.tres')
 profile.update(id='guard_cel',display_name='Source-authored guard compatibility skin',atlas='res://art/pixel/tracer_sheet.png',feet_origin=[48,88],status='Source-derived compatibility art; not the new hero redraw.')
 profile['sockets']={'hand':[63,62],'foot':[59,84],'weapon_tip':[81,73],'chest':[49,47],'pelvis':[48,60]}
 for name,clip in profile['clips'].items():
  key='attack' if name.startswith('sword') or name in ['charged','power','ranged','kick'] else ('jump' if name in ['land','fall','plunge'] else ('idle' if name in ['charge','crouch','dash'] else name))
  a=source.get(key,source['idle'])
  clip.clear();clip.update(frames=[{'rect':r,'duration_ms':round(1000/a['speed'])} for r in a['frames']],loop=a['loop'])
  if name in ['run','walk']:
   clip['stride_world']=180
   for i in [0,len(clip['frames'])//2]:clip['frames'][i]['events']=['foot_contact']
 for attack in profile['attacks'].values():
  attack['contact_frame']=min(4,len(profile['clips'][attack['clip']]['frames'])-1)
 (ROOT/'game/animation/profiles/guard_cel.json').write_text(json.dumps(profile,indent=2)+'\n')
if __name__=='__main__':
 OUT.mkdir(parents=True,exist_ok=True)
 normalize_profile();guard_profile()
 print('Registered fixed-canvas source movement and guard profile; preserved source artwork.')
