extends Node
signal cue_triggered(cue: String)
var defeated: bool = false
var motion_timing: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/audio_timing.json"))
var defeat_mix: float = 0
# Event audio is deliberately separate from the two cross-faded music stems.
var enabled: bool = true
var music: AudioStreamPlayer
var battle_music: AudioStreamPlayer
var voices: Array[AudioStreamPlayer] = []
var streams: Dictionary = {}
var combat_active: bool = false
var battle_mix: float = 0.0
var impact_duck: float = 0.0
var music_fade: float = 0.0
const CONTACT_CUES := ["impact", "impact_armor", "impact_spirit", "kick_hit", "hurt", "aerial_land", "push", "explosion"]
var cue_last_played: Dictionary = {}
var stream_variants: Dictionary = {}
var cue_variant_index: Dictionary = {}
const CUE_VOLUME_DB := {
	"land_light": -21.0, "land_heavy": -14.0, "swing_reverse": -13.0, "swing_finisher": -11.0, "defeat": -11.0,
	"enemy_step": -28.0, "ranged_swing": -14.0, "energy_swing": -14.0,
	"swing": -12.0, "impact_armor": -13.0, "impact_spirit": -17.0, "impact": -10.0, "jump": -18.0, "land": -18.0,
	"step": -23.0, "dodge": -19.0, "hurt": -10.0, "bell": -15.0, "ui": -24.0, "air_jump": -20.0,
	"kick": -14.0, "charge": -22.0, "charged_swing": -12.0, "power": -12.0,
	"aerial_land": -12.0, "power_empty": -24.0, "kick_hit": -10.0, "push": -15.0, "enemy_swing": -16.0, "enemy_heavy": -17.0, "enemy_thrust": -17.0, "enemy_cast": -17.0,
	"explosion": -9.0
}
const QUIET_DB: float = -80.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for bus_name in ["Combat", "EnemyCombat", "Music", "Interface"]:
		if AudioServer.get_bus_index(bus_name) < 0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, bus_name)
	if AudioServer.get_bus_effect_count(0) == 0:
		var limiter := AudioEffectHardLimiter.new()
		limiter.ceiling_db = -1.0
		AudioServer.add_bus_effect(0, limiter)
	streams = {
		"land_light": preload("res://audio/ground-v3/landing.wav"),
		"land_heavy": preload("res://audio/ground-v3/landing_heavy.wav"),
		"swing_reverse": preload("res://audio/combat-v5/reverse.wav"),
		"swing_finisher": preload("res://audio/combat-v5/heavy.wav"),
		"defeat": preload("res://audio/foley/designed/defeat.wav"),

		"swing": preload("res://audio/combat-v5/cut.wav"),
		"impact": preload("res://audio/combat-v5/contact.wav"),
		"impact_armor": preload("res://audio/combat-v5/armor.wav"),
		"impact_spirit": preload("res://audio/combat-v5/energy.wav"),
		"jump": preload("res://audio/foley/designed/jump.wav"),
		"air_jump": preload("res://audio/foley/designed/air_jump.wav"),
		"land": preload("res://audio/foley/designed/land.wav"),
		"step": preload("res://audio/foley/footstep00.ogg"),
		"enemy_step": preload("res://audio/foley/footstep02.ogg"),
		"ranged_swing": preload("res://audio/combat-v5/reverse.wav"),
		"energy_swing": preload("res://audio/combat-v5/energy.wav"),
		"dodge": preload("res://audio/foley/cloth3.ogg"),
		"hurt": preload("res://audio/foley/impactPunch_medium_000.ogg"),
		"bell": preload("res://audio/shrine_bell.wav"),
		"ui": preload("res://audio/foley/footstep04.ogg"),
		"kick": preload("res://audio/combat-v5/kick.wav"),
		"kick_hit": preload("res://audio/combat-v5/kick_hit.wav"),
		"charge": preload("res://audio/power_charge.wav"),
		"charged_swing": preload("res://audio/combat-v5/heavy.wav"),
		"power": preload("res://audio/combat-v5/power.wav"),
		"aerial_land": preload("res://audio/ground-v3/slam.wav"),
		"power_empty": preload("res://audio/power_empty.wav"),
		"push": preload("res://audio/ground-v3/stone.wav"),
		"enemy_swing": preload("res://audio/combat-v5/enemy.wav"),
		"enemy_cast": preload("res://audio/combat-v2/enemy_fire.wav"),
		"explosion": preload("res://audio/ground-v3/slam.wav")
	}
	streams["enemy_thrust"] = preload("res://audio/combat-v2/enemy_thrust.wav")
	streams["enemy_heavy"] = streams["enemy_swing"]
	stream_variants = {
		"swing": [streams.swing, preload("res://audio/combat-v5/cut_alt.wav")],
		"kick": [streams.kick, preload("res://audio/combat-v5/kick_alt.wav")],
		"impact": [streams.impact, preload("res://audio/combat-v5/contact_alt.wav")],
		"kick_hit": [streams.kick_hit, preload("res://audio/combat-v5/kick_hit_alt.wav")],
		"step": [streams.step, preload("res://audio/foley/footstep02.ogg"), preload("res://audio/foley/footstep04.ogg")],
	}
	# Hove Audio: clean movement and contact layers remain separate.
	streams["swing"] = preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_07.wav")
	stream_variants["swing"] = [preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_07.wav"), preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_26.wav")]
	streams["swing_reverse"] = preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_26.wav")
	stream_variants["swing_reverse"] = [preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_26.wav"), preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_07.wav")]
	streams["swing_finisher"] = preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_26.wav")
	stream_variants["swing_finisher"] = [preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_26.wav"), preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_07.wav")]
	streams["charged_swing"] = preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_26.wav")
	stream_variants["charged_swing"] = [preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_26.wav"), preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_07.wav")]
	streams["kick"] = preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_07.wav")
	stream_variants["kick"] = [preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_07.wav"), preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_26.wav")]
	streams["enemy_swing"] = preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_07.wav")
	stream_variants["enemy_swing"] = [preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_07.wav"), preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_26.wav")]
	streams["enemy_thrust"] = preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_07.wav")
	stream_variants["enemy_thrust"] = [preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_07.wav"), preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_26.wav")]
	streams["enemy_heavy"] = preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_26.wav")
	stream_variants["enemy_heavy"] = [preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_26.wav"), preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_07.wav")]
	streams["ranged_swing"] = preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_07.wav")
	stream_variants["ranged_swing"] = [preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_07.wav"), preload("res://audio/hove/WHSH_Whoosh_HoveAud_SwordCombat_26.wav")]
	streams["impact"] = preload("res://audio/hove/WEAPSwrd_SwordStab_HoveAud_SwordCombat_01.wav")
	stream_variants["impact"] = [preload("res://audio/hove/WEAPSwrd_SwordStab_HoveAud_SwordCombat_01.wav"), preload("res://audio/hove/WEAPSwrd_SwordStab_HoveAud_SwordCombat_11.wav"), preload("res://audio/hove/WEAPSwrd_SwordStab_HoveAud_SwordCombat_17.wav")]
	streams["impact_armor"] = preload("res://audio/hove/WEAPSwrd_BaseMetal_HoveAud_SwordCombat_03.wav")
	stream_variants["impact_armor"] = [preload("res://audio/hove/WEAPSwrd_BaseMetal_HoveAud_SwordCombat_03.wav"), preload("res://audio/hove/WEAPSwrd_BaseMetal_HoveAud_SwordCombat_06.wav")]
	streams["hurt"] = preload("res://audio/hove/VOXScrm_DamageGrunt_HoveAudio_SwordCombat_01.wav")
	stream_variants["hurt"] = [preload("res://audio/hove/VOXScrm_DamageGrunt_HoveAudio_SwordCombat_01.wav"), preload("res://audio/hove/VOXScrm_DamageGrunt_HoveAudio_SwordCombat_13.wav"), preload("res://audio/hove/VOXScrm_DamageGrunt_HoveAudio_SwordCombat_22.wav"), preload("res://audio/hove/VOXScrm_DamageGrunt_HoveAudio_SwordCombat_27.wav")]
	streams["power"] = preload("res://audio/hove/MAGShim_Ring_HoveAud_SwordCombat_01.wav")
	stream_variants["power"] = [preload("res://audio/hove/MAGShim_Ring_HoveAud_SwordCombat_01.wav"), preload("res://audio/hove/MAGShim_Ring_HoveAud_SwordCombat_11.wav"), preload("res://audio/hove/MAGShim_Ring_HoveAud_SwordCombat_17.wav")]
	streams["energy_swing"] = preload("res://audio/hove/MAGShim_Ring_HoveAud_SwordCombat_01.wav")
	stream_variants["energy_swing"] = [preload("res://audio/hove/MAGShim_Ring_HoveAud_SwordCombat_01.wav"), preload("res://audio/hove/MAGShim_Ring_HoveAud_SwordCombat_11.wav"), preload("res://audio/hove/MAGShim_Ring_HoveAud_SwordCombat_17.wav")]
	streams["impact_spirit"] = preload("res://audio/hove/MAGShim_Ring_HoveAud_SwordCombat_01.wav")
	stream_variants["impact_spirit"] = [preload("res://audio/hove/MAGShim_Ring_HoveAud_SwordCombat_01.wav"), preload("res://audio/hove/MAGShim_Ring_HoveAud_SwordCombat_11.wav"), preload("res://audio/hove/MAGShim_Ring_HoveAud_SwordCombat_17.wav")]
	streams["enemy_heavy"] = streams["enemy_swing"]
	stream_variants["enemy_heavy"] = stream_variants["enemy_swing"]
	_install_combat_layers()
	for i in range(12):
		var voice := AudioStreamPlayer.new()
		voice.bus = "Combat"
		add_child(voice)
		voices.append(voice)
	music = _music_player(preload("res://audio/moonlight_loop.ogg"))
	battle_music = _music_player(preload("res://audio/kyoto_tension_loop.ogg"))
	music.volume_db = -18.0
	battle_music.volume_db = QUIET_DB
	if _can_play():
		music.play()

func _music_player(stream: AudioStreamOggVorbis) -> AudioStreamPlayer:
	# New loops are crossfaded from the licensed composer takes; see build_quiet_audio.py.
	stream.loop = true
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = "Music"
	add_child(player)
	return player

func _can_play() -> bool:
	return DisplayServer.get_name() != "headless"

func _process(delta: float) -> void:
	defeat_mix = move_toward(defeat_mix,1.0 if defeated else 0.0,delta*3.0)
	music_fade = move_toward(music_fade, 1.0, delta / 2.5)
	impact_duck = move_toward(impact_duck, 0.0, delta * 12.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), -impact_duck-defeat_mix*60.0)
	battle_mix = move_toward(battle_mix, 1.0 if combat_active else 0.0, delta / (2.5 if combat_active else 4.0))
	if not is_instance_valid(music) or not is_instance_valid(battle_music):
		return
	music.volume_db = -22.0 + linear_to_db(maxf(0.0001, music_fade * (1.0 - battle_mix)))
	battle_music.volume_db = -23.0 + linear_to_db(maxf(0.0001, music_fade * battle_mix))
	if not combat_active and is_zero_approx(battle_mix) and battle_music.playing:
		battle_music.stop()

