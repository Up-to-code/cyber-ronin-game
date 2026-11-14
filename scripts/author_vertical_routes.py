"""Author the ten route families with primary traversal and explicit optional branches."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
old=json.loads((root/'game/data/route_templates.json').read_text())
ys={1:[620,550,480,550,620,550,480,410,410],2:[420,490,560,630,630,560,490,420,350],3:[650,580,510,440,440,510,580,510,440],4:[700,630,560,490,420,350,420,490,420],5:[520,450,380,450,520,590,520,450,380],6:[650,580,510,580,650,580,510,440,370],8:[350,420,490,560,630,560,490,420,350],9:[600,530,460,390,460,530,460,390,320]}
widths=[400,260,500,260,560,260,560,260,420]
for m in old:
 i=m['id']
 if i==7:
  for p in m['platforms']:p.update(route=True,construction='rock',depth=40)
  m['platforms'][0]['construction']='arch';m['platforms'][-1]['construction']='arch'
  m['enemies']=[e for e in m['enemies'] if e['kind']!='tengu']
  m['enemies'].append(dict(position=[680,1280],kind='tengu',elite=False,health_bonus=30))
  continue
 platforms=[];x=0
 heights=ys.get(i,[650,580,510,440,510,580])
 sizes=widths if i!=10 else [400,260,260,400,260,1100]
 for n,(w,y) in enumerate(zip(sizes,heights)):
  if n:x+=50
  construction=('rock' if m['theme']=='bamboo' else 'arch') if w>=400 else 'balcony'
  platforms.append(dict(center=[x+w/2,y],width=w,optional=False,one_way=construction=='balcony',route=True,construction=construction,depth=40,beat='arrival' if n==0 else ('combat terrace' if w>=500 else 'recover ledge')))
  x+=w
 m['width']=x;m['spawn']=[150,heights[0]];m['exit']=[x-120,heights[-1]];m['height']=1100;m['lifts']=[]
 enemies=[]
 decks=[n for n,p in enumerate(platforms) if p['width']>=500]
 pool={1:['guard','guard','tengu'],2:['fire','guard','tengu'],3:['lancer','lantern','tengu'],4:['tengu','fire','lancer'],5:['obsidian','wraith','tengu'],6:['fire','obsidian','lantern'],8:['obsidian','lantern','tengu'],9:['lancer','impostor','tengu'],10:['guard','sentinel']}
 for n,index in enumerate(decks):
  p=platforms[index]
  for k in range(2):
   enemies.append(dict(position=[p['center'][0]-100+k*220,p['center'][1]],kind=pool[i][n%len(pool[i])] if k==0 else ('tengu' if i>1 and n==1 else 'guard'),elite=False,health_bonus=0))
 if i==10:
  # Last record remains the boss anchor consumed by build_campaign.py.
  enemies[-1]['kind']='obsidian'
  arena=platforms[-1];cx,cy=arena['center']
  extras=[(cx-300,cy-80,220),(cx,cy-160,240),(cx+300,cy-80,220)]
 else:
  p=platforms[4];cx,cy=p['center']
  extras=[(cx+20,cy-80,160),(cx+190,cy-160,160)]
 m['branch_links']=[[len(platforms)-1,len(platforms)],[len(platforms),len(platforms)+1],[len(platforms)+1,len(platforms)+2]] if i==10 else [[4,len(platforms)],[len(platforms),len(platforms)+1]]
 for bx,by,bw in extras:
  platforms.append(dict(center=[bx,by],width=bw,optional=True,one_way=True,route=False,construction='balcony',depth=24,beat='upper reward route'))
 if i!=10 and heights[1]<=heights[0]:
  j=len(platforms)
  platforms.append(dict(center=[530,heights[0]+90],width=280,optional=True,one_way=True,route=False,construction='rock',depth=24,beat='lower recovery ledge'))
  m['branch_links'].extend([[0,j],[j,0]])
 m['platforms']=platforms;m['enemies']=enemies
(root/'game/data/route_templates.json').write_text(json.dumps(old,indent=2)+'\n')
