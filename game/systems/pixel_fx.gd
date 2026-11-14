extends Node2D
var echo_material: ShaderMaterial
const ImpactRing = preload("res://systems/impact_ring.gd")
const PixelBurst = preload("res://systems/pixel_burst.gd")
func _ready() -> void:
	echo_material = ShaderMaterial.new()
	echo_material.shader = preload("res://systems/dash_echo.gdshader")
func spawn(kind: String, at: Vector2, direction: float) -> void:
	# Reserve four slots for the layers of a single impact event.
	if get_child_count() >= 60:
		return
	if kind == "barrel_blast":
		var blast: Node2D = preload("res://systems/fire_barrel_blast.gd").new()
		blast.position = at
		blast.direction = direction
		blast.set_meta("family", "fire_barrel")
		add_child(blast)
		return
	if kind == "barrel_scorch":
		var scorch: Node2D = preload("res://systems/fire_barrel_scorch.gd").new()
		scorch.position = at
		scorch.direction = direction
		scorch.set_meta("family", "fire_barrel")
		add_child(scorch)
		return
	if kind == "swim_bubbles":
		var bubbles:=preload("res://systems/swim_bubbles.gd").new()
		bubbles.position=at
		bubbles.z_index=10
		add_child(bubbles)
		return
	if kind in ["jump", "air_jump", "land", "aerial_land"]:
		var strokes := preload("res://systems/jump_calligraphy.gd").new()
		strokes.kind=kind
		strokes.direction=direction
		strokes.position=at
		strokes.z_index=10
		strokes.set_meta("family","motion_strokes")
		strokes.set_meta("event",kind)
		add_child(strokes)
	if kind in ["run_wind","slide_wind","fall_wind","kick_wind"]:
		var wind := preload("res://systems/movement_wind.gd").new()
		wind.kind=kind
		wind.position=at
		wind.direction=direction
		wind.z_index=1
		wind.set_meta("family","wind")
		wind.set_meta("event",kind)
		add_child(wind)
		return
	if kind in ["charge", "power_empty", "plunge_trail", "fire_cast", "fire_impact"]:
		burst(kind, at, direction)
		return
	if kind in ["wall_hit", "impact", "finisher_hit", "air_jump", "aerial_land", "sparkle", "shockwave_ring", "critical_hit", "booster", "monster_spawn", "level_transition", "heal", "shield", "explosion", "blade", "attack", "slash_burst"]:
		var ring := ImpactRing.new()
		ring.position = at
		ring.radius = 60.0 if kind in ["level_transition", "monster_spawn"] else (52.0 if kind in ["critical_hit", "shockwave_ring", "booster"] else (44.0 if kind in ["finisher_hit", "aerial_land"] else 26.0))
		ring.flatten = 0.32 if kind in ["air_jump", "aerial_land"] else 0.85
		ring.tint = Color("5cff9d") if kind == "heal" else (Color("5ca8ff") if kind == "shield" else (Color("ff9a3c") if kind == "explosion" else (Color("7cff6b") if kind == "booster" else (Color("b06cff") if kind == "monster_spawn" else (Color("6cf0ff") if kind == "level_transition" else (Color("ffd166") if kind == "sparkle" else (Color("ff3b3b") if kind == "critical_hit" else (Color("a4dad3") if kind == "air_jump" else (Color("ff6258") if kind in ["impact", "finisher_hit"] else Color("f3ead1"))))))))))
		ring.set_meta("family", "contact_ring")
		ring.set_meta("event", kind)
		ring.z_index = 11
		add_child(ring)
	if kind in ["slash", "slash_reverse", "finisher", "sweep", "charged", "power", "ranged", "energy", "enemy_slash", "kick", "wall_hit", "impact", "finisher_hit"]:
		_attack_effect(kind,at,direction)
		return
	var family: String = "dust" if kind in ["jump", "air_jump", "land", "aerial_land", "dodge", "step"] else ("slash" if kind in ["slash", "slash_reverse", "finisher", "charged", "power", "ranged", "enemy_slash", "kick", "energy"] else "impact")
	if kind in ["air_jump", "land", "impact", "finisher_hit", "defeat", "finisher", "sparkle", "shockwave_ring", "critical_hit", "booster", "monster_spawn", "level_transition", "heal", "shield", "explosion", "blade", "attack", "slash_burst"]:
		burst(kind, at, direction)
	if get_child_count() >= 64:
		return
	var effect := AnimatedSprite2D.new()
	var frames := SpriteFrames.new()
	frames.set_animation_loop("default", false)
	frames.set_animation_speed("default", 28 if family in ["slash", "impact"] else 20)
	var texture: Texture2D = load("res://art/pixel/" + family + "_fx.png")
	for i in range(4):
		var frame := AtlasTexture.new()
		frame.atlas = texture
		frame.region = Rect2(i * 64, 0, 64, 64)
		frames.add_frame("default", frame)
	effect.sprite_frames = frames
	effect.set_meta("family", family)
	effect.set_meta("event", kind)
	effect.position = at
	effect.scale = Vector2(1.6, 1.6) if family == "slash" else (Vector2(0.85, 0.85) if family == "impact" else Vector2(1.1, 0.7))
	if kind in ["impact", "finisher_hit", "defeat"]:
		effect.modulate = Color("ff6258")
	if kind == "step":
		effect.scale *= 0.45
		effect.modulate.a = 0.55
	if kind == "enemy_slash":
		effect.modulate = Color("ff796a")
	if kind == "energy":
		effect.scale = Vector2(3.6,2.7)
		effect.modulate = Color("a3eee4")
		burst("finisher", at, direction)
	if kind == "slash_reverse":
		effect.flip_v = true
		effect.scale = Vector2(3, 3)
		burst("finisher", at, direction)
	if kind == "finisher":
		effect.scale = Vector2(3.4, 3.4)
		effect.rotation = -0.20 * direction
	if kind in ["charged", "power"]:
		effect.scale = Vector2(4.8, 3.8) if kind == "power" else Vector2(3.8, 3.2)
		effect.modulate = Color("a3eee4")
		burst(kind, at, direction)
	if kind == "kick":
		effect.scale = Vector2(1.15, 0.55)
		effect.rotation = -0.25 * direction
		effect.modulate = Color("e6dfc7")
	if kind == "aerial_land":
		effect.scale = Vector2(4.8, 1.4)
		burst(kind, at + Vector2(0, -8), direction)
	if kind == "air_jump":
		effect.scale = Vector2(2.8, 0.7)
		effect.modulate = Color(0.55, 1.25, 1.3, 0.9)
	effect.flip_h = direction < 0
	effect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if family == "dust":
		effect.offset.y = -27
	effect.z_index = 10
	add_child(effect)
	effect.animation_finished.connect(effect.queue_free)
	effect.play("default")

