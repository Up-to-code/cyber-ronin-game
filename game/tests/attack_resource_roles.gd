extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	create_timer(10,true,false,true).timeout.connect(func():quit(1))
	var audio: Node=root.get_node("Audio")
	for cue in ["swing","swing_reverse","swing_finisher","charged_swing","power","kick","kick_hit","impact_armor","impact_spirit","energy_swing","enemy_cast"]:
		assert("/combat-v2/" in audio.streams[cue].resource_path or "/combat-v5/" in audio.streams[cue].resource_path,"Attack roles must use replacement resources")
	assert(audio.streams.impact_armor != audio.streams.impact_spirit)
	assert(audio.streams.energy_swing != audio.streams.charged_swing)
	var fx: Node=load("res://systems/pixel_fx.gd").new()
	root.add_child(fx)
	var sheets: Dictionary={}
	for kind in ["slash","kick","impact","finisher_hit","power","energy"]:
		fx.spawn(kind,Vector2.ZERO,-1)
		var effect: Node=fx.get_child(-1)
		sheets[kind]=effect.sheet
		assert(effect.visual.flip_h,"Imported directional artwork mirrors with attack direction")
		assert(effect.visual.texture_filter==CanvasItem.TEXTURE_FILTER_PARENT_NODE)
		assert(effect.texture_filter==CanvasItem.TEXTURE_FILTER_NEAREST)
	assert(sheets.slash!=sheets.impact and sheets.impact!=sheets.finisher_hit and sheets.power!=sheets.energy)
	await create_timer(.6).timeout
	assert(fx.get_child_count()==0,"No attack effect may persist after its clip")
	audio.shutdown()
	print("PASS: distinct replacement attack roles, material contacts, mirrored pixel cels, full expiry")
	quit()
