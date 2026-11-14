extends Control
## Reference-based world, foreground, VFX and border remain independent.
@export var motion_enabled := true
var age := 0.0
var scenery: TextureRect
var foreground: TextureRect
var effects: Control
func _ready() -> void:
 process_mode = Node.PROCESS_MODE_ALWAYS
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 clip_contents = true
 scenery = _layer("CitadelWorld", "world")
 foreground = _layer("RoninAndBranches", "foreground")
 effects = preload("res://ui/citadel_effects.gd").new()
 effects.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(effects)
 effects.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 _layer("CarvedScreenFrame", "frame")
func _layer(label: String, asset: String) -> TextureRect:
 var layer := TextureRect.new()
 layer.name = label
 layer.texture = load("res://art/menu-approved/" + asset + ".png")
 layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 layer.stretch_mode = TextureRect.STRETCH_SCALE if asset == "frame" else TextureRect.STRETCH_KEEP_ASPECT_COVERED
 layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(layer)
 layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 return layer
func _process(delta: float) -> void:
 if not is_visible_in_tree(): return
 if motion_enabled: age += delta
 var drift := Vector2(sin(age * .13)*.6,cos(age*.17)*.3) if motion_enabled else Vector2.ZERO
 scenery.offset_left = -1+drift.x
 scenery.offset_right = 1+drift.x
 scenery.offset_top = -1+drift.y
 scenery.offset_bottom = 1+drift.y
 foreground.position = -drift*.4
 effects.set("age",age)
 effects.queue_redraw()
