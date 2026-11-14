extends CanvasLayer
signal skills_requested
signal armory_requested
signal start_requested
signal pause_requested
signal resume_requested
signal retry_requested
signal story_requested
signal menu_requested
signal sound_changed(enabled: bool)
signal ui_clicked
signal level_selected(index: int)
const PixelUI = preload("res://ui/pixel_menu_components.gd")
const TouchControls = preload("res://ui/touch_controls.gd")
var damage_veil: Control
var campaign_map: Control
var health_label: Label
var state_label: Label
var progress_label: Label
var power_label: Label
var power_bar: TextureProgressBar
var touch_options_grid: GridContainer
var pause_button: TextureButton
var health_bar: TextureProgressBar
var loading_bar: TextureProgressBar
var loading_label: Label
var loading_name: String = "CASTLE ROAD"
var max_unlocked: int = 1
var campaign_names: Array[String] = []
var map_chapter := 0
var rewards_label: Label
const Campaign = preload("res://data/campaign.gd")
var root: Control
var safe: Control
var gameplay: Control
var overlay: ColorRect
var menu_center: CenterContainer
var menu_box: VBoxContainer
var menu_scroll: ScrollContainer
var citadel: Control
var title_view: Control
var title_layout: BoxContainer
var touch: Control
var exit_button: Button
var screens: Array[String] = []
var sound_enabled: bool = true
var touch_enabled: bool = OS.has_feature("mobile")
var saved_screen: String = "title"
var shown_level: int = -1
var previous_remaining: int = -1
var toast_tween: Tween
var settings_path: String = "user://settings.cfg"
var settings := ConfigFile.new()
var control_scale: float = 1.0
var left_handed: bool = false
var control_opacity: float = 1.0
var vibration_enabled: bool = true
var master_volume: float = 1.0
var privacy := ConfigFile.new()
var save_error: Error = OK
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	for route in Campaign.levels(): campaign_names.append(route.name.to_upper())
	settings.load(settings_path)
	max_unlocked = clampi(settings.get_value("progress", "unlocked", 1), 1, campaign_names.size())
	map_chapter = (max_unlocked-1)/10
	sound_enabled = settings.get_value("audio", "enabled", true)
	touch_enabled = settings.get_value("input", "touch", OS.has_feature("mobile")) or "--touch-preview" in OS.get_cmdline_user_args()
	control_scale = clampf(float(settings.get_value("input", "scale", 1.0)), 0.8, 1.15)
	left_handed = bool(settings.get_value("input", "left_handed", false))
	control_opacity = clampf(float(settings.get_value("input", "opacity", 1.0)), 0.6, 1.0)
	vibration_enabled = bool(settings.get_value("input", "vibration", true))
	master_volume = clampf(float(settings.get_value("audio", "volume", 1.0)), 0.25, 1.0)
	AudioServer.set_bus_volume_db(0, linear_to_db(master_volume))
	privacy.load("res://config/privacy.cfg")
	root = Control.new()
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	citadel = preload("res://ui/citadel_backdrop.gd").new()
	root.add_child(citadel)
	root.theme = _theme()
	root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	safe = Control.new()
	root.add_child(safe)
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gameplay = Control.new()
	safe.add_child(gameplay)
	gameplay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gameplay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_gameplay()
	overlay = ColorRect.new()
	root.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.035, 0.02, 0.035, 0.48)
	root.move_child(overlay, 0)
	menu_center = CenterContainer.new()
	safe.add_child(menu_center)
	menu_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_scroll = ScrollContainer.new()
	menu_scroll.name = "MenuViewport"
	menu_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	menu_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	menu_scroll.follow_focus = true
	menu_scroll.get_v_scroll_bar().custom_minimum_size.x = 6
	menu_center.add_child(menu_scroll)
	menu_box = VBoxContainer.new()
	menu_box.custom_minimum_size.x = 250
	menu_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	menu_box.add_theme_constant_override("separation", 8)
	menu_scroll.add_child(menu_box)
	menu_box.minimum_size_changed.connect(_fit_menu.call_deferred)
	get_viewport().size_changed.connect(_safe_layout)
	_safe_layout()
	show_title()
