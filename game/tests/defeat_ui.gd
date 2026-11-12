extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var hud: CanvasLayer = load("res://ui/hud.gd").new()
	hud.settings_path = "user://defeat-ui-test.cfg"
	root.add_child(hud)
	await process_frame
	hud.shown_level = 3
	hud.show_result(false)
	await process_frame
	await process_frame
	var card: Control = hud.menu_box.get_node("DefeatCard")
	var retry: Button = card.find_child("RetryRoute",true,false)
	var leave: Button = card.find_child("LeaveRoute",true,false)
	assert(retry.has_focus(),"Retry must receive initial focus")
	assert(not hud.gameplay.visible,"Defeat hides gameplay inputs")
	assert(card.find_child("Route",true,false).text.contains("BAMBOO"),"Defeat identifies actual route")
	var requested: Array[String] = []
	hud.retry_requested.connect(func():requested.append("retry"))
	hud.menu_requested.connect(func():requested.append("menu"))
	retry.pressed.emit()
	leave.pressed.emit()
	assert(requested == ["retry","menu"],"Both defeat actions must dispatch once")
	for dimensions in [Vector2i(960,540),Vector2i(1600,720),Vector2i(1024,768)]:
		root.size = dimensions
		await process_frame
		await process_frame
		assert(hud.safe.get_global_rect().encloses(card.get_global_rect()),"Defeat card fits safe area")
		assert(not retry.get_global_rect().intersects(leave.get_global_rect()),"Defeat actions do not overlap")
	if DisplayServer.get_name() != "headless":
		await create_timer(0.3).timeout
		root.get_texture().get_image().save_png("/tmp/defeat-card.png")
	print("PASS: defeat context, retry focus, action dispatch, safe bounds and nonoverlap")
	hud.queue_free()
	root.get_node("Audio").shutdown()
	await create_timer(0.1).timeout
	quit()
