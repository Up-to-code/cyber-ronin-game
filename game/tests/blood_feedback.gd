extends SceneTree
func _initialize():call_deferred("run")
func run():
	create_timer(15,true,false,true).timeout.connect(func():quit(1))
	var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene)
	await process_frame
	scene.start_game();await scene.level_loaded
	for actor in get_nodes_in_group("enemies"):actor.set_physics_process(false)
	for i in range(10):await physics_frame
	scene.player.set_physics_process(false)
	assert(scene.hud.damage_veil.mouse_filter==Control.MOUSE_FILTER_IGNORE)
	assert(scene.hud.damage_veil.variants.size()==4)
	scene._player_fx("wall_hit",scene.player.position+Vector2(40,-50),1)
	assert(scene.hud.damage_veil.drops.is_empty(),"Wall recoil must not paint player damage")
	scene.player.invulnerable=0;scene.player.take_damage(25,-1)
	assert(not scene.hud.damage_veil.drops.is_empty() and scene.camera_trauma>0)
	var blood:=0
	for effect in scene.fx.get_children():
		if effect.get_meta("family","")=="motes" and effect.blood:blood+=1
	assert(blood==1,"One confirmed damage event owns one blood spray")
	for i in range(10):scene.hud.damage_veil.splash(1.0)
	assert(scene.hud.damage_veil.drops.size()<=18,"Screen blood is bounded")
	await create_timer(2.0).timeout
	assert(scene.hud.damage_veil.drops.is_empty(),"Blood fades completely")
	assert(scene.fx.get_child_count()==0,"All contact effects and floor stains clean up")
	root.get_node("Audio").shutdown()
	print("PASS: four blood decal variants, input-transparent edge veil, no blood on wall impacts, confirmed player blood/shake, bounded overlays and complete effect cleanup")
	quit()
