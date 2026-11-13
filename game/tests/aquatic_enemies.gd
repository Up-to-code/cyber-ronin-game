extends SceneTree
class Victim extends CharacterBody2D:
	var health := 10000
	func take_damage(amount: int,_f: float) -> void: health-=amount
var failures := 0
func check(ok: bool,label: String) -> void:
	if not ok: failures+=1;push_error(label)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var victim:=Victim.new();root.add_child(victim);victim.position=Vector2(330,360)
	for role in ["jelly","eel","crab"]:
		var enemy=preload("res://actors/enemy_2d.gd").new()
		enemy.swimming=true;enemy.swim_role=role;enemy.swim_bounds=Rect2(0,0,800,600)
		enemy.position=Vector2(180,240);root.add_child(enemy);enemy.set_physics_process(false)
		enemy.apply_monster_profile(81 if role=="jelly" else (46 if role=="eel" else 35));enemy.target=victim
		var evidence:Dictionary={"starts":0,"contacts":0}
		enemy.contract.action_started.connect(func(_id,_name):evidence.starts+=1)
		enemy.contract.damage_contact.connect(func(_id,_name,_hit):evidence.contacts+=1)
		var start:Vector2=enemy.position
		for i in range(360):
			enemy._swim_physics(1.0/60)
			enemy.contract._physics_process(1.0/60)
		check(evidence.starts>0 and evidence.contacts>0,"No floorless authored attack: "+role)
		check(enemy.position.distance_to(start)>10,"No swimming approach: "+role)
		check(enemy.swim_bounds.has_point(enemy.position),"Leash escaped: "+role)
		for mark in enemy.contract.marks:check(mark.element=="water","Nonwater hazard")
		enemy.health=0;enemy.contract._physics_process(.1)
		check(enemy.contract.marks.is_empty(),"Dead water hazards retained")
		enemy.free()
	print("AQUATIC_ENEMIES failures=",failures)
	quit(failures)
