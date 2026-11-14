extends SceneTree
func _initialize():call_deferred("run")
func run():
 var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene);await process_frame
 scene._choose_level(2);await scene.level_loaded
 for enemy in get_nodes_in_group("enemies"):enemy.set_physics_process(false)
 scene.player.position=scene.map.exit-Vector2(100,0);scene.player.velocity=Vector2.ZERO;scene.camera_initialized=false
 for i in range(12):await physics_frame;await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://../docs/qa/exit-clearance-fixed.png")
 root.get_node("Audio").shutdown();quit()
