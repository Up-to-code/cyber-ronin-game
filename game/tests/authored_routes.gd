extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var scene=load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var transitions := 0
	for index in range(1,101):
		scene._choose_level(index)
		await scene.level_loaded
		for enemy in get_nodes_in_group("enemies"): enemy.queue_free()
		var route: Array=scene.map.platforms.filter(func(surface): return surface.get("route",true))
		var p=scene.player
		for i in range(route.size()-1):
			var a: Dictionary=route[i]
			var b: Dictionary=route[i+1]
			var side: float=signf(b.center.x-a.center.x)
			var action: String="move_right" if side>0 else "move_left"
			p.position=Vector2(a.center.x+side*(a.width/2-35),a.center.y-2)
			p.velocity=Vector2.ZERO
			p.invulnerable=100
			p.attack_time=0
			p.hurt_left=0
			p.reset_motion_presentation()
			for tick in range(5): await physics_frame
			var target_x: float=b.center.x-side*(b.width/2-90)
			if b.center.y>a.center.y:
				target_x = maxf(target_x,a.center.x+a.width/2+50) if side>0 else minf(target_x,a.center.x-a.width/2-50)
			Input.action_press(action)
			Input.action_press("jump")
			var landed := false
			for tick in range(100):
				await physics_frame
				if tick==20: Input.action_release("jump")
				Input.action_release("move_down")
				# Optional overhead branches are real landings; descend through them
				# when this test is exercising the lower primary route.
				if tick>22 and tick%4==0 and p.is_on_floor() and p.position.y < b.center.y-5 and absf(p.position.x-b.center.x)<b.width/2:
					Input.action_press("move_down")
				var stopping_distance: float = p.velocity.x * p.velocity.x / (2.0 * 3200.0)
				if (target_x-p.position.x)*side <= stopping_distance: Input.action_release(action)
				if tick>10 and p.is_on_floor() and absf(p.position.y-b.center.y)<3 and absf(p.position.x-b.center.x)<b.width/2:
					landed=true
					break
			Input.action_release("jump")
			Input.action_release("move_down")
			Input.action_release(action)
			if not landed:
				push_error("Route %d transition %d failed at %s -> %s, player %s" % [index,i,a.center,b.center,p.position])
				quit(1)
				return
			transitions+=1
	root.get_node("Audio").shutdown()
	print("PASS: %d actual jump/landing transitions across 100 campaign routes (injected starts)" % transitions)
	quit()
