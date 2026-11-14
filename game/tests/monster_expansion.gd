extends SceneTree
var shots := 0
var effects: Array[String] = []
func _initialize(): call_deferred("run")
func run():
 var scene=load("res://scenes/main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 for kind in ["lantern","obsidian","tengu"]:
  scene._choose_level(5 if kind=="obsidian" else 3)
  await scene.level_loaded
  var chosen: Node
  for enemy in get_nodes_in_group("enemies"):
   enemy.set_physics_process(false)
   if enemy.monster_variant==kind: chosen=enemy
  assert(chosen!=null)
  assert(chosen.rig.profile_id==kind+"_pixel")
  chosen.target=scene.player
  scene.player.set_physics_process(false)
  scene.player.position=chosen.position+Vector2(80,0)
  scene.player.invulnerable=100
  chosen.facing=1
  chosen.windup=0.01
  chosen.cooldown=99
  chosen.projectile_requested.connect(func(_k,_p,_d,_s): shots+=1)
  chosen.fx_requested.connect(func(k,_p,_d): effects.append(k))
  shots=0
  effects.clear()
  chosen.set_physics_process(true)
  for tick in range(45): await physics_frame
  assert(shots==(3 if kind=="lantern" else (2 if kind=="obsidian" else 0)),"Distinct attack projectile count")
  assert(effects.has("fire_cast" if kind=="lantern" else ("aerial_land" if kind=="obsidian" else "finisher")))
  assert(chosen.health>=(95 if kind=="tengu" else 110))
 root.get_node("Audio").shutdown()
 print("PASS: generated monster profiles, health, revenant spread and oni impact VFX/projectiles")
 quit()
