extends SceneTree
func _initialize(): call_deferred("run")
func ticks(n: int):
 for i in range(n): await physics_frame; await process_frame
func run():
 create_timer(20,true,false,true).timeout.connect(func():quit(1))
 var scene=load("res://scenes/main.tscn").instantiate()
 root.add_child(scene)
 scene._choose_level(11)
 await scene.level_loaded
 for enemy in get_nodes_in_group("enemies"):enemy.set_physics_process(false)
 var floor_body:=StaticBody2D.new()
 floor_body.position=Vector2(587,742)
 scene._decorate_platform(floor_body,300)
 scene.level_root.add_child(floor_body)
 var p=scene.player
 p.position=Vector2(587,742);p.velocity=Vector2.ZERO
 await ticks(8)
 Input.action_press("jump")
 await ticks(35)
 Input.action_release("jump")
 await ticks(55)
 print("LANDING ",p.position," floor ",p.is_on_floor())
 assert(p.is_on_floor() and absf(p.position.y-572)<2,"Jump through balcony lands with feet at deck")
 if DisplayServer.get_name()!="headless":
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("/tmp/player-polish-landing.png")
 Input.action_press("move_right")
 p._start_attack()
 p._update_rig(0)
 assert(p.sword_motion=="moving_sword" and p.rig.current_clip=="moving_sword")
 await ticks(10)
 if DisplayServer.get_name()!="headless":
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("/tmp/player-polish-moving.png")
 Input.action_release("move_right")
 p.attack_time=0
 p.velocity.y=-400
 await ticks(3)
 p._start_attack();p._update_rig(0)
 assert(p.sword_motion=="air_sword" and p.rig.current_clip==p.current_attack_spec.clip)
 await ticks(10)
 if DisplayServer.get_name()!="headless":
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("/tmp/player-polish-air.png")
 root.get_node("Audio").shutdown()
 print("PASS: actual balcony jump-through landing, moving sword and aerial sword clips")
 quit()
