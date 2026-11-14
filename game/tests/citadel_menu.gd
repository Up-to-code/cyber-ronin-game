extends SceneTree
var failed := false
func _initialize() -> void:
 call_deferred("run")
func check(value: bool, message: String) -> void:
 if not value:
  push_error(message)
  failed = true
func run() -> void:
 var hud = load("res://ui/hud.gd").new()
 root.add_child(hud)
 await process_frame
 await process_frame
 check(hud.citadel.visible,"Title must show separate scenery")
 var before: float = hud.citadel.age
 await create_timer(0.2).timeout
 check(hud.citadel.age > before,"Menu must animate")
 var buttons: Node = hud.title_layout.get_node("StartActions")
 check(buttons.get_child_count() >= 4,"Title actions must stay available")
 if DisplayServer.get_name() != "headless":
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("/tmp/citadel-isolated.png")
 hud.close_menu()
 check(not hud.citadel.visible,"Artwork must hide during gameplay")
 hud.show_title()
 check(hud.citadel.visible,"Returning to title must restore artwork")
 hud.queue_free()
 await process_frame
 var model = load("res://systems/skill_inventory.gd").new()
 var inventory = load("res://ui/character_inventory.gd").new()
 inventory.setup(model,1250)
 root.add_child(inventory)
 await process_frame
 await process_frame
 check(inventory.rows.get_child_count() == 4,"All existing skill offers must remain available")
 if DisplayServer.get_name() != "headless":
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("/tmp/citadel-armory.png")
 inventory.queue_free()
 await process_frame
 print("Citadel menu transitions and motion: ", "FAIL" if failed else "PASS")
 quit(1 if failed else 0)
