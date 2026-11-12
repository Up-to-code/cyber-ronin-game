extends SceneTree
var cues: Array[String] = []
func _initialize() -> void: call_deferred("_run")
func _ticks(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func _run() -> void:
	var audio: Node = root.get_node("Audio")
	audio.cue_triggered.connect(func(cue: String): cues.append(cue))
	assert(audio.landing_cue(220)=="land_light" and audio.landing_cue(700)=="land_heavy")
	assert(audio.streams.land_light != audio.streams.land_heavy)
	assert(audio.streams.enemy_swing != audio.streams.swing and audio.streams.enemy_cast != audio.streams.power)
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	scene.start_game()
	await scene.level_loaded
	scene.player.invulnerable = 999
	for enemy in get_nodes_in_group("enemies"): enemy.set_physics_process(false)
	await _ticks(10)
	for step in range(3):
		scene.player._start_attack()
		await _ticks(int(ceil(scene.player.attack_duration*60))+1)
	assert("swing" in cues and "swing_reverse" in cues and "swing_finisher" in cues,"Three actual combo contacts must emit different motion cues")
	cues.clear()
	scene.player.position = Vector2(380,480)
	scene.player.velocity = Vector2.ZERO
	scene.player.attack_time = 0
	scene.player.attack_kind = "plunge" # Previous plunge must not silence later normal landings.
	await _ticks(45)
	assert("land_light" in cues,"Short physical fall must choose light landing")
	cues.clear()
	scene.player.position = Vector2(380,250)
	scene.player.velocity = Vector2.ZERO
	await _ticks(75)
	assert("land_heavy" in cues,"Long physical fall must choose heavy landing")
	cues.clear()
	scene.player.invulnerable = 0
	scene.player.take_damage(100,1)
	assert(audio.defeated and cues.count("defeat")==1)
	audio.set_defeated(true)
	audio.play("enemy_swing")
	assert(cues.count("defeat")==1 and not "enemy_swing" in cues,"Defeat is once-only and suppresses ongoing fight cues")
	audio._process(0.5)
	assert(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")) < -30)
	audio.set_defeated(false)
	assert(not audio.defeated and audio.music_fade==0)
	audio.play("land_light")
	assert(cues.back()=="land_light")
	audio.shutdown()
	print("PASS: landing tiers, distinct combo/enemy cues, once-only defeat, music fade and restart audio")
	quit()
