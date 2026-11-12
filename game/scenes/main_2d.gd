extends Node2D
signal level_loaded(index: int)
const Player = preload("res://actors/player_2d.gd")
const Enemy = preload("res://actors/enemy_2d.gd")
const Hud = preload("res://ui/hud.gd")
const CampaignData = preload("res://data/campaign.gd")
var player: CharacterBody2D
var hud: CanvasLayer
var camera: Camera2D
var remaining: int = 0
var level: int = 1
var elapsed: float = 0
var screenshot_path: String = ""
var capture_started: bool = false
var background_layers: Array[Dictionary] = []
var snow_field: Node2D
var camera_trauma: float = 0
var camera_initialized: bool = false
var camera_ground_y: float = 550
var welcome_layer: CanvasLayer
var welcome_art: Sprite2D
var moving_platform: AnimatableBody2D
var lifts: Array[AnimatableBody2D] = []
var fx: Node2D
var started: bool = false
var run_token: int = 0
var shrine: Sprite2D
var gate_open: bool = false
var gate_entry_time: float = 0.0
var level_root: Node2D
var map: Dictionary = {}
var transitioning: bool = false
var threat_hold: float = 0
var textures: Dictionary = {}
var platform_surface: int = 8
var torch_frames: SpriteFrames
var story_card: CanvasLayer
var story_ending: bool = false
var story_seen: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_window().title = "Ashen Veil — The Bell That Would Not Rest"
	get_tree().auto_accept_quit = false
	get_tree().root.close_requested.connect(quit_game)
	_build_background()
	_build_weather()
	_build_welcome()
	# Removed mismatched second cloud style; sky owns the coherent cloud art.
	fx = preload("res://systems/pixel_fx.gd").new()
	fx.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(fx)
	player = Player.new()
	player.z_index = 2
	player.position = Vector2(200, 550)
	add_child(player)
	camera = Camera2D.new()
	camera.position = Vector2(640, 360)
	camera.zoom = Vector2(0.69, 0.69)
	add_child(camera)
	hud = Hud.new()
	add_child(hud)
	story_card = preload("res://ui/story_card.gd").new()
	add_child(story_card)
	story_card.continued.connect(_finish_story)
	player.health_changed.connect(hud.set_health)
	player.power_changed.connect(hud.set_power)
	player.charge_changed.connect(hud.set_charge)
	player.state_changed.connect(_player_state)
	player.fx_requested.connect(_player_fx)
	player.projectile_requested.connect(_spawn_projectile)
	hud.start_requested.connect(start_game)
	hud.pause_requested.connect(pause_game)
	hud.resume_requested.connect(resume_game)
	hud.retry_requested.connect(retry_game)
	hud.menu_requested.connect(main_menu)
	if hud.has_signal("story_requested"): hud.connect("story_requested",func(): _show_story(level,false))
	hud.level_selected.connect(_choose_level)
	hud.ui_clicked.connect(func(): _audio().play("ui"))
	hud.sound_changed.connect(_audio().set_enabled)
	_audio().set_enabled(hud.sound_enabled)
	map = CampaignData.get_level(1)
	for path in _resource_paths(map):
		textures[path] = load(path)
	_populate_level(map)
	get_tree().paused = true
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--qa-screenshot="):
			screenshot_path = arg.trim_prefix("--qa-screenshot=")
	if "--qa-gameplay" in OS.get_cmdline_user_args():
		var qa_level: int = 1
		for arg in OS.get_cmdline_user_args():
			if arg.begins_with("--qa-level="):
				qa_level = clampi(int(arg.trim_prefix("--qa-level=")), 1, 6)
		_choose_level(qa_level)

func _enemy_fx(kind: String, at: Vector2, direction: float) -> void:
	fx.spawn("enemy_slash" if kind == "slash" else kind, at, direction)
	if kind in ["impact", "finisher_hit"]:
		camera_trauma = minf(0.65, camera_trauma + (0.40 if kind == "finisher_hit" else 0.22))

