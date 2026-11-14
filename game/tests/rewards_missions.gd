extends SceneTree
func _initialize(): call_deferred("run")
func settle(scene,point: Vector2) -> void:
 scene.player.position=point+Vector2(0,45)
 for tick in range(3): await physics_frame
func run():
 create_timer(30,true).timeout.connect(func():push_error("Reward test timeout");quit(1))
 var scene=load("res://scenes/main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 scene.hud.settings_path="user://rewards-test.cfg"
 var seal_route: int = 0
 for number in range(1,101):
  var route: Dictionary = preload("res://data/campaign.gd").get_level(number)
  if route.get("mission","")=="seals" and route.get("devices",[]).is_empty() and not route.has("water_bounds") and seal_route==0: seal_route=number
 assert(seal_route>0,"Campaign must supply a seal fixture")
 scene._choose_level(seal_route)
 await scene.level_loaded
 scene.player.set_physics_process(false)
 scene.player.invulnerable=999
 for enemy in get_nodes_in_group("enemies"): enemy.set_physics_process(false)
 var seals: Array=[]
 var coin: Node
 for item in get_nodes_in_group("world_pickups"):
  if item.kind=="seal": seals.append(item)
  elif item.kind=="coin": coin=item
 var initial: int=scene.coins
 var value: int=coin.amount
 await settle(scene,coin.position)
 assert(scene.coins==initial+value)
 for tick in range(4):await physics_frame
 assert(scene.coins==initial+value,"Pickup must award once")
 scene.remaining=0
 scene._check_gate()
 assert(not scene.gate_opening,"Seals must gate mission completion")
 for seal in seals: await settle(scene,seal.position)
 assert(scene.seals_left==0 and scene.gate_opening)
 var at: Vector2=scene.player.position+Vector2(0,-45)
 scene._spawn_pickup("health",20,at)
 for tick in range(3):await physics_frame
 assert(scene.player.health==scene.player.max_health)
 scene.player.health=scene.player.max_health-10
 for tick in range(3):await physics_frame
 assert(scene.player.health==scene.player.max_health,"Healing must clamp and remain available at full health")
 scene._bank_rewards()
 var saved:=ConfigFile.new()
 assert(saved.load(scene.hud.settings_path)==OK)
 assert(saved.get_value("progress","coins")==scene.coins)
 # Hunt remains a supported rule even when no authored route uses it.
 var hunt_fixture: Dictionary = preload("res://data/campaign.gd").get_level(1).duplicate(true)
 hunt_fixture.mission="hunt"
 hunt_fixture.enemies[0]["captain"]=true
 scene._populate_level(hunt_fixture)
 scene.player.set_physics_process(false)
 for enemy in get_nodes_in_group("enemies"):
  enemy.set_physics_process(false)
  if enemy.has_meta("marked"): enemy.take_damage(9999)
 assert(scene.remaining>0 and scene._objectives_met() and scene.gate_opening,"Hunt requires only marked captain")
 scene._choose_level(20)
 await scene.level_loaded
 assert(scene.player.laser_unlocked)
 assert(scene.coins==scene.banked_coins)
 root.get_node("Audio").shutdown()
 DirAccess.remove_absolute(ProjectSettings.globalize_path("user://rewards-test.cfg"))
 print("PASS: physical pickups, one-time coins, capped healing, saved checkpoint wallet, seals and captain mission gates")
 quit()
