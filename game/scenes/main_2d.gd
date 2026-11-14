extends Node2D
signal level_loaded(index: int)
const Player = preload("res://actors/player_2d.gd")
const Enemy = preload("res://actors/enemy_2d.gd")
const Hud = preload("res://ui/hud.gd")
const ObjectiveTracker = preload("res://systems/objective_tracker.gd")
const SkillInventory = preload("res://systems/skill_inventory.gd")
var skill_inventory: RefCounted
var inventory_screen: Control
var inventory_layer: CanvasLayer
var inventory_button: Button
var nova_button: Button
var heal_button: Button
var objective_guide: Control
var guide_refresh_left := 0.0
const CampaignData = preload("res://data/campaign.gd")
const SaveStore = preload("res://systems/run/save_store.gd")
const RunProgression = preload("res://systems/run/run_progression.gd")
const CameraDirector = preload("res://systems/run/camera_director.gd")
const BackgroundDirector = preload("res://systems/run/background_director.gd")
const FxDirector = preload("res://systems/run/fx_director.gd")
var save_store: RefCounted
var progression: RefCounted
var camera_director: RefCounted
var background_director: RefCounted
var fx_director: RefCounted
var required_devices: Dictionary = {}
var active_realm := "surface"
var tidal_water: Node2D
var sequence_machine: Node2D
var player: CharacterBody2D
var hud: CanvasLayer
var camera: Camera2D
var remaining: int = 0
var coins: int = 0
var banked_coins: int = 0
var seals_left: int = 0
var marked_left: int = 0
var gate_opening: bool:
	get: return progression.gate_opening
	set(value): progression.gate_opening = value
var level: int = 1
var elapsed: float = 0
var screenshot_path: String = ""
var capture_started: bool = false
var background_layers: Array[Dictionary]:
	get: return background_director.layers
var snow_field: Node2D
var camera_trauma: float:
	get: return camera_director.trauma
	set(value): camera_director.trauma = value
var camera_initialized: bool:
	get: return camera_director.initialized
	set(value): camera_director.initialized = value
var welcome_layer: CanvasLayer
var welcome_art: Sprite2D
var moving_platform: AnimatableBody2D
var lifts: Array[AnimatableBody2D] = []
var fx: Node2D
var started: bool = false
var run_token: int = 0
var shrine: Sprite2D
var gate_open: bool:
	get: return progression.gate_open
	set(value): progression.gate_open = value
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
	progression = RunProgression.new()
	camera_director = CameraDirector.new()
	background_director = BackgroundDirector.new()
	fx_director = FxDirector.new()
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
	save_store = SaveStore.new(hud.settings, hud.settings_path)
	banked_coins = save_store.coins()
	coins = banked_coins
	fx_director.bind(fx, player, camera_director, hud.damage_veil, level_root)
	_build_inventory()
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
				qa_level = clampi(int(arg.trim_prefix("--qa-level=")), 1, CampaignData.levels().size())
		_choose_level(qa_level)

func _enemy_fx(kind: String, at: Vector2, direction: float) -> void:
	fx_director.enemy(kind, at, direction)

func _player_fx(kind: String, at: Vector2, direction: float) -> void:
	fx_director.player_effect(kind, at, direction)

func _spawn_projectile(kind: String, at: Vector2, direction: Vector2, source: Node) -> void:
	fx_director.projectile(kind, at, direction, source)

func _water_impact(at: Vector2) -> void:
	fx_director.water_impact(at)

func _audio() -> Node:
	return get_node("/root/Audio")

func _backdrop_for(theme: String) -> String:
	return BackgroundDirector.backdrop_for(theme)

func _build_background() -> void:
	background_director.build(self)

func _resource_paths(data: Dictionary) -> Array[String]:
	return ["res://art/pixel/sky.png", "res://art/pixel/" + _backdrop_for(data.theme) + ".png", "res://art/pixel/" + ("platform" if data.theme in ["approach", "bamboo"] else "rampart") + ".png", "res://art/pixel/torch.png", "res://art/pixel/shrine.png"]

