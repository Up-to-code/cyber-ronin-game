extends Node2D
signal impact(at: Vector2, kind: String)
var kind: String = "blade"
var direction := Vector2.RIGHT
var speed: float = 760
var damage: int = 40
var from_player: bool = true
var owner_body: CollisionObject2D
var age: float = 0
var life: float = 0.85
var visual: AnimatedSprite2D
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("combat_projectiles")
	if kind == "energy":
		speed = 1100
		damage = 65
		life = 0.8
	visual = AnimatedSprite2D.new()
	var frames := SpriteFrames.new()
	frames.set_animation_speed("default", 16)
	var path: String = "res://art/pixel/fire_bolt.png" if kind == "fire" else ("res://art/crimson-magic/spirit-flight.png" if kind=="energy" else "res://art/pixel/combat-v2/sword.png")
	var texture: Texture2D = load(path) if ResourceLoader.exists(path) else load("res://art/pixel/impact_fx.png")
	var count: int = 4 if kind=="fire" else (9 if kind=="energy" else 7)
	for i in range(count):
		var frame := AtlasTexture.new()
		frame.atlas = texture
		frame.region = Rect2(i * texture.get_width() / count, 0, texture.get_width() / count, texture.get_height())
		frames.add_frame("default", frame)
	visual.sprite_frames = frames
	visual.scale = Vector2(1.3, 1.3) if kind == "fire" else Vector2(2.6, 2.1)
	visual.modulate = Color.WHITE if kind == "fire" else Color.WHITE
	if kind == "energy":
		visual.scale = Vector2(2.0,2.0)
		# Leading tip follows the swept collision point; smoke trails behind it.
		visual.offset = Vector2(-40,0)
		visual.modulate = Color.WHITE
	visual.rotation = direction.angle()
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(visual)
	visual.play()

	z_index = 5
func _physics_process(delta: float) -> void:
	age += delta
	if age >= life:
		queue_free()
		return
	var next: Vector2 = global_position + direction * speed * delta
	if kind == "fire" and not from_player:
		for actor in get_tree().get_nodes_in_group("player"):
			if actor.has_method("can_cut_fire") and actor.can_cut_fire(global_position,next):
				impact.emit(global_position,"fire")
				queue_free()
				return
		for other in get_tree().get_nodes_in_group("combat_projectiles"):
			if other != self and other.from_player and not other.is_queued_for_deletion():
				var closest := Geometry2D.get_closest_point_to_segment(other.global_position,global_position,next)
				if closest.distance_to(other.global_position)<42:
					impact.emit(closest,"fire")
					queue_free()
					return
	var exclusions: Array[RID] = []
	if is_instance_valid(owner_body): exclusions.append(owner_body.get_rid())
	var mask: int = 1 | (4 if from_player else 2)
	var query := PhysicsRayQueryParameters2D.create(global_position, next, mask, exclusions)
	var hit: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		global_position = hit.position
		var body: Node = hit.collider
		var actor_owns_feedback: bool = false
		if body.has_method("receive_hit") and from_player:
			actor_owns_feedback = true
			body.receive_hit(damage, "ranged", direction.x, global_position)
		elif body.has_method("take_damage") and not from_player:
			actor_owns_feedback = true
			body.take_damage(damage, direction.x)
		# Actors emit their confirmed damage response. Only scenery needs a
		# projectile-owned impact; emitting both produced duplicate contact rings.
		if not actor_owns_feedback: impact.emit(global_position, kind)
		queue_free()
	else:
		global_position = next
