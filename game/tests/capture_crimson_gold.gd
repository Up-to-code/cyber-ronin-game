extends SceneTree
func _initialize():call_deferred("run")
func shot(label: String):
 for i in range(10): await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://../docs/qa/crimson-gold-"+label+".png")
func run():
 var scene=load("res://scenes/main.tscn").instantiate()
 root.add_child(scene)
 await shot("menu")
 scene._choose_level(11)
 await scene.level_loaded
 for enemy in get_nodes_in_group("enemies"):enemy.set_physics_process(false)
 scene.player.position=scene.sequence_machine.position
 scene.player.velocity=Vector2.ZERO
 scene.camera_initialized=false
 for i in range(150):await physics_frame
 await shot("machine")
 var machine=scene.sequence_machine
 machine.phase="input"
 machine.lift=90
 for action in machine.SEQUENCE:machine.submit(action)
 for i in range(20):await physics_frame
 await shot("laser")
 scene.pause_game()
 await shot("pause")
 root.get_node("Audio").shutdown()
 quit()
