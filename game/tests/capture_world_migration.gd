extends SceneTree
func _initialize():call_deferred("run")
func run():
 var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene);await process_frame
 for number in [1,2,3,4,5,10]:
  scene._choose_level(number);await scene.level_loaded
  for enemy in get_nodes_in_group("enemies"):enemy.set_physics_process(false)
  scene.player.invulnerable=999
  if number==10:
   for enemy in get_nodes_in_group("enemies"):
    if enemy.is_boss:scene.player.position=enemy.position+Vector2(-230,0);scene.camera_initialized=false
  if number==5:scene._enter_realm("underworld")
  for i in range(15):await physics_frame;await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://../docs/qa/world-migration-%d.png"%number)
 root.get_node("Audio").shutdown();quit()