func _player_fx(kind: String, at: Vector2, direction: float) -> void:
	if kind in ["slash_reverse","finisher","charged"] and is_instance_valid(player): at=player.global_position+Vector2(0,-62)
	if kind == "power" and is_instance_valid(player): at = player.global_position + Vector2(0,-6)
	if kind in ["land", "aerial_land"]: camera_trauma = minf(0.60,camera_trauma+(0.48 if kind == "aerial_land" else 0.32))
	if kind in ["step", "land", "jump", "aerial_land"]:
		var snow := preload("res://systems/pixel_burst.gd").new()
		snow.position = at
		snow.tint = Color("d7e5ed")
		snow.count = 5 if kind == "step" else 12
		snow.spread = 0.45 if kind == "step" else 0.85
		snow.lifetime = 0.35
		snow.direction = direction
		fx.add_child(snow)
	if kind in ["dodge", "dash_trail"]:
		if is_instance_valid(player.rig): fx.rig_trail(player.rig)
		else: fx.trail(player.sprite, at, direction)
		if kind == "dodge":
			fx.burst("dash_start", at + Vector2(0, -32), direction)
		if kind == "dodge" and player.is_on_floor():
			fx.spawn("step", at, direction)
	else:
		var previous := fx.get_children()
		fx.spawn(kind, at, direction)
		if kind in ["slash", "slash_reverse", "finisher", "charged", "kick", "ranged", "energy"]:
			var angle: float = Vector2(direction,0).angle_to(player.attack_aim)
			for effect in fx.get_children():
				if effect in previous: continue
				effect.rotation += angle
				effect.set_meta("follow_actor", player)
				effect.set_meta("follow_offset", effect.global_position - player.global_position)
		if kind in ["impact", "finisher_hit"] and player.velocity.length() > 80:
			if is_instance_valid(player.rig): fx.rig_trail(player.rig)

func _spawn_projectile(kind: String, at: Vector2, direction: Vector2, source: Node) -> void:
	var projectile := preload("res://systems/combat_projectile.gd").new()
	projectile.kind = kind
	projectile.position = at
	projectile.direction = direction.normalized()
	projectile.from_player = source == player
	projectile.owner_body = source
	projectile.speed = 760 if source == player else 360
	projectile.damage = 40 if source == player else 10
	projectile.life = 0.85 if source == player else 1.8
	projectile.impact.connect(func(point: Vector2, family: String):
		fx.spawn("fire_impact" if family == "fire" else "impact", point, direction.x))
	level_root.add_child(projectile)

func _audio() -> Node:
	return get_node("/root/Audio")

func _backdrop_for(theme: String) -> String:
	match theme:
		"bamboo": return "bamboo"
		"rooftops", "sanctuary": return "roofs"
		_: return "castle"

func _resource_paths(data: Dictionary) -> Array[String]:
	return ["res://art/pixel/sky.png", "res://art/pixel/" + _backdrop_for(data.theme) + ".png", "res://art/pixel/" + ("platform" if data.theme in ["approach", "bamboo"] else "rampart") + ".png", "res://art/pixel/torch.png", "res://art/pixel/shrine.png"]

func _build_background() -> void:
	var backdrop := CanvasLayer.new()
	backdrop.layer = -10
	add_child(backdrop)
	for spec in [[true, 0.035, 0.8], [false, 0.10, 0.0], [false, 0.26, 0.0]]:
		var sprites: Array[Sprite2D] = []
		for i in range(4):
			var visual := Sprite2D.new()
			visual.centered = false
			visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			visual.flip_h = i % 2 == 1
			backdrop.add_child(visual)
			sprites.append(visual)
		background_layers.append({"sprites":sprites, "ratio":spec[1], "speed":spec[2], "sky":spec[0]})

func _build_welcome() -> void:
	welcome_layer = CanvasLayer.new()
	welcome_layer.layer = 1
	add_child(welcome_layer)
	welcome_art = Sprite2D.new()
	welcome_art.texture = load("res://art/pixel/ashen-veil-welcome.png")
	welcome_art.centered = false
	welcome_art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	welcome_layer.add_child(welcome_art)

