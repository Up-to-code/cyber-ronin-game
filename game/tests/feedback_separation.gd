extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var fx: Node2D = load("res://systems/pixel_fx.gd").new()
	root.add_child(fx)
	fx.spawn("kick", Vector2.ZERO, 1)
	for child in fx.get_children():
		assert(child.get_meta("family", "") == "slash", "A missed kick may show motion, never a contact spark")
	fx.spawn("impact", Vector2.ZERO, 1)
	var rings: int = 0
	for child in fx.get_children():
		if child.get_meta("family", "") == "contact_ring": rings += 1
	assert(rings == 1, "Confirmed impact has one contour")
	await create_timer(1.0).timeout
	assert(fx.get_child_count() == 0, "Feedback must expire completely")
	fx.spawn("wall_hit",Vector2.ZERO,1)
	for effect in fx.get_children():
		if effect.get_meta("family","")=="motes":assert(not effect.blood,"Scenery impacts must not spray blood")
	await create_timer(0.5).timeout
	var audio: Node = root.get_node("Audio")
	assert(audio.music.bus == "Music" and audio.voices[0].bus == "Combat")
	audio.shutdown()
	fx.queue_free()
	print("PASS: missed kick vs confirmed hit feedback, complete expiry, independent music/combat routing")
	quit()
