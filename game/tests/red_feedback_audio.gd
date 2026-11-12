extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	await process_frame
	var audio: Node = root.get_node("Audio")
	assert(audio.streams.energy_swing != audio.streams.power and audio.streams.ranged_swing != audio.streams.power,"Ranged and energy releases must not all reuse the same power burst")
	assert(audio.streams.enemy_step != audio.streams.step,"Enemy footsteps need a separate source and limiter identity")
	assert(AudioServer.get_bus_index("EnemyCombat") >= 0)
	if DisplayServer.get_name() != "headless":
		audio.play("step")
		audio.play("enemy_step")
		var player_step: bool = false
		var enemy_step: bool = false
		for voice in audio.voices:
			if voice.get_meta("cue", "") == "step": player_step = voice.bus == "Combat"
			if voice.get_meta("cue", "") == "enemy_step": enemy_step = voice.bus == "EnemyCombat"
		assert(player_step and enemy_step,"Concurrent enemy footsteps must not suppress player steps through a shared limiter")
	var fx: Node2D = load("res://systems/pixel_fx.gd").new()
	root.add_child(fx)
	for kind in ["impact", "finisher_hit", "defeat"]: fx.spawn(kind,Vector2.ZERO,1)
	for effect in fx.get_children():
		if effect is AnimatedSprite2D:
			assert(effect.modulate.r > effect.modulate.g*1.5,"Damage art must have a crimson palette")
		elif effect.get_meta("family", "") in ["motes", "contact_ring"]:
			assert(effect.tint.r > effect.tint.g*1.5,"Damage motes and contours must share the crimson palette")
	fx.spawn("energy",Vector2.ZERO,1)
	var energy_found: bool = false
	for effect in fx.get_children():
		if effect is AnimatedSprite2D and effect.get_meta("event", "") == "energy":
			energy_found = effect.modulate.g > effect.modulate.r
	assert(energy_found,"Energy motion remains readable separately from red damage")
	await create_timer(0.7).timeout
	assert(fx.get_child_count() == 0,"All palette feedback remains transient")
	fx.queue_free()
	audio.shutdown()
	print("PASS: distinct ranged/energy releases, separate enemy footsteps, crimson damage and bounded cyan energy motion")
	quit()
