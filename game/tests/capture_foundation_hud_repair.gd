extends SceneTree
func _initialize():call_deferred("run")
func run():
 var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene);await process_frame
 scene.welcome_layer.hide()
 for number in [3,6,26]:
  scene._choose_level(number);await scene.level_loaded
  scene.player.invulnerable=999;scene.player.set_physics_process(false)
  for enemy in get_nodes_in_group("enemies"):enemy.set_physics_process(false)
  scene.player.position=scene.map.exit-Vector2(100,0);scene.camera_initialized=false
  for frame in range(8):await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_jpg("res://../docs/qa/foundation-hud-%d.jpg"%number,.85)
 root.get_node("Audio").shutdown();quit()
