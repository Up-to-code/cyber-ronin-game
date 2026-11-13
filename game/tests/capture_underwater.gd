extends SceneTree
func _initialize():call_deferred("run")
func run():
 var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene);await process_frame
 scene._choose_level(8);await scene.level_loaded
 scene.player.invulnerable=0
 for enemy in get_nodes_in_group("enemies"):enemy.set_physics_process(false)
 for n in range(3):
  scene.player.position=[Vector2(800,650),Vector2(1360,1230),Vector2(2160,650)][n]
  scene.player.velocity=Vector2.ZERO;scene.camera_initialized=false
  Input.action_press("move_right")
  for i in range(12):await physics_frame;await process_frame
  Input.action_release("move_right")
  if n==2:
   Input.action_press("ranged_attack");await physics_frame;await process_frame;Input.action_release("ranged_attack")
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://../docs/qa/underwater-%d.png"%n)
 root.get_node("Audio").shutdown();quit()
