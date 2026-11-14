extends SceneTree
func _initialize():call_deferred("run")
func tick():await physics_frame;await process_frame
func run():
 create_timer(12,true,false,true).timeout.connect(func():push_error("Water projectile timeout");quit(1))
 var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene);await process_frame
 scene._choose_level(8);await scene.level_loaded
 var p=scene.player;p.position=Vector2(700,580);p.invulnerable=999
 var enemy=get_nodes_in_group("enemies")[0]
 enemy.position=Vector2(900,580);enemy.set_physics_process(false)
 for other in get_nodes_in_group("enemies"):
  if other!=enemy:other.queue_free()
 await tick();await tick()
 var before=enemy.health
 Input.action_press("ranged_attack");await tick();Input.action_release("ranged_attack")
 for i in range(40):await tick()
 assert(enemy.health<before,"Swim input emits real swept damaging water projectile")
 p.position=Vector2(700,600);await tick()
 var fire=load("res://systems/combat_projectile.gd").new();fire.kind="fire";fire.position=Vector2(490,600);fire.direction=Vector2.RIGHT;fire.owner_body=p;scene.level_root.add_child(fire)
 for i in range(8):await tick()
 assert(not is_instance_valid(fire),"Fire crossing boundary quenches")
 root.get_node("Audio").shutdown();print("PASS input-fired water pulse damages aquatic enemy; incoming fire quenched at water boundary");quit()
