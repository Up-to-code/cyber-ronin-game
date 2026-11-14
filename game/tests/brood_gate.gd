extends SceneTree
func _initialize():call_deferred("run")
func ticks(n: int):
 for i in range(n):await physics_frame;await process_frame
func run():
 create_timer(12,true,false,true).timeout.connect(func():push_error("Brood test timeout");quit(1))
 var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene);await process_frame
 scene._choose_level(10);await scene.level_loaded
 var mother: Node2D
 for enemy in get_nodes_in_group("enemies"):
  enemy.set_physics_process(false)
  if enemy.is_boss:mother=enemy
 assert(is_instance_valid(mother) and mother.monster_id==10)
 var count=scene.remaining
 mother.take_damage(99999)
 await ticks(2)
 assert(scene.remaining==count+5,"Mother replaced by six children")
 assert(scene.marked_left==6,"Six brood keep boss objective locked")
 assert(not scene._objectives_met())
 var children=0
 for enemy in get_nodes_in_group("enemies"):
  if enemy.get_meta("brood_child",false):
   children+=1
   assert(enemy.health==22)
   enemy.take_damage(99999)
 assert(children==6)
 await ticks(2)
 assert(scene.marked_left==0)
 assert(scene._objectives_met())
 scene._choose_level(11);await scene.level_loaded
 assert(not scene._objectives_met(),"Sentinel still required")
 root.get_node("Audio").shutdown();print("PASS brood death spawn cap, health, required children gate, no recursion, sentinel objective");quit()
