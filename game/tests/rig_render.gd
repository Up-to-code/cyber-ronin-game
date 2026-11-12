extends SceneTree
var rigs: Array[Node2D] = []
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var background := ColorRect.new()
	background.color = Color("251018")
	background.z_index = -30
	background.size = Vector2(640,360)
	root.add_child(background)
	for i in range(3):
		var rig: Node2D = load("res://rig/rig_visual.gd").new()
		rig.profile_id = ["ronin","ember_fire","wraith"][i]
		rig.position = Vector2(170+i*150,265)
		root.add_child(rig)
		rigs.append(rig)
	for frame in range(180):
		var t: float = frame/30.0
		var state: String = "run" if frame < 60 else ("kick" if frame < 90 else ("sword" if frame < 120 else "hurt"))
		for i in range(rigs.size()):
			var rig: Node2D = rigs[i]
			rig.update_pose(1.0/30,state,1,Vector2(210,0) if frame < 60 else Vector2.ZERO,true,fposmod(t,1.0))
		if frame in [30,75,105]:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("/tmp/rig-preview-%d.png" % frame)
		await process_frame
	root.get_node("Audio").shutdown()
	quit()
