extends SceneTree
var frame: int = 0
var log_events: Array = []
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	create_timer(35,true,false,true).timeout.connect(func():quit(1))
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP,true)
	root.grab_focus()
	scene._choose_level(1)
	await scene.level_loaded
	var audio: Node = root.get_node("Audio")
	audio.cue_triggered.connect(func(cue):log_events.append({"frame":frame,"cue":cue}))
	var guard: Node
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
		if guard==null and enemy.enemy_kind=="guard":guard=enemy
	scene.player.invulnerable=999
	guard.health=500
	guard.position=scene.player.position+Vector2(450,0)
	for i in range(720):
		frame=i
		match i:
			60: Input.action_press("jump")
			75: scene.player._start_attack()
			85: Input.action_release("jump")
			180: scene.player._start_special("kick") # Miss: no body-hit sound.
			240:
				guard.position=scene.player.position+Vector2(68,0)
				scene.player._start_attack()
			275: scene.player._start_attack()
			315: scene.player._start_attack()
			350: scene.player._start_special("kick")
			380:
				scene.player.invulnerable=0
				scene.player.health=100
				guard.position=scene.player.position+Vector2(68,0)
				guard.velocity=Vector2.ZERO
				guard.knockback=0
				guard.hurt_left=0
				guard.windup=.32
				guard.strike_left=0
				guard.facing=-1
				guard.set_physics_process(true)
			440: guard.set_physics_process(false)
			480: scene.player._start_special("energy")
			540:
				scene.player.power=100
				scene.player._start_special("charged")
			610:
				scene.player.power=100
				scene.player._start_special("power")
		await physics_frame
		await process_frame
	FileAccess.open("/tmp/attack-resource-events.json",FileAccess.WRITE).store_string(JSON.stringify(log_events,"\t"))
	audio.shutdown()
	quit()
