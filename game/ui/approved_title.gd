extends Control
## Reference-registered independent controls. Labels are live and localizable.
signal action_requested(action: String)
const DESIGN := Vector2(1672,941)
var resume_available := false
var canvas: Control
var logo: TextureRect
var primary: Button
var buttons: Array[Button] = []
func _ready() -> void:
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 canvas = Control.new()
 canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(canvas)
 canvas.size = DESIGN
 logo = TextureRect.new()
 var logo_atlas := AtlasTexture.new()
 logo_atlas.atlas = preload("res://art/menu-approved/logo.png")
 logo_atlas.region = Rect2(195,65,420,300)
 logo.texture = logo_atlas
 logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
 logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 canvas.add_child(logo)
 logo.size = Vector2(420,300)
 primary = _button("START", "play",Rect2(1138,248,485,151))
 primary.name = "Start"
 _button("INVENTORY","inventory",Rect2(1138,399,485,151)).name = "Inventory"
 _button("SKILLS","skills",Rect2(1138,554,485,153)).name = "Skills"
 _button("","settings",Rect2(1458,784,190,131)).name = "Settings"
 for index in buttons.size():
  var button := buttons[index]
  button.focus_neighbor_bottom = button.get_path_to(buttons[(index+1)%buttons.size()])
  button.focus_neighbor_top = button.get_path_to(buttons[posmod(index-1,buttons.size())])
 resized.connect(_layout)
 _layout()
func _button(title: String, action: String, region: Rect2) -> Button:
 var button := Button.new()
 button.tooltip_text = "Settings" if action == "settings" else title.capitalize()
 button.set_meta("accessible_description",button.tooltip_text)
 button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
 canvas.add_child(button)
 button.position = region.position
 button.size = region.size
 for state in ["normal","hover","pressed","focus"]:
  button.add_theme_stylebox_override(state,StyleBoxEmpty.new())
 var art := TextureRect.new()
 var atlas := AtlasTexture.new()
 atlas.atlas = preload("res://art/menu-approved/controls.png")
 atlas.region = region
 art.texture = atlas
 art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 art.mouse_filter = Control.MOUSE_FILTER_IGNORE
 button.add_child(art)
 art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 if not title.is_empty():
  var label := Label.new()
  label.text = title
  label.mouse_filter = Control.MOUSE_FILTER_IGNORE
  var font := SystemFont.new()
  font.font_names = PackedStringArray(["Baskerville","Times New Roman","serif"])
  label.add_theme_font_override("font",font)
  label.add_theme_font_size_override("font_size",44)
  label.add_theme_color_override("font_color",Color("f3dfb4"))
  label.add_theme_color_override("font_shadow_color",Color("22100b"))
  label.add_theme_constant_override("shadow_offset_y",2)
  label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
  button.add_child(label)
  label.position = Vector2(156,14)
  label.size = Vector2(310,120)
 var update := func():
  art.modulate = Color(1.22,1.14,1.04) if button.has_focus() or button.is_hovered() else Color.WHITE
 button.mouse_entered.connect(update)
 button.mouse_exited.connect(update)
 button.focus_entered.connect(update)
 button.focus_exited.connect(update)
 button.button_down.connect(func():art.modulate=Color(.8,.75,.7))
 button.button_up.connect(update)
 button.pressed.connect(func():action_requested.emit(action))
 buttons.append(button)
 return button
func _layout() -> void:
 if not is_instance_valid(canvas): return
 var safe := Rect2(Vector2(12,12),size-Vector2(24,24))
 if OS.has_feature("mobile"):
  var device_safe := Rect2(DisplayServer.get_display_safe_area())
  var local_safe: Rect2 = get_viewport().get_screen_transform().affine_inverse()*device_safe
  safe = safe.intersection(local_safe)
 if safe.size.x <= 0 or safe.size.y <= 0: return
 if safe.size.x < safe.size.y * 1.3:
  # A centered vertical stack keeps the same plaque art readable on tall screens.
  var factor := minf(safe.size.x/485.0,safe.size.y/941.0)
  canvas.scale = Vector2.ONE*factor
  canvas.position = safe.position+(safe.size-Vector2(485,941)*factor)*.5
  logo.position = Vector2(32.5,0)
  for index in range(3): buttons[index].position = Vector2(0,310+index*160)
  buttons[3].position = Vector2(295,800)
 else:
  # Maintain the approved composition and button proportions on landscape displays.
  var factor := minf(safe.size.x/DESIGN.x,safe.size.y/DESIGN.y)
  canvas.scale = Vector2.ONE*factor
  canvas.position = safe.position+(safe.size-DESIGN*factor)*.5
  logo.position = Vector2(195,65)
  buttons[0].position = Vector2(1138,248)
  buttons[1].position = Vector2(1138,399)
  buttons[2].position = Vector2(1138,554)
  buttons[3].position = Vector2(1458,784)
