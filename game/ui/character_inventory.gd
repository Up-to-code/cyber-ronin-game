extends Control
## Selection is a local preview. Only the explicit purchase action emits a write request.
signal purchase_requested(id: String)
signal closed
const Art = preload("res://ui/armory_art.gd")
const DESIGN := Vector2(1672,941)
const SKILLS := ["sword","tide","vitality","dash","heal","locked"]
const INVENTORY := ["gear_blade","gear_armor","gear_bracers","gear_boots","tide","heal"]
var mode := "all"
var model: RefCounted
var wallet := 0
var selected_id := "tide"
var previous_mode := ""
var canvas: Control
var scroll: ScrollContainer
var content: Control
var preview: Control
var close_button: Button
var replay_button: Button
var loop_button: Button
var _detail_tween: Tween
var buy_button: Button
var inventory_tab: Button
var skills_tab: Button
var coin_label: Label
var status_label: Label
var detail_title: Label
var detail_description: Label
var detail_state: Label
var detail_icon: TextureRect
var detail: TextureRect
var equipment: TextureRect
var tiles: Array[Button] = []
var badges: Array[Label] = []
var selected_frames: Array[Control] = []
var shown_ids: Array = []
var _background: TextureRect
var _frame: TextureRect
var _coin_art: TextureRect
var _portrait_stage: TextureRect
var _pattern: TextureRect
var _font: Font
func setup(inventory: RefCounted, coins: int) -> void:
 model=inventory
 wallet=coins
 if is_node_ready(): refresh(coins)
