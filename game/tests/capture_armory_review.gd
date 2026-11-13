extends SceneTree
func _initialize():call_deferred("run")
func frame():
 for i in range(8):await physics_frame;await process_frame
 await RenderingServer.frame_post_draw
func run():
 var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene);await process_frame
 scene._choose_level(2);await scene.level_loaded
 for enemy in get_nodes_in_group("enemies"):enemy.set_physics_process(false)
 scene.player.position=Vector2(680,500);scene.camera_initialized=false
 await frame();root.get_texture().get_image().save_png("res://../docs/qa/normalized-monsters.png")
 scene._open_inventory()
 for i in range(5):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://../docs/qa/armory-integrated.png")
 scene._close_inventory()
 scene._choose_level(4);await scene.level_loaded
 for enemy in get_nodes_in_group("enemies"):enemy.take_damage(99999)
 scene.player.position=Vector2(1240,858);scene.camera_initialized=false
 await frame();root.get_texture().get_image().save_png("res://../docs/qa/gate-objective-guide.png")
 root.get_node("Audio").shutdown();quit()
