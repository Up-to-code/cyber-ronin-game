"""Register approved whole-character pose sheets; never synthesize artwork."""
from pathlib import Path
import json
from PIL import Image
root=Path(__file__).resolve().parents[1]
for number in range(1,101):
 name=f'{number:03}'
 path=root/'game/art/monster-cels'/f'{name}.json'
 if not path.exists():raise RuntimeError(f'Missing approved sheet {name}')
 data=json.loads(path.read_text());cell=data['cell_size'];columns=data.get('columns',4)
 atlas=Image.open(root/'game'/data['texture'].removeprefix('res://')).convert('RGBA')
 bounds=[];origins=data.get('origins',[data.get('feet_origin',[64,112])[:] for _ in range(12)])
 for i in range(12):
  frame=atlas.crop((i%columns*cell,i//columns*cell,(i%columns+1)*cell,(i//columns+1)*cell))
  bbox=frame.getchannel('A').getbbox()
  if not bbox:raise RuntimeError(f'Empty pose {number}/{i}')
  if i<10:bounds.append(bbox)
  else:origins[i]=[origins[i][0],bbox[3]]
 data['origins']=origins
 data.setdefault('locomotion','walk')
 data.setdefault('clips',{}).setdefault('idle',[data['clips']['attack'][-1]])
 path.write_text(json.dumps(data,indent=2)+'\n')
 profile_path=root/'game/animation/profiles'/f'monster_{name}.json'
 profile=json.loads(profile_path.read_text())
 profile.setdefault('source_reference',f'res://art/monster-migration/{name}.png')
 profile.update(atlas=data['texture'],feet_origin=data['feet_origin'],status='12 model-generated whole-character key poses; four locomotion, four attack, two hurt, two death. Limited keyframe animation, not full in-betweens.',movement_status='Four distinct replacement locomotion poses selected by distance/flight cadence; gameplay owns action phase.')
 x=min(b[0] for b in bounds);y=min(b[1] for b in bounds)
 profile['body_bounds']=[x,y,max(b[2] for b in bounds)-x,max(b[3] for b in bounds)-y]
 def frames(indices,durations):
  return [{'rect':[i%columns*cell,i//columns*cell,cell,cell],'duration_ms':durations[min(n,len(durations)-1)],'feet_origin':origins[i]} for n,i in enumerate(indices)]
 clips=data['clips']
 profile['clips']={
  'idle':{'frames':frames(clips['idle'],[600]),'loop':True},
  'walk':{'frames':frames(clips['walk'],[125]),'loop':True,'stride_world':60},
  'float':{'frames':frames(clips['walk'],[125]),'loop':True},
  'windup':{'frames':frames([clips['attack'][0]],[320])},
  'attack':{'frames':frames(clips['attack'],[90,60,80,90])},
  'hurt':{'frames':frames(clips['hurt'],[100,180])},
  'death':{'frames':frames(clips['death'],[275,1025])},
  'air':{'frames':frames([clips['walk'][1]],[100])}}
 profile_path.write_text(json.dumps(profile,indent=2)+'\n')
print('Registered all 100 approved 12-pose sheets, explicit locomotion and grounded corpse origins')
