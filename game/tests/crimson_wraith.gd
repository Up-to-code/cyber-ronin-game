extends SceneTree
const Visual = preload("res://animation/cel_actor_visual.gd")
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var actor := Visual.new()
	actor.profile_id = "wraith_pixel"
	root.add_child(actor)
	await process_frame
	var observed := {}
	for i in range(18):
		actor.update_pose(0.09,"float",1,Vector2.ZERO,false)
		observed[actor.current_frame] = true
	assert(observed.size() == 9, "Hover must advance through all nine drawn frames")
	for state in ["charged","sword","hurt","death"]:
		actor.update_pose(0.01,state,1,Vector2.ZERO,false,0.5,0.5)
		assert(actor.current_clip != "float", "Combat reaction must override hover")
	var before = JSON.parse_string(FileAccess.get_file_as_string("res://../assets/enemies/crimson-wraith/previous-profile.json"))
	for clip in ["hurt","death"]:
		assert(actor.profile.clips[clip] == before.clips[clip], "Existing combat clip must be preserved")
	var spec = actor.get_attack_spec("sword",1)
	assert(is_equal_approx(spec.contact_progress,100.0/320.0))
	assert(is_equal_approx(spec.active_end_progress,150.0/320.0))
	assert(is_equal_approx(spec.duration,0.32))
	assert(actor.profile.clips.attack.frames.size()==5)
	if not DisplayServer.get_name() == "headless":
		actor.position = Vector2(180,270)
		actor.scale = Vector2.ONE
		actor.update_pose(0.0,"sword",1,Vector2.ZERO,false,0.35)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://../docs/qa/crimson-wraith-cast.png")
	root.get_node("Audio").shutdown()
	print("PASS: nine advancing hover cels and preserved combat overrides")
	quit()