func _attack_effect(kind: String, at: Vector2, direction: float) -> void:
	if kind in ["slash_reverse","finisher","sweep","charged"]:
		var arc := preload("res://systems/combo_sweep.gd").new()
		arc.position=at
		arc.direction=direction
		arc.strength=1.45 if kind=="sweep" else (1.25 if kind in ["finisher","charged"] else 1.0)
		if kind=="sweep": arc.scale.y=0.55
		arc.z_index=10
		arc.set_meta("event",kind)
		arc.set_meta("family","slash")
		add_child(arc)
		return
	var effect := preload("res://systems/attack_effect.gd").new()
	effect.position=at
	effect.direction=direction
	effect.z_index=10
	effect.set_meta("event",kind)
	effect.set_meta("family","impact" if kind in ["wall_hit","impact","finisher_hit"] else "slash")
	match kind:
		"slash_reverse":
			effect.reverse=true
			effect.size=Vector2(3,3)
		"finisher", "charged":
			effect.size=Vector2(3.8,3.8)
		"enemy_slash":
			effect.size=Vector2(2.2,2.2)
		"kick":
			# A short displaced air stroke at the foot, never a hit star on a miss.
			effect.size=Vector2(1.8,0.65)
			effect.position+=Vector2(direction*12,0)
			effect.rotation=-0.35*direction
		"power":
			effect.sheet="shockwave"
			effect.frames=8
			effect.first=0
			effect.fps=26
			effect.size=Vector2(7,2.5)
		"ranged", "energy":
			effect.sheet="bolt"
			effect.frames=6
			effect.first=0
			effect.fps=36
			effect.size=Vector2(2,1.4)
		"wall_hit", "impact", "finisher_hit":
			effect.sheet="critical" if kind=="finisher_hit" else "hit"
			effect.frames=8 if kind=="finisher_hit" else 6
			effect.first=0
			effect.fps=32
			effect.size=Vector2(2.8,2.8) if kind=="finisher_hit" else Vector2(1.8,1.8)
			burst(kind,at,direction)
	add_child(effect)

