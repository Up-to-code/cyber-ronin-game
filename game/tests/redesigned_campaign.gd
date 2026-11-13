extends SceneTree
const Campaign=preload("res://data/campaign.gd")
func _initialize():
 var roster: Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/monsters.json"))
 var signatures: Dictionary={};var worlds: Dictionary={};var shapes: Dictionary={}
 var climbs:=0;var drops:=0;var turns:=0;var pockets:=0
 for level in Campaign.levels():
  var route: Array=level.platforms.filter(func(p):return p.route)
  var signature: Array=[]
  var prior_direction:=0.0
  var introduced:=false
  for i in range(route.size()):
   var p: Dictionary=route[i]
   assert(not p.purpose.is_empty())
   if level.biome=="sky":assert(p.construction=="cloud" and p.one_way)
   if i:
    var delta: Vector2=p.center-route[i-1].center
    if delta.y<0:climbs+=1
    if delta.y>0:drops+=1
    if prior_direction!=0 and signf(delta.x)!=prior_direction:turns+=1
    prior_direction=signf(delta.x)
    signature.append([p.width,delta.x,delta.y])
  assert(not signatures.has(str(signature)),"No duplicate directed geometry")
  signatures[str(signature)]=true;worlds[level.biome]=true;shapes[level.traversal]=true
  assert(level.route_revision==3 and level.route_order.size()==route.size())
  for guard in level.enemies:
   assert(guard.monster_id>=1 and guard.monster_id<=100)
   assert(guard.kind==roster[guard.monster_id-1].kind)
   if guard.monster_id==level.id:introduced=true
  assert(introduced,"Every level introduces its own roster identity")
  if int(level.id)%10==0:
   assert(level.enemies.back().boss)
   assert(level.enemies.back().position.distance_to(route.back().center)<150)
  if int(level.id)%10==7:
   var vows: Array=level.pickups.filter(func(p):return p.kind=="seal")
   assert(vows.size()==1)
   var outer: Array=level.devices[1].landings[-1]
   assert(vows[0].position==Vector2(outer[0],outer[1]-48))
  if level.has("realm_regions"):
   pockets+=1
   assert(level.realm_regions.size()==2 and level.devices.size()==2)
   assert(level.realm_regions[0].spawn.distance_to(level.devices[0].position)<1)
   assert(level.realm_regions[1].bounds.has_point(level.realm_regions[1].spawn))
  for p in level.platforms:
   if p.optional:assert("realm pocket" in p.purpose)
 assert(signatures.size()==100 and worlds.size()==4 and shapes.size()==11)
 assert(climbs>200 and drops>150 and turns>=50 and pockets==10)
 assert(Campaign.get_level(1).biome=="surface" and Campaign.get_level(2).biome=="underground" and Campaign.get_level(3).biome=="sky")
 print("PASS 100 unique directed routes;4 worlds;11 traversal patterns;",climbs," rises,",drops," drops,",turns," reversals;10 portal pockets;100 introductions;10 finale bosses")
 quit()
