extends SceneTree
func _initialize():call_deferred("run")
func run():
 var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene);await process_frame
 scene.welcome_layer.hide()
 for number in range(1,101):
  scene._choose_level(number);await scene.level_loaded
  for enemy in get_nodes_in_group("enemies"):enemy.set_physics_process(false)
  scene.player.set_physics_process(false);scene.player.invulnerable=999
  var route: Array=scene.map.platforms.filter(func(p):return p.route)
  var samples=[scene.map.spawn,route[route.size()/2].center,scene.map.exit-Vector2(100,0)]
  for i in range(3):
   scene.player.position=samples[i];scene.camera_initialized=false
   for frame in range(3):await process_frame
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_jpg("res://../docs/qa/full-review/route-%03d-%d.jpg"%[number,i],.7)
  print("CAPTURE route ",number)
 root.get_node("Audio").shutdown();quit()
