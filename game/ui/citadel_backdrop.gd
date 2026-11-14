extends Control
## Independent artwork and VFX layers; never intercepts menu input.
@export var motion_enabled := true
var age := 0.0
var sky: TextureRect
var scenery: TextureRect
var foreground: TextureRect
var effects: Control
func _ready() -> void:
 process_mode = Node.PROCESS_MODE_ALWAYS
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 clip_contents = true
 sky = _layer("MoonAndSky", "sky")
 scenery = _layer("Citadel", "architecture")
 foreground = _layer("RoninAndBranches", "foreground")
 effects = Control.new()
 effects.mouse_filter = Control.MOUSE_FILTER_IGNORE
 effects.set_script(preload("res://ui/citadel_effects.gd"))
 add_child(effects)
 effects.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 _layer("CarvedScreenFrame", "frame")
func _layer(label: String, asset: String) -> TextureRect:
 var layer := TextureRect.new()
 layer.name = label
 layer.texture = load("res://art/menu-citadel/" + asset + ".png")
 layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 layer.stretch_mode = TextureRect.STRETCH_SCALE if asset == "frame" else TextureRect.STRETCH_KEEP_ASPECT_COVERED
 layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(layer)
 layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 return layer
func _process(delta: float) -> void:
 if not is_visible_in_tree(): return
 if motion_enabled: age += delta
 var drift := Vector2(sin(age * 0.13) * 3.0, cos(age * 0.17) * 1.5) if motion_enabled else Vector2.ZERO
 sky.offset_left = -10 + drift.x * 0.3
 sky.offset_right = 10 + drift.x * 0.3
 scenery.offset_left = -8 + drift.x
 scenery.offset_right = 8 + drift.x
 scenery.offset_top = -5 + drift.y
 scenery.offset_bottom = 5 + drift.y
 foreground.offset_left = -4 - drift.x * 0.5
 foreground.offset_right = 4 - drift.x * 0.5
 effects.set("age", age)
 effects.queue_redraw()
