extends RefCounted
# Pure objective model shared by gate checks, HUD explanations and world guides.
# Live targets are dictionaries {position: Vector2, kind?: String, marked?: bool}.
static func describe(map: Dictionary, remaining: int, seals_left: int, marked_left: int, required_devices: Dictionary, sequencephase: String, submerged: bool) -> Dictionary:
 var state: Dictionary={"complete":false,"text":"","kind":"","required_ids":required_devices.keys()}
 if not required_devices.is_empty():
  for device in map.get("devices",[]):
   if not required_devices.has(str(device.id)):continue
   state.kind=str(device.type)
   match state.kind:
    "laser_seal":state.text="GATE LOCKED • Take the Sun Core, face the prism, press X / G."
    "cloud_anchor":state.text="GATE LOCKED • Take the Cloud Seed, press E at the loom, climb for its vow."
    "portal":state.text="GATE LOCKED • Press E at the realm engine; explore the hidden chamber and return."
    _:state.text="GATE LOCKED • Complete the marked mechanism."
   return state
 if seals_left>0:
  state.kind="seal"
  state.text=("RECOVER %d PEARLS • Swim through the castle chambers." if map.has("water_bounds") else ("RECOVER %d CLOUD VOW • Climb the grown clouds." if int(map.get("id",0))%10==7 else "RECOVER %d VOWS • Follow the marked relics."))%seals_left
  return state
 if map.get("traversal","")=="swim":
  state.kind="surface" if submerged else "exit"
  state.complete=not submerged
  state.text="PEARLS FOUND • Rise beside the eastern gate and swim onto dry ground." if submerged else "GATE OPEN • Leave through the eastern sanctuary."
  return state
 if int(map.get("id",0))==11 and sequencephase!="done":
  state.kind="sequence"
  state.text="GATE LOCKED • Stand on the cockpit pad for 2 seconds; follow its arrow sequence." if sequencephase=="idle" else "COCKPIT • Follow the displayed arrows. Wrong input restarts the sequence."
  return state
 var marked: bool=map.get("mission","purge") in ["boss","hunt"]
 var count: int=marked_left if marked else remaining
 if count>0:
  state.kind="boss" if marked else "enemy"
  state.text=("DEFEAT %d BOSS • The final arena is marked." if marked else "DEFEAT %d GUARDS • Follow the enemy marker, then return to the gate.")%count
  return state
 state.complete=true;state.kind="exit";state.text="GATE OPEN • Enter the marked sanctuary."
 return state

static func targets(map: Dictionary, state: Dictionary, live_enemies: Array=[], live_pickups: Array=[], player_position: Vector2=Vector2.ZERO, active_realm: String="surface", relic_charges: Dictionary={}) -> Array[Dictionary]:
 var result: Array[Dictionary]=[]
 var kind: String=state.get("kind","")
 if kind in ["laser_seal","cloud_anchor","portal"]:
  var wanted: String=kind
  if kind=="laser_seal" and int(relic_charges.get("laser",0))==0:wanted="relic_laser"
  if kind=="cloud_anchor" and int(relic_charges.get("cloud",0))==0:wanted="relic_cloud"
  for device in map.get("devices",[]):
   if device.type==wanted and (wanted in ["relic_laser","relic_cloud"] or str(device.id) in state.get("required_ids",[])):
    result.append({"position":device.position,"label":{"relic_laser":"TAKE SUN CORE","laser_seal":"FACE PRISM • X/G","relic_cloud":"TAKE CLOUD SEED","cloud_anchor":"GROW CLOUDS • E","portal":"ENTER REALM • E"}[wanted],"kind":wanted})
 elif kind in ["enemy","boss"]:
  for actor in live_enemies:
   if kind=="boss" and not actor.get("marked",false):continue
   result.append({"position":actor.position,"label":"BOSS" if kind=="boss" else "GUARD","kind":kind})
 elif kind=="seal":
  for pickup in live_pickups:
   if pickup.get("kind","")=="seal":result.append({"position":pickup.position,"label":"PEARL" if map.has("water_bounds") else "VOW","kind":"seal"})
 elif kind=="sequence":result.append({"position":map.exit-Vector2(160,0),"label":"COCKPIT • STAND 2s","kind":kind})
 else:
  result.append({"position":map.exit,"label":"RISE TO DRY EXIT" if kind=="surface" else "EXIT","kind":kind})
 result.sort_custom(func(a,b):return player_position.distance_squared_to(a.position)<player_position.distance_squared_to(b.position))
 # Cross-realm objectives point to the correct gateway, not through solid space.
 for i in range(result.size()):
  var destination: String="surface"
  for region in map.get("realm_regions",[]):
   if region.id!="surface" and region.bounds.has_point(result[i].position):destination=region.id
  if destination!=active_realm:
   for device in map.get("devices",[]):
    if device.type=="portal" and device.get("destination","")==destination:
     result[i]={"position":device.position,"label":"RETURN • E" if destination=="surface" else "HIDDEN GUARD • E","kind":"portal"}
     break
 return result