func _build_welcome() -> void:
	welcome_layer=CanvasLayer.new()
	welcome_layer.layer=1
	add_child(welcome_layer)
	var backdrop:=ColorRect.new()
	backdrop.color=Color("10090d")
	backdrop.mouse_filter=Control.MOUSE_FILTER_IGNORE
	welcome_layer.add_child(backdrop)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	welcome_art=Sprite2D.new()
	welcome_layer.add_child(welcome_art)

func _build_weather() -> void:
	var weather := CanvasLayer.new()
	weather.layer = -2
	add_child(weather)
	snow_field = preload("res://systems/snow_field.gd").new()
	snow_field.process_mode = Node.PROCESS_MODE_PAUSABLE
	weather.add_child(snow_field)

func _set_background(data: Dictionary) -> void:
	background_director.set_theme(data, textures, snow_field)

func _decorate_platform(body: PhysicsBody2D, width: float, one_way: bool = false) -> void:
	body.z_index = -1
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, float(body.get_meta("deck_depth",24 if one_way else (56 if body is AnimatableBody2D else maxf(144,820-body.position.y)))))
	body.set_meta("foundation_depth", shape.size.y)
	collider.shape = shape
	collider.position.y = shape.size.y / 2
	collider.one_way_collision = one_way
	collider.one_way_collision_margin = 8.0 if one_way else 1.0
	body.add_child(collider)
	preload("res://systems/terrain_visual.gd").decorate(body, width, one_way)

func _decorate_scenery(segment: Dictionary) -> void:
	if segment.get("optional",false) or segment.width<400 or _biome_at(segment.center) != "surface": return
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

func _place_fire_barrels() -> void:
	# A small deterministic set of hazards per route. Water routes and shafts
	# keep their authored traversal clean.
	if map.has("water_bounds") or map.get("shaft",false): return
	var candidates: Array = []
	for segment in map.platforms:
		if segment.get("optional",false) or float(segment.width) < 360.0: continue
		if _biome_at(segment.center) in ["sky","underwater"]: continue
		candidates.append(segment)
	if candidates.is_empty(): return
	var rng := RandomNumberGenerator.new()
	rng.seed = level * 7919 + 41
	var count: int = mini(2 + level % 2, candidates.size())
	for i in range(count):
		var pick: int = rng.randi_range(0, candidates.size() - 1)
		var segment: Dictionary = candidates[pick]
		candidates.remove_at(pick)
		var half: float = float(segment.width) * 0.5
		var x: float = float(segment.center.x) + rng.randf_range(-half * 0.55, half * 0.55)
		x = _clear_fire_barrel_space(x, segment)
		var barrel = preload("res://systems/fire_barrel.gd").new()
		barrel.position = Vector2(roundf(x), segment.center.y)
		barrel.direction = 1.0 if x < segment.center.x else -1.0
		barrel.fused.connect(_fire_barrel_fused)
		barrel.detonated.connect(_fire_barrel_detonated)
		level_root.add_child(barrel)
		if candidates.is_empty(): break

func _clear_fire_barrel_space(x: float, segment: Dictionary) -> float:
	var landmarks: Array = [map.spawn, map.exit]
	for item in map.get("pickups",[]): landmarks.append(item.position)
	for record in map.get("devices",[]): landmarks.append(record.position)
	for point in landmarks:
		if absf(x - point.x) < 130.0 and absf(float(segment.center.y) - point.y) < 150.0:
			x = point.x + (170.0 if x >= point.x else -170.0)
	return clampf(x, float(segment.center.x) - float(segment.width) * 0.5 + 70.0, float(segment.center.x) + float(segment.width) * 0.5 - 70.0)

func _fire_barrel_fused(at: Vector2) -> void:
	_audio().play("charge")
	fx.burst("fire_cast", at + Vector2(0, -42), 1)

func _fire_barrel_detonated(at: Vector2, direction: float) -> void:
	fx.spawn("barrel_blast", at + Vector2(0, -30), direction)
	fx.spawn("barrel_scorch", at, direction)
	camera_director.add_trauma(0.90, 0.65)
	_audio().play("explosion")
	if player.global_position.distance_to(at) < 190.0:
		hud.damage_veil.splash(0.55)

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
	var flame := preload("res://systems/pixel_brazier.gd").new()
	flame.position = at
	flame.phase = float(phase)*0.17
	flame.variant = absi(phase)%3
	level_root.add_child(flame)

