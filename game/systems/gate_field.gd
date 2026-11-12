extends Node2D
# Nine generated pixel-art cels, independent of gate collision and actors.
var age := 0.0
var entry_charge := 0.0
var visual: Sprite2D
func _ready() -> void:
	show_behind_parent = true
	z_index = -1
	visual = Sprite2D.new()
	visual.texture = preload("res://art/crimson-gate/vortex.png")
	visual.hframes = 9
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(visual)
func _process(delta: float) -> void:
	age += delta * (1.0 + entry_charge * 1.5)
	visual.frame = int(age * 12.0) % 9
	var opening := smoothstep(0.0, 0.8, age)
	visual.scale = Vector2(0.92, 0.82) * opening * (1.0 + entry_charge * 0.08)
	visual.modulate = Color(1.0 + entry_charge * 0.4, 1.0, 1.0)
	visual.modulate.a = opening
