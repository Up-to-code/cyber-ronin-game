extends StaticBody2D
## Destructible fire hazard. Any confirmed player hit lights a short fuse; the
## blast damages nearby actors and chain-ignites neighbouring barrels. The
## barrel never blocks movement (mask 0) and only offers a hit target on layer 4.
signal fused(at: Vector2)
signal detonated(at: Vector2, direction: float)

const BLAST_RADIUS: float = 148.0
const ENEMY_DAMAGE: int = 60
const PLAYER_DAMAGE: int = 24
const FUSE_TIME: float = 0.16
const CHAIN_TIME: float = 0.10
const FLAME_FRAMES: Array[Texture2D] = [
	preload("res://art/living-marsh/fire0.png"),
	preload("res://art/living-marsh/fire1.png"),
	preload("res://art/living-marsh/fire2.png"),
	preload("res://art/living-marsh/fire3.png"),
]

var age: float = 0.0
var fuse: float = 0.0
var exploded: bool = false
var direction: float = 1.0
var sprite: Sprite2D
var flame: AnimatedSprite2D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("fire_barrels")
	collision_layer = 4
	collision_mask = 0
	z_index = 1
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(30, 48)
	collider.shape = shape
	collider.position = Vector2(0, -24)
	add_child(collider)
	sprite = Sprite2D.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = preload("res://art/crimson-levels/scenery.png")
	atlas.region = Rect2(0, 0, 64, 64)
	sprite.texture = atlas
	sprite.centered = false
	sprite.position = Vector2(-32, -62)
	sprite.scale = Vector2(1.35, 1.35)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.modulate = Color(1.08, 0.82, 0.70)
	add_child(sprite)
	flame = AnimatedSprite2D.new()
	var frames := SpriteFrames.new()
	frames.set_animation_speed("default", 10)
	for frame in FLAME_FRAMES:
		frames.add_frame("default", frame)
	flame.sprite_frames = frames
	flame.position = Vector2(0, -94)
	flame.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	flame.modulate = Color(1.0, 0.92, 0.78)
	add_child(flame)
	flame.play("default")

func _process(delta: float) -> void:
	age += delta
	if exploded:
		return
	if fuse > 0.0:
		fuse -= delta
		# Bright warning pulse while the fuse burns, then the blast.
		sprite.modulate = Color(1.65, 1.18, 0.78) if int(age * 40.0) % 2 == 0 else Color(1.15, 0.72, 0.52)
		flame.speed_scale = 3.2
		flame.modulate = Color(1.35, 1.05, 0.72)
		if fuse <= 0.0:
			_detonate()
			return
	else:
		var breathe: float = sin(age * 6.0) * 0.04
		sprite.modulate = Color(1.08 + breathe, 0.82 + breathe * 0.5, 0.70)
		flame.speed_scale = 1.0
	queue_redraw()

func _draw() -> void:
	# Warm ground bounce plus drifting embers; both stay behind the prop art.
	var pulse: float = 0.10 + 0.03 * sin(age * 8.0) + (0.12 if fuse > 0.0 else 0.0)
	draw_rect(Rect2(-27, -78, 54, 70), Color(1.0, 0.40, 0.12, pulse))
	draw_rect(Rect2(-18, -64, 36, 44), Color(1.0, 0.58, 0.18, pulse * 0.8))
	for i in range(6):
		var rise: float = fposmod(age * (26.0 + i * 7.0) + i * 19.0, 92.0)
		var x: float = sin(age * 1.7 + i * 1.3) * 10.0 + (float(i) - 2.5) * 3.0
		var alpha: float = (1.0 - rise / 92.0) * 0.85
		draw_rect(Rect2(Vector2(x, -54.0 - rise).floor(), Vector2(2, 2)), Color(1.0, 0.45 + 0.1 * (i % 3), 0.12, alpha))

func receive_hit(_amount: int, _kind: String, hit_direction: float, _point: Vector2) -> void:
	if exploded or fuse > 0.0:
		return
	direction = signf(hit_direction) if hit_direction != 0.0 else direction
	fuse = FUSE_TIME
	fused.emit(global_position)
	queue_redraw()

func ignite_chain(_chain_direction: float = 0.0) -> void:
	if exploded or fuse > 0.0:
		return
	fuse = CHAIN_TIME
	queue_redraw()

func _detonate() -> void:
	exploded = true
	remove_from_group("fire_barrels")
	collision_layer = 0
	flame.hide()
	var base: Vector2 = global_position
	_apply_blast()
	detonated.emit(base, direction)
	queue_free()

func _apply_blast() -> void:
	var center: Vector2 = global_position + Vector2(0, -30)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.health <= 0:
			continue
		var offset: Vector2 = enemy.global_position + Vector2(0, -46) - center
		if offset.length() > BLAST_RADIUS:
			continue
		var falloff: float = 1.0 - (offset.length() / BLAST_RADIUS) * 0.55
		var push: float = signf(offset.x) if absf(offset.x) > 0.1 else direction
		if enemy.has_method("receive_hit"):
			enemy.receive_hit(roundi(ENEMY_DAMAGE * falloff), "explosion", push, center)
		elif enemy.has_method("take_damage"):
			enemy.take_damage(roundi(ENEMY_DAMAGE * falloff), push)
	for actor in get_tree().get_nodes_in_group("player"):
		if not is_instance_valid(actor) or actor.health <= 0:
			continue
		var offset: Vector2 = actor.global_position + Vector2(0, -46) - center
		if offset.length() > BLAST_RADIUS:
			continue
		var falloff: float = 1.0 - (offset.length() / BLAST_RADIUS) * 0.55
		var push: float = signf(offset.x) if absf(offset.x) > 0.1 else direction
		actor.take_damage(roundi(PLAYER_DAMAGE * falloff), push)
	for other in get_tree().get_nodes_in_group("fire_barrels"):
		if other == self or not is_instance_valid(other) or other.exploded:
			continue
		if other.global_position.distance_to(global_position) <= BLAST_RADIUS * 0.9:
			other.ignite_chain(direction)