func set_combat(active: bool) -> void:
	if defeated: active = false
	if combat_active == active:
		return
	combat_active = active
	if active and _can_play() and not battle_music.playing:
		battle_music.play()
		battle_music.stream_paused = not enabled

func play(cue: String) -> void:
	if not enabled or not streams.has(cue) or (defeated and cue not in ["defeat", "ui"]): return
	cue_triggered.emit(cue)
	if not _can_play():
		return
	var now: float = Time.get_ticks_msec() / 1000.0
	var minimum_gap: float = 0.08 if cue in ["step", "enemy_step"] else 0.025
	if now - float(cue_last_played.get(cue, -10.0)) < minimum_gap:
		return
	cue_last_played[cue] = now
	if cue in CONTACT_CUES:
		impact_duck = 3.5
	var available: AudioStreamPlayer
	for voice in voices:
		if not voice.playing:
			available = voice
			break
	if available == null:
		# A footstep may disappear under a busy fight, never displace a hit cue.
		if cue in ["step", "enemy_step"]:
			return
		for voice in voices:
			if voice.get_meta("cue", "") not in CONTACT_CUES:
				available = voice
				break
		if available == null:
			return
	available.stream = streams[cue]
	if stream_variants.has(cue):
		var index: int = int(cue_variant_index.get(cue, 0))
		available.stream = stream_variants[cue][index]
		cue_variant_index[cue] = (index + 1) % stream_variants[cue].size()
	available.bus = "Interface" if cue in ["ui", "power_empty"] else ("EnemyCombat" if cue.begins_with("enemy_") else "Combat")
	available.set_meta("cue", cue)
	available.volume_db = -23.0 if cue in ["effort_light","effort_strong","blood_contact"] else (-24.0 if cue=="heavy_contact" else CUE_VOLUME_DB.get(cue, -12.0))
	available.pitch_scale = randf_range(0.96, 1.04) if cue in ["step", "land"] else 1.0
	if cue == "enemy_swing":
		available.pitch_scale = 0.86
	elif cue == "enemy_heavy":
		available.pitch_scale = 0.72
	elif cue == "enemy_cast":
		available.pitch_scale = 0.78
	elif cue == "push":
		available.pitch_scale = 0.85
	elif cue == "explosion":
		available.pitch_scale = 0.62
	if cue == "air_jump":
		available.pitch_scale = 1.06
	available.play()
	# Additional layers are event-specific, quiet, and share the bounded voice pool.
	if cue in ["swing_reverse", "swing_finisher", "charged_swing", "kick", "enemy_heavy"]:
		play("effort_strong" if cue in ["swing_finisher","charged_swing","enemy_heavy"] else "effort_light")
	if cue in ["impact"]:
		play("blood_contact")


