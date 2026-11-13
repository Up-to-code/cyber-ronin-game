extends Control
# Thumb zones: directional cross and a large sword surrounded by reachable skills.
# Coordinates are local to bottom-corner anchors inside the HUD safe area.
var buttons: Array[TouchScreenButton] = []
var button_art: Array[AtlasTexture] = []
var actions: Array[String] = ["move_left", "move_right", "jump", "move_down", "kick", "attack", "power_attack", "ranged_attack", "energy_attack"]
var centers: Array[Vector2] = []
var slots: Array[Control] = []
var press_amount: Array[float] = []
const ACTION_NAMES := ["Move left", "Move right", "Jump / double jump", "Crouch / slide / drop through shelf", "Kick", "Sword / hold to charge", "Power (50)", "Ranged blade (25)", "Energy slash (35)"]
var target_sizes: Array[Vector2] = []
var power: float = 100
var charge: float = 0
const TARGET_SIZE := Vector2(44, 44)
var control_scale: float = 1.0
var layout_scale: float = 1.0
var _output_scale: float = 0
var face_sizes: Array[Vector2] = []
var left_handed: bool = false
var vibration_enabled: bool = true
var movement: Control
var action_group: Control
const PAD_POINTS := [Vector2(22,74), Vector2(126,74), Vector2(74,22), Vector2(74,126), Vector2(30,108), Vector2(100,108), Vector2(100,28), Vector2(36,42), Vector2(164,64)]
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in range(9):
		var art := AtlasTexture.new()
		if i==5 or i==2:
			art.atlas=load("res://art/pixel-redesign/"+("sword" if i==5 else "jump")+".png")
			art.region=Rect2(Vector2.ZERO,art.atlas.get_size())
		else:
			art.atlas=load("res://art/pixel/controls-red-ivory.png" if i<4 else "res://art/pixel/ashen-combat-buttons.png")
			var cell: int=[0,2,1,3,1,0,2,3,4][i]
			art.region=Rect2(cell*64,0,64,64)
		button_art.append(art)
	movement = Control.new()
	movement.name = "DirectionPad"
	add_child(movement)
	movement.mouse_filter = Control.MOUSE_FILTER_IGNORE
	action_group = Control.new()
	action_group.name = "CombatPad"
	add_child(action_group)
	action_group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in range(actions.size()):
		var slot := Control.new()
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		(movement if i < 4 else action_group).add_child(slot)
		var target := Vector2(44,44) if i < 4 else (Vector2(60,60) if i == 5 else TARGET_SIZE)
		target_sizes.append(target)
		face_sizes.append(target*0.82)
		slot.name = actions[i]
		slot.set_meta("accessible_description", ACTION_NAMES[i])
		slot.set_meta("accessible_action_name", ACTION_NAMES[i])
		slots.append(slot)
		press_amount.append(0.0)
		var button := TouchScreenButton.new()
		button.action = actions[i]
		var shape := RectangleShape2D.new()
		shape.size = target
		button.shape = shape
		button.pressed.connect(_pressed)
		button.released.connect(queue_redraw)
		slot.add_child(button)
		buttons.append(button)
		slot.resized.connect(_layout)
	resized.connect(_responsive_layout)
	visibility_changed.connect(_visibility_changed)
	apply_preferences(1.0, false, 1.0, true)
func apply_preferences(new_scale: float, mirrored: bool, opacity: float, haptics: bool) -> void:
	release_all()
	control_scale = clampf(new_scale, 0.8, 1.15)
	left_handed = mirrored
	vibration_enabled = haptics
	modulate.a = clampf(opacity, 0.6, 1.0)
	_responsive_layout()

