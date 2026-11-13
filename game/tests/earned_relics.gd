extends SceneTree
var p: CharacterBody2D
func _initialize():call_deferred("run")
func ticks(n: int):
 for i in range(n):await physics_frame;await process_frame
func device(kind: String, at: Vector2, extra: Dictionary={}):
 var d=load("res://systems/realm_device.gd").new()
 var record={"id":kind,"type":kind,"position":at};record.merge(extra)
 d.setup(p,record);root.add_child(d);return d
func run():
 create_timer(15,true,false,true).timeout.connect(func():quit(1))
 p=load("res://actors/player_2d.gd").new();p.position=Vector2(300,500);root.add_child(p);p.set_physics_process(false)
 var pedestal=device("relic_laser",p.position)
 var seal=device("laser_seal",p.position+Vector2(220,0))
 await ticks(3)
 assert(p.relic_charges.laser==1)
 p.power=0
 assert(p.use_relic_laser())
 assert(p.power==0 and p.relic_charges.laser==0,"Earned laser independent of power")
 assert(not p.use_relic_laser(),"Single earned charge")
 await ticks(22)
 assert(seal.solved and seal.collision_layer==0,"Laser opens solid seal")
 pedestal.cooldown=0;await ticks(2)
 assert(p.relic_charges.laser==1,"Spent shot can be replenished without retry")
 var anchor=device("cloud_anchor",p.position+Vector2(100,0),{"landings":[[450,460,140],[590,420,120]]})
 assert(not anchor.activate(),"Cannot grow bridge without earned seed")
 p.grant_relic("cloud");assert(anchor.activate())
 assert(anchor.platforms.size()==2 and p.relic_charges.cloud==0)
 assert(not anchor.activate(),"No duplicate platform accumulation")
 var portal=device("portal",p.position)
 assert(portal.activate() and not portal.activate(),"Portal cooldown prevents immediate repeated transition")
 p.power=27;p.health=61;p.grant_relic("cloud")
 p.attack_time=.4;p.plunging=true;p.fast_falling=true
 p.prepare_realm_transition()
 assert(p.attack_time==0 and not p.plunging and not p.fast_falling)
 assert(p.relic_charges.cloud==1 and p.power==27 and p.health==61,"Realm crossing preserves resources")
 p.reset_motion_presentation();assert(p.relic_charges.laser==0 and p.relic_charges.cloud==0)
 await ticks(2)
 assert(get_nodes_in_group("combat_projectiles").is_empty(),"Retry removes old beam before next level contact")
 root.get_node("Audio").shutdown()
 print("PASS: earned one-use beam, zero power cast, physical seal collision, replenishment, cloud bridge consumption, duplicate and portal cooldown guards, retry reset")
 quit()