func _build_weather() -> void:
	var weather := CanvasLayer.new()
	weather.layer = -2
	add_child(weather)
	snow_field = preload("res://systems/snow_field.gd").new()
	snow_field.process_mode = Node.PROCESS_MODE_PAUSABLE
	weather.add_child(snow_field)

func _set_background(data: Dictionary) -> void:
	var sky_texture: Texture2D = textures["res://art/pixel/sky.png"]
	var near_texture: Texture2D = textures["res://art/pixel/" + _backdrop_for(data.theme) + ".png"]
	var tint: Color = {"approach":Color(1,0.9,0.88), "courtyard":Color(1.1,0.86,0.8), "bamboo":Color(0.8,0.78,0.88), "rooftops":Color(0.88,0.85,1.0), "sanctuary":Color(1.0,0.8,0.85), "summit":Color(1.18,0.76,0.76)}[data.theme]
	for layer in background_layers:
		for visual in layer.sprites:
			visual.texture = sky_texture if layer.sky else near_texture
			if not layer.sky and layer.ratio < 0.2:
				visual.texture = load("res://art/concept-pass/skyline.png")
			elif not layer.sky and data.theme in ["approach", "courtyard"]:
				visual.texture = load("res://art/pixel/castle-separated.png")
			visual.modulate = tint
			if not layer.sky:
				visual.modulate *= Color(0.66,0.64,0.72,1) if layer.ratio < 0.2 else Color(0.58,0.52,0.60,1)

func _decorate_platform(body: PhysicsBody2D, width: float, one_way: bool = false) -> void:
	body.z_index = -1
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, 24 if one_way else (56 if body is AnimatableBody2D else maxf(144, 820 - body.position.y)))
	body.set_meta("foundation_depth", shape.size.y)
	collider.shape = shape
	collider.position.y = shape.size.y / 2
	collider.one_way_collision = one_way
	body.add_child(collider)
	preload("res://systems/terrain_visual.gd").decorate(body, width, one_way)

func _decorate_scenery(segment: Dictionary) -> void:
	if segment.get("optional",false) or segment.width<400: return
	var count: int=clampi(floori(segment.width/450.0),1,3)
	for i in range(count):
		var prop:=preload("res://systems/scenery_prop.gd").new()
		prop.variant=(i+level-1+int(segment.center.x/1200))%6
		var x: float=segment.center.x-segment.width*0.5+100+i*(segment.width-180)/maxi(1,count)
		if absf(x-map.spawn.x)<85:x+=100
		prop.position=Vector2(clampf(x,segment.center.x-segment.width*0.5+40,segment.center.x+segment.width*0.5-40),segment.center.y)
		prop.scale=Vector2(1.35,1.35)
		prop.phase=float(i+level)
		level_root.add_child(prop)

func _make_torch_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.set_animation_speed("default", 9)
	var texture: Texture2D = textures["res://art/pixel/torch.png"]
	for i in range(8):
		var frame := AtlasTexture.new()
		frame.atlas = texture
		frame.region = Rect2(i % 2 * 32, i / 2 * 48, 32, 48)
		frames.add_frame("default", frame)
	return frames

func _torch(at: Vector2, phase: int) -> void:
	var torch := AnimatedSprite2D.new()
	torch.sprite_frames = torch_frames
	torch.position = at
	torch.offset = Vector2(0, -24)
	torch.scale = Vector2(1.8, 1.8)
	torch.z_index = -1
	torch.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	level_root.add_child(torch)
	torch.play("default")
	torch.frame = phase % 8