func _theme() -> Theme:
	var theme := Theme.new()
	var font: FontFile = load("res://art/pixel/PixelifySans.ttf")
	font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	font.generate_mipmaps = false
	theme.default_font = font
	theme.default_font_size = 17
	theme.set_color("font_color", "Label", Color("f5e8d8"))
	theme.set_color("font_color", "Button", Color("ffe5df"))
	theme.set_color("font_hover_color", "Button", Color("ffe5df"))
	theme.set_color("font_focus_color", "Button", Color("fff1ed"))
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		theme.set_stylebox(state, "Button", PixelUI.button_style(state in ["pressed","focus","hover"],false,state=="pressed"))
	for state in ["scroll","grabber","grabber_highlight","grabber_pressed"]:
		var pixel := StyleBoxFlat.new()
		pixel.bg_color = Color("211016") if state=="scroll" else (Color("f0d3a0") if state=="grabber_pressed" else Color("9f3642"))
		pixel.content_margin_left=3
		pixel.content_margin_right=3
		pixel.content_margin_top=12 if state!="scroll" else 0
		pixel.content_margin_bottom=12 if state!="scroll" else 0
		theme.set_stylebox(state,"VScrollBar",pixel)
		var horizontal:=pixel.duplicate()
		horizontal.content_margin_top=3
		horizontal.content_margin_bottom=3
		horizontal.content_margin_left=12 if state!="scroll" else 0
		horizontal.content_margin_right=12 if state!="scroll" else 0
		theme.set_stylebox(state,"HScrollBar",horizontal)
	var empty_arrow := ImageTexture.create_from_image(Image.create(1,1,false,Image.FORMAT_RGBA8))
	for icon_name in ["increment","increment_highlight","increment_pressed","decrement","decrement_highlight","decrement_pressed"]:
		theme.set_icon(icon_name,"VScrollBar",empty_arrow)
		theme.set_icon(icon_name,"HScrollBar",empty_arrow)
	return theme
func _fit_menu() -> void:
	if not is_instance_valid(menu_scroll) or not is_instance_valid(menu_box): return
	var available: Vector2 = safe.size - Vector2(16,8)
	if available.x < 100 or available.y < 100: return
	if is_instance_valid(title_layout): title_layout.vertical = available.x < 550
	if is_instance_valid(touch_options_grid): touch_options_grid.columns = 2 if available.x>=560 else 1
	var required: Vector2 = menu_box.get_combined_minimum_size()
	menu_scroll.custom_minimum_size = Vector2(minf(required.x+14,available.x),minf(required.y+2,available.y))

func _safe_layout() -> void:
	var inset := Vector4(12, 10, 12, 10)
	if OS.has_feature("mobile"):
		var safe_rect := Rect2(DisplayServer.get_display_safe_area())
		var local_safe: Rect2 = get_viewport().get_screen_transform().affine_inverse() * safe_rect
		var dimensions := get_viewport().get_visible_rect().size
		inset = Vector4(maxf(12, local_safe.position.x), maxf(10, local_safe.position.y), maxf(12, dimensions.x - local_safe.end.x), maxf(10, dimensions.y - local_safe.end.y))
	safe.offset_left = inset.x
	safe.offset_top = inset.y
	safe.offset_right = -inset.z
	safe.offset_bottom = -inset.w
	if is_instance_valid(menu_box) and not screens.is_empty() and screens.back() == "death":
		menu_box.custom_minimum_size.x = minf(300,get_viewport().get_visible_rect().size.x-inset.x-inset.z-24)
	_fit_menu.call_deferred()
