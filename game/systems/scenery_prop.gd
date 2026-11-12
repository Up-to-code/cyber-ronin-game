extends Node2D
## Decorative art only; never participates in collision or attack queries.
var variant: int = 0
var phase: float = 0
var sprite: Sprite2D
func _ready() -> void:
	add_to_group("scenery")
	set_meta("decorative",true)
	z_index=-2
	sprite=Sprite2D.new()
	var texture:=AtlasTexture.new()
	texture.atlas=preload("res://art/crimson-levels/scenery.png")
	texture.region=Rect2(clampi(variant,0,5)*64,0,64,64)
	sprite.texture=texture
	sprite.centered=false
	sprite.position=Vector2(-32,-62)
	sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.modulate=Color(0.9,0.78,0.8,0.95)
	add_child(sprite)
func _process(delta: float) -> void:
	phase+=delta
	if variant==5: rotation=sin(phase*1.4)*0.012
	elif variant==2: sprite.modulate=Color(0.96+sin(phase*5.3)*0.04,0.83+sin(phase*3.7)*0.03,0.77,0.95)
