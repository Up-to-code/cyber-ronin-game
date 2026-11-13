extends SceneTree
const Campaign=preload("res://data/campaign.gd")
const Guide=preload("res://systems/objective_tracker.gd")
func _initialize():
 for map in Campaign.levels():
  assert(not map.objective.is_empty())
  var required:Dictionary={};var seals:=0;var marked:=0
  for device in map.get("devices",[]):
   if device.get("required",false):required[str(device.id)]=true
  for pickup in map.pickups:
   if pickup.kind=="seal":seals+=1
  for guard in map.enemies:
   if not guard.get("swim",false):
    var supported:=false
    for deck in map.platforms:
     if absf(guard.position.y-deck.center.y)<4 and absf(guard.position.x-deck.center.x)<deck.width/2:supported=true
    assert(supported,"Required guards must stand on a purposeful reachable deck")
   if guard.get("boss",false) or guard.get("captain",false):marked+=1
  var sequence:String="idle" if int(map.id)==11 else "done"
  var state:Dictionary=Guide.describe(map,map.enemies.size(),seals,marked,required,sequence,map.traversal=="swim")
  assert(not state.complete and not state.text.is_empty())
  # Killing every actor must never bypass a device, vow, cockpit or water exit.
  var killed:Dictionary=Guide.describe(map,0,seals,0,required,sequence,map.traversal=="swim")
  if not required.is_empty() or seals>0 or int(map.id)==11:assert(not killed.complete)
  if not required.is_empty():
   var markers:Array=Guide.targets(map,killed,[],[],map.spawn,"surface",{})
   assert(not markers.is_empty() and not markers[0].label.is_empty())
  # Simulate required interactions and pickups in sequence, then gate eligibility.
  for device_id in required.keys():required.erase(device_id)
  seals=0;sequence="done"
  var complete:Dictionary=Guide.describe(map,0,seals,0,required,sequence,false)
  assert(complete.complete and complete.kind=="exit")
  var targets:Array=Guide.targets(map,complete)
  assert(targets.size()==1 and targets[0].position==map.exit)
 var sun:Dictionary=Campaign.get_level(4)
 var locked:Dictionary=Guide.describe(sun,0,0,0,{"sun-seal":true},"done",false)
 assert(locked.kind=="laser_seal" and "X / G" in locked.text)
 assert(Guide.targets(sun,locked,[],[],sun.spawn,"surface",{}).front().kind=="relic_laser")
 assert(Guide.targets(sun,locked,[],[],sun.spawn,"surface",{"laser":1}).front().kind=="laser_seal")
 var pocket:Dictionary=Campaign.get_level(5)
 var hunt:Dictionary=Guide.describe(pocket,1,0,0,{},"done",false)
 var hidden:Array=Guide.targets(pocket,hunt,[{"position":pocket.enemies.back().position}],[],pocket.spawn)
 assert(hidden.front().kind=="portal" and hidden.front().position==pocket.devices[0].position)
 var wet:Dictionary=Campaign.get_level(8)
 assert(not Guide.describe(wet,0,0,0,{},"done",true).complete)
 assert(Guide.describe(wet,5,0,0,{},"done",false).complete)
 print("PASS 100 objective state machines; no kill-only puzzle bypass; Sun Core guidance; hidden-realm routing; dry underwater exit")
 quit()