func _responsive_layout() -> void:
	if not is_instance_valid(movement) or size.x < 100 or size.y < 100: return
	var pixels_per_unit: float = maxf(0.01, get_viewport().get_screen_transform().get_scale().x)
	_output_scale = pixels_per_unit
	var density: float = maxf(1.0, DisplayServer.screen_get_scale()) if OS.has_feature("mobile") else 1.0
	var desired_pixels: float = (48.0 if OS.has_feature("mobile") else 52.0) * density
	layout_scale = desired_pixels / (44.0*pixels_per_unit) * control_scale
	layout_scale = minf(layout_scale, minf(maxf(0.1,size.x-40)/376.0,maxf(0.1,size.y-64)/160.0))
	var mirrored: bool = left_handed
	movement.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT if mirrored else Control.PRESET_BOTTOM_LEFT)
	action_group.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT if mirrored else Control.PRESET_BOTTOM_RIGHT)
	for group in [movement, action_group]:
		var group_size: Vector2 = (Vector2(148,148) if group == movement else Vector2(188,148)) * layout_scale
		var on_right: bool = (group == movement) == mirrored
		group.offset_left = -group_size.x - 16 if on_right else 16
		group.offset_right = -16 if on_right else group_size.x + 16
		group.offset_top = -group_size.y - 18
		group.offset_bottom = -18
	for i in range(slots.size()):
		var target: Vector2 = (Vector2(44,44) if i < 4 else (Vector2(60,60) if i == 5 else TARGET_SIZE)) * layout_scale
		target_sizes[i] = target
		face_sizes[i] = target*0.82
		var point: Vector2 = PAD_POINTS[i] * layout_scale
		if mirrored and i >= 4:
			point.x = 188 * layout_scale - point.x
		slots[i].position = point - target * 0.5
		slots[i].size = target
		(buttons[i].shape as RectangleShape2D).size = target
	_layout.call_deferred()

func _process(delta: float) -> void:
	if not is_visible_in_tree(): return
	if not is_equal_approx(_output_scale, get_viewport().get_screen_transform().get_scale().x):
		_responsive_layout()
	var changed: bool = false
	for i in range(buttons.size()):
		var goal: float = 1.0 if buttons[i].is_pressed() else 0.0
		var previous: float = press_amount[i]
		press_amount[i] = move_toward(previous, goal, delta * (20.0 if goal > 0 else 8.0))
		changed = changed or not is_equal_approx(previous, press_amount[i])
	if changed: queue_redraw()
func _pressed() -> void:
	queue_redraw()
	if vibration_enabled and OS.has_feature("mobile"):
		Input.vibrate_handheld(12)
func _layout() -> void:
	centers.clear()
	for i in range(buttons.size()):
		buttons[i].position = slots[i].size * 0.5
		centers.append(get_global_transform_with_canvas().affine_inverse() * buttons[i].get_global_transform_with_canvas().origin)
	queue_redraw()
func release_all() -> void:
	for action in actions:
		Input.action_release(action)
	Input.action_release("sprint")
	set_charge(0)
func set_power(current: float, _maximum: float = 100) -> void:
	power = current
	queue_redraw()
func set_charge(fraction: float) -> void:
	charge = clampf(fraction, 0, 1)
	queue_redraw()
func _visibility_changed() -> void:
	if not is_visible_in_tree(): release_all()
func _draw() -> void:
	for i in range(centers.size()):
		var target: Vector2 = target_sizes[i]
		var visual_size: Vector2 = face_sizes[i]
		var rect := Rect2(centers[i] - visual_size * 0.5, visual_size)
		var inset: float = roundf(press_amount[i]*1.5)
		var tint := Color(1.18,1.10,0.95) if press_amount[i]>0.1 else Color.WHITE
		if (i == 6 and power < 50) or (i == 7 and power < 25) or (i == 8 and power < 35): tint = Color(0.48,0.48,0.48,0.8)
		draw_texture_rect(button_art[i],rect.grow(-inset),false,tint)
		if i == 5 and charge > 0:
			draw_rect(Rect2(rect.position + Vector2(3, visual_size.y-6),Vector2((visual_size.x-6)*charge,2)),Color("a4dad3"))


