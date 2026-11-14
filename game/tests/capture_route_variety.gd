extends SceneTree
func _initialize():call_deferred("run")
func run():
 var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene)
 await process_frame
 for number in [1,17,42,88]:
  scene._choose_level(number);await scene.level_loaded
  for enemy in get_nodes_in_group("enemies"):enemy.set_physics_process(false)
  var route: Array=scene.map.platforms.filter(func(p):return p.get("route",false))
  scene.player.position=route[mini(3,route.size()-1)].center
  scene.player.velocity=Vector2.ZERO;scene.player.invulnerable=999
  scene.camera_initialized=false
  for i in range(15):await physics_frame;await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://../docs/qa/route-redesign-%d.png"%number)
 root.get_node("Audio").shutdown();quit()