func _populate_level(data: Dictionary) -> void:
	_audio().set_defeated(false)
	run_token += 1
	for projectile in get_tree().get_nodes_in_group("combat_projectiles"):
		projectile.free()
	threat_hold = 0
	if is_instance_valid(level_root):
		level_root.free()
	level_root = Node2D.new()
	level_root.process_mode = Node.PROCESS_MODE_PAUSABLE
	fx_director.root = level_root
	add_child(level_root)
	sequence_machine = null
	tidal_water = null
	fx_director.water = null
	player.set_submerged(false)
	player.set_physics_process(true)
	map = data
	required_devices.clear()
	active_realm = "surface"
	level = data.id
	platform_surface = 0
	_set_background(data)
	torch_frames = _make_torch_frames()
	lifts.clear()
	if data.get("shaft",false):
		for side in [-1.0,1.0]:
			var wall:=preload("res://systems/shaft_architecture.gd").new()
			wall.side=side
			wall.position=Vector2((540 if side<0 else 1070)*data.width/1800.0,data.spawn.y)
			wall.scale.x=data.width/1800.0
			level_root.add_child(wall)
	for segment in data.platforms:
		var body := StaticBody2D.new()
		body.position = segment.center
		body.set_meta("wall_shelf",data.get("shaft",false))
		body.set_meta("construction",segment.get("construction","legacy"))
		body.set_meta("biome",_biome_at(segment.center))
		var support_depth: float = float(data.get("height",1100))+80-segment.center.y
		var has_lower := false
		for lower in data.platforms:
			if lower.center.y <= segment.center.y+20: continue
			if absf(lower.center.x-segment.center.x) < (lower.width+segment.width)*0.5:
				support_depth = minf(support_depth,lower.center.y-segment.center.y)
				has_lower = true
		var ground_depth: float = float(segment.get("depth",40))
		if not segment.get("one_way",false) and not has_lower and not data.get("shaft",false) and not data.get("vertical_route",false) and _biome_at(segment.center) != "sky":
			ground_depth = maxf(ground_depth,support_depth)
		body.set_meta("support_depth",0 if data.get("vertical_route",false) else support_depth)
		body.set_meta("deck_depth",ground_depth)
		_decorate_platform(body, segment.width, segment.get("one_way", false))
		level_root.add_child(body)
		if not segment.get("optional", false) and segment.width >= 400 and _biome_at(segment.center) in ["surface","citadel"]:
			_torch(segment.center + Vector2(-segment.width / 2 + 65, 0), int(segment.center.x) / 50)
		_decorate_scenery(segment)
	_place_fire_barrels()
	for lift in data.lifts:
		var body: AnimatableBody2D = preload("res://systems/moving_platform.gd").new()
		body.position = lift.center
		body.travel = lift.travel
		body.duration = lift.duration
		body.set_meta("biome",_biome_at(lift.center))
		_decorate_platform(body, lift.width, lift.get("one_way",false))
		level_root.add_child(body)
		lifts.append(body)
	moving_platform = lifts[0] if not lifts.is_empty() else null
	shrine = Sprite2D.new()
	shrine.texture = preload("res://art/crimson-gate/gate.png")
	shrine.hframes = 4
	progression.reset()
	gate_entry_time = 0.0
	shrine.position = data.exit
	shrine.offset = Vector2(0, -88)
	var gate_scale: Array = data.get("gate_visual",{}).get("scale",[0.65,1.0])
	shrine.scale = Vector2(gate_scale[0],gate_scale[1])
	shrine.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	shrine.modulate = Color(0.65, 0.58, 0.6)
	level_root.add_child(shrine)
	camera_director.reset()
	player.position = data.spawn
	player.reset_physics_interpolation()
	player.map_width = data.width
	player.map_bottom = data.get("height",950.0)
	player.velocity = Vector2.ZERO
	player.laser_unlocked = level >= 20
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
	if skill_inventory != null: player.apply_skill_inventory(skill_inventory,true)
	hud.set_health(player.health, player.max_health)
	hud.set_exit_available(false)
	coins=banked_coins
	seals_left=0
	marked_left=0
	for item in data.get("pickups",[]):
		_spawn_pickup(item.kind,item.amount,item.position)
		if item.kind=="seal": seals_left+=1
	for record in data.enemies:
		if record.get("boss",false) or record.get("captain",false): marked_left+=1
	remaining = data.enemies.size()
	var token: int = run_token
	for guard in data.enemies:
		_spawn_campaign_enemy(guard,token)
	for record in data.get("devices",[]):
		var device := preload("res://systems/realm_device.gd").new()
		device.setup(player,record)
		if record.get("required",false): required_devices[str(record.id)] = true
		device.completed.connect(func(id: String):
			required_devices.erase(id)
			_update_mission()
			_check_gate())
		device.realm_requested.connect(_enter_realm)
		level_root.add_child(device)
	if level == 11:
		sequence_machine = preload("res://systems/sequence_machine.gd").new()
		sequence_machine.player = player
		sequence_machine.position = Vector2(data.exit.x-160,data.exit.y)
		level_root.add_child(sequence_machine)
		sequence_machine.completed.connect(func():
			fx.burst("charge",sequence_machine.position,1)
			camera_director.add_trauma(0.6)
			_update_mission()
			_check_gate())
	if data.has("water_bounds"):
		tidal_water = preload("res://systems/tidal_water.gd").new()
		fx_director.water = tidal_water
		tidal_water.player = player
		tidal_water.bounds = data.water_bounds
		tidal_water.currents = data.get("water_currents",[])
		tidal_water.immersion_changed.connect(func(wet: bool):
			var view := map.duplicate()
			view.biome = "underwater" if wet else "surface"
			_set_background(view)
			hud.set_state("W / SPACE rise · S dive · I water pulse" if wet else "Back above water")
			_update_mission()
			_check_gate())
		level_root.add_child(tidal_water)
		var view := data.duplicate()
		view.biome = "surface"
		_set_background(view)
	_update_mission()

