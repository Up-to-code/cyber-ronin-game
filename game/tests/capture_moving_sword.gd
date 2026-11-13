extends SceneTree
var scene: Node
func _initialize():call_deferred("run")
func ticks(n: int):
 for i in range(n): await physics_frame;await process_frame
func release():
 for action in ["move_left","move_right","attack","jump"]:Input.action_release(action)
func run():
 scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene)
 await process_frame
 scene._choose_level(11);await scene.level_loaded
 for enemy in get_nodes_in_group("enemies"):enemy.set_physics_process(false)
 var p=scene.player
 p.position=Vector2(1900,432);p.velocity=Vector2.ZERO;p.invulnerable=999
 scene.camera_initialized=false
 scene.hud.touch.hide()
 await ticks(25)
 for cycle in range(3):
  for frame in range(120):
   if frame==0:Input.action_press("move_right")
   if frame in [4,28,52,76]:Input.action_press("attack")
   if frame in [5,29,53,77]:Input.action_release("attack")
   if frame==20:Input.action_release("move_right");Input.action_press("move_left")
   if frame==54:Input.action_release("move_left");Input.action_press("move_right")
   if frame==81:release()
   if frame==88:Input.action_press("jump")
   if frame==100:Input.action_press("attack");Input.action_press("move_left")
   if frame==101:Input.action_release("attack")
   if frame==105:Input.action_release("jump")
   if frame==115:release()
   await ticks(1)
   if cycle==0 and frame in [12,32,63,105]:
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png("res://../docs/qa/moving-sword-%d.png"%frame)
  release();await ticks(30)
  p.position=Vector2(1900,432);p.velocity=Vector2.ZERO;p.reset_motion_presentation()
 release()
 root.get_node("Audio").shutdown();quit()
