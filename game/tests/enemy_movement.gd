extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var visuals: Array[CelActorVisual] = []
	for kind in ["guard","fire","wraith"]:
		var visual := CelActorVisual.new()
		root.add_child(visual)
		visual.configure(kind+"_pixel")
		visuals.append(visual)
		if kind != "wraith":
			var seen: Dictionary = {}
			var longest_hold: int = 0
			var hold: int = 0
			var previous: int = -1
			for tick in range(72):
				visual.update_pose(1.0/60,"walk",1,Vector2(84,0),true)
				seen[visual.current_frame] = true
				hold = hold+1 if visual.current_frame==previous else 1
				longest_hold = maxi(longest_hold,hold)
				previous = visual.current_frame
				assert(visual.feet_local().length()<0.01,"Movement art keeps its shared foot anchor")
			assert(seen.size()==8,"Enemy walking consumes all eight source drawings within one gait cycle at84px/s")
			assert(longest_hold<=9,"Enemy gait cannot retain the old half-second drawing holds")
	var wraith: CelActorVisual = visuals[2]
	var baseline := Vector2.ZERO
	for pose in ["float","charged","sword","hurt"]:
		for tick in range(10):
			wraith.update_pose(0.1,pose,1,Vector2.ZERO,false,0.5,0.5)
			var image: Image = wraith.sprite.sprite_frames.get_frame_texture(wraith.current_clip,wraith.current_frame).get_image()
			var sum := Vector2.ZERO
			var count: int = 0
			for y in range(image.get_height()):
				for x in range(image.get_width()):
					var p: Color = image.get_pixel(x,y)
					if p.a>0.5 and p.r>0.647 and p.g>0.529 and p.b>0.412:
						sum += Vector2(x,y)
						count += 1
			assert(count>20,"Mask has measurable ivory face pixels")
			var center: Vector2 = wraith.body_pivot.transform*(wraith.sprite.position+sum/float(count)*wraith.sprite.scale)
			if baseline==Vector2.ZERO: baseline=center
			assert(center.distance_to(baseline)<3.5,"Cloth shape cannot displace the mask between hover/attack/hurt drawings")
	root.get_node("Audio").shutdown()
	for visual in visuals: visual.queue_free()
	await process_frame
	print("PASS: eight distance-clocked gait drawings, bounded frame holds, stable feet and registered hover/action mask")
	quit()