func _populate_level(data: Dictionary) -> void:
	_audio().set_defeated(false)
	run_token += 1
	threat_hold = 0
	if is_instance_valid(level_root):
		level_root.free()
	level_root = Node2D.new()
	level_root.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(level_root)
	map = data
	level = data.id
	platform_surface = 0
	_set_background(data)
	torch_frames = _make_torch_frames()
	lifts.clear()
	for segment in data.platforms:
		var body := StaticBody2D.new()
		body.position = segment.center
		_decorate_platform(body, segment.width, segment.get("one_way", false))
		level_root.add_child(body)
		if not segment.get("optional", false) and segment.width >= 400:
			_torch(segment.center + Vector2(-segment.width / 2 + 65, 0), int(segment.center.x) / 50)
		_decorate_scenery(segment)
	for lift in data.lifts:
		var body: AnimatableBody2D = preload("res://systems/moving_platform.gd").new()
		body.position = lift.center
		body.travel = lift.travel
		body.duration = lift.duration
		_decorate_platform(body, lift.width)
		level_root.add_child(body)
		lifts.append(body)
	moving_platform = lifts[0] if not lifts.is_empty() else null
	shrine = Sprite2D.new()
	shrine.texture = preload("res://art/crimson-gate/gate.png")
	shrine.hframes = 4
	gate_open = false
	gate_entry_time = 0.0
	shrine.position = data.exit
	shrine.offset = Vector2(0, -88)
	shrine.scale = Vector2(1.5, 1.5)
	shrine.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	shrine.modulate = Color(0.65, 0.58, 0.6)
	level_root.add_child(shrine)
	camera_initialized = false
	camera_trauma = 0
	player.position = data.spawn
	player.reset_physics_interpolation()
	player.map_width = data.width
	player.velocity = Vector2.ZERO
	player.health = 100
	player.invulnerable = 0
	player.attack_time = 0
	player.dodge_time = 0
	player.dodge_cooldown = 0
	player.hurt_left = 0
	player.jump_buffer_left = 0
	player.attack_buffer_left = 0
	player.coyote_left = 0
	player.facing = 1
	player.reset_motion_presentation()
	player.sprite.play("idle")
	for effect in fx.get_children():
		effect.queue_free()
	hud.set_health(100, 100)
	hud.set_exit_available(false)
	remaining = data.enemies.size()
	var token: int = run_token
	for guard in data.enemies:
		var enemy := Enemy.new()
		enemy.enemy_kind = guard.get("kind", "guard")
		enemy.position = guard.position
		enemy.z_index = 2
		enemy.target = player
		enemy.defeated.connect(func():
			if token == run_token:
				_enemy_defeated())
		enemy.fx_requested.connect(_enemy_fx)
		enemy.projectile_requested.connect(_spawn_projectile)
		level_root.add_child(enemy)
		if guard.elite:
			enemy.health = 175 if level < 6 else 210
			enemy.approach_speed = 125
			enemy.modulate = Color(1.3, 0.8, 0.72)
	hud.set_progress(level, remaining)

func _enemy_defeated() -> void:
	remaining = maxi(0, remaining - 1)
	shrine.modulate = Color(1.4, 1.25, 1.05) if remaining == 0 else Color(0.65, 0.58, 0.6)
	if remaining == 0:
		_audio().play("bell")
		var field := preload("res://systems/gate_field.gd").new()
		field.name = "GateField"
		field.position = Vector2(0, -55)
		shrine.add_child(field)
		var gate_tween := create_tween()
		gate_tween.tween_method(func(value: float):
			if is_instance_valid(shrine): shrine.frame = mini(3,int(value)),0.0,3.99,0.8)
		gate_tween.tween_callback(func():
			gate_open = true
			if is_instance_valid(shrine):
				fx.burst("charge",shrine.position+Vector2(0,-90),1)
				_audio().play("power"))
	hud.set_progress(level, remaining)

func start_game() -> void:
	_choose_level(1)

func _choose_level(index: int) -> void:
	if not transitioning:
		_transition_level(clampi(index, 1, 6))

