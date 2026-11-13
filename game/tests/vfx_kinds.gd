extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	await process_frame
	var fx: Node2D = load("res://systems/pixel_fx.gd").new()
	root.add_child(fx)
	for kind in ["sparkle","shockwave_ring","critical_hit","booster","monster_spawn","level_transition","heal","shield","explosion","blade","attack","slash_burst"]:
		fx.spawn(kind, Vector2.ZERO, 1)
	assert(fx.get_child_count() > 0, "VFX kinds should spawn children")
	print("PASS: vfx kinds spawn")
	quit()