"""World migration: ordered traversal itineraries, not horizontal template copies.
Platforms exist for a route transition, encounter, objective, or device. No filler
balconies are added. All geometry is deterministic and checked in as route data.
"""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
BIOMES=['surface','underground','sky','citadel']
REGIONS={'surface':'Ashen Province','underground':'Rootvault Depths','sky':'Cloud Pilgrimage','citadel':'The Old Shogunate'}
THEMES={'surface':'bamboo','underground':'courtyard','sky':'summit','citadel':'sanctuary'}
BOSSES=['Broodmother of the Hollow','The Furnace Abbot','Nine-Kite Executioner','The Iron Shogun','Root-Eater Matriarch','Keeper of the Sunken Bell','Cloud-Eater','The Red Regent','The Hollow Moon','The Last Unbound']
NAMES=['First Footfall','Into the Rootwell','The Cloud Stair','Courtyard Reversal','Return of the Lantern','Broken Aqueduct','Ascent of Embers','The Deep Descent','Three Lost Vows','The Sealed Throne']
# Distinct directed route patterns repeat only as traversal vocabulary. Every
# level has its own rhythm, widths, encounters, objectives, branches and contour.
PATTERNS=['traverse','descent','ascent','switchback','return','gorge','tower','sink','pilgrimage','boss']
def platform(x,y,w,biome,one_way,purpose):
 return dict(center=[round(x,2),round(y,2)],width=round(w,2),optional=False,one_way=one_way,route=True,construction='cloud' if biome=='sky' else ('balcony' if one_way else 'rock'),depth=24 if one_way else 48,beat=purpose,purpose=purpose)
def itinerary(number,pattern,biome):
 chapter=(number-1)//10;slot=(number-1)%10
 n=7+(chapter*3+slot)%5
 widths=[(240+((i*37+number*19+chapter*(i+1)*13)%7)*20) for i in range(n)]
 pts=[]
 if pattern in ['traverse','gorge','pilgrimage','boss']:
  x=0;y=650
  for i,w in enumerate(widths):
   if i==0:w=400
   if i==n-1:w=960 if pattern=='boss' else 440
   if i:
    x+=42+((number+i*3)%4)*8
    y+=([0,-65,50,-45,60][(number+i)%5] if pattern!='boss' else [0,45,-45][i%3])
   pts.append((x+w/2,y,w));x+=w
 elif pattern in ['ascent','tower','switchback']:
  y=420+(n-1)*72
  cols=4 if pattern=='ascent' else (3 if pattern=='tower' else 5)
  for i,w in enumerate(widths):
   cycle=i%(2*(cols-1));col=cycle if cycle<cols else 2*(cols-1)-cycle
   pts.append((260+col*330,y-i*(65+(number%3)*5),400 if i in [0,n-1] else min(w,280)))
 elif pattern in ['descent','sink']:
  cols=4 if pattern=='descent' else 3
  for i,w in enumerate(widths):
   cycle=i%(2*(cols-1));col=cycle if cycle<cols else 2*(cols-1)-cycle
   pts.append((260+col*330,350+i*(85+(number%3)*8),400 if i in [0,n-1] else min(w,280)))
 elif pattern=='return':
  # Travel east, climb at the end, then return west on a high route. The exit
  # is spatially near arrival but cannot be reached without climbing the loop.
  pts=[(240,850,400),(610,850,260),(930,805,260),(1250,850,260),(1570,785,280),(1700,710,240),(1550,635,260),(1220,570,270),(890,505,280),(560,440,280),(240,375,400)]
  pts=[(x,y-((chapter*(i+2))%3)*5,w+((chapter*(i+1)*7)%5)*8) for i,(x,y,w) in enumerate(pts)]
 # Each non-horizontal itinerary has jump-through intermediate landings so the
 # route does not create accidental head-blocking ceilings or solid shafts.
 vertical=pattern not in ['traverse','gorge','pilgrimage','boss']
 return [platform(x,y,w,biome,vertical or biome=='sky','arrival' if i==0 else ('boss arena' if pattern=='boss' and i==len(pts)-1 else ('exit sanctuary' if i==len(pts)-1 else ('combat landing' if i%2==0 else 'traversal landing')))) for i,(x,y,w) in enumerate(pts)]
def build():
 roster=json.loads((ROOT/'game/data/monsters.json').read_text());by_id={r['id']:r for r in roster}
 out=[]
 for number in range(1,101):
  chapter=(number-1)//10;slot=(number-1)%10
  pattern=PATTERNS[slot]
  biome=BIOMES[(chapter+slot)%4]
  if number==1:biome='surface'
  if number==2:biome='underground'
  if number==3:biome='sky'
  if slot==9:biome=BIOMES[chapter%4]
  surfaces=itinerary(number,pattern,biome)
  if number==11:
   surfaces[0].update(center=[202.4,642],width=404.8)
   surfaces[1].update(center=[586.96,572],width=263.12,one_way=True,construction='balcony')
   # Preserve an attainable join after the sentinel tutorial's fixed first jump.
   shift=surfaces[2]['center'][0]-(586.96+263.12/2+55+surfaces[2]['width']/2)
   for p in surfaces[2:]:p['center'][0]-=shift
  width=max(1520,max(p['center'][0]+p['width']/2 for p in surfaces)+80)
  height=max(1100,max(p['center'][1] for p in surfaces)+300)
  enemies=[]
  count=3+min(4,chapter//2)
  slots=sorted(set([2]+[min(len(surfaces)-2,2+i*2) for i in range(count)]))
  for i,index in enumerate(slots):
   mid=(number-1 if slot==9 else number) if i==0 else max(1,number-1-((i*7+chapter)%max(1,number)))
   spec=by_id[mid];p=surfaces[index]
   enemies.append(dict(position=p['center'].copy(),kind=spec['kind'],monster_id=mid,elite=False,health_bonus=chapter*6,skill='native',projectile_damage=10+chapter))
  boss=slot==9
  if boss:
   p=surfaces[-1];spec=by_id[number]
   enemies.append(dict(position=[p['center'][0]+80,p['center'][1]],kind=spec['kind'],monster_id=number,elite=False,boss=True,boss_name=BOSSES[chapter],health=340+chapter*70,melee_damage=22+min(14,chapter*2),projectile_damage=14+chapter,boss_scale=1.15,skill='native',boss_mechanic='broodmother' if chapter in [0,4] else ['forge','kite','duel','roots','bell','storm','regent','eclipse','finale'][min(chapter-1,8)]))
  mission='boss' if boss else ('seals' if pattern in ['return','pilgrimage'] else 'purge')
  pickups=[]
  for i,p in enumerate(surfaces[1:],1):
   pickups.append(dict(position=[p['center'][0],p['center'][1]-28],kind='coin',amount=4+chapter))
   if i%3==0:pickups.append(dict(position=[p['center'][0]-60,p['center'][1]-28],kind='health',amount=20))
  if mission=='seals':
   for i in [2,len(surfaces)//2,len(surfaces)-2]:
    p=surfaces[i];pickups.append(dict(position=[p['center'][0]+50,p['center'][1]-28],kind='seal',amount=1))
  spawn=[surfaces[0]['center'][0]-50,surfaces[0]['center'][1]]
  exit=[surfaces[-1]['center'][0]+(240 if boss else 60),surfaces[-1]['center'][1]]
  objective=('Defeat '+BOSSES[chapter]+'.') if boss else ('Recover the three vows along the return route.' if mission=='seals' else {'ascent':'Climb the cloud stair and silence its guardians.','tower':'Ascend the tower, using each landing as cover.','descent':'Descend through the rootwell; choose safe landings.','sink':'Drop through the chambers to reach the lower sanctuary.','switchback':'Follow the changing route up the keep.','gorge':'Cross broken ground and defeat the sentries.'}.get(pattern,'Defeat the sentries and reach the sanctuary.'))
  out.append(dict(id=number,name='Monastery Approach' if number==1 else REGIONS[biome]+' — '+NAMES[slot]+' '+str(chapter+1),theme=THEMES[biome],biome=biome,difficulty='normal' if number<6 else 'hard',width=width,height=height,spawn=spawn,exit=exit,description=objective,objective=objective,platforms=surfaces,lifts=[],enemies=enemies,pickups=pickups,branch_links=[[i,i+1] for i in range(len(surfaces)-1)],route_order=list(range(len(surfaces))),chapter=chapter+1,chapter_name=REGIONS[biome],template=number,mission=mission,route_score=pattern+'-'+str(number),design_focus=objective,route_revision=3,vertical_route=pattern not in ['traverse','gorge','pilgrimage','boss'],traversal=pattern,devices=[]))
 add_devices(out)
 from underwater_route import apply_underwater
 apply_underwater(out,roster)
 for stage in out:
  if stage["id"]==11:
   stage["objective"]="Defeat every guard, stand on the cockpit pad for 2 seconds, and complete its arrow sequence to open the gate."
  elif stage["traversal"]=="swim":
   stage["objective"]="Swim to all three chamber pearls, then rise onto the dry eastern exit. Aquatic guards can be avoided."
  elif stage["mission"]=="seals":
   stage["objective"] += " Defeat every guard, including any hidden-realm resident; collect all three vows to open the gate."
  elif stage["mission"]!="boss":
   stage["objective"] += " Clear every guard as well as the named mechanism or relic before leaving." if stage["devices"] else " Clear every guard to open the gate."
  # Taller hero-sized exit needs an open outer apron below low ceilings.
  if stage["id"] in [12,28,52,78,88]:
   deck=stage["platforms"][stage["route_order"][-1]]
   previous=stage["platforms"][stage["route_order"][-2]]
   direction=1 if deck["center"][0]>previous["center"][0] else -1
   stage["exit"]=[deck["center"][0]+250*direction,deck["center"][1]]
   deck["center"][0]+=80*direction
   deck["width"]+=160
   stage["width"]=max(stage["width"],deck["center"][0]+deck["width"]/2+80)
  stage["gate_visual"]={"scale":[0.65,1.0],"offset":[0,-88],"size":[166.4,176.0]}
  stage["description"]=stage["objective"]
 return out

def add_devices(routes):
 for r in routes:
  slot=(r['id']-1)%10
  ps=r['platforms'];base=ps[min(3,len(ps)-2)];x,y=base['center']
  if slot==3:
   r['devices']=[dict(id='sun-core',type='relic_laser',position=[x-90,y-35],required=False),dict(id='sun-seal',type='laser_seal',position=[x+80,y],size=[34,100],required=True)]
   r['objective']='Take the Sun Core, aim X/G at the sealed prism, then reach the exit.'
  elif slot==6:
   r['devices']=[dict(id='cloud-seed',type='relic_cloud',position=[x-75,y-35],required=False),dict(id='cloud-loom',type='cloud_anchor',position=[x+60,y],landings=[[x+160,y-70,140],[x+320,y-140,140]],required=True)]
   r['pickups'].append(dict(position=[x+320,y-188],kind='seal',amount=1))
   r['objective']='Collect the cloud seed, awaken the loom with E, and retrieve the vow above its outer cloud.'
  elif slot==4:
   base_width=r['width'];px=base_width+340;py=max(p['center'][1] for p in ps)+260
   r['platforms'] += [dict(center=[px,py],width=400,optional=True,one_way=True,route=False,construction='rock',depth=32,beat='portal arrival',purpose='realm pocket arrival'),dict(center=[px+300,py-70],width=220,optional=True,one_way=True,route=False,construction='balcony',depth=24,beat='return machine',purpose='realm pocket return')]
   r['width']=px+470;r['height']=max(r['height'],py+300)
   other='sky' if r['biome']=='underground' else 'underground'
   r['realm_regions']=[dict(id='surface',biome=r['biome'],bounds=[0,0,base_width,r['height']],spawn=[x-60,y]),dict(id='underworld',biome=other,bounds=[base_width+80,py-250,750,550],spawn=[px-100,py])]
   r['devices']=[dict(id='realm-engine',type='portal',position=[x-60,y],destination='underworld',required=True),dict(id='realm-return',type='portal',position=[px+300,py-70],destination='surface',required=False)]
   r['branch_links'] += [[len(ps)-2,len(ps)-1]]
   source=dict(r['enemies'][0]);source.update(position=[px+60,py],monster_id=max(1,r['id']-1))
   roster=json.loads((ROOT/'game/data/monsters.json').read_text());source['kind']=roster[source['monster_id']-1]['kind'];r['enemies'].append(source)
   r['objective']='Use the realm engine to clear the hidden world, return, and recover the three vows.'
  elif slot in [5,7]:
   r['devices']=[dict(id='vent-'+str(i),type='fire_vent',position=[p['center'][0]+min(60,p['width']/4),p['center'][1]],required=False) for i,p in enumerate(ps) if i in [2,4] and p['width']>=240]
  r['description']=r['objective']
if __name__=='__main__':
 routes=build();(ROOT/'game/data/routes.json').write_text(json.dumps(routes,indent=2)+'\n');print('Wrote',len(routes),'directed world routes')