func _ready() -> void:
 process_mode=Node.PROCESS_MODE_ALWAYS
 mouse_filter=Control.MOUSE_FILTER_STOP
 texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 _font=Art.font()
 _background=_picture(self,load(Art.ROOT+"stage.png"),Rect2(Vector2.ZERO,size))
 _background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 _background.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
 scroll=ScrollContainer.new()
 scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
 scroll.follow_focus=true
 add_child(scroll)
 scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 content=Control.new()
 scroll.add_child(content)
 canvas=Control.new()
 canvas.mouse_filter=Control.MOUSE_FILTER_IGNORE
 content.add_child(canvas)
 canvas.size=DESIGN
 _portrait_stage=_picture(canvas,Art.atlas("stage",Rect2(0,0,835,941)),Rect2(0,0,835,941))
 _pattern=_picture(canvas,Art.atlas("stage",Rect2(835,0,836,941)),Rect2(835,0,837,941))
 preview=preload("res://ui/armory_preview.gd").new()
 canvas.add_child(preview)
 preview.position=Vector2(0,105)
 preview.size=Vector2(835,565)
 equipment=_picture(canvas,Art.atlas("chrome",Rect2(170,765,540,130)),Rect2(170,765,540,130))
 inventory_tab=_action("INVENTORY",Rect2(465,5,370,100),func():_switch_mode("inventory"))
 skills_tab=_action("SKILLS",Rect2(835,5,370,100),func():_switch_mode("skills"))
 close_button=_action("",Rect2(25,25,120,70),func():closed.emit())
 close_button.tooltip_text="Back · Escape"
 close_button.name="Back"
 _coin_art=_picture(canvas,Art.atlas("chrome",Rect2(1420,20,220,75)),Rect2(1420,20,220,75))
 _coin_art.name="CoinPlaque"
 coin_label=_label(canvas,"",42,Rect2(1485,22,145,65))
 replay_button=_action("REPLAY",Rect2(300,682,280,80),func():preview.replay())
 replay_button.name="Replay"
 loop_button=Button.new()
 loop_button.text=""
 loop_button.tooltip_text="Automatically repeat the selected demonstration"
 loop_button.add_theme_font_override("font",_font)
 loop_button.add_theme_font_size_override("font_size",29)
 loop_button.add_theme_color_override("font_color",Color("efce8e"))
 for state in ["normal","hover","pressed","focus"]:
  var style:=Art.outline(Color("c5a16b"),2 if state=="focus" else 1)
  loop_button.add_theme_stylebox_override(state,StyleBoxEmpty.new())
 canvas.add_child(loop_button)
 loop_button.position=Vector2(615,682)
 loop_button.size=Vector2(172,125)
 var loop_face:=Panel.new()
 loop_face.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var loop_style:=Art.outline(Color("a7844b"),1)
 loop_style.bg_color=Color(.035,.025,.05,.9)
 loop_face.add_theme_stylebox_override("panel",loop_style)
 loop_button.add_child(loop_face)
 loop_face.size=Vector2(172,80)
 var loop_focus:=Art.outline(Color("ffe1a0"),3)
 loop_focus.bg_color=loop_style.bg_color
 loop_button.focus_entered.connect(func():loop_face.add_theme_stylebox_override("panel",loop_focus))
 loop_button.focus_exited.connect(func():loop_face.add_theme_stylebox_override("panel",loop_style))
 _label(loop_button,"LOOP ON",28,Rect2(0,0,172,80)).name="Caption"
 loop_button.pressed.connect(func():
  preview.auto_replay=not preview.auto_replay
  (loop_button.get_node("Caption") as Label).text="LOOP ON" if preview.auto_replay else "LOOP OFF")
 for index in range(6):
  var tile:=Button.new()
  tile.name="Slot%d"%index
  tile.tooltip_text="Select to preview"
  tile.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
  for state in ["normal","hover","pressed","focus"]:tile.add_theme_stylebox_override(state,StyleBoxEmpty.new())
  canvas.add_child(tile)
  tile.size=Vector2(220,200)
  _picture(tile,Art.icon(index),Rect2(Vector2.ZERO,tile.size))
  var selected:=preload("res://ui/armory_selection.gd").new()
  selected.mouse_filter=Control.MOUSE_FILTER_IGNORE
  tile.add_child(selected)
  selected.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  selected_frames.append(selected)
  var badge:=_label(tile,"",29,Rect2(171,9,39,39))
  badge.add_theme_color_override("font_color",Color("ffe2a6"))
  badges.append(badge)
  tile.pressed.connect(_select_slot.bind(index))
  tile.focus_entered.connect(_update_selection)
  tile.focus_exited.connect(_update_selection)
  tiles.append(tile)
 detail=_picture(canvas,Art.atlas("chrome",Rect2(865,575,775,190)),Rect2(865,575,775,190))
 detail_icon=_picture(detail,Art.icon(1),Rect2(25,25,140,140))
 detail_title=_label(detail,"",40,Rect2(180,12,570,55))
 detail_description=_label(detail,"",29,Rect2(185,69,550,71))
 detail_description.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 detail_state=_label(detail,"",25,Rect2(185,139,550,38))
 buy_button=_action("",Rect2(1010,780,475,100),_buy_selected)
 buy_button.name="Buy"
 status_label=_label(canvas,"",27,Rect2(865,881,775,42))
 _frame=_picture(self,preload("res://art/menu-approved/frame.png"),Rect2(Vector2.ZERO,size))
 _frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 resized.connect(_layout)
 refresh(wallet)
 _layout()
 _wire_focus()
 focus_selection.call_deferred()
func focus_selection() -> void:
 if not is_visible_in_tree():return
 var index:=shown_ids.find(selected_id)
 if index>=0:tiles[index].grab_focus()
func _wire_focus() -> void:
 for index in tiles.size():
  var tile:=tiles[index]
  tile.focus_neighbor_left=tile.get_path_to(tiles[index-1] if index%3>0 else replay_button)
  tile.focus_neighbor_right=tile.get_path_to(tiles[index+1] if index%3<2 else tile)
  tile.focus_neighbor_top=tile.get_path_to(tiles[index-3] if index>=3 else skills_tab)
  tile.focus_neighbor_bottom=tile.get_path_to(tiles[index+3] if index<3 else buy_button)
 replay_button.focus_neighbor_right=replay_button.get_path_to(loop_button)
 loop_button.focus_neighbor_left=loop_button.get_path_to(replay_button)
 loop_button.focus_neighbor_right=loop_button.get_path_to(tiles[3])
 buy_button.focus_neighbor_top=buy_button.get_path_to(tiles[4])
 skills_tab.focus_neighbor_bottom=skills_tab.get_path_to(tiles[1])
 inventory_tab.focus_neighbor_bottom=inventory_tab.get_path_to(replay_button)