func _build_gameplay() -> void:
	damage_veil=preload("res://ui/damage_veil.gd").new()
	gameplay.add_child(damage_veil)
	damage_veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var health := VBoxContainer.new()
	gameplay.add_child(health)
	health.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	health.offset_right = 142
	health.add_theme_constant_override("separation", 3)
	health_label = _label("HEALTH 100", 11)
	health_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	health.add_child(health_label)
	health_bar = TextureProgressBar.new()
	health_bar.texture_under = preload("res://art/pixel/health_slim_empty.png")
	health_bar.texture_progress = preload("res://art/pixel/health_slim_full.png")
	health_bar.nine_patch_stretch = true
	health_bar.stretch_margin_left = 3
	health_bar.stretch_margin_right = 3
	health_bar.custom_minimum_size = Vector2(128, 10)
	health.add_child(health_bar)
	power_label = _label("POWER 100", 11)
	power_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	health.add_child(power_label)
	power_bar = TextureProgressBar.new()
	power_bar.texture_under = preload("res://art/pixel/health_slim_empty.png")
	var power_path: String = "res://art/pixel/power_slim_full.png"
	power_bar.texture_progress = load(power_path) if ResourceLoader.exists(power_path) else preload("res://art/pixel/health_slim_full.png")
	if not ResourceLoader.exists(power_path):
		power_bar.tint_progress = Color(0.30, 1.15, 1.5)
	power_bar.nine_patch_stretch = true
	power_bar.stretch_margin_left = 3
	power_bar.stretch_margin_right = 3
	power_bar.custom_minimum_size = Vector2(128, 10)
	health.add_child(power_bar)
	rewards_label=_label("COINS 0",10)
	rewards_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT
	health.add_child(rewards_label)
	progress_label = _label("", 10)
	gameplay.add_child(progress_label)
	progress_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	progress_label.offset_left = -130
	progress_label.offset_right = -56
	progress_label.offset_top = 12
	progress_label.offset_bottom = 28
	state_label = _label("", 12)
	gameplay.add_child(state_label)
	state_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	state_label.offset_left = -110
	state_label.offset_right = 110
	state_label.offset_top = 38
	state_label.offset_bottom = 56
	state_label.hide()
	pause_button = TextureButton.new()
	var pause := pause_button
	pause.texture_normal = preload("res://art/pixel/pause.png")
	pause.ignore_texture_size = true
	pause.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
	pause.set_meta("accessible_description", "Pause · Esc")
	pause.pressed.connect(func(): ui_clicked.emit(); pause_requested.emit())
	gameplay.add_child(pause)
	pause.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	pause.offset_left = -48
	pause.offset_right = 0
	pause.offset_bottom = 48
	touch = TouchControls.new()
	gameplay.add_child(touch)
	touch.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_apply_touch_preferences()
	exit_button = _button("Enter shrine", func(): Input.action_press("interact"); call_deferred("_release_interact"))
	gameplay.add_child(exit_button)
	exit_button.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	exit_button.offset_left = -75
	exit_button.offset_right = 75
	exit_button.offset_top = -44
	exit_button.offset_bottom = -4
	exit_button.hide()
func _release_interact() -> void:
	await get_tree().process_frame
	Input.action_release("interact")
func _label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_shadow_color", Color(0.03, 0.01, 0.02, 0.95))
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label
func _button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text.to_upper()
	button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var icon_path := "res://art/pixel-redesign/sword.png"
	if "SETTING" in text.to_upper() or "CONTROL" in text.to_upper(): icon_path = "res://art/pixel/ui-kit/icon_settings.png"
	elif "AUDIO" in text.to_upper() or "MUSIC" in text.to_upper(): icon_path = "res://art/pixel/ui-kit/icon_audio.png"
	elif text.to_upper() in ["BACK","MAIN MENU","START MENU"]: icon_path = "res://art/pixel/ui-kit/icon_back.png"
	button.icon = load(icon_path)
	button.expand_icon = true
	button.add_theme_constant_override("icon_max_width",22)
	button.add_theme_constant_override("h_separation",12)
	button.custom_minimum_size.y = 42
	button.button_down.connect(func(): _click_feedback(button.get_global_rect()))
	button.pressed.connect(func(): ui_clicked.emit(); callback.call())
	return button
