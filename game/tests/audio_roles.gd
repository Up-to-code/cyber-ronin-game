extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	await process_frame
	var audio: Node = root.get_node("Audio")
	for cue in ["kick", "kick_hit", "push", "ui", "swing", "enemy_swing", "enemy_cast"]:
		assert(audio.streams.has(cue) and audio.streams[cue].get_length() > 0)
	assert(audio.streams.kick != audio.streams.kick_hit, "Miss motion must not use contact recording")
	assert(audio.streams.enemy_swing != audio.streams.swing, "Enemy release needs separate timbre")
	assert(audio.stream_variants.kick.size() > 1 and audio.stream_variants.kick_hit.size() > 1)
	assert(AudioServer.get_bus_index("Interface") >= 0)
	assert("push" in audio.CONTACT_CUES and "kick" not in audio.CONTACT_CUES and "enemy_swing" not in audio.CONTACT_CUES)
	print("PASS: separate motion/contact roles, kick variations, enemy release and interface bus")
	audio.shutdown()
	quit()
