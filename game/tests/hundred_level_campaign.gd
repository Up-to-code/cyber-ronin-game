extends SceneTree
const Campaign=preload("res://data/campaign.gd")
func _initialize(): call_deferred("run")
func run():
 create_timer(150,true).timeout.connect(func(): push_error("Campaign test timed out");quit(1))
 var scene=load("res://scenes/main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 scene.hud.settings_path="user://campaign100-test.cfg"
 var bosses:=0
 var last_health:=0
 for index in range(1,101):
  scene._choose_level(index)
  await scene.level_loaded
  assert(scene.level==index and scene.remaining==scene.map.enemies.size())
  assert(scene.player.laser_unlocked==(index>=20))
  var count:=0
  for enemy in get_nodes_in_group("enemies"):
   enemy.set_physics_process(false)
   if enemy.is_boss:
    count+=1
    bosses+=1
    assert(enemy.health>last_health)
    last_health=enemy.health
  assert(count==(1 if index%10==0 else 0))
  assert(not scene._objectives_met())
  assert(scene.seals_left==(3 if scene.map.mission=="seals" else 0))
  for tick in range(6): await physics_frame
  assert(scene.player.is_on_floor())
  assert(get_nodes_in_group("world_pickups").size()==scene.map.pickups.size())
  if index%10==0: print("PASS: chapter ",index/10," loads; boss ",index," health ",last_health)
 assert(bosses==10 and scene.hud.campaign_names.size()==100)
 assert(scene.hud.progress_label.text.contains("100 / 100"))
 root.get_node("Audio").shutdown()
 print("PASS: 100 runtime levels, 10 scaling bosses, pickups, missions, player upgrade and HUD progress")
 quit()
