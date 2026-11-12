extends SceneTree
var frame: int=0
var events: Array=[]
func _initialize() -> void:call_deferred("_run")
func _run() -> void:
	create_timer(40,true,false,true).timeout.connect(func():quit(1))
	var scene: Node=load("res://scenes/main.tscn").instantiate();root.add_child(scene)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP,true);root.grab_focus()
	scene._choose_level(1);await scene.level_loaded
	scene.pause_game()
	for screen in ["title","pause","settings","touch_settings","audio_settings","maps","death"]:
		scene.hud.screens.assign([screen])
		scene.hud._render_menu()
		for step in range(22):await process_frame
		root.get_texture().get_image().save_png("/tmp/v5-ui-%s.png"%screen)
	scene.resume_game()
	scene.hud.touch_enabled=true
	scene.hud.touch.show()
	for step in range(15):await process_frame
	root.get_texture().get_image().save_png("/tmp/v5-ui-controls.png")
	scene.player.invulnerable=999
	var guard: Node
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
		if guard==null and enemy.enemy_kind=="guard":guard=enemy
	guard.position=scene.player.position+Vector2(68,0);guard.health=1000
	guard.velocity=Vector2.ZERO;guard.knockback=0;guard.approach_speed=0;guard.patrol_speed=0;guard.cooldown=999;guard.set_physics_process(true)
	var heavy: Node=load("res://actors/enemy_2d.gd").new();heavy.enemy_kind="sentinel";heavy.position=scene.player.position+Vector2(132,0);scene.add_child(heavy)
	heavy.health=1000;heavy.target=scene.player;heavy.approach_speed=0;heavy.patrol_speed=0;heavy.cooldown=999
	root.get_node("Audio").cue_triggered.connect(func(cue):events.append({"frame":frame,"cue":cue,"combo":scene.player.combo_step,"guard_x":guard.position.x,"heavy_x":heavy.position.x}))
	for i in range(800):
		frame=i
		match i:
			120,127,142:Input.action_press("attack")
			121,128,143:Input.action_release("attack")
			300:Input.action_press("jump")
			320:Input.action_release("jump")
			335:Input.action_press("jump")
			336:Input.action_release("jump")
			345:Input.action_press("kick")
			346:Input.action_release("kick")
			480:scene.player._start_special("energy")
			560:
				scene.player.power=100;scene.player._start_special("charged")
			640:
				scene.player.power=100;scene.player._start_special("power")
		if i in [130,145,170,180,195,380,653]:root.get_texture().get_image().save_png("/tmp/v5-combat-%d.png"%i)
		await physics_frame
		await process_frame
	FileAccess.open("/tmp/v5-ui-events.json",FileAccess.WRITE).store_string(JSON.stringify(events,"\t"))
	root.get_node("Audio").shutdown();quit()
