from pathlib import Path
from PIL import Image
import json,shutil
R=Path(__file__).resolve().parents[1];O=R/'game/art/ronin-v2';O.mkdir(exist_ok=True)
src=Path('/Users/ahmedmansour/.codex/generated_images/01a1c895-624e-7573-b11a-af481a70fdba/exec-f9dc6e0f-82c0-4b8c-a870-2879813d9df9.png')
raw=R/'assets/ronin-v2';raw.mkdir(exist_ok=True);shutil.copyfile(src,raw/'generated-sheet.png')
im=Image.open(src).convert('RGBA');print(im.size)
atlas=Image.new('RGBA',(1024,1024));frames=[]
for row in range(8):
 for col in range(8):
  cell=im.crop((col*im.width//8,row*im.height//8,(col+1)*im.width//8,(row+1)*im.height//8))
  cell.putalpha(cell.getchannel('A').point(lambda a:255 if a>160 else 0))
  # One shared scale across every pose; no limb edits or synthesized poses.
  cell=cell.resize((80,80),Image.Resampling.NEAREST)
  box=cell.getbbox();bottom=box[3] if box else 80
  out=Image.new('RGBA',(128,128));out.alpha_composite(cell,(24,112-bottom));atlas.alpha_composite(out,(col*128,row*128));frames.append(out)
atlas.save(O/'actions.png')
p=R/'game/animation/profiles/ronin_cel.json';old=json.loads(p.read_text());shutil.copyfile(p,raw/'previous-profile.json')
old['display_name']='Ashen ronin — crimson scarf';old['status']='Generated whole-character 64-pose sheet; shared poses for secondary actions.';old['atlas']='res://art/ronin-v2/actions.png'
rows={'idle':(0,list(range(8))),'walk':(1,list(range(8))),'run':(1,list(range(8))),'sword1':(2,list(range(8))),'sword2':(3,list(range(8))),'sword3':(6,list(range(8))),'kick':(4,list(range(8))),'jump':(5,[2,3,4]),'fall':(5,[4,5]),'takeoff':(5,[0,1,2]),'apex':(5,[3,4]),'land':(5,[6,7]),'hurt':(7,[0,1,2,3]),'death':(7,[4,5,6,7]),'charge':(6,[0,1,2]),'charged':(6,list(range(8))),'power':(6,list(range(8))),'ranged':(3,list(range(8))),'crouch':(5,[0]),'dash':(1,[3]),'plunge':(6,[3,4]),'block':(7,[3])}
for k,(row,cols) in rows.items():
 clip=old['clips'][k];original=clip['frames'];duration=sum(f.get('duration_ms',60) for f in original)
 if k=='idle':duration=1200
 clip['atlas']=old['atlas'];clip['frames']=[{'rect':[c*128,row*128,128,128],'duration_ms':duration/len(cols)} for c in cols]
 if k in ['walk','run']:
  clip['frames'][0]['events']=['foot_contact'];clip['frames'][4]['events']=['foot_contact']
p.write_text(json.dumps(old,indent=2)+'\n')
frames[0].resize((512,512),Image.Resampling.NEAREST).save(O/'preview.png')
