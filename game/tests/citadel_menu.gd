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
 check(hud.title_view.buttons.size() == 4,"Three primary actions and settings must match reference")
 # Exercise layout directly without changing project orientation or window settings.
 var menu: Control = hud.title_view
 check(menu.primary.name=="Start","Main action must be START")
 for extent in [Vector2(640,360),Vector2(844,390),Vector2(320,568),Vector2(360,640),Vector2(1024,768)]:
  menu.size=extent
  menu._layout()
  for button in menu.buttons:
   var rect: Rect2=Rect2(menu.canvas.position+button.position*menu.canvas.scale,button.size*menu.canvas.scale)
   check(Rect2(Vector2.ZERO,extent).encloses(rect),"Menu controls must fit %s"%extent)
   check(rect.size.y>=40,"Menu targets must remain usable at %s"%extent)
 menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 menu._layout()
 if DisplayServer.get_name() != "headless":
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("/tmp/citadel-isolated.png")
 hud._push("settings")
 await process_frame
 check(not hud.citadel.visible,"Settings must not leave title art over its controls")
 hud._back()
 await process_frame
 check(hud.title_view.visible,"Back must restore the three-button menu")
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
 check(inventory.tiles.size() == 6,"The selected reference has six selectable icons")
 if DisplayServer.get_name() != "headless":
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("/tmp/citadel-armory.png")
 inventory.mode="skills"
 inventory.refresh(1250)
 check(inventory.shown_ids.has("sword") and inventory.shown_ids.has("vitality"),"Skills must show permanent training")
 inventory.mode="inventory"
 inventory.refresh(1250)
 check(inventory.shown_ids.has("heal") and inventory.shown_ids.has("tide"),"Inventory must show consumable packs")
 inventory.queue_free()
 await process_frame
 var game = load("res://scenes/main.tscn").instantiate()
 root.add_child(game)
 await process_frame
 game.hud.armory_requested.emit()
 check(game.inventory_screen.visible,"Inventory must open from the paused title")
 check(game.inventory_screen.mode=="inventory","Inventory action must select inventory")
 game.inventory_screen.closed.emit()
 check(paused,"Closing title inventory must keep the world paused")
 game.hud.skills_requested.emit()
 check(game.inventory_screen.visible and game.inventory_screen.mode=="skills","Skills must open its own offer view")
 game.inventory_screen.closed.emit()
 if DisplayServer.get_name() != "headless":
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("/tmp/approved-menu-live.png")
 game.queue_free()
 paused=false
 await process_frame
 root.get_node("Audio").shutdown()
 print("Citadel menu transitions and motion: ", "FAIL" if failed else "PASS")
 quit(1 if failed else 0)
