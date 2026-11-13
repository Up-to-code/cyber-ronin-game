extends SceneTree
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1152,648)
 var model=load("res://systems/skill_inventory.gd").new();model.purchase("sword",1000);model.purchase("tide",1000)
 var ui=load("res://ui/character_inventory.gd").new();ui.setup(model,850);root.add_child(ui)
 for i in range(5):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://../docs/qa/inventory-native.png")
 root.get_node("Audio").shutdown();quit()
