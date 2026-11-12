extends SceneTree
const Rules=preload("res://systems/world_rules.gd")
func _initialize() -> void:call_deferred("_run")
func _ticks(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func _run() -> void:
	create_timer(12,true,false,true).timeout.connect(func():quit(1))
	var normal: Dictionary=Rules.combat_response(35,"sword",1,70,1)
	var double_mass: Dictionary=Rules.combat_response(35,"sword",1,140,1)
	var braced: Dictionary=Rules.combat_response(35,"sword",1,140,2)
	assert(is_equal_approx(double_mass.velocity.x,normal.velocity.x*.5))
	assert(is_equal_approx(braced.velocity.x,double_mass.velocity.x*.5))
	assert(is_equal_approx(double_mass.ground_stop_distance,normal.ground_stop_distance*.25))
	assert(Rules.combat_response(70,"sword",1,70,1).velocity.x>normal.velocity.x)
	assert(Rules.combat_response(35,"sword",-1,70,1).velocity.x==-normal.velocity.x)
	assert(Rules.combat_response(0,"sword",1).velocity==Vector2.ZERO)
	assert(Rules.combat_response(90,"power",1,600,3).velocity.x<normal.velocity.x*.25)
	var world:=Node2D.new();root.add_child(world)
	var floor_body:=StaticBody2D.new();var collider:=CollisionShape2D.new();var shape:=RectangleShape2D.new()
	shape.size=Vector2(3000,80);collider.shape=shape;floor_body.add_child(collider);floor_body.position=Vector2(1000,650);world.add_child(floor_body)
	var enemies: Array=[]
	for i in range(3):
		var enemy: Node=load("res://actors/enemy_2d.gd").new();enemy.position=Vector2(600+i*300,610);world.add_child(enemy)
		enemy.mass_kg=70 if i==0 else 140;enemy.knockback_resistance=2 if i==2 else 1;enemies.append(enemy)
	await _ticks(5)
	var starts: Array=[]
	for enemy in enemies:
		starts.append(enemy.position.x);enemy.receive_hit(35,"sword",1,enemy.position+Vector2(0,-45));enemy.hurt_left=2
	await _ticks(40)
	var distances: Array=[]
	for i in range(3):
		distances.append(enemies[i].position.x-starts[i]);enemies[i].set_physics_process(false)
	assert(distances[0]>distances[1] and distances[1]>distances[2] and distances[2]>0,"Actual body travel must decrease with mass and bracing")
	var player: Node=load("res://actors/player_2d.gd").new();player.position=Vector2(200,610);world.add_child(player);player.invulnerable=999
	var target: Node=load("res://actors/enemy_2d.gd").new();target.position=Vector2(268,610);world.add_child(target);target.health=1000;target.set_physics_process(false)
	await _ticks(5)
	Input.action_press("attack");await _ticks(1);Input.action_release("attack");await _ticks(3)
	var first_duration: float=player.attack_duration
	Input.action_press("attack");await _ticks(1);Input.action_release("attack")
	var elapsed: int=5
	while player.combo_step<2 and elapsed<40:
		await _ticks(1);elapsed+=1
	assert(player.combo_step==2 and elapsed/60.0<first_duration,"A real second tap must chain after active cels, before full recovery")
	await _ticks(35)
	assert(target.health==923,"Rapid double tap must deal exactly 35 + 42 damage, not repeat or drop a cut")
	player.set_physics_process(false)
	player.rig.update_pose(0,"idle",1,Vector2.ZERO,true)
	var before_scale: Vector2=player.rig.sprite.scale
	player.rig.update_pose(.6,"idle",1,Vector2.ZERO,true)
	assert(player.rig.sprite.scale.distance_to(before_scale)>.005,"Idle must breathe")
	assert(player.rig.feet_local().length()<.01,"Breathing must keep foot contact fixed")
	var arc: Node=load("res://systems/combo_sweep.gd").new();world.add_child(arc)
	for dir in [-1,1]:
		arc.direction=dir
		for i in range(25):
			var point: Vector2=arc.edge_point(lerpf(-PI/2,PI/2,float(i)/24))
			assert(point.y-62<=-8 and point.x*dir>=0,"The half-shell must clear the ground and face the hit direction")
	await _ticks(20)
	assert(not is_instance_valid(arc))
	root.get_node("Audio").shutdown()
	print("PASS: global damage/mass/resistance recoil, physical travel %s, buffered double tap at %.3fs, 77 damage, idle foot anchor and half-shell ground clearance"%[distances,elapsed/60.0])
	quit()
