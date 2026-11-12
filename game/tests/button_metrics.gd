extends SceneTree
func _initialize() -> void:call_deferred("_run")
func _settle() -> void:
	for i in range(5):await process_frame
func _run() -> void:
	create_timer(15,true,false,true).timeout.connect(func():quit(1))
	var hud: Node=load("res://ui/hud.gd").new();hud.settings_path="user://button-metrics.cfg";root.add_child(hud)
	hud.max_unlocked=6
	for dimensions in [Vector2i(640,360),Vector2i(480,320),Vector2i(960,540),Vector2i(1024,768)]:
		root.size=dimensions;await _settle()
		for screen in ["title","pause","settings","audio_settings","touch_settings","maps","help","privacy","credits","death","complete"]:
			hud.screens.assign([screen]);hud._render_menu();await _settle()
			for button in hud.menu_box.find_children("*","Button",true,false):
				if button.text.is_empty():continue
				var style: StyleBox=button.get_theme_stylebox("normal")
				var text_size: Vector2=button.get_theme_font("font").get_string_size(button.text,HORIZONTAL_ALIGNMENT_LEFT,-1,button.get_theme_font_size("font_size"))
				var interior: Vector2=button.size-style.get_minimum_size()
				assert(text_size.x<=interior.x+.1,"Text must fit inside its padding: %s, %s vs %s"%[button.text,text_size,interior])
				assert(button.size.y>=44,"Every menu action keeps a usable row")
				if not button.has_meta("pixel_component"):
					assert(style.content_margin_top==9 and style.content_margin_bottom==9,"Navigation shares button padding, never panel padding")
			if screen=="death":
				var retry: Button=hud.menu_box.find_child("RetryRoute",true,false)
				var leave: Button=hud.menu_box.find_child("LeaveRoute",true,false)
				assert(is_equal_approx(retry.size.y,leave.size.y) and leave.size.y<=48,"Defeat actions must match rather than inflate MAIN MENU")
				assert(leave.position.y-retry.get_rect().end.y>=8,"Defeat actions retain separation")
	root.get_node("Audio").shutdown();print("PASS: all menu text fits padding, minimum rows, consistent box metrics and matching defeat actions at four sizes");quit()
