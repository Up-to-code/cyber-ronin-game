extends SceneTree
func _initialize(): call_deferred("run")
func run():
 var scene=load("res://scenes/main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 scene._choose_level(11)
 await scene.level_loaded
 var machine=scene.sequence_machine
 assert(is_instance_valid(machine))
 assert(not scene._objectives_met())
 machine.phase="input"
 machine.remaining=40
 machine.submit("move_up")
 machine.submit("move_down")
 assert(machine.step==0 and machine.remaining==40)
 for action in machine.SEQUENCE: machine.submit(action)
 assert(machine.phase=="fire")
 machine._physics_process(2)
 machine._physics_process(2)
 assert(machine.phase=="done" and scene.player.is_physics_processing())
 machine.phase="input"
 machine.remaining=0.01
 machine._physics_process(0.1)
 assert(scene.player.health==0 and machine.phase=="failed")
 root.get_node("Audio").shutdown()
 print("PASS machine reset, strict sequence, firing, release and timeout death")
 quit()
