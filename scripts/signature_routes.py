"""Four singular, hand-authored encounter spaces; no repeated signature power."""
PLANS={
12:('Mirror Scriptorium','echo','Your attacks leave delayed echoes. Strike, then leave your old position.',[(200,650,400),(820,650,720),(1360,590,240),(1790,650,500),(2230,605,300)],[(900,555,200),(1170,515,160)],1),
24:('The Severed Thread','tether','Cut the glowing knot with J, or dash free before the tether pulls you back.',[(200,650,400),(650,590,380),(1160,650,520),(1710,580,440),(2220,650,460)],[(1150,560,240)],2),
37:('Glass Vow Duel','glass','Bait the guarded monk into a strike. Punish recovery, or break the guard with a kick.',[(200,650,400),(570,600,220),(1050,600,620),(1510,660,220),(1910,600,460)],[(1050,520,180)],2),
58:('Garden of Sleeping Embers','garden','Footsteps awaken planted embers. Jump over the bloom or take the upper trellises.',[(200,650,400),(710,650,500),(1310,650,560),(1880,590,460),(2330,650,320)],[(640,570,220),(930,510,220),(1230,565,220)],2),
}
def apply(routes):
 for number,(title,mode,objective,primary,branches,arena) in PLANS.items():
  r=routes[number-1]
  platforms=[]
  for i,(x,y,w) in enumerate(primary):
   platforms.append(dict(center=[x,y],width=w,optional=False,one_way=w<300,route=True,construction='balcony' if w<300 else 'rock',depth=40,beat=['approach','escape runway' if mode=='echo' else 'tactical approach','signature arena','recovery crossing','exit sanctuary'][i]))
  for x,y,w in branches:platforms.append(dict(center=[x,y],width=w,optional=True,one_way=True,route=False,construction='balcony',depth=24,beat='counter route'))
  first=dict(r['enemies'][0]);first.update(position=list(primary[arena][:2]),monster_id=number,signature=mode,elite=False,health_bonus=50)
  r.update(name=title,objective=objective,description=objective,design_focus=objective,width=primary[-1][0]+primary[-1][2]/2,height=1100,spawn=[150,650],exit=[primary[-1][0]+60,primary[-1][1]],platforms=platforms,lifts=[],enemies=[first],mission='purge',signature=mode,route_score='signature_'+mode)
  r['branch_links']=[[arena,5],[len(platforms)-1,min(arena+1,4)]]
  for i in range(5,len(platforms)-1):r['branch_links'].append([i,i+1])
  r['pickups']=[dict(position=[p['center'][0],p['center'][1]-28],kind='coin',amount=8 if p['optional'] else 4) for p in platforms[1:]]
