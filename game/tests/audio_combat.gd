extends SceneTree
var peak: float = -200
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	await process_frame
	var audio: Node = root.get_node("Audio")
	audio.set_enabled(true)
	if DisplayServer.get_name() == "headless":
		for cue in ["kick", "kick_hit", "charge", "charged_swing", "power", "aerial_land", "power_empty"]:
			assert(audio.streams.has(cue) and audio.streams[cue].get_length() > 0)
		assert(audio.stream_variants.swing.size() >= 2 and audio.stream_variants.kick_hit.size() >= 2)
		print("PASS: imported combat cues and alternating swing/kick-contact variants (native output check requires display)")
		quit()
		return
	audio.music.stop()
	audio.battle_music.stop()
	for cue in ["swing", "impact", "kick", "kick_hit", "charge", "charged_swing", "power", "aerial_land", "power_empty"]:
		audio.play(cue)
		var cue_peak: float = -200
		var deadline: int = Time.get_ticks_msec() + 350
		while Time.get_ticks_msec() < deadline:
			await process_frame
			cue_peak = maxf(cue_peak, AudioServer.get_bus_peak_volume_left_db(0,0))
		peak = maxf(peak, cue_peak)
		assert(cue_peak > -55, "Cue must produce native audio output: " + cue)
		print(cue, " output peak ", cue_peak, " dB")
		audio.stop_cue(cue)
	audio.play("charge")
	await process_frame
	audio.stop_cue("charge")
	for voice in audio.voices:
		assert(not (voice.playing and voice.get_meta("cue", "") == "charge"), "Charge must cancel")
	audio.play("swing")
	var first: AudioStream
	for voice in audio.voices:
		if voice.playing and voice.get_meta("cue", "") == "swing": first=voice.stream
	audio.stop_cue("swing")
	await create_timer(.04).timeout
	audio.play("swing")
	for voice in audio.voices:
		if voice.playing and voice.get_meta("cue", "") == "swing": assert(voice.stream != first, "Swing must alternate")
	audio.shutdown()
	await create_timer(.1).timeout
	print("PASS: all combat cue output, charge cancellation, alternating samples; overall peak ", peak, " dB")
	quit()