func motion_lead(cue: String) -> float:
	# Releases belong to launch, not anticipation. Melee uses the next take's
	# measured 5ms RMS peak, adjusted for the enemy playback pitch.
	if cue not in ["swing", "swing_reverse", "swing_finisher", "charged_swing", "kick", "enemy_swing", "enemy_thrust", "enemy_heavy"]: return 0.0
	var stream: AudioStream = streams.get(cue)
	if stream_variants.has(cue):
		stream = stream_variants[cue][int(cue_variant_index.get(cue, 0))]
	if stream == null: return 0.0
	var pitch: float = 0.86 if cue == "enemy_swing" else (0.72 if cue == "enemy_heavy" else 1.0)
	return float(motion_timing.get(stream.resource_path, motion_timing.get(stream.resource_path.get_file(), 0.0))) / pitch

func landing_cue(fall_speed: float) -> String:
	return "land_heavy" if fall_speed >= 550.0 else "land_light"

func set_defeated(value: bool) -> void:
	if defeated == value: return
	defeated = value
	if value:
		set_combat(false)
		for voice in voices: voice.stop()
		play("defeat")
	else:
		music_fade = 0.0
		cue_last_played.clear()

func stop_cue(cue: String) -> void:
	# Charging must stop on release, dash, damage, pause, or menu cancellation.
	for voice in voices:
		if voice.get_meta("cue", "") == cue:
			voice.stop()