func burst(kind: String, at: Vector2, direction: float) -> void:
	if get_child_count() >= 64:
		return
	var motes := PixelBurst.new()
	motes.position = at
	motes.direction = direction
	motes.z_index = 9
	motes.set_meta("family", "motes")
	motes.set_meta("event", kind)
	match kind:
		"land", "wall_hit":
			motes.tint = Color("ae967d")
			motes.count = 6
			motes.spread = 0.7
		"impact", "finisher_hit":
			motes.tint = Color("ed484b")
			motes.count = 64 if kind == "finisher_hit" else 40
			motes.blood = true
			motes.spread = 1.6 if kind == "finisher_hit" else 1.1
			motes.lifetime = 0.72
		"defeat":
			motes.tint = Color("b82e3e")
			motes.count = 80
			motes.blood = true
			motes.lifetime = 0.85
			motes.spread = 2.4
		"finisher":
			motes.count = 5
			motes.lifetime = 0.16
		"dash_start":
			motes.count = 6
			motes.lifetime = 0.18
		"charge":
			motes.count = 4
			motes.spread = 0.4
			motes.lifetime = 0.18
		"power_empty":
			motes.tint = Color("ae967d")
			motes.count = 3
			motes.spread = 0.3
			motes.lifetime = 0.14
		"plunge_trail":
			motes.count = 3
			motes.spread = 0.35
			motes.lifetime = 0.16
		"charged", "power", "aerial_land":
			motes.count = 20 if kind == "power" else 14
			motes.spread = 2.2 if kind == "power" else 1.7
			motes.lifetime = 0.35
		"fire_cast", "fire_impact":
			motes.tint = Color("ff823d")
			motes.count = 14
			motes.spread = 1.3
		"sparkle":
			motes.tint = Color("ffd166")
			motes.count = 18
			motes.spread = 1.9
			motes.lifetime = 0.45
		"critical_hit":
			motes.tint = Color("ff3b3b")
			motes.count = 42
			motes.blood = true
			motes.spread = 2.0
			motes.lifetime = 0.6
		"shockwave_ring":
			motes.tint = Color("a3eee4")
			motes.count = 22
			motes.spread = 2.4
			motes.lifetime = 0.35
		"booster":
			motes.tint = Color("7cff6b")
			motes.count = 26
			motes.spread = 2.0
			motes.lifetime = 0.4
		"monster_spawn":
			motes.tint = Color("b06cff")
			motes.count = 30
			motes.spread = 2.2
			motes.lifetime = 0.5
		"level_transition":
			motes.tint = Color("6cf0ff")
			motes.count = 34
			motes.spread = 2.6
			motes.lifetime = 0.55
		"heal":
			motes.tint = Color("5cff9d")
			motes.count = 20
			motes.spread = 1.6
			motes.lifetime = 0.45
		"shield":
			motes.tint = Color("5ca8ff")
			motes.count = 16
			motes.spread = 1.2
			motes.lifetime = 0.35
		"explosion":
			motes.tint = Color("ff9a3c")
			motes.count = 48
			motes.spread = 2.8
			motes.lifetime = 0.6
		"blade":
			motes.tint = Color("e6dfc7")
			motes.count = 12
			motes.spread = 1.4
			motes.lifetime = 0.25
		"attack":
			motes.tint = Color("ff6258")
			motes.count = 20
			motes.spread = 1.8
			motes.lifetime = 0.3
		"slash_burst":
			motes.tint = Color("a3eee4")
			motes.count = 24
			motes.spread = 2.0
			motes.lifetime = 0.35
	add_child(motes)
	if motes.blood and get_child_count()<64:
		var query:=PhysicsRayQueryParameters2D.create(at,at+Vector2(direction*30,280),1)
		var hit:=get_world_2d().direct_space_state.intersect_ray(query)
		if not hit.is_empty() and hit.normal.y<-0.5:
			var stain:=preload("res://systems/blood_stain.gd").new()
			stain.position=hit.position+Vector2(0,-2)
			stain.direction=direction
			stain.z_index=3
			add_child(stain)

