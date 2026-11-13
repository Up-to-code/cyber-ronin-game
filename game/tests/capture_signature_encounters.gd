extends SceneTree
func _initialize():call_deferred("run")
func ticks(n: int):
 for i in range(n):await physics_frame;await process_frame
func run():
 var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene);await process_frame
 for number in [12,24,37,58]:
  scene._choose_level(number);await scene.level_loaded
  var enemy=get_nodes_in_group("enemies")[0]
  enemy.set_physics_process(false)
  scene.player.position=enemy.position-Vector2(140,0);scene.player.velocity=Vector2.ZERO;scene.player.invulnerable=999
  scene.hud.touch.hide();scene.camera_initialized=false
  await ticks(20)
  var rule=enemy.get_children().filter(func(n):return n.get_script()==load("res://systems/signature_encounter.gd"))[0]
  rule.clock=0
  if number==12:Input.action_press("attack")
  await ticks(1);Input.action_release("attack")
  await ticks(8)
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://../docs/qa/signature-%d.png"%number)
 root.get_node("Audio").shutdown();quit()
