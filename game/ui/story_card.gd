extends CanvasLayer
## A skippable story card. It never pauses or resumes the game itself.
signal continued
const Book = preload("res://systems/story_book.gd")
var root: Control
var safe: MarginContainer
var panel: PanelContainer
var heading: Label
var chapter_title: Label
var body: Label
var objective_label: Label
var continue_button: Button
var _open: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 30
	root = Control.new()
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var shade := ColorRect.new()
	shade.color = Color(0.025, 0.018, 0.025, 0.87)
	root.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	safe = MarginContainer.new()
	root.add_child(safe)
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	safe.add_child(center)
	panel = PanelContainer.new()
	center.add_child(panel)
	var style: StyleBoxTexture = preload("res://ui/pixel_menu_components.gd").frame()
	panel.add_theme_stylebox_override("panel", style)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	panel.add_child(column)
	heading = _label("", 12, Color("c79570"))
	column.add_child(heading)
	chapter_title = _label("", 23, Color("f4e5cb"))
	column.add_child(chapter_title)
	body = _label("", 16, Color("e6ddd0"))
	body.add_theme_constant_override("line_spacing", 4)
	column.add_child(body)
	objective_label = _label("", 14, Color("9dc6bd"))
	column.add_child(objective_label)
	continue_button = Button.new()
	continue_button.text = "CONTINUE"
	continue_button.custom_minimum_size = Vector2(120, 48)
	continue_button.add_theme_font_override("font", preload("res://art/pixel/PixelifySans.ttf"))
	continue_button.add_theme_font_size_override("font_size", 17)
	continue_button.add_theme_color_override("font_color", Color("f4e5cb"))
	for state in ["normal","hover","focus","pressed"]:
		continue_button.add_theme_stylebox_override(state,preload("res://ui/pixel_menu_components.gd").button_style(state=="pressed"))
	continue_button.pressed.connect(_continue)
	column.add_child(continue_button)
	get_viewport().size_changed.connect(_layout)
	_layout()
	root.hide()

func _label(value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_override("font", preload("res://art/pixel/PixelifySans.ttf"))
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _layout() -> void:
	var inset := Vector4(20, 16, 20, 16)
	var size: Vector2 = get_viewport().get_visible_rect().size
	if OS.has_feature("mobile"):
		var local_safe: Rect2 = get_viewport().get_screen_transform().affine_inverse() * Rect2(DisplayServer.get_display_safe_area())
		inset = Vector4(maxf(20, local_safe.position.x), maxf(16, local_safe.position.y), maxf(20, size.x-local_safe.end.x), maxf(16, size.y-local_safe.end.y))
	safe.add_theme_constant_override("margin_left", roundi(inset.x))
	safe.add_theme_constant_override("margin_top", roundi(inset.y))
	safe.add_theme_constant_override("margin_right", roundi(inset.z))
	safe.add_theme_constant_override("margin_bottom", roundi(inset.w))
	panel.custom_minimum_size.x = minf(440, maxf(240, size.x-inset.x-inset.z))
	chapter_title.add_theme_font_size_override("font_size", 20 if size.x < 500 else 23)
	body.add_theme_font_size_override("font_size", 14 if size.x < 500 else 16)

func show_chapter(index: int, ending: bool = false) -> void:
	var entry: Dictionary = Book.completion() if ending else Book.get_chapter(index)
	if entry.is_empty():
		return
	heading.text = "EPILOGUE" if ending else "CHAPTER %02d · %s" % [index, str(entry.get("location", "")).to_upper()]
	chapter_title.text = str(entry.get("title", ""))
	body.text = str(entry.get("body", ""))
	objective_label.text = str(entry.get("objective", ""))
	_open = true
	root.show()
	continue_button.grab_focus.call_deferred()

func is_open() -> bool:
	return _open

func close() -> void:
	_open = false
	root.hide()
	get_viewport().gui_release_focus()

func _continue() -> void:
	if not _open:
		return
	close()
	continued.emit()

func _input(event: InputEvent) -> void:
	if not _open:
		return
	if event.is_action_pressed("ui_cancel"):
		_continue()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo:
		# Action keys do not leak into gameplay while the card has ownership.
		if event.is_action_pressed("ui_accept"):
			_continue()
		get_viewport().set_input_as_handled()
