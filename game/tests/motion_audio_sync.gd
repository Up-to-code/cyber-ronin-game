extends SceneTree
var events: Array[Dictionary] = []
var actor: Node
func _initialize() -> void: call_deferred("_run")
func _ticks(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func _run() -> void:
	var audio: Node = root.get_node("Audio")
	audio.cue_triggered.connect(func(cue: String):
		if is_instance_valid(actor): events.append({"cue":cue,"elapsed":actor.attack_duration-actor.attack_time,"contact":actor.attack_hit}))
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	scene.start_game()
	await scene.level_loaded
	actor = scene.player
	actor.invulnerable = 999
	for enemy in get_nodes_in_group("enemies"): enemy.set_physics_process(false)
	await _ticks(10)
	for kind in ["sword", "kick", "ranged"]:
		events.clear()
		if kind == "sword": actor._start_attack()
		else: actor._start_special(kind)
		var cue: String = actor._attack_motion_cue()
		var contact: float = actor.attack_duration * actor.attack_contact_progress
		var expected: float = maxf(0,contact-audio.motion_lead(cue))
		await _ticks(int(ceil(actor.attack_duration*60))+2)
		var found: Array = events.filter(func(e): return e.cue==cue)
		assert(found.size()==1,"Exactly one motion cue per action")
		assert(absf(found[0].elapsed-expected)<=1.0/60.0+0.002,"Motion cue must follow clip-derived lead within one physics tick")
		if kind != "ranged": assert(not found[0].contact,"Melee motion starts before contact")
		assert(actor.attack_hit,"Moving whoosh earlier must retain authored contact")
	# An interruption before the motion window must not leave a delayed sound queued.
	events.clear()
	actor._start_attack()
	actor.invulnerable = 0
	actor.take_damage(1,1)
	await _ticks(35)
	assert(not events.any(func(e): return e.cue in ["swing","swing_reverse","swing_finisher"]))
	# Enemy misses have a movement cue, never the body-contact recording.
	assert(audio.streams.enemy_heavy==audio.streams.enemy_swing)
	assert(audio.motion_lead("enemy_heavy")>audio.motion_lead("enemy_swing"))
	var guard: Node = get_nodes_in_group("enemies")[0]
	actor.set_physics_process(false)
	guard.target=actor
	guard.health=500
	guard.position=actor.position+Vector2(68,0)
	var enemy_events: Array = []
	audio.cue_triggered.connect(func(cue: String):
		if cue.begins_with("enemy_"): enemy_events.append({"cue":cue,"elapsed":guard.strike_duration-guard.strike_left}))
	for kind in ["guard","lancer","sentinel","fire"]:
		enemy_events.clear()
		guard.enemy_kind=kind
		guard.hurt_left=0
		guard.windup=0.001
		guard.strike_left=0
		guard.cooldown=999
		guard.set_physics_process(true)
		await _ticks(1)
		var cue: String = {"guard":"enemy_swing","lancer":"enemy_thrust","sentinel":"enemy_heavy","fire":"enemy_cast"}[kind]
		var expected: float = maxf(0,guard.strike_duration*guard.strike_contact-audio.motion_lead(cue))
		await _ticks(int(ceil(guard.strike_duration*60))+2)
		guard.set_physics_process(false)
		var found: Array = enemy_events.filter(func(e): return e.cue==cue)
		assert(found.size()==1,"Enemy action must emit one appropriate motion/release cue")
		assert(absf(found[0].elapsed-expected)<=1.0/60.0+0.002,"Enemy cue must follow action clock")
	audio.shutdown()
	print("PASS: clip-timed melee audio, once-only emission, launch alignment, interruption, heavy whiff roles")
	quit()