func trail(source: AnimatedSprite2D, at: Vector2, direction: float) -> void:
	if get_child_count() >= 64:
		return
	var ghost := Sprite2D.new()
	ghost.texture = source.sprite_frames.get_frame_texture(source.animation, source.frame)
	ghost.offset = source.offset
	ghost.scale = source.scale
	ghost.position = at
	ghost.flip_h = direction < 0
	ghost.modulate = Color.WHITE
	ghost.material = echo_material
	ghost.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ghost.z_index = 1
	ghost.set_meta("family", "dash")
	add_child(ghost)
	var fade := create_tween()
	fade.tween_property(ghost, "modulate:a", 0.0, 0.14)
	fade.tween_callback(ghost.queue_free)

func rig_trail(rig: Node2D) -> void:
	if get_child_count() >= 64: return
	if rig.has_method("create_snapshot"):
		var snapshot: Node2D = rig.create_snapshot()
		snapshot.position = rig.global_position
		snapshot.modulate = Color(0.5,1.1,1.1,0.25)
		snapshot.z_index = 1
		snapshot.set_meta("family","dash")
		add_child(snapshot)
		var tween := create_tween()
		tween.tween_property(snapshot,"modulate:a",0,0.14)
		tween.tween_callback(snapshot.queue_free)
		return
	var echo := Node2D.new()
	echo.z_index = 1
	echo.set_meta("family", "dash")
	add_child(echo)
	for part in rig.find_children("*", "Polygon2D", true, false):
		var clone := Polygon2D.new()
		clone.polygon = part.polygon
		clone.uv = part.uv
		clone.texture = part.texture
		clone.color = part.color
		clone.transform = global_transform.affine_inverse() * part.global_transform
		clone.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		echo.add_child(clone)
	echo.modulate = Color(0.5, 1.1, 1.1, 0.25)
	var fade := create_tween()
	fade.tween_property(echo, "modulate:a", 0, 0.14)
	fade.tween_callback(echo.queue_free)

# Short-lived attack art follows the moving body, but keeps its contact direction.
func _process(_delta: float) -> void:
	for effect in get_children():
		if not effect.has_meta("follow_actor"): continue
		var actor = effect.get_meta("follow_actor")
		if is_instance_valid(actor) and not actor.is_queued_for_deletion():
			effect.global_position = actor.global_position + effect.get_meta("follow_offset")

func shatter(rig: Node2D, at: Vector2, direction: float) -> void:
	# Drawn collapse already owns the body. Existing defeat blood supplies impact.
	if is_instance_valid(rig) and rig.has_meta("monster_cel_visual"): return
	if get_child_count()>=60 or not is_instance_valid(rig): return
	var fragments := preload("res://systems/death_fragments.gd").new()
	fragments.texture=rig.sprite.sprite_frames.get_frame_texture(rig.current_clip,rig.current_frame)
	fragments.art_scale=rig.sprite.scale*rig.get_parent().scale
	fragments.mirrored=rig.sprite.flip_h
	fragments.direction=direction
	fragments.position=at
	fragments.z_index=8
	fragments.set_meta("family","fragments")
	add_child(fragments)