func _click_feedback(at: Rect2) -> void:
	var flash := ColorRect.new()
	flash.name = "ClickFeedback"
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.color = Color(1.0,0.8,0.60,0.8)
	flash.position = at.position+Vector2(12,at.size.y-3)
	flash.size = Vector2(maxf(0,at.size.x-24),2)
	flash.z_index = 1000
	root.add_child(flash)
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(flash,"modulate:a",0.0,0.14)
	tween.tween_callback(flash.queue_free)

func _menu_button(text: String, callback: Callable) -> Button:
	var button := _button(text, callback)
	menu_box.add_child(button)
	return button
func _render_menu() -> void:
	if is_instance_valid(title_view):
		title_view.hide()
		title_view.queue_free()
	for child in menu_box.get_children():
		menu_box.remove_child(child)
		child.queue_free()
	menu_scroll.scroll_vertical = 0
	var screen: String = screens.back()
	citadel.visible = screen == "title"
	gameplay.hide()
	touch.release_all()
	overlay.show()
	menu_center.show()
	var heading: String = {"title":"ASHEN\nVEIL", "pause":"PAUSED", "settings":"SETTINGS", "help":"HOW TO PLAY", "death":"FALLEN RONIN", "complete":"CASTLE CLEARED", "loading":"ENTERING", "maps":"CAMPAIGN", "credits":"CREDITS", "touch_settings":"TOUCH LAYOUT", "audio_settings":"AUDIO", "privacy":"PRIVACY"}[screen]
	overlay.color = Color(0.025,0.015,0.025,0.76 if screen == "death" else (0.08 if screen == "title" else 0.48))
	menu_box.custom_minimum_size.x = minf(300,get_viewport().get_visible_rect().size.x-48) if screen == "death" else (270 if screen in ["settings","audio_settings","touch_settings"] else 250)
	if screen not in ["death","title"]: menu_box.add_child(_menu_heading(screen, heading))
	var first: Button
	match screen:
		"title":
			first = _build_title_screen()
		"pause":
			menu_box.add_child(_label("ROUTE %02d  ·  %s" % [clampi(shown_level,1,campaign_names.size()),campaign_names[clampi(shown_level,1,campaign_names.size())-1]],12))
			first = _menu_button("CONTINUE", func(): resume_requested.emit())
			_menu_button("SETTINGS", func(): _push("settings"))
			_menu_button("CHAPTER", func(): story_requested.emit())
			_menu_button("RETRY", func(): retry_requested.emit())
			_menu_button("MAIN MENU", func(): menu_requested.emit())
		"settings":
			first = _menu_button("Audio", func(): _push("audio_settings"))
			_menu_toggle("Touch controls",touch_enabled,_toggle_touch)
			_menu_button("Touch layout", func(): _push("touch_settings"))
			_menu_button("Privacy", func(): _push("privacy"))
			_menu_button("Campaign map",func():_push("maps"))
			_menu_button("New adventure",func():start_requested.emit())
			_menu_button("How to play",func():_push("help"))
			_menu_button("Credits",func():_push("credits"))
			_menu_button("START MENU",func(): menu_requested.emit())
			_menu_button("Back", _back)
		"audio_settings":
			first = _menu_toggle("Sound",sound_enabled,_toggle_sound)
			menu_box.add_child(PixelUI.volume(master_volume,_set_master_volume))
			_menu_button("Back", _back)
		"touch_settings":
			touch_options_grid=GridContainer.new()
			touch_options_grid.name="TouchOptions"
			touch_options_grid.columns=2 if safe.size.x>=576 else 1
			touch_options_grid.add_theme_constant_override("h_separation",10)
			touch_options_grid.add_theme_constant_override("v_separation",8)
			menu_box.add_child(touch_options_grid)
			var size_choice := _button("Size  ·  " + ("LARGE" if control_scale>1 else ("COMPACT" if control_scale<1 else "STANDARD")),_cycle_scale)
			var side_choice := _button("Sword side  ·  " + ("LEFT" if left_handed else "RIGHT"),_toggle_handedness)
			var opacity_choice := _button("Opacity  ·  %d%%" % roundi(control_opacity*100),_cycle_opacity)
			var vibration := PixelUI.toggle("Vibration",vibration_enabled,func():ui_clicked.emit();_toggle_vibration())
			vibration.button_down.connect(func():_click_feedback(vibration.get_global_rect()))
			for item in [size_choice,side_choice,opacity_choice,vibration,_button("Reset touch layout",_reset_touch),_button("Back",_back)]:
				item.custom_minimum_size.x=250
				item.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				touch_options_grid.add_child(item)
			menu_box.add_child(_label("Opacity fades artwork only; touch targets stay active.",10))
			first=size_choice
		"privacy":
			var notice := _label("Progress and preferences are saved on this device.\nPolicy links open in your browser.", 15)
			notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			notice.custom_minimum_size.x = 300
			menu_box.add_child(notice)
			var has_policy: bool = _add_policy_link("Privacy policy", "privacy_policy_url")
			_add_policy_link("Terms of use", "terms_url")
			if not has_policy:
				var unavailable := _label("Privacy policy link is not configured for this build.", 14)
				unavailable.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				menu_box.add_child(unavailable)
			first = _menu_button("Back", _back)
		"help":
			var instructions := _label("100 routes · major guardian every 10 levels.\nClear patrols, collect seals, or hunt the marked captain.\n\nA / D or arrows  Move     Space / W  Jump twice\nJ  Tap: sword combo · hold: charged slash\nL  Kick     U  Power     I  Ranged     K  Dash\nX / G  Energy slash · becomes piercing beam at level 20\nAirborne J: four-cut combo · DOWN + J: plunge\nMobile: UP jumps; tap again for double jump.\nDOWN: crouch / running slide / shelf drop.\nAir DOWN: fast fall. Double-tap left/right to dash.\n\nPower: charged 30 · power 50 · ranged 25 · energy 35 · beam 45\nCoins bank at each cleared gate; retry restores the bank.\nRed flasks restore health.\nE  Enter shrine     Esc  Pause", 14)
			menu_box.add_child(instructions)
			first = _menu_button("Back", _back)
		"loading":
			menu_box.add_child(_label(loading_name, 22))
			loading_bar = TextureProgressBar.new()
			loading_bar.texture_under = preload("res://art/pixel/health_empty.png")
			loading_bar.texture_progress = preload("res://art/pixel/health_full.png")
			loading_bar.nine_patch_stretch = true
			loading_bar.stretch_margin_left = 8
			loading_bar.stretch_margin_right = 8
			loading_bar.custom_minimum_size = Vector2(250, 28)
			menu_box.add_child(loading_bar)
			loading_label = _label("Preparing route…", 16)
			menu_box.add_child(loading_label)
		"maps":
			campaign_map=preload("res://ui/campaign_map.gd").new()
			campaign_map.max_unlocked=max_unlocked
			campaign_map.level_selected.connect(func(index: int):ui_clicked.emit();level_selected.emit(index))
			campaign_map.back_requested.connect(_back)
			menu_box.add_child(campaign_map)
		"credits":
			var credit := _label("Music: Free Music : MOMIZizm MUSiC\n\nCharacter art: PavelEKh\nPixel environments and UI: generated for this game\nFont: Pixelify Sans (OFL)\nSamurai SFX: Taira Komori\nTK’S FREE SOUND FX", 15)
			menu_box.add_child(credit)
			_menu_button("Music source", func(): OS.shell_open("https://music.storyinvention.com/en/"))
			_menu_button("Samurai sound source",func():OS.shell_open("https://taira-komori.net/freesounden.html"))
			first = _menu_button("Back", _back)
		"death":
			first = _build_defeat_card()
		"complete":
			menu_box.add_child(_label("All 100 routes and ten guardians are clear.", 16))
			first = _menu_button("Play again", func(): retry_requested.emit())
			_menu_button("MAIN MENU", func(): menu_requested.emit())
	if save_error != OK:
		menu_box.add_child(_label("Could not save. Changes apply for this session.", 12))
	_fit_menu.call_deferred()
	if first:
		_focus_button.call_deferred(first)