func _picture(parent: Node, texture: Texture2D, rect: Rect2) -> TextureRect:
 var picture:=TextureRect.new()
 picture.texture=texture
 picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 picture.mouse_filter=Control.MOUSE_FILTER_IGNORE
 parent.add_child(picture)
 picture.position=rect.position
 picture.size=rect.size
 return picture
func _label(parent: Node, text: String, font_size: int, rect: Rect2) -> Label:
 var label:=Label.new()
 label.text=text
 label.mouse_filter=Control.MOUSE_FILTER_IGNORE
 label.add_theme_font_override("font",_font)
 label.add_theme_font_size_override("font_size",font_size)
 label.add_theme_color_override("font_color",Color("f5dfb1"))
 label.add_theme_color_override("font_shadow_color",Color("140c0e"))
 label.add_theme_constant_override("shadow_offset_y",2)
 label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
 parent.add_child(label)
 label.position=rect.position
 label.size=rect.size
 return label
func _action(title: String, source: Rect2, callback: Callable) -> Button:
 var button:=Button.new()
 button.position=source.position
 button.size=source.size
 button.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
 button.tooltip_text=title.capitalize()
 for state in ["normal","hover","pressed","disabled"]:button.add_theme_stylebox_override(state,StyleBoxEmpty.new())
 button.add_theme_stylebox_override("focus",StyleBoxEmpty.new())
 canvas.add_child(button)
 var art:=_picture(button,Art.atlas("chrome",source),Rect2(Vector2.ZERO,source.size))
 var focus_line:=ColorRect.new()
 focus_line.color=Color("ffe6b2")
 focus_line.mouse_filter=Control.MOUSE_FILTER_IGNORE
 focus_line.position=Vector2(18,source.size.y-5)
 focus_line.size=Vector2(source.size.x-36,3)
 focus_line.hide()
 button.add_child(focus_line)
 button.focus_entered.connect(func():focus_line.show();art.modulate=Color(1.15,1.1,1.0))
 button.focus_exited.connect(func():focus_line.hide();art.modulate=Color.WHITE)
 button.mouse_entered.connect(func():art.modulate=Color(1.15,1.1,1.0))
 button.mouse_exited.connect(func():art.modulate=Color.WHITE)
 var label:=_label(button,title,42,Rect2(Vector2.ZERO,source.size))
 label.name="Caption"
 button.pressed.connect(callback)
 return button
func _switch_mode(next: String) -> void:
 mode=next
 refresh(wallet)
 (inventory_tab if mode=="inventory" else skills_tab).grab_focus()
func _catalog() -> Array:
 return INVENTORY if mode=="inventory" else SKILLS
func _offer(id: String) -> Dictionary:
 if model!=null:
  for offer in model.offers():
   if offer.id==id:return offer
 return {}
func _texture(id: String) -> Texture2D:
 var gear:= ["gear_blade","gear_armor","gear_bracers","gear_boots"].find(id)
 if gear>=0:return Art.atlas("chrome",Art.GEAR[gear])
 return Art.icon(SKILLS.find(id))
