"""Authored flooded-castle replacement; geometry uses real solid masonry."""
def apply_underwater(routes, roster):
 r=routes[7]
 def masonry(x,y,width,depth,purpose,route=False):
  return dict(center=[x,y],width=width,depth=depth,optional=False,one_way=False,route=route,construction='rock',beat=purpose,purpose=purpose)
 r.update(name='The Drowned Palace',biome='underground',theme='courtyard',width=3300,height=1850,spawn=[220,350],exit=[3060,350],traversal='swim',vertical_route=True,mission='seals',route_score='flooded-castle-8',water_bounds=[500,250,2400,1400],water_currents=[dict(center=[1140,1060],radius=220,strength=125,spin=1),dict(center=[2180,700],radius=250,strength=105,spin=-1),dict(center=[2670,1350],radius=180,strength=90,spin=1)],swim_waypoints=[[650,450],[880,650],[650,650],[650,950],[1050,1020],[1450,1270],[1640,850],[2100,750],[2500,950],[2780,450],[2850,315]],platforms=[masonry(260,350,480,180,'dry arrival',True),masonry(3050,350,300,180,'dry exit sanctuary',True),masonry(1200,250,120,650,'broken west partition'),masonry(1800,1000,140,650,'sunken east partition'),masonry(900,800,350,70,'first pearl chamber sill'),masonry(1450,1440,380,65,'deep reliquary floor'),masonry(2450,1150,750,90,'upper pearl chamber sill'),masonry(1700,1650,2400,120,'flooded castle bed')],route_order=[0,1],branch_links=[],lifts=[],devices=[])
 r['pickups']=[dict(position=p,kind='seal',amount=1) for p in [[880,650],[1450,1270],[2500,950]]]+[dict(position=p,kind='coin',amount=10) for p in [[700,470],[1050,1000],[1640,850],[2750,500]]]
 by_id={m['id']:m for m in roster}
 r['enemies']=[dict(position=p,kind=by_id[mid]['kind'],monster_id=mid,elite=False,health_bonus=0,skill='native',swim=True,swim_role=('jelly' if mid==81 else ('eel' if mid==46 else 'crab')),projectile_damage=10) for mid,p in [(8,[800,540]),(18,[1400,1150]),(25,[2200,850]),(46,[2550,1350]),(81,[2060,530])]]
 r['water_enemies']=[dict(e) for e in r['enemies']]
 r['objective']='Dive into the drowned palace, recover three pearls in separate chambers, then rise to the dry eastern gate. Steer around the whirlpools.'
 r['description']=r['objective'];r['design_focus']=r['objective']