func _spawn_campaign_enemy(guard: Dictionary, token: int) -> void:
	var enemy := Enemy.new()
	enemy.enemy_kind = guard.get("kind", "guard")
	if guard.get("swim",false):
		enemy.swimming = true
		enemy.swim_bounds = map.water_bounds
		enemy.swim_role = guard.get("swim_role","crab")
	enemy.position = guard.position
	enemy.map_bottom = map.get("height",950.0)
	enemy.z_index = 2
	enemy.target = player
	enemy.attack_skill = guard.get("skill","native")
	enemy.projectile_damage = int(guard.get("projectile_damage",10))
	if guard.get("brood_child",false): enemy.set_meta("brood_child",true)
	if enemy.has_signal("brood_requested"):
		enemy.connect("brood_requested",func(specs: Array):
			if token != run_token: return
			for spec in specs.slice(0,6):
				spec["captain"] = true
				remaining += 1
				marked_left += 1
				_spawn_campaign_enemy(spec,token))
	enemy.defeated.connect(func():
		if token == run_token:
			_enemy_defeated(enemy,guard.get("boss",false) or guard.get("captain",false)))
	enemy.fx_requested.connect(_enemy_fx)
	enemy.fragments_requested.connect(func(actor: Node2D, direction: float): fx.shatter(actor.rig,actor.global_position+Vector2(0,-45),direction))
	enemy.projectile_requested.connect(_spawn_projectile)
	level_root.add_child(enemy)
	enemy.health += int(guard.get("health_bonus",0))
	if guard.get("boss",false):
		enemy.is_boss = true
		enemy.boss_name = guard.boss_name
		enemy.health = guard.health
		enemy.mass_kg = 180
		enemy.knockback_resistance = 1.6
		enemy.scale = Vector2.ONE * float(guard.get("boss_scale",1.0))
		enemy.melee_damage = int(guard.get("melee_damage",30))
		enemy.projectile_damage = int(guard.get("projectile_damage",20))
		enemy.modulate = Color(1.2,0.65,0.65)
	if guard.get("captain",false):
		enemy.modulate=Color(1.1,0.75,0.55)
	if guard.get("boss",false) or guard.get("captain",false):
		enemy.set_meta("marked",true)
	if guard.get("elite",false):
		enemy.health = 175 if level < 6 else 210
		enemy.approach_speed = 125
		enemy.modulate = Color(1.3, 0.8, 0.72)
	enemy.apply_monster_profile(int(guard.get("monster_id",0)))
	if guard.get("brood_child",false): enemy.health = int(guard.get("health",22))
	if guard.has("signature"): enemy.configure_signature(guard.signature)
	enemy.configure_health_display()


