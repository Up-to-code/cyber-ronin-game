extends Node2D
## Bounded fragments cut from the defeated actor's actual current pixel cel.
var texture: Texture2D
var art_scale := Vector2.ONE
var direction := 1.0
var mirrored := false
var age := 0.0
var fragments: Array[Dictionary] = []
func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if texture == null: queue_free(); return
	var bounds := texture.get_image().get_used_rect()
	for row in range(2):
		for column in range(3):
			var part := Sprite2D.new()
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(Vector2(bounds.position)+Vector2(column,row)*Vector2(bounds.size)/Vector2(3,2),Vector2(bounds.size)/Vector2(3,2))
			part.texture = atlas
			part.scale = art_scale
			part.flip_h = mirrored
			part.position = Vector2((column-1)*12,(row-0.5)*20)
			add_child(part)
			fragments.append({"sprite":part,"velocity":Vector2(direction*(90+column*60),-170-row*70-column*28),"spin":(-1 if column%2==0 else 1)*(3+row)})
func _process(delta: float) -> void:
	age += delta
	if age>0.8: queue_free(); return
	for fragment in fragments:
		fragment.velocity.y += 900*delta
		fragment.sprite.position += fragment.velocity*delta
		fragment.sprite.rotation += fragment.spin*delta
		fragment.sprite.modulate.a = clampf((0.8-age)/0.24,0,1)
