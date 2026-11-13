extends SceneTree
func _initialize():call_deferred("run")
func run():
 create_timer(90,true,false,true).timeout.connect(func():push_error("Migration runtime timeout");quit(1))
 var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene);await process_frame
 for number in range(1,101):
  scene._choose_level(number);await scene.level_loaded
  assert(scene.map.id==number)
  var introduced=false
  var boss_count=0
  for enemy in get_nodes_in_group("enemies"):
   assert(enemy.rig!=null and enemy.contract!=null)
   assert(ResourceLoader.exists("res://art/monster-migration/%03d.png"%enemy.monster_id))
   if enemy.monster_id==number:introduced=true
   if enemy.is_boss:boss_count+=1
  assert(introduced,"Each route introduces matching identity")
  assert(boss_count==(1 if number%10==0 else 0))
  assert(scene.remaining==scene.map.enemies.size())
  scene.player.grant_relic("laser")
  scene.player.use_relic_laser()
 root.get_node("Audio").shutdown();print("PASS100 runtime loads, monster identity/art/contracts,10 boss assignments, retry beam cleanup");quit()