func set_enabled(value: bool) -> void:
	enabled = value
	if is_instance_valid(music):
		music.stream_paused = not value
	if is_instance_valid(battle_music):
		battle_music.stream_paused = not value
	if not value:
		for voice in voices:
			voice.stop()

func shutdown() -> void:
	if is_inside_tree():
		for voice in get_tree().get_nodes_in_group("monster_sfx"):
			voice.stop()
			voice.stream = null
			voice.queue_free()
	for player in [music, battle_music]:
		if is_instance_valid(player):
			player.stop()
			player.stream = null
	for voice in voices:
		voice.stop()
		voice.stream = null
	var contract_script = load("res://actors/monster_contract.gd")
	if contract_script: contract_script.sound_cache.clear()
	streams.clear()
	stream_variants.clear()

func _exit_tree() -> void:
	shutdown()


func _install_combat_layers() -> void:
	var groups := {"effort_light":"VOXEfrt_", "effort_strong":"VOXEfrt_", "blood_contact":"GOREStab_", "heavy_contact":"WEAPSwrd_SwordStabwRing_", "wood_contact":"WEAPSwrd_BaseWood_"}
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://audio/hove/manifest.json"))
	for cue in groups:
		var variants: Array = []
		for file in manifest.imported:
			if str(file).begins_with(groups[cue]): variants.append(load("res://audio/hove/"+str(file)))
		streams[cue] = variants[0]
		stream_variants[cue] = variants
	cue_variant_index["effort_strong"] = 2