func _build_title_screen() -> Button:
	menu_center.hide()
	title_view = preload("res://ui/approved_title.gd").new()
	title_view.resume_available = max_unlocked > 1
	root.add_child(title_view)
	title_view.action_requested.connect(_title_action)
	return title_view.primary

func _title_action(action: String) -> void:
	ui_clicked.emit()
	match action:
		"play":
			if max_unlocked > 1: level_selected.emit(max_unlocked)
			else: start_requested.emit()
		"inventory": armory_requested.emit()
		"skills": skills_requested.emit()
		"settings": _push("settings")

func _menu_heading(screen: String, title: String) -> VBoxContainer:
	var header := VBoxContainer.new()
	header.add_theme_constant_override("separation",3)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	var icon := TextureRect.new()
	var key: String = "icon_audio" if screen == "audio_settings" else ("icon_back" if screen in ["title","help","privacy"] else "icon_settings")
	icon.texture = load("res://art/pixel/pause.png") if screen == "pause" else PixelUI.art(key,"res://art/pixel/pause.png")
	icon.flip_h = screen == "title"
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(22,22)
	if screen != "maps": row.add_child(icon)
	else: icon.queue_free()
	row.add_child(_label(title,27 if screen == "title" else 24))
	header.add_child(row)
	return header
func _menu_toggle(title: String, value: bool, callback: Callable) -> Button:
	var toggle: Button = PixelUI.toggle(title,value,func():ui_clicked.emit();callback.call())
	toggle.button_down.connect(func(): _click_feedback(toggle.get_global_rect()))
	menu_box.add_child(toggle)
	return toggle
