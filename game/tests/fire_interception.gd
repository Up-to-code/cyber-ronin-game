extends SceneTree
func _initialize() -> void:call_deferred("_run")
func _run() -> void:
	var scene: Node=load("res://scenes/main.tscn").instantiate();root.add_child(scene)
	await process_frame
	scene.start_game();await scene.level_loaded
	var p: Node=scene.player
	p.set_physics_process(false)
	p.attack_kind="sword";p.attack_duration=1;p.attack_contact_progress=0.3;p.current_attack_spec={"active_end_progress":0.5};p.attack_time=0.6;p.hurt_left=0;p.facing=1
	var fire: Node=load("res://systems/combat_projectile.gd").new()
	fire.kind="fire";fire.from_player=false;fire.global_position=p.global_position+Vector2(70,-50);fire.direction=Vector2.LEFT;scene.add_child(fire)
	await physics_frame
	await process_frame
	assert(not is_instance_valid(fire) or fire.is_queued_for_deletion(),"Active sword must cut fire")
	p.attack_time=0.9
	assert(not p.can_cut_fire(p.position+Vector2(70,-50),p.position+Vector2(60,-50)),"Windup must not grant a permanent shield")
	p.attack_time=0
	var soul: Node=load("res://systems/combat_projectile.gd").new()
	soul.kind="energy";soul.from_player=true;soul.position=p.position+Vector2(220,-120);scene.add_child(soul)
	var bolt: Node=load("res://systems/combat_projectile.gd").new()
	bolt.kind="fire";bolt.from_player=false;bolt.position=soul.position+Vector2(15,0);bolt.direction=Vector2.LEFT;scene.add_child(bolt)
	await physics_frame
	await process_frame
	assert(not is_instance_valid(bolt) or bolt.is_queued_for_deletion(),"Soul projectile must extinguish fire")
	assert(InputMap.action_has_event("energy_attack",_key_g()))
	root.get_node("Audio").shutdown();print("PASS: active sword intercepts fire, windup does not, G maps to soul attack");quit()
func _key_g() -> InputEventKey:
	var event:=InputEventKey.new();event.physical_keycode=KEY_G;return event