func _biome_at(at: Vector2) -> String:
	if map.has("water_bounds"):
		return "underwater" if map.water_bounds.grow(2).has_point(at) else "surface"
	for region in map.get("realm_regions",[]):
		if region.bounds.has_point(at): return region.biome
	return map.get("biome","surface")

func _enter_realm(destination: String) -> void:
	for region in map.get("realm_regions",[]):
		if region.id != destination: continue
		active_realm = destination
		player.prepare_realm_transition()
		player.position = region.spawn
		player.velocity = Vector2.ZERO
		player.reset_physics_interpolation()
		camera_director.initialized = false
		var view := map.duplicate()
		view.biome = region.biome
		_set_background(view)
		for device in get_tree().get_nodes_in_group("realm_devices"):
			if device.kind == "portal": device.cooldown = 1.0
		fx.burst("charge",player.position,player.facing)
		return

func _spawn_pickup(kind: String, amount: int, at: Vector2) -> void:
	var pickup:=preload("res://systems/world_pickup.gd").new()
	pickup.kind=kind
	pickup.amount=amount
	pickup.position=at
	pickup.target=player
	pickup.collected.connect(_pickup_collected)
	level_root.add_child(pickup)
	if map.has("water_bounds") and kind == "seal":
		pickup.visual.texture = preload("res://art/tidal-castle/pearl.png")
		pickup.visual.scale = Vector2.ONE

func _pickup_collected(kind: String, amount: int, at: Vector2) -> void:
	if player.health<=0: return
	match kind:
		"coin": coins+=amount
		"health":
			player.health=mini(player.max_health,player.health+amount)
			player.health_changed.emit(player.health,player.max_health)
		"seal": seals_left=maxi(0,seals_left-1)
	fx.spawn("heal" if kind=="health" else "sparkle",at,1)
	_audio().play("ui" if kind=="coin" else "bell")
	_update_mission()
	_check_gate()

func _objective_state() -> Dictionary:
	var phase: String = sequence_machine.phase if is_instance_valid(sequence_machine) else "idle"
	return ObjectiveTracker.describe(map,remaining,seals_left,marked_left,required_devices,phase,player.submerged)

func _objectives_met() -> bool:
	return bool(_objective_state().complete)

func _refresh_guide() -> void:
	if not is_instance_valid(objective_guide) or map.is_empty(): return
	var enemies: Array = []
	var pickups: Array = []
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.health > 0 and not enemy.is_queued_for_deletion(): enemies.append({"position":enemy.global_position,"marked":enemy.get_meta("marked",false)})
	for pickup in get_tree().get_nodes_in_group("world_pickups"):
		if not pickup.taken: pickups.append({"position":pickup.global_position,"kind":pickup.kind})
	var state := _objective_state()
	var targets: Array = ObjectiveTracker.targets(map,state,enemies,pickups,player.position,active_realm,player.relic_charges)
	objective_guide.refresh(state.text,targets[0] if not targets.is_empty() else {},player.position)
	inventory_button.text = "B · ARMORY"
	nova_button.text = "Q NOVA · %d" % skill_inventory.charges.tide
	heal_button.text = "H HEAL · %d" % skill_inventory.charges.heal
	nova_button.visible = skill_inventory.charges.tide>0
	heal_button.visible = skill_inventory.charges.heal>0

func _update_mission() -> void:
	hud.set_rewards(coins,seals_left,"PEARLS" if map.has("water_bounds") else "SEALS")
	hud.set_progress(level,0 if _objectives_met() else maxi(1,remaining))
	_refresh_guide()