func _transition_level(index: int) -> void:
	transitioning = true
	get_tree().paused = true
	_audio().set_combat(false)
	var data: Dictionary = CampaignData.get_level(index)
	hud.show_loading(index, data.name)
	hud.set_loading_progress(0, "Loading")
	await get_tree().process_frame
	var paths: Array[String] = _resource_paths(data)
	for path in paths:
		ResourceLoader.load_threaded_request(path)
	var ready: bool = false
	while not ready:
		ready = true
		var fraction: float = 0
		for path in paths:
			var progress: Array = []
			var status: int = ResourceLoader.load_threaded_get_status(path, progress)
			if status == ResourceLoader.THREAD_LOAD_LOADED:
				fraction += 1
			elif status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				ready = false
				fraction += float(progress[0]) if not progress.is_empty() else 0.0
			else:
				push_error("Failed to load level resource: " + path)
				transitioning = false
				hud.show_title()
				return
		hud.set_loading_progress(0.75 * fraction / paths.size(), "Loading")
		await get_tree().process_frame
	for path in paths:
		textures[path] = ResourceLoader.load_threaded_get(path)
	hud.set_loading_progress(0.85, "Building route")
	await get_tree().process_frame
	_populate_level(data)
	hud.set_loading_progress(1, "Ready")
	await get_tree().process_frame
	await hud.finish_loading()
	started = true
	transitioning = false
	get_tree().paused = false
	level_loaded.emit(index)
	# Chapter text is available on demand; entering a route keeps play in motion.
	hud.set_state(StoryBook.objective(index))

func _show_story(index: int, ending: bool) -> void:
	if transitioning or not started: return
	player.cancel_pending_input()
	hud.touch.release_all()
	hud.touch.hide()
	get_tree().paused = true
	story_ending = ending
	story_card.show_chapter(index, ending)

func _finish_story() -> void:
	await get_tree().process_frame
	player.cancel_pending_input()
	hud.touch.release_all()
	if story_ending:
		hud.show_result(true)
	else:
		hud.close_menu()
		get_tree().paused = false
		hud.set_state(preload("res://systems/story_book.gd").objective(level))

func _reset_encounter() -> void:
	# Synchronous reset remains useful for isolated test setup.
	_populate_level(map)

func pause_game() -> void:
	player.cancel_pending_input()
	if not started or get_tree().paused or transitioning:
		return
	get_tree().paused = true
	_audio().set_combat(false)
	hud.show_pause()

func resume_game() -> void:
	if transitioning:
		return
	hud.close_menu()
	get_tree().paused = false

func retry_game() -> void:
	_choose_level(level)

func main_menu() -> void:
	_audio().set_defeated(false)
	player.cancel_pending_input()
	if transitioning:
		return
	run_token += 1
	started = false
	get_tree().paused = true
	_audio().set_combat(false)
	hud.show_title()

