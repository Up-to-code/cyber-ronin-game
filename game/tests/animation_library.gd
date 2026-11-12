extends SceneTree
const Visual = preload("res://animation/cel_actor_visual.gd")
var failures: int = 0
func _initialize() -> void: call_deferred("_run")
func _check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _run() -> void:
	var actor := Visual.new()
	root.add_child(actor)
	await process_frame
	_check(actor.sprite is AnimatedSprite2D and actor.current_clip == "idle", "Cel visual must load the authored profile into AnimatedSprite2D")
	var first_rects: Array[Rect2] = []
	for variant in range(1,4):
		var spec: Dictionary = actor.get_attack_spec("sword",variant)
		actor.update_pose(0,"sword",1,Vector2.ZERO,true,spec.contact_progress+0.00001,0,variant)
		_check(actor.current_clip == "sword%d" % variant and actor.current_frame == spec.contact_frame, "Attack contact and visible authored frame must use the same phase")
		var chosen: int = actor.current_frame
		actor.update_pose(1.2,"sword",1,Vector2.ZERO,true,spec.contact_progress+0.00001,0,variant)
		_check(actor.current_frame == chosen and not actor.sprite.is_playing(), "Action presentation must not invent an independent timer")
		first_rects.append(actor.sprite.sprite_frames.get_frame_texture(actor.current_clip,0).region)
	_check(first_rects[0] != first_rects[1] and first_rects[1] != first_rects[2], "Three sword actions must refer to distinct authored drawings")
	actor.update_pose(0,"idle",1,Vector2.ZERO,true)
	var positive: Vector2 = actor.socket("hand")
	var root_in_pivot: Vector2 = Vector2(0,float(actor.profile.body_center_height))
	var origin: Array = actor.profile.feet_origin
	_check((actor.body_pivot.transform * (actor.sprite.position + Vector2(origin[0],origin[1])*actor.sprite.scale)).length() < 0.001, "The fixed canvas feet anchor must map to actor root")
	actor.update_pose(0,"idle",-1,Vector2.ZERO,true)
	var negative: Vector2 = actor.socket("hand")
	_check(is_equal_approx(positive.x,-negative.x) and is_equal_approx(positive.y,negative.y), "Socket mirroring must use the same feet origin as the artwork")
	var slow := Visual.new()
	var fast := Visual.new()
	root.add_child(slow)
	root.add_child(fast)
	slow.update_pose(0.2,"run",1,Vector2(42,0),true)
	fast.update_pose(0.028,"run",1,Vector2(300,0),true)
	_check(slow.current_frame == fast.current_frame, "Equal travel at different velocities must select the same locomotion phase")
	var contacts: Array[int] = [0]
	fast.foot_contact.connect(func():contacts[0]+=1)
	fast.update_pose(0.6,"run",1,Vector2(300,0),true)
	_check(contacts[0] == 2, "One stride must emit exactly its two declared contact events even across skipped frames")
	var profile: Dictionary = actor.profile.duplicate(true)
	profile.clips.kick["feet_origin"] = [64,112]
	profile.clips.kick["sockets"] = {"foot":[75,110]}
	profile.clips.kick.frames[0]["sockets"] = {"hand":[68,80]}
	var path: String = "user://animation-library-test.json"
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_string(JSON.stringify(profile))
	file.close()
	_check(actor.configure(path), "Custom JSON profiles must load without changing code")
	actor.update_pose(0,"kick",1,Vector2.ZERO,true,0)
	_check(actor.socket("hand").is_equal_approx(Vector2(8,-64)) and actor.socket("foot").is_equal_approx(Vector2(22,-4)), "Frame sockets must override only named sockets while retaining per-clip sockets")
	_check(actor.sprite.scale == Vector2(2,2), "Per-clip origin changes must not stretch character art")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	actor.queue_free()
	slow.queue_free()
	fast.queue_free()
	await process_frame
	if failures == 0: print("PASS: controller-clocked authored contacts, distinct combos, stable feet origin, uniform scale, socket mirroring/overrides, distance gait events and custom profiles")
	quit(1 if failures else 0)