func refresh(coins: int, message: String="") -> void:
 var purchased:=coins<wallet and not message.is_empty()
 wallet=coins
 if canvas==null:return
 shown_ids=_catalog().duplicate()
 if previous_mode!=mode or not shown_ids.has(selected_id):
  selected_id="tide"
  previous_mode=mode
  preview.play_skill(selected_id)
 coin_label.text=str(wallet)
 inventory_tab.modulate=Color.WHITE if mode=="inventory" else Color(.75,.75,.8)
 skills_tab.modulate=Color(.75,.75,.8) if mode=="inventory" else Color.WHITE
 for index in range(6):
  var id: String=shown_ids[index]
  (tiles[index].get_child(0) as TextureRect).texture=_texture(id)
  var offer:=_offer(id)
  tiles[index].tooltip_text=str(offer.get("title",_title(id)))+" · Preview"
  tiles[index].set_meta("skill_id",id)
  badges[index].text="◆" if id.begins_with("gear_") else ("✓" if _owned(id) else "")
  badges[index].visible=not badges[index].text.is_empty()
 _show_details()
 _update_selection()
 if message!="":status_label.text=message
 if purchased:_purchase_feedback()
func _owned(id: String) -> bool:
 if id=="dash":return true
 if model==null:return false
 return int(model.ranks.get(id,model.charges.get(id,0)))>0
func _title(id: String) -> String:
 return {"dash":"DASH","locked":"SEALED ART","gear_blade":"RONIN KATANA","gear_armor":"RONIN ARMOR","gear_bracers":"ARMORED BRACERS","gear_boots":"TRAVEL BOOTS"}.get(id,id.to_upper())
func _select_slot(index: int) -> void:
 select_skill(str(shown_ids[index]))
