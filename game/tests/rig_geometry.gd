extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var Rig = load("res://rig/rig_visual.gd")
	var rig: Node2D = Rig.new()
	root.add_child(rig)
	await process_frame
	assert(rig.skeleton is Skeleton2D and rig.bones.size() == 17, "Rig must expose real bone hierarchy")
	assert(rig.meshes.size() == 17, "Every body role must have a textured mesh")
	rig.update_pose(1,"idle",1,Vector2.ZERO,true)
	var before_hand: Vector2 = rig.socket("hand")
	var before_foot: Vector2 = rig.socket("foot")
	rig.update_pose(0,"kick",1,Vector2.ZERO,true,0.5)
	assert(rig.socket("hand").distance_to(before_hand) < 0.1 and rig.socket("foot").distance_to(before_foot) < 0.1, "Action boundary must preserve the previous targets before blending")
	for tick in range(6):
		rig.update_pose(0.016,"kick",1,Vector2.ZERO,true,0.5)
		for limb in rig.LIMBS:
			var a: Vector2 = rig.joints[limb]
			var b: Vector2 = rig.joints[limb+"_lower"]
			var c: Vector2 = rig.joints[limb+"_end"]
			assert(a.is_finite() and b.is_finite() and c.is_finite(), "Transition IK must remain finite")
			assert(absf(a.distance_to(b)-rig.bones[limb].get_length()) < 0.02 and absf(b.distance_to(c)-rig.bones[limb+"_lower"].get_length()) < 0.02, "Target blending must preserve both segment lengths")
	assert(rig.socket("foot").x > before_foot.x + 25, "Blended kick must arrive at its extended pose")
	for target in [Vector2(20,30),Vector2(0,80),Vector2(-30,8),Vector2.ZERO]:
		var chain: Array[Vector2] = Rig.solve_two_bone(Vector2.ZERO,target,28,29,-1)
		assert(absf(chain[0].length()-28) < 0.02)
		assert(absf(chain[1].distance_to(chain[0])-29) < 0.02)
	for phase in [0.0,0.1,0.3,0.5]:
		rig.phase = phase
		rig.motion_blend = 1
		rig.update_pose(0,"run",1,Vector2(300,0),true)
		assert(absf(rig.joints.front_leg_end.y + 8) < 0.1, "Stance foot must stay planted on fixed ankle line")
	rig.update_pose(1,"kick",1,Vector2.ZERO,true,0.5)
	assert(rig.socket("foot").x > 38 and rig.socket("foot").y < -35, "Kick must extend its actual foot, not just move a sprite")
	rig.external_roll = PI / 2
	rig.update_pose(0,"hurt",1,Vector2(100,-300),false,0,0.7)
	assert(rig.socket("chest").x > 10, "Air roll must rotate around body center")
	rig.external_roll = 0
	rig.configure("wraith")
	rig.update_pose(1,"idle",-1,Vector2.ZERO,false)
	assert(not rig.meshes.front_leg.visible and not rig.meshes.weapon.visible)
	rig.configure("ember_fire")
	rig.update_pose(1,"idle",1,Vector2.ZERO,true)
	assert(rig.meshes.front_leg.visible and rig.profile.id == "ember_fire")
	print("PASS: real bone/mesh hierarchy, target-blended transitions, analytic limb lengths/reach, planted stance, kick endpoint, center roll and skin/profile swap")
	rig.queue_free()
	await process_frame
	root.get_node("Audio").shutdown()
	quit()
