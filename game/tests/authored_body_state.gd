extends SceneTree
const Enemy = preload("res://actors/enemy_2d.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var floor := StaticBody2D.new()
	floor.position = Vector2(600,550)
	var col := CollisionShape2D.new();var rect := RectangleShape2D.new()
	rect.size=Vector2(12000,80);col.shape=rect;col.position.y=40;floor.add_child(col);root.add_child(floor)
	var player=load("res://actors/player_2d.gd").new();root.add_child(player)
	player.set_physics_process(false);player.position=Vector2(650,550);player.invulnerable=999
	await physics_frame
	var delayed_bosses := 0
	for id in range(1,101):
		var enemy=Enemy.new();enemy.position=Vector2(500,550);enemy.target=player;enemy.is_boss=id%10==0
		root.add_child(enemy);enemy.set_physics_process(false);enemy.apply_monster_profile(id)
		enemy.health=maxi(1,int(enemy.max_health*.4))
		var action=enemy.contract;action.set_physics_process(false)
		var record: Dictionary=action.get_choreography()
		var body_end: float=record.motion.windup+record.motion.commit
		var evidence := {"late":false,"contacts":0}
		action.damage_contact.connect(func(_id,_event,_hit):
			evidence.contacts+=1
			if action.current_action_time>body_end+.02:
				evidence.late=true
				assert(action.body_state().phase=="recovery","Delayed effect does not extend body strike"))
		action.cast()
		var seen := {}
		var duration: float=action.current_action_duration
		for step in range(ceili(duration*60)+2):
			if not action.action_active:break
			enemy._physics_process(1.0/60)
			action._physics_process(1.0/60)
			# Present the same authoritative clock snapshot; no fabricated timer state.
			enemy.motion_visual.tick(0)
			var body: Dictionary=action.body_state()
			if not action.action_active:break
			seen[body.phase]=true
			assert(enemy.motion_visual.phase==body.phase,"Actual pose reads authored body phase %d"%id)
			var attack: Array=enemy.motion_visual.manifest.clips.attack
			var expected: int=attack[0] if body.phase=="windup" else (attack[1 if body.progress<.6 else 2] if body.phase=="strike" else attack.back())
			assert(enemy.motion_visual.frame_index==expected,"Drawn frame follows action snapshot %d"%id)
		assert(not action.action_active and action.marks.is_empty())
		assert(action.body_state().phase=="idle" and enemy.motion_visual.phase not in ["windup","strike","recovery"],"No stale authored recovery after action end")
		assert(seen.has("windup") and seen.has("strike") and seen.has("recovery"))
		assert(evidence.contacts>0)
		if id%10==0:
			assert(evidence.late,"Boss delayed contact survives body recovery %d"%id)
			delayed_bosses+=1
		# Interruption clears both body presentation and pending travelling effects.
		action.cast();action._physics_process(.1)
		enemy.receive_hit(1,"sword",-1,enemy.position);enemy.motion_visual.tick(0)
		assert(not action.action_active and action.marks.is_empty() and action.body_state().phase=="idle")
		assert(enemy.motion_visual.phase=="hurt")
		var contacts: int=evidence.contacts
		action._physics_process(duration+1)
		assert(evidence.contacts==contacts,"Interrupted effects cannot contact later")
		enemy.free()
	root.get_node("Audio").shutdown()
	print("PASS authored body state: 100 live timelines/renderers, ",delayed_bosses," delayed boss contacts, interruption and end cleanup")
	quit()