func _bank_rewards() -> void:
	banked_coins=coins
	save_store.set_coins(banked_coins)
	save_store.save(hud.settings_path)

func _enemy_defeated(enemy: Node2D = null, marked: bool = false) -> void:
	if marked: marked_left=maxi(0,marked_left-1)
	if is_instance_valid(enemy):
		var point: Vector2=enemy.position
		var best: Vector2=map.spawn
		var distance:=INF
		for surface in map.platforms:
			var candidate:=Vector2(clampf(point.x,surface.center.x-surface.width/2+35,surface.center.x+surface.width/2-35),surface.center.y-28)
			if candidate.distance_squared_to(point)<distance:
				distance=candidate.distance_squared_to(point)
				best=candidate
		_spawn_pickup("coin",20 if marked else 5,best)
		if remaining%3==0 or marked: _spawn_pickup("health",25,best+Vector2(32,-4))
	remaining=maxi(0,remaining-1)
	_update_mission()
	_check_gate()

func _check_gate() -> void:
	if not progression.begin_open(_objectives_met()): return
	shrine.modulate=Color(1.4,1.25,1.05)
	_audio().play("bell")
	var field:=preload("res://systems/gate_field.gd").new()
	field.name="GateField"
	field.position=Vector2(0,-55)
	shrine.add_child(field)
	var token:=run_token
	var gate_tween:=level_root.create_tween()
	gate_tween.tween_method(func(value: float):
		if is_instance_valid(shrine): shrine.frame=mini(3,int(value)),0.0,3.99,0.8)
	gate_tween.tween_callback(func():
		if token!=run_token: return
		progression.complete()
		hud.set_state("Gate open")
		fx.burst("charge",shrine.position+Vector2(0,-90),1)
		_audio().play("power"))

func start_game() -> void:
	_choose_level(1)

func _choose_level(index: int) -> void:
	if not transitioning:
		_transition_level(clampi(index, 1, CampaignData.levels().size()))

func _transition_level(index: int) -> void:
	if is_instance_valid(inventory_screen): inventory_screen.hide()
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
	# Route objectives live in the map and chapter screen, leaving combat clear.

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
		hud.state_label.hide()

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
	if value == "Fire and sun relics cannot ignite underwater": hud.set_state(value)
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
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_B:
		if is_instance_valid(inventory_screen) and inventory_screen.visible: _close_inventory()
		else: _open_inventory()
		get_viewport().set_input_as_handled()
		return
	if is_instance_valid(inventory_screen) and inventory_screen.visible: return
	if event.is_action_pressed("ui_cancel"):
		hud.handle_back()
		get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(hud) and not "--qa-gameplay" in OS.get_cmdline_user_args() and not "--qa-capture" in OS.get_cmdline_user_args():
		pause_game()

func _process(delta: float) -> void:
	elapsed += delta
	guide_refresh_left -= delta
	if guide_refresh_left <= 0 and started and not transitioning:
		guide_refresh_left = 0.25
		_refresh_guide()
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
	camera_director.update(delta, camera, map, player, get_viewport_rect().size, get_tree().paused)
	var half_width: float = get_viewport_rect().size.x / (2.0*camera.zoom.x)
	if is_instance_valid(snow_field): snow_field.camera_x = camera.position.x - half_width
	_layout_background(get_viewport_rect().size,Vector2(camera.position.x-half_width,camera.position.y-360))
	if started and not get_tree().paused and not transitioning:
		var at_exit: bool = player.position.distance_to(map.exit) < 120
		hud.set_exit_available(_objectives_met() and gate_open and at_exit)
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
		if Input.is_action_just_pressed("interact") and at_exit and not _objectives_met(): hud.set_state(_objective_state().text)
		var can_enter: bool = _objectives_met() and gate_open and player.health > 0
		gate_entry_time = minf(0.45, gate_entry_time + delta) if can_enter and inside_gate else 0.0
		var gate_field := shrine.get_node_or_null("GateField")
		if gate_field != null:
			gate_field.entry_charge = gate_entry_time / 0.45
		if (Input.is_action_just_pressed("interact") or gate_entry_time >= 0.45) and can_enter and at_exit:
			_bank_rewards()
			if level < CampaignData.levels().size():
				hud.unlock_level(level + 1)
				_choose_level(level + 1)
			else:
				get_tree().paused = true
				_audio().set_combat(false)
				if DisplayServer.get_name() != "headless" and not "--qa-gameplay" in OS.get_cmdline_user_args() and not "--qa-capture" in OS.get_cmdline_user_args():
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

