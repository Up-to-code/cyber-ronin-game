extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	await process_frame
	var audio: Node = root.get_node("Audio")
	assert(audio.music.stream.resource_path.ends_with("moonlight_loop.ogg"))
	assert(audio.battle_music.stream.resource_path.ends_with("kyoto_tension_loop.ogg"))
	assert(audio.music.stream.get_length() > 60 and audio.battle_music.stream.get_length() > 60)
	for cue in ["jump", "air_jump", "dodge", "hurt", "ui", "aerial_land"]:
		assert("/foley/" in audio.streams[cue].resource_path or "/ground-v3/" in audio.streams[cue].resource_path,"Movement/material cues must use recorded material")
	audio.music_fade = 0
	audio._process(0.1)
	assert(audio.music_fade > 0 and audio.music_fade < 0.1)
	audio.set_enabled(false)
	assert(not audio.enabled)
	audio.set_enabled(true)
	assert(audio.enabled)
	audio.shutdown()
	print("PASS: new music pair, recorded movement palette, fade-in and mute/resume")
	quit()