func _player_state(value: String) -> void:
	if value == "Defeated":
		# Remove touch affordances for the whole death beat, not only once the
		# result card finally covers gameplay.
		hud.hide_touch_controls()
	if player.health == 0:
		var token: int = run_token
		var duration: float = player.death_duration()
		await get_tree().create_timer(duration, false).timeout
		if token == run_token and player.health == 0 and started:
			get_tree().paused = true
			_audio().set_combat(false)
			hud.show_result(false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		hud.handle_back()
		get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(hud) and not "--qa-gameplay" in OS.get_cmdline_user_args():
		pause_game()

func _process(delta: float) -> void:
	elapsed += delta
	if not OS.has_feature("mobile"):
		var desired_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_HIDDEN if started and not get_tree().paused and not transitioning else Input.MOUSE_MODE_VISIBLE
		if Input.mouse_mode != desired_mouse_mode: Input.mouse_mode = desired_mouse_mode
	if is_instance_valid(welcome_layer):
		welcome_layer.visible = not started
		var extent := get_viewport_rect().size
		var cover: float = maxf(extent.x/640.0,extent.y/360.0)*1.06
		welcome_art.scale = Vector2.ONE*cover
		welcome_art.position = (extent-Vector2(640,360)*cover)*0.5+Vector2(sin(elapsed*0.16)*4,cos(elapsed*0.11)*2)
	if not is_instance_valid(player) or map.is_empty():
		return
	# Mild contact push-in; ease back without changing gameplay or UI scale.
	var shot_zoom: float = 0.69 + camera_trauma * 0.045
	camera.zoom = camera.zoom.lerp(Vector2.ONE*shot_zoom,1.0-exp(-delta*5.0))
	var half_width: float = get_viewport_rect().size.x / (2.0*camera.zoom.x)
	if not camera_initialized or player.is_on_floor(): camera_ground_y = player.position.y
	var rise_follow: float = clampf((camera_ground_y-player.position.y)*0.9,0,130)
	var camera_target := Vector2(clampf(player.position.x + player.velocity.x*0.14, half_width, maxf(half_width,map.width-half_width)),clampf(camera_ground_y-135-rise_follow,250,500))
	if not camera_initialized:
		camera.position = camera_target
		camera_initialized = true
	elif not get_tree().paused:
		camera.position.x = lerpf(camera.position.x,camera_target.x,1.0-exp(-delta*8.0))
		camera.position.y = lerpf(camera.position.y,camera_target.y,1.0-exp(-delta*12.0))
	camera_trauma = maxf(0,camera_trauma-delta*1.8)
	camera.offset = Vector2(sin(elapsed*43),cos(elapsed*51))*camera_trauma*camera_trauma*12
	if is_instance_valid(snow_field): snow_field.camera_x = camera.position.x - half_width
	for layer in background_layers:
		if layer.sky:
			var cover_scale: float = maxf(get_viewport_rect().size.x / 640.0, get_viewport_rect().size.y / 360.0)
			var tile_width: float = 640.0 * cover_scale
			var sky_offset: float = fposmod(elapsed * layer.speed + (camera.position.x-half_width)*0.5*layer.ratio, tile_width*2)
			for i in range(layer.sprites.size()):
				var visual: Sprite2D = layer.sprites[i]
				visual.show()
				visual.scale = Vector2.ONE * cover_scale
				visual.position = Vector2(i*tile_width-sky_offset, -(360*cover_scale-get_viewport_rect().size.y)*0.5)
			continue
		var layer_scale: float = 1.0 if layer.ratio < 0.2 else 0.82
		var layer_width: float = 640.0 * layer_scale
		var offset: float = fposmod((camera.position.x-half_width)*0.5*layer.ratio,layer_width*2)
		for i in range(layer.sprites.size()):
			layer.sprites[i].scale = Vector2.ONE*layer_scale
			layer.sprites[i].position = Vector2(i*layer_width-offset,360*(1-layer_scale)-(camera.position.y-360)*layer.ratio*0.5)
	if started and not get_tree().paused and not transitioning:
		var at_exit: bool = player.position.distance_to(map.exit) < 120
		hud.set_exit_available(remaining == 0 and gate_open and at_exit)
		var near_threat: bool = false
		for guard in get_tree().get_nodes_in_group("enemies"):
			if guard.health > 0 and guard.position.distance_to(player.position) < 470:
				near_threat = true
				break
		threat_hold = 2.0 if near_threat else maxf(0, threat_hold - delta)
		_audio().set_combat(threat_hold > 0 and player.health > 0)
		if Input.is_action_just_pressed("restart"):
			retry_game()
		# Walking into the aperture charges passage; leaving it cancels the charge.
		var inside_gate: bool = absf(player.position.x - map.exit.x) < 34 and absf(player.position.y - map.exit.y) < 24
		var can_enter: bool = remaining == 0 and gate_open and player.health > 0
		gate_entry_time = minf(0.45, gate_entry_time + delta) if can_enter and inside_gate else 0.0
		var gate_field := shrine.get_node_or_null("GateField")
		if gate_field != null:
			gate_field.entry_charge = gate_entry_time / 0.45
		if (Input.is_action_just_pressed("interact") or gate_entry_time >= 0.45) and can_enter and at_exit:
			if level < 6:
				hud.unlock_level(level + 1)
				_choose_level(level + 1)
			else:
				get_tree().paused = true
				_audio().set_combat(false)
				if DisplayServer.get_name() != "headless" and not "--qa-gameplay" in OS.get_cmdline_user_args():
					_show_story(level, true)
				else: hud.show_result(true)
	if not screenshot_path.is_empty() and elapsed > 1.0 and not capture_started and not transitioning:
		capture_started = true
		_capture_qa_frame()

func _capture_qa_frame() -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(screenshot_path)
	await quit_game()

func quit_game() -> void:
	_audio().shutdown()
	await get_tree().create_timer(0.12, true).timeout
	get_tree().quit()
