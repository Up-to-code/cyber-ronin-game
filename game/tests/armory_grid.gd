extends SceneTree
var failed:=false
var purchases: Array[String]=[]
func _initialize() -> void:call_deferred("run")
func check(value: bool, message: String) -> void:
 if not value:
  failed=true
  push_error(message)
func run() -> void:
 if "--portrait" in OS.get_cmdline_user_args():
  root.content_scale_size=Vector2i(360,640)
  root.size=Vector2i(540,960)
 var model=load("res://systems/skill_inventory.gd").new()
 var inventory=load("res://ui/character_inventory.gd").new()
 inventory.mode="skills"
 inventory.setup(model,1250)
 root.add_child(inventory)
 await process_frame
 await process_frame
 inventory.preview.set_process(false)
 inventory.purchase_requested.connect(func(id: String):
  purchases.append(id)
  var result: Dictionary=model.purchase(id,inventory.wallet)
  check(result.ok,"Explicit Buy must delegate to existing purchase rules")
  inventory.refresh(result.wallet,result.message))
 var original: Dictionary=model.export_state().duplicate(true)
 check(inventory.preview.rig.profile_id=="ronin_cel","Preview must share the real gameplay character")
 check(inventory.preview.viewport.world_2d!=root.world_2d,"Preview must own a separate world")
 check(get_nodes_in_group("player").is_empty() and get_nodes_in_group("enemies").is_empty(),"Preview must not enter gameplay groups")
 for id in ["sword","tide","heal","dash","vitality","locked"]:
  inventory.select_skill(id)
  inventory.preview.replay()
  inventory.preview._process(.2)
  check(model.export_state()==original and inventory.wallet==1250 and purchases.is_empty(),"Selection and replay must not spend currency or charges")
  if id in ["tide","heal"]:
   check(inventory.preview.fx.get_child_count()>0,"Preview must use live gameplay VFX")
  if id=="sword":check(inventory.preview.rig.current_clip.begins_with("sword"),"Sword selection must use authored gameplay cels")
  if id=="locked":
   inventory._buy_selected()
   check(purchases.is_empty() and inventory.buy_button.disabled,"Locked art must never be purchasable")
 inventory.select_skill("tide")
 inventory._buy_selected()
 check(inventory.wallet==1090 and model.charges.tide==3,"Buy must deduct exactly 160 and stock three charges")
 inventory._buy_selected()
 check(purchases.size()==1 and model.charges.tide==3,"Owned packs must not be purchased twice")
 inventory.select_skill("sword")
 inventory._buy_selected()
 check(inventory.wallet==910 and model.ranks.sword==1,"Training Buy must use existing rank pricing")
 inventory.refresh(0)
 inventory.select_skill("heal")
 inventory._buy_selected()
 check(purchases.size()==2 and model.charges.heal==0,"Insufficient funds must never emit a purchase")
 inventory._switch_mode("inventory")
 check(inventory.shown_ids.has("gear_armor"),"Inventory must include equipped-item inspections")
 inventory.select_skill("gear_armor")
 check(inventory.buy_button.disabled,"Equipped items must not pretend to offer unsupported purchases")
 for extent in [Vector2(640,360),Vector2(844,390),Vector2(1024,768),Vector2(320,568),Vector2(360,640)]:
  inventory.size=extent
  inventory._layout()
  var factor: float=inventory.canvas.scale.x
  var content_width: float=inventory.content.custom_minimum_size.x
  for tile in inventory.tiles:
   var end_x: float=inventory.canvas.position.x+(tile.position.x+tile.size.x)*factor
   check(end_x<=content_width+.1,"All icon columns must fit %s"%extent)
   check(tile.size.x*factor>=44,"Icon touch targets must remain usable")
  check(inventory.buy_button.size.y*factor>=44,"Buy touch target must remain usable")
  if extent.x<extent.y:
   check(inventory.scroll.vertical_scroll_mode==ScrollContainer.SCROLL_MODE_AUTO,"Tall layouts must scroll instead of clipping controls")
 inventory.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 inventory._layout()
 inventory._switch_mode("skills")
 inventory.refresh(1250)
 inventory.select_skill("tide")
 inventory.preview.replay()
 inventory.preview._process(.2)
 if DisplayServer.get_name()!="headless":
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("/tmp/armory-grid-portrait.png" if "--portrait" in OS.get_cmdline_user_args() else "/tmp/armory-grid-live.png")
 inventory.hide()
 await process_frame
 check(inventory.preview.viewport.render_target_update_mode==SubViewport.UPDATE_DISABLED,"Hidden preview must stop rendering")
 inventory.queue_free()
 await process_frame
 root.get_node("Audio").shutdown()
 print("Armory grid: ","FAIL" if failed else "PASS"," — preview isolation, live cels/VFX, explicit purchases, caps, tabs, responsive layout")
 quit(1 if failed else 0)
