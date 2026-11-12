extends Node2D
# Imported pixel cels: strike silhouette, separate contact star and floor wave.
var sheet: String = "sword"
var first: int = 2
var fps: float = 30
var direction: float = 1
var reverse: bool = false
var size := Vector2(2.6,2.6)
var age: float = 0
var frames: int = 7
var visual: Sprite2D
func _ready() -> void:
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	visual=Sprite2D.new()
	visual.texture=load("res://art/pixel/combat-v2/"+sheet+".png")
	visual.hframes=frames
	visual.frame=first
	visual.scale=size
	visual.flip_h=direction<0
	visual.flip_v=reverse
	add_child(visual)
func _process(delta: float) -> void:
	age+=delta
	var index: int=first+int(age*fps)
	if index>=frames:queue_free()
	else:visual.frame=index
