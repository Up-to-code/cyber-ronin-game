extends SceneTree
const Roster=preload("res://data/monster_roster.gd")
const Enemy=preload("res://actors/enemy_2d.gd")
func _initialize():call_deferred("run")
func run():
 var names: Dictionary={}
 var tactics: Dictionary={}
 for spec in Roster.all():
  assert(not names.has(spec.name))
  names[spec.name]=true
  tactics[spec.behavior]=true
  var enemy=Enemy.new()
  enemy.enemy_kind=spec.kind
  root.add_child(enemy)
  enemy.set_physics_process(false)
  enemy.apply_monster_profile(spec.id)
  assert(enemy.monster_id==spec.id and enemy.monster_name==spec.name)
  assert(enemy.rig.profile_id==spec.profile)
  assert(enemy.health>0 and enemy.windup_duration>0.15)
  assert(enemy.health_display.current==enemy.health)
  if spec.behavior=="bulwark":
   var initial: int=enemy.health
   enemy.receive_hit(20,"sword",-enemy.facing,enemy.position)
   assert(enemy.health==initial-11,"Frontal armor reduces light attacks")
   initial=enemy.health
   enemy.receive_hit(20,"kick",-enemy.facing,enemy.position)
   assert(enemy.health==initial-20,"Kick bypasses armor")
  if spec.behavior=="berserker":
   enemy.health=enemy.max_health/2
   var speed: float=enemy.approach_speed
   enemy._physics_process(0.01)
   assert(enemy.enraged and enemy.approach_speed>speed)
   enemy._physics_process(0.01)
   assert(is_equal_approx(enemy.approach_speed,speed*1.5),"Enrage applies once")
  if spec.behavior=="bloodmender":
   enemy.health=enemy.max_health-20
   enemy.tactic_clock=3
   enemy._physics_process(0.01)
   assert(enemy.health==enemy.max_health-12)
  enemy.free()
 assert(names.size()==100 and tactics.size()==10)
 var boss=Enemy.new()
 root.add_child(boss)
 boss.is_boss=true;boss.health=777
 boss.apply_monster_profile(100)
 assert(boss.health==777,"Roster preserves authored boss health")
 boss.free()
 root.get_node("Audio").shutdown()
 print("PASS: 100 unique roster identities load, 10 doctrines, 8 art families, frontal armor/counter, one-shot enrage, capped healing, boss health preservation")
 quit()
