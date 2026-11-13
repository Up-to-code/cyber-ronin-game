extends SceneTree
var failures:=0
func check(ok: bool,msg: String) -> void:
	if not ok: failures+=1;push_error(msg)
func _initialize() -> void:call_deferred("run")
func run() -> void:
	for id in range(1,101):
		var enemy=preload("res://actors/enemy_2d.gd").new()
		enemy.is_boss=id%10==0
		enemy.scale=Vector2.ONE*(1.8 if enemy.is_boss else 1.0)
		root.add_child(enemy);enemy.set_physics_process(false);enemy.apply_monster_profile(id)
		var height:float=enemy.body_height*enemy.scale.y
		var width:float=enemy.body_width*enemy.scale.x
		check(height<=211 and width<=361,"Oversized body %d"%id)
		if not enemy.is_boss:check(height<=121 and width<=231,"Oversized normal %d"%id)
		check(enemy.health_display.position.y < -enemy.body_height,"Healthbar overlaps body %d"%id)
		check(enemy.body_collider.shape.height<=enemy.body_height,"Collider exceeds art %d"%id)
		var element:String=enemy.roster_spec.element
		for cue in ["cast","contact"]:check(ResourceLoader.exists("res://audio/monster-elements/%s_%s.wav"%[element,cue]),"Missing sound")
		enemy.free()
	print("MONSTER_ARTIST failures=",failures," bodies=100 sounds=12 patterns=20 elements=5")
	quit(failures)