func _layout_background(extent: Vector2, camera_shift: Vector2) -> void:
	background_director.layout(extent, camera_shift, elapsed)

func _build_inventory() -> void:
	skill_inventory = SkillInventory.new()
	skill_inventory.load_state(save_store.skill_state())
	player.apply_skill_inventory(skill_inventory)
	player.inventory_consumed.connect(func(_id: String):
		_save_skill_progress()
		_refresh_guide())
	inventory_layer = CanvasLayer.new()
	inventory_layer.layer = 30
	add_child(inventory_layer)
	inventory_screen = preload("res://ui/character_inventory.gd").new()
	inventory_screen.setup(skill_inventory,coins)
	inventory_layer.add_child(inventory_screen)
	inventory_screen.hide()
	inventory_screen.closed.connect(_close_inventory)
	hud.armory_requested.connect(_open_inventory)
	inventory_screen.purchase_requested.connect(_purchase_skill)
	inventory_button = Button.new()
	inventory_button.text="B · ARMORY"
	inventory_button.position=Vector2(12,98)
	inventory_button.custom_minimum_size=Vector2(132,28)
	inventory_button.add_theme_font_size_override("font_size",11)
	for state in ["normal","hover","pressed","focus"]:
		inventory_button.add_theme_stylebox_override(state,preload("res://ui/pixel_menu_components.gd").button_style(state in ["hover","focus"],true,state=="pressed"))
	hud.gameplay.add_child(inventory_button)
	inventory_button.pressed.connect(_open_inventory)
	for id in ["tide","heal"]:
		var action:=Button.new()
		action.text="Q · NOVA" if id=="tide" else "H · HEAL"
		action.position=Vector2(12 if id=="tide" else 110,132)
		action.custom_minimum_size=Vector2(92,30)
		action.add_theme_font_size_override("font_size",11)
		for state in ["normal","hover","pressed","focus"]: action.add_theme_stylebox_override(state,preload("res://ui/pixel_menu_components.gd").button_style(state in ["hover","focus"],true,state=="pressed"))
		hud.gameplay.add_child(action)
		action.pressed.connect(func(): player.use_inventory_skill(id))
		if id=="tide":nova_button=action
		else:heal_button=action
	objective_guide=preload("res://ui/objective_guide.gd").new()
	hud.gameplay.add_child(objective_guide)

func _open_inventory() -> void:
	if transitioning or get_tree().paused or player.health<=0: return
	player.cancel_pending_input()
	hud.touch.release_all()
	hud.gameplay.hide()
	get_tree().paused=true
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	inventory_screen.show()
	inventory_screen.refresh(coins)
	inventory_screen.close_button.grab_focus()

func _close_inventory() -> void:
	inventory_screen.hide()
	hud.gameplay.visible = started
	get_tree().paused=false
	player.cancel_pending_input()
	_refresh_guide()

func _save_skill_progress() -> Error:
	save_store.set_coins(banked_coins)
	save_store.set_skill_state(skill_inventory.export_state())
	return save_store.save(hud.settings_path)

func _purchase_skill(id: String) -> void:
	var before: Dictionary=skill_inventory.export_state()
	var old_coins: int=coins
	var old_bank: int=banked_coins
	var result: Dictionary=skill_inventory.purchase(id,coins)
	if result.ok:
		coins=int(result.wallet)
		banked_coins=coins
		if _save_skill_progress()!=OK:
			skill_inventory.load_state(before)
			coins=old_coins;banked_coins=old_bank
			result.message="Could not save. Purchase was cancelled."
		else:
			player.apply_skill_inventory(skill_inventory)
			hud.set_health(player.health,player.max_health)
			_audio().play("bell")
	inventory_screen.refresh(coins,result.message)
	_update_mission()
