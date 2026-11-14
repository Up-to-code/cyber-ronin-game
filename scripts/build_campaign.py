"""Build deterministic campaign data from ten traversable route templates.
No random runtime geometry; rerun after intentionally editing route_templates.json.
"""
import copy, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
base=json.loads((ROOT/'game/data/route_templates.json').read_text())
chapters=['Ash Road','Lantern Marsh','Iron Ramparts','Cinder Aqueduct','Hollow Cistern','Storm Monastery','Crimson Gardens','Obsidian Keep','Eclipse Ascent','The Last Bell']
bosses=['Bell Tyrant','Lantern Matriarch','Iron Fang','Cinder Oracle','Drowned Keeper','Storm Executioner','Crimson Twinsworn','Obsidian Emperor','Eclipse Herald','The Unbound Bell']
kinds=['obsidian','lantern','lancer','impostor','sentinel','guard','fire','obsidian','lantern','sentinel']
out=[]
for chapter in range(10):
 for slot in range(1,11):
  number=chapter*10+slot
  template=slot if chapter==0 else (10 if slot==10 else (slot-1+chapter*2)%9+1)
  m=copy.deepcopy(base[template-1])
  m.update(id=number,chapter=chapter+1,chapter_name=chapters[chapter],template=template,
           name=m['name'] if chapter==0 else f'{chapters[chapter]} {slot:02d}',
           difficulty='normal' if chapter==0 and slot<6 else 'hard',
           mission='boss' if slot==10 else ('seals' if slot in [3,7] else ('hunt' if slot==9 else 'purge')))
  scale=1+chapter*.012
  dy=0 if chapter==0 else ((chapter%5)-2)*8
  def point(p):return [round(p[0]*scale,2),p[1]+dy]
  for p in m['platforms']:
   p['center']=point(p['center']);p['width']=round(p['width']*scale,2)
  m['spawn']=point(m['spawn']);m['exit']=point(m['exit']);m['width']=round(m['width']*scale,2)
  if 'height' in m:m['height']+=max(0,dy)
  for lift in m['lifts']:
   lift['center']=point(lift['center']);lift['width']*=scale;lift['travel'][0]*=scale
  for e in m['enemies']:
   e['position']=point(e['position']);e['health_bonus']=chapter*14+min(slot,7)*2
   for key in ['boss','boss_name','health']:e.pop(key,None)
   e['elite']=False
   # Old route-five boss becomes a regular heavy encounter.
   e['skill']='laser' if chapter>=2 and e['kind'] in ['impostor','lantern'] else ('fan' if e['kind']=='fire' else 'native')
   e['projectile_damage']=min(24,10+chapter)
  if slot==10:
   boss=m['enemies'][-1]
   boss.update(kind=kinds[chapter],boss=True,boss_name=bosses[chapter],health=340+chapter*70,
               skill='cycle' if chapter>=2 else ('fan' if chapter==1 else 'quake'),
               melee_damage=min(36,22+chapter*2),projectile_damage=min(28,14+chapter),
               boss_scale=1.15+chapter*.015)
  elif m['mission']=='hunt':
   m['enemies'][-1]['captain']=True
   m['enemies'][-1]['health_bonus']+=45
  # A later-chapter reinforcement occupies spare deck space, never a landing lip.
  if chapter>=3 and not m.get('shaft') and slot!=10:
   for p in reversed(m['platforms'][1:]):
    x=p['center'][0]+p['width']/2-110
    if p.get('route',True) and p['width']>=600 and all(abs(e['position'][0]-x)>145 for e in m['enemies']):
     m['enemies'].append(dict(position=[x,p['center'][1]],kind='obsidian' if chapter%2 else 'lantern',elite=False,health_bonus=chapter*14,skill='laser' if chapter>=6 else 'native',projectile_damage=12+chapter));break
  m['pickups']=[]
  # Route breadcrumbs sit on safe landings, not over pits.
  for i,p in enumerate(m['platforms'][1:]):
   m['pickups'].append(dict(position=[p['center'][0],p['center'][1]-28],kind='coin',amount=3+chapter))
   if 'recover' in p.get('beat','') or (i==len(m['platforms'])//2 and slot==10):
    m['pickups'].append(dict(position=[p['center'][0]+45,p['center'][1]-30],kind='health',amount=20))
  if m['mission']=='seals':
   platforms=[p for p in m['platforms'] if p.get('route',True)]; choices=sorted(set([1,len(platforms)//2,len(platforms)-2]))
   for i in choices:
    p=platforms[i];m['pickups'].append(dict(position=[p['center'][0]-45,p['center'][1]-30],kind='seal',amount=1))
  m['objective']={'purge':'Defeat the patrols and open the gate.','seals':'Recover three seals and defeat the patrols.','hunt':'Defeat the marked captain; other patrols are optional.','boss':f'Defeat {bosses[chapter]}.'}[m['mission']]
  m['description']=m['objective']
  out.append(m)
(ROOT/'game/data/routes.json').write_text(json.dumps(out,indent=2)+'\n')
print(f'{len(out)} levels; {sum(bool(e.get("boss")) for m in out for e in m["enemies"])} major bosses; {sum(len(m["enemies"]) for m in out)} enemies distributed across the campaign')
