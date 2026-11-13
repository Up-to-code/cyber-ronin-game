extends SceneTree
func _initialize():call_deferred("run")
func shot(name: String):
 for i in range(8):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/tmp/menu-redesign-"+name+".png")
func run():
 var scene=load("res://scenes/main.tscn").instantiate()
 root.add_child(scene)
 await shot("title")
 scene.hud._push("maps")
 await shot("world")
 scene.hud.campaign_map.focus_region(0)
 await shot("region")
 scene.hud.show_title()
 scene.hud._push("settings")
 await shot("settings")
 root.get_node("Audio").shutdown()
 quit()
