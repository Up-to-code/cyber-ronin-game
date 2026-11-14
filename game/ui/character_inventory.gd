extends Control
signal purchase_requested(id: String)
signal closed
const Kit=preload("res://ui/pixel_menu_components.gd")
var model: RefCounted
var wallet:=0
var coin_label: Label
var status_label: Label
var stats: Label
var rows: VBoxContainer
var columns: BoxContainer
var preview_host: Control
var preview: Node2D
var close_button: Button
var age:=0.0
var selected_id:=""
func setup(inventory: RefCounted, coins: int) -> void:
 model=inventory;wallet=coins
 if is_node_ready():refresh(coins)
func _ready() -> void:
 process_mode=Node.PROCESS_MODE_ALWAYS
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 theme=Theme.new()
 theme.default_font=preload("res://art/pixel/PixelifySans.ttf")
 add_theme_color_override("font_color",Color("ffe4ac"))
 var shade:=ColorRect.new();shade.color=Color(.035,.015,.035,.96);add_child(shade);shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var margin:=MarginContainer.new();add_child(margin);margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 for side in ["left","right","top","bottom"]:margin.add_theme_constant_override("margin_"+side,12)
 var panel:=PanelContainer.new();panel.add_theme_stylebox_override("panel",Kit.frame());margin.add_child(panel)
 var stack:=VBoxContainer.new();panel.add_child(stack);stack.add_theme_constant_override("separation",8)
 var header:=HBoxContainer.new();stack.add_child(header)
 var title:=_label("RONIN • ARMORY",22);title.size_flags_horizontal=Control.SIZE_EXPAND_FILL;header.add_child(title)
 close_button=_button("CLOSE · ESC");close_button.pressed.connect(func():closed.emit());header.add_child(close_button)
 coin_label=_label("",16);stack.add_child(coin_label)
 columns=BoxContainer.new();columns.size_flags_vertical=Control.SIZE_EXPAND_FILL;columns.add_theme_constant_override("separation",18);stack.add_child(columns)
 var left:=VBoxContainer.new();left.custom_minimum_size.x=150;columns.add_child(left)
 preview_host=Control.new();preview_host.custom_minimum_size=Vector2(150,120);preview_host.size_flags_vertical=Control.SIZE_EXPAND_FILL;left.add_child(preview_host)
 preview=preload("res://animation/cel_actor_visual.gd").new();preview_host.add_child(preview);preview.configure("ronin_cel")
 stats=_label("",14);left.add_child(stats)
 var scroll:=ScrollContainer.new();scroll.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;scroll.follow_focus=true;columns.add_child(scroll)
 rows=VBoxContainer.new();rows.size_flags_horizontal=Control.SIZE_EXPAND_FILL;rows.add_theme_constant_override("separation",10);scroll.add_child(rows)
 status_label=_label("Permanent training stays. Packs contain exactly 3 uses.",13);status_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;stack.add_child(status_label)
 resized.connect(_layout);_layout();refresh(wallet);close_button.grab_focus()
func _label(text: String, size: int) -> Label:
 var label:=Label.new();label.text=text;label.add_theme_font_size_override("font_size",size);return label
func _button(text: String) -> Button:
 var button:=Button.new();button.text=text;button.custom_minimum_size.y=38;button.add_theme_font_size_override("font_size",14)
 for state in ["normal","hover","pressed","focus","disabled"]:button.add_theme_stylebox_override(state,Kit.button_style(state in ["hover","focus"],true,state=="pressed"))
 return button
func _layout() -> void:
 if columns:columns.vertical=size.x<480
func refresh(coins: int, message: String="") -> void:
 wallet=coins
 if not is_instance_valid(rows) or model==null:return
 coin_label.text="COINS  %d"%wallet
 stats.text="SWORD  +%d%%\nHEALTH  %d\nQ NOVA  %d / 3\nH ELIXIR  %d / 3"%[int(model.ranks.sword)*15,100+int(model.ranks.vitality)*20,model.charges.tide,model.charges.heal]
 for child in rows.get_children():child.free()
 for offer in model.offers():
  var card:=VBoxContainer.new();card.add_theme_constant_override("separation",3);rows.add_child(card)
  var title_row:=HBoxContainer.new();card.add_child(title_row)
  var icon:=TextureRect.new();icon.texture=load("res://art/pickups/health.png" if offer.id in ["vitality","heal"] else ("res://art/realm-relics/cloud.png" if offer.id=="tide" else "res://art/realm-relics/sun.png"));icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;icon.custom_minimum_size=Vector2(24,24);title_row.add_child(icon)
  var title:=_label(offer.title,16);title_row.add_child(title)
  var description:=_label(offer.description,13);description.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;card.add_child(description)
  card.add_child(_label(offer.owned,12))
  var button:=_button(("COMPLETE" if model.ranks.has(offer.id) else "PACK IN INVENTORY") if offer.capped else "BUY  ·  %d COINS"%offer.price)
  button.disabled=offer.capped or wallet<int(offer.price)
  button.tooltip_text=offer.description+" "+offer.owned
  button.pressed.connect(func():selected_id=offer.id;purchase_requested.emit(offer.id));card.add_child(button)
  if selected_id==offer.id and not button.disabled:button.grab_focus()
 if message!="":status_label.text=message
 if get_viewport().gui_get_focus_owner()==null:close_button.grab_focus()
func _process(delta: float) -> void:
 if not visible or not is_instance_valid(preview):return
 age+=delta
 preview.position=Vector2(preview_host.size.x*.5,preview_host.size.y*.77)
 preview.scale=Vector2.ONE*minf(1.05,preview_host.size.y/150)
 preview.update_pose(delta,"idle",1,Vector2.ZERO,true)
func _unhandled_key_input(event: InputEvent) -> void:
 if visible and event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_ESCAPE:
  get_viewport().set_input_as_handled();closed.emit()
