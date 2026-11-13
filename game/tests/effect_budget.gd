extends SceneTree
func _initialize():call_deferred("run")
func run():
 var scene=load("res://scenes/main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 scene._choose_level(1)
 await scene.level_loaded
 for i in range(100):
  scene.fx.spawn("finisher_hit",Vector2(180,480),1)
  scene._spawn_projectile("energy",Vector2(180,480),Vector2.RIGHT,scene.player)
 assert(scene.fx.get_child_count()<=64)
 assert(get_nodes_in_group("combat_projectiles").size()<=48)
 var first=get_nodes_in_group("combat_projectiles")[0]
 var second=get_nodes_in_group("combat_projectiles")[1]
 assert(first.visual.sprite_frames==second.visual.sprite_frames,"Projectiles share animation frame resources")
 root.get_node("Audio").shutdown()
 print("PASS: bounded impact VFX, projectile cap and shared projectile animations")
 quit()
