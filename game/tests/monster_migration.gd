extends SceneTree
class Victim extends CharacterBody2D:
	var health := 10000
	var power := 100.0
	func take_damage(amount: int, _direction: float) -> void: health -= amount
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok: failures += 1; push_error(message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var victim := Victim.new()
	root.add_child(victim)
	victim.position = Vector2(100,200)
	var names := {}; var profiles := {}; var contracts := {}
	var roster = preload("res://data/monster_roster.gd")
	for id in range(1,101):
		var r: Dictionary = roster.get_monster(id)
		names[r.name]=true; profiles[r.profile]=true; contracts[r.skill_contract]=true
		var enemy = preload("res://actors/enemy_2d.gd").new()
		root.add_child(enemy); enemy.set_physics_process(false)
		enemy.position=Vector2(60,200);enemy.target=victim;enemy.apply_monster_profile(id)
		check(enemy.rig.profile_id == r.profile,"Profile failed %d"%id)
		enemy.contract.cast()
		check(enemy.contract.marks.size()>0 and enemy.contract.marks.size()<=12,"Missing/capped attack %d"%id)
		var before: int = victim.health
		# Move into a real scheduled rectangle, verify it cannot hit before its tell.
		var mark: Dictionary = enemy.contract.marks[0]
		victim.position=mark.at+Vector2(0,45)
		enemy.contract._physics_process(.01)
		check(victim.health==before,"Early damage %d"%id)
		enemy.contract._physics_process(3)
		check(victim.health<before,"No contact damage %d"%id)
		enemy.free();victim.position=Vector2(100,200)
	check(names.size()==100 and profiles.size()==100 and contracts.size()==100,"Roster uniqueness")
	var mother = preload("res://actors/enemy_2d.gd").new()
	root.add_child(mother);mother.set_physics_process(false);mother.is_boss=true;mother.apply_monster_profile(10)
	var record := {"brood":0,"defeated":false}
	mother.brood_requested.connect(func(specs): record.brood=specs.size();check(not record.defeated,"Brood must precede defeat"))
	mother.defeated.connect(func():record.defeated=true)
	mother.receive_hit(99999,"power",1,mother.position)
	check(record.brood==6 and record.defeated,"Mother brood lifecycle")
	print("MONSTER_MIGRATION failures=",failures," profiles=",profiles.size()," contracts=",contracts.size())
	quit(failures)