func select_skill(id: String) -> void:
 if not shown_ids.has(id):return
 selected_id=id
 preview.play_skill(id)
 status_label.text=""
 _show_details()
 _update_selection()
 if is_instance_valid(_detail_tween):_detail_tween.kill()
 detail.modulate.a=.55
 _detail_tween=create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
 _detail_tween.tween_property(detail,"modulate:a",1.0,.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
 var index:=shown_ids.find(id)
 if index>=0:
  var art: Control=tiles[index].get_child(0)
  art.pivot_offset=art.size*.5
  var old: Tween=art.get_meta("pop") if art.has_meta("pop") else null
  if is_instance_valid(old):old.kill()
  art.scale=Vector2.ONE*1.035
  var pop:=create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
  art.set_meta("pop",pop)
  pop.tween_property(art,"scale",Vector2.ONE,.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
func _purchase_feedback() -> void:
 coin_label.modulate=Color(1.3,1.12,.7)
 var feedback:=create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
 feedback.tween_property(coin_label,"modulate",Color.WHITE,.35)
func _update_selection() -> void:
 for index in tiles.size():
  var active: bool=index<shown_ids.size() and shown_ids[index]==selected_id
  selected_frames[index].set("active",active)
  selected_frames[index].set("focused",tiles[index].has_focus())
  selected_frames[index].visible=active or tiles[index].has_focus()
func _show_details() -> void:
 var offer:=_offer(selected_id)
 preview.summary.text=""
 preview.damage_multiplier=1.0
 if model!=null and selected_id in ["sword","vitality"]:
  var rank: int=int(model.ranks[selected_id])
  var next_rank: int=rank if offer.get("capped",false) else rank+1
  if selected_id=="sword":preview.damage_multiplier=1.0+next_rank*.15
  preview.summary.text="DAMAGE  +%d%% → +%d%%"%[rank*15,next_rank*15] if selected_id=="sword" else "MAX HEALTH  %d → %d"%[100+rank*20,100+next_rank*20]
 detail_icon.texture=_texture(selected_id)
 detail_title.text=str(offer.get("title",_title(selected_id)))
 detail_description.text=str({"tide":"Q · 85 damage and knockback. Pack of 3.","heal":"H · Restore 55 health. Pack of 3.","sword":"Permanent +15% sword damage per rank.","vitality":"Permanent +20 max health per rank."}.get(selected_id,offer.get("description", "A quick evasive burst. Already learned." if selected_id=="dash" else ("This art is not available yet." if selected_id=="locked" else "Part of the ronin's current equipment."))))
 detail_state.text=str(offer.get("owned","LOCKED" if selected_id=="locked" else ("EQUIPPED" if selected_id.begins_with("gear_") else "CORE ABILITY")))
 buy_button.disabled=offer.is_empty() or bool(offer.get("capped",false)) or wallet<int(offer.get("price",0))
 var caption: String
 if offer.is_empty():caption="LOCKED" if selected_id=="locked" else ("EQUIPPED" if selected_id.begins_with("gear_") else "LEARNED")
 elif offer.capped:caption="COMPLETE" if model.ranks.has(selected_id) else "IN INVENTORY"
 else:caption="BUY · %d"%offer.price
 (buy_button.get_node("Caption") as Label).text=caption
 buy_button.tooltip_text="Need %d more coins"%maxi(0,int(offer.get("price",0))-wallet) if buy_button.disabled and not offer.is_empty() and not offer.capped else caption
 buy_button.modulate=Color(.65,.65,.65) if buy_button.disabled else Color.WHITE
 replay_button.disabled=selected_id=="locked"
func _buy_selected() -> void:
 var offer:=_offer(selected_id)
 if offer.is_empty() or offer.capped or wallet<int(offer.price):return
 purchase_requested.emit(selected_id)
func _layout() -> void:
 if canvas==null:return
 var inset:=Vector4(12,12,12,12)
 if OS.has_feature("mobile"):
  var device_safe:=Rect2(DisplayServer.get_display_safe_area())
  var local_safe: Rect2=get_viewport().get_screen_transform().affine_inverse()*device_safe
  inset=Vector4(maxf(12,local_safe.position.x),maxf(12,local_safe.position.y),maxf(12,size.x-local_safe.end.x),maxf(12,size.y-local_safe.end.y))
 var available:=size-Vector2(inset.x+inset.z,inset.y+inset.w)
 scroll.offset_left=inset.x;scroll.offset_top=inset.y;scroll.offset_right=-inset.z;scroll.offset_bottom=-inset.w
 if available.x<=0 or available.y<=0:return
 var portrait:=available.x<available.y*1.25
 _background.texture=Art.atlas("stage",Rect2(0,0,835,941)) if portrait else load(Art.ROOT+"stage.png")
 _portrait_stage.visible=portrait
 _pattern.position=Vector2(0,920) if portrait else Vector2(835,0)
 _pattern.size=Vector2(835,930) if portrait else Vector2(837,941)
 _coin_art.position=Vector2(580,125) if portrait else Vector2(1420,20)
 coin_label.position=Vector2(645,127) if portrait else Vector2(1485,22)
 var design:=Vector2(835,1850) if portrait else DESIGN
 var factor:=available.x/design.x if portrait else minf(available.x/design.x,available.y/design.y)
 content.custom_minimum_size=Vector2(available.x,design.y*factor) if portrait else available
 canvas.scale=Vector2.ONE*factor
 canvas.position=Vector2.ZERO if portrait else (available-DESIGN*factor)*.5
 scroll.vertical_scroll_mode=ScrollContainer.SCROLL_MODE_AUTO if portrait else ScrollContainer.SCROLL_MODE_DISABLED
 inventory_tab.position=Vector2(115,0) if portrait else Vector2(465,5)
 inventory_tab.size=Vector2(350,125) if portrait else Vector2(370,125)
 skills_tab.position=Vector2(465,0) if portrait else Vector2(835,5)
 skills_tab.size=Vector2(350,125) if portrait else Vector2(370,125)
 close_button.position=Vector2(25,140) if portrait else Vector2(25,25)
 close_button.size=Vector2(128,125)
 for index in range(6):
  tiles[index].position=Vector2(40+(index%3)*270,950+(index/3)*220) if portrait else Vector2(900+(index%3)*240,130+(index/3)*215)
 detail.position=Vector2(30,1410) if portrait else Vector2(865,575)
 buy_button.position=Vector2(180,1630) if portrait else Vector2(1010,780)
 buy_button.size.y=125
 replay_button.size.y=125
 status_label.position=Vector2(30,1770) if portrait else Vector2(865,881)
func _unhandled_key_input(event: InputEvent) -> void:
 if visible and event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_ESCAPE:
  get_viewport().set_input_as_handled()
  closed.emit()