func _set_master_volume(value: float) -> void:
	master_volume = clampf(value,0.25,1.0)
	AudioServer.set_bus_volume_db(0,linear_to_db(master_volume))
	_save_settings()

func _build_defeat_card() -> Button:
	var card := PanelContainer.new()
	card.name = "DefeatCard"
	var frame: StyleBoxTexture = PixelUI.frame()
	card.add_theme_stylebox_override("panel",frame)
	menu_box.add_child(card)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation",9)
	card.add_child(content)
	var chapter: int = clampi(shown_level,1,campaign_names.size())
	var route := _label("%03d / %d  ·  %s" % [chapter,campaign_names.size(),Campaign.get_level(chapter).chapter_name],11)
	route.name = "Route"
	route.add_theme_color_override("font_color",Color("b69a87"))
	content.add_child(route)
	var title := _label("FALLEN RONIN",27)
	content.add_child(title)
	var rule := ColorRect.new()
	rule.custom_minimum_size.y = 2
	rule.color = Color("9b4b43")
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(rule)
	var context := _label("The bell is still waiting.
Begin this route again.",15)
	context.name = "DefeatContext"
	context.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(context)
	var retry := _button("RETRY THIS ROUTE",func():retry_requested.emit())
	retry.name = "RetryRoute"
	retry.custom_minimum_size.y = 44
	retry.add_theme_font_size_override("font_size",17)
	content.add_child(retry)
	var leave := _button("MAIN MENU",func():menu_requested.emit())
	leave.name = "LeaveRoute"
	leave.custom_minimum_size.y = 44
	leave.add_theme_font_size_override("font_size",17)
	for state in ["normal","hover","pressed","focus"]:
		leave.add_theme_stylebox_override(state,PixelUI.button_style(state in ["pressed","focus","hover"],false,state=="pressed"))
	leave.add_theme_color_override("font_color",Color("f1d5aa"))
	content.add_child(leave)
	retry.focus_neighbor_bottom = retry.get_path_to(leave)
	retry.focus_neighbor_top = retry.get_path_to(leave)
	leave.focus_neighbor_top = leave.get_path_to(retry)
	leave.focus_neighbor_bottom = leave.get_path_to(retry)
	card.modulate.a = 0
	var reveal := create_tween()
	reveal.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	reveal.tween_property(card,"modulate:a",1.0,0.18)
	return retry

func _focus_button(button: Variant) -> void:
	if is_instance_valid(button) and button is Button and button.is_inside_tree():
		button.grab_focus()
func _push(screen: String) -> void:
	screens.append(screen)
	_render_menu()
func _back() -> void:
	if screens.size() > 1:
		screens.pop_back()
		_render_menu()
func handle_back() -> void:
	if not screens.is_empty() and screens.back() == "loading":
		return
	if screens.size() > 1:
		_back()
	elif screens.size() == 1 and screens.back() == "pause":
		resume_requested.emit()
	elif screens.is_empty():
		pause_requested.emit()
func _save_settings() -> void:
	settings.set_value("audio", "enabled", sound_enabled)
	settings.set_value("input", "touch", touch_enabled)
	settings.set_value("input", "scale", control_scale)
	settings.set_value("input", "left_handed", left_handed)
	settings.set_value("input", "opacity", control_opacity)
	settings.set_value("input", "vibration", vibration_enabled)
	settings.set_value("audio", "volume", master_volume)
	save_error = settings.save(settings_path)
func _apply_touch_preferences() -> void:
	touch.apply_preferences(control_scale, left_handed, control_opacity, vibration_enabled)
func _update_touch_settings(focus_index: int) -> void:
	_apply_touch_preferences()
	_save_settings()
	_render_menu()
	_focus_button.call_deferred(menu_box.get_child(focus_index))
func _cycle_scale() -> void:
	control_scale = 1.0 if control_scale < 0.9 else (1.15 if control_scale < 1.1 else 0.8)
	_update_touch_settings(1)
func _toggle_handedness() -> void:
	left_handed = not left_handed
	_update_touch_settings(2)
func _cycle_opacity() -> void:
	control_opacity = 1.0 if control_opacity < 0.7 else control_opacity - 0.2
	_update_touch_settings(3)
func _toggle_vibration() -> void:
	vibration_enabled = not vibration_enabled
	_update_touch_settings(4)
func _reset_touch() -> void:
	control_scale = 1.0
	left_handed = false
	control_opacity = 1.0
	vibration_enabled = true
	_update_touch_settings(5)
func _cycle_volume() -> void:
	master_volume = 0.25 if master_volume > 0.9 else master_volume + 0.25
	AudioServer.set_bus_volume_db(0, linear_to_db(master_volume))
	_save_settings()
	_render_menu()
	menu_box.get_child(2).get_node("VolumeSlider").grab_focus.call_deferred()
func _policy_url(key: String) -> String:
	var url: String = str(privacy.get_value("links", key, "")).strip_edges()
	# Only explicit publisher-supplied HTTPS links may leave the game.
	if not url.begins_with("https://") or url.length() < 12 or " " in url:
		return ""
	return url
func _add_policy_link(title: String, key: String) -> bool:
	var url: String = _policy_url(key)
	if url.is_empty():
		return false
	var button := _menu_button(title + " ↗", func():
		if OS.shell_open(url) != OK:
			button_link_failed())
	button.set_meta("accessible_description", url)
	return true
func button_link_failed() -> void:
	menu_box.add_child(_label("Could not open the browser. Please try again.", 13))
func _toggle_sound() -> void:
	sound_enabled = not sound_enabled
	sound_changed.emit(sound_enabled)
	_save_settings()
	_render_menu()
func _toggle_touch() -> void:
	touch_enabled = not touch_enabled
	_save_settings()
	_render_menu()
	_focus_button.call_deferred(menu_box.get_child(2))
func show_title() -> void:
	screens.assign(["title"])
	_render_menu()
func show_pause() -> void:
	screens.assign(["pause"])
	_render_menu()
func show_result(won: bool) -> void:
	screens.assign(["complete" if won else "death"])
	_render_menu()
func close_menu() -> void:
	if is_instance_valid(title_view): title_view.hide()
	citadel.hide()
	damage_veil.clear()
	screens.clear()
	overlay.hide()
	menu_center.hide()
	gameplay.show()
	touch.visible = touch_enabled
	get_viewport().gui_release_focus()
func hide_touch_controls() -> void:
	# A defeated actor must not keep bright, pressable-looking controls over the
	# death sequence; close_menu restores them with the next route.
	if is_instance_valid(touch):
		touch.release_all()
		touch.hide()
func set_health(current: int, maximum: int) -> void:
	health_label.text = "HEALTH %d" % current
	health_label.set_meta("accessible_description", "%d / %d" % [current, maximum])
	health_bar.max_value = maximum
	health_bar.value = current
func set_power(current: float, maximum: float) -> void:
	power_label.text = "POWER %d" % roundi(current)
	power_bar.max_value = maximum
	power_bar.value = current
	touch.set_power(current, maximum)
func set_charge(fraction: float) -> void:
	touch.set_charge(fraction)
func set_rewards(coins: int, seals: int, objective_label: String = "SEALS") -> void:
	rewards_label.text="COINS %d%s" % [coins," · %s %d" % [objective_label,seals] if seals>0 else ""]

func set_progress(level: int, remaining: int) -> void:
	progress_label.text = "%03d / %d" % [level,campaign_names.size()]
	progress_label.set_meta("accessible_description",Campaign.get_level(level).name)
	if shown_level != level or remaining > previous_remaining:
		state_label.hide()
		if is_instance_valid(toast_tween):
			toast_tween.kill()
	elif remaining == 0 and previous_remaining > 0:
		set_state("Gate open")
	shown_level = level
	previous_remaining = remaining
func set_exit_available(available: bool) -> void:
	exit_button.visible = available
func set_state(value: String) -> void:
	if is_instance_valid(toast_tween):
		toast_tween.kill()
	state_label.text = value
	state_label.modulate.a = 1
	state_label.show()
	toast_tween = create_tween()
	toast_tween.tween_interval(2.0)
	toast_tween.tween_property(state_label, "modulate:a", 0.0, 0.25)
	toast_tween.tween_callback(state_label.hide)

func show_loading(index: int, name: String) -> void:
	loading_name = "%02d  %s" % [index, name.to_upper()]
	screens.assign(["loading"])
	_render_menu()
func set_loading_progress(fraction: float, stage: String) -> void:
	if is_instance_valid(loading_bar):
		loading_bar.value = clampf(fraction, 0, 1) * 100
		loading_label.text = "%s  %d%%" % [stage, roundi(fraction * 100)]
func finish_loading() -> void:
	set_loading_progress(1, "Ready")
	var fade := create_tween()
	fade.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade.set_parallel(true)
	fade.tween_property(overlay, "color:a", 0.0, 0.22)
	fade.tween_property(menu_center, "modulate:a", 0.0, 0.22)
	await fade.finished
	close_menu()
	overlay.color.a = 0.48
	menu_center.modulate.a = 1
func unlock_level(index: int) -> void:
	max_unlocked = maxi(max_unlocked, clampi(index, 1, campaign_names.size()))
	settings.set_value("progress", "unlocked", max_unlocked)
	settings.save(settings_path)
