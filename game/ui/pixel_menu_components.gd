extends RefCounted
## Shared pixel-art controls. Atlas regions can be replaced without changing HUD code.
const KIT := "res://art/pixel/ui-kit/components.json"
static func art(key: String, fallback: String) -> Texture2D:
	var direct := "res://art/pixel/ui-kit/" + key + ".png"
	if ResourceLoader.exists(direct): return load(direct)
	if FileAccess.file_exists(KIT):
		var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(KIT))
		if data is Dictionary and data.has("regions") and data.regions.has(key):
			var record: Array = data.regions[key]
			var texture := AtlasTexture.new()
			texture.atlas = load(str(data.atlas))
			texture.region = Rect2(record[0],record[1],record[2],record[3])
			return texture
	return load(fallback)
static func frame(key: String = "panel") -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = art(key,"res://art/pixel/button_selected.png")
	if key == "panel":
		var cropped := AtlasTexture.new()
		cropped.atlas = style.texture
		cropped.region = Rect2(4,12,120,116)
		style.texture = cropped
	style.texture_margin_left = 24
	style.texture_margin_right = 24
	style.texture_margin_top = 24
	style.texture_margin_bottom = 24
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 26
	style.content_margin_bottom = 20
	return style
static func button_style(pressed: bool = false, compact: bool = false) -> StyleBoxTexture:
	# Navigation buttons have their own box metrics; panel padding never belongs here.
	var style := StyleBoxTexture.new()
	style.texture=art("button_primary" if pressed else "button_secondary","res://art/pixel/button.png")
	style.texture_margin_left=30
	style.texture_margin_right=30
	style.texture_margin_top=18
	style.texture_margin_bottom=18
	style.content_margin_left=16 if compact else 28
	style.content_margin_right=16 if compact else 28
	style.content_margin_top=9
	style.content_margin_bottom=9
	return style

static func toggle(title: String, value: bool, callback: Callable) -> Button:
	var button := Button.new()
	button.text = title
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = Vector2(250,44)
	button.add_theme_font_size_override("font_size",17)
	button.set_meta("accessible_description", title + (": on" if value else ": off"))
	button.set_meta("pixel_component","toggle")
	button.set_meta("value",value)
	# Setting rows are flat; ornamental frames belong to navigation actions.
	for state in ["normal","hover","pressed","focus"]:
		var flat := StyleBoxFlat.new()
		flat.bg_color = Color(0.16,0.09,0.12,0.65) if state == "pressed" else Color.TRANSPARENT
		flat.content_margin_left = 12
		flat.content_margin_right = 76
		flat.content_margin_top = 8
		flat.content_margin_bottom = 8
		if state == "focus":
			flat.border_width_bottom = 1
			flat.border_color = Color("b84b55")
		button.add_theme_stylebox_override(state,flat)
	var icon: Control = preload("res://ui/pixel_switch_indicator.gd").new()
	icon.enabled = value
	button.add_child(icon)
	icon.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	icon.offset_left = -56
	icon.offset_right = -12
	icon.offset_top = -10
	icon.offset_bottom = 10
	button.pressed.connect(callback)
	return button
static func volume(value: float, callback: Callable) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.set_meta("pixel_component","volume")
	box.add_theme_constant_override("separation",3)
	var label := Label.new()
	label.text = "VOLUME  %d%%" % roundi(value*100)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size",15)
	box.add_child(label)
	var slider: HSlider = preload("res://ui/pixel_volume_slider.gd").new()
	slider.frame_art = art("button_secondary","res://art/pixel/button.png")
	slider.name = "VolumeSlider"
	slider.min_value = 0.25
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = value
	slider.custom_minimum_size = Vector2(250,30)
	slider.set_meta("accessible_description", "Master volume")
	slider.value_changed.connect(func(next: float):
		label.text = "VOLUME  %d%%" % roundi(next*100)
		callback.call(next))
	box.add_child(slider)
	return box
