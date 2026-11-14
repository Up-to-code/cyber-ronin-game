extends SceneTree
var effects: Array[String] = []
func _initialize():call_deferred("run")
func ticks(count: int):
	for i in range(count):await physics_frame;await process_frame
func tap(action: String):
	Input.action_press(action);await ticks(1);Input.action_release(action)
func platform(at: Vector2, width: float, one_way: bool) -> StaticBody2D:
	var body:=StaticBody2D.new()
	body.position=at
	var collider:=CollisionShape2D.new()
	var shape:=RectangleShape2D.new()
	shape.size=Vector2(width,20)
	collider.shape=shape
	collider.position.y=10
	collider.one_way_collision=one_way
	body.add_child(collider)
	root.add_child(body)
	return body
func run():
	create_timer(25,true,false,true).timeout.connect(func():push_error("Combat expansion timeout");quit(1))
	platform(Vector2(1000,650),2200,false)
	var shelf:=platform(Vector2(500,430),300,true)
	var player=load("res://actors/player_2d.gd").new();player.position=Vector2(300,650);root.add_child(player)
	player.invulnerable=999
	var enemy=load("res://actors/enemy_2d.gd").new();enemy.position=Vector2(368,650);root.add_child(enemy)
	enemy.health=2000;enemy.configure_health_display();enemy.set_physics_process(false)
	player.fx_requested.connect(func(kind: String,_at: Vector2,_direction: float):effects.append(kind))
	await ticks(5)
	for step in range(1,5):
		await tap("attack")
		var tries:=0
		while player.combo_step!=step and tries<50:await ticks(1);tries+=1
		assert(player.combo_step==step,"Every new tap must advance one combo step")
		await ticks(2)
		player._update_rig(0)
		assert(player.rig.current_clip=="sword%d"%step,"Each strike must use its own clip")
	await ticks(40)
	assert(enemy.health==1803,"Four taps must deal exactly 35+42+55+65 once each")
	for kind in ["slash","slash_reverse","finisher","sweep"]:assert(kind in effects)
	assert(enemy.health_display.current==1803 and enemy.health_display.maximum==2000)
	await ticks(35)
	await tap("attack")
	assert(player.combo_step==1,"A late tap starts a fresh combo")
	await ticks(40)
	Input.action_press("move_right");await ticks(10)
	var slide_start: float=player.position.x
	await tap("move_down")
	assert(player.slide_left>0 and player.rig.current_state=="slide")
	assert(player.crouch_collider.shape.height==48)
	await ticks(12)
	assert(player.position.x>slide_start+75,"Slide travels faster than a run")
	assert("run_wind" in effects and "slide_wind" in effects,"Running and sliding have separate air trails")
	await tap("jump")
	assert(player.slide_left==0 and player.velocity.y<0,"Jump cancels the slide without eating input")
	Input.action_release("move_right")
	await tap("move_down")
	await ticks(4)
	assert(player.fast_falling and player.velocity.y>400)
	await ticks(30)
	player.position=Vector2(500,430);player.velocity=Vector2.ZERO;player.reset_motion_presentation();player.invulnerable=999
	await ticks(8)
	assert(player.is_on_floor())
	await tap("move_down")
	assert(shelf in player.dropped_platforms and player.velocity.y>0)
	await ticks(38)
	assert(player.is_on_floor() and absf(player.position.y-650)<2,"Shelf drop must land on solid floor")
	assert(player.dropped_platforms.is_empty(),"Temporary collision exceptions restore")
	await tap("move_down")
	assert(player.is_on_floor() and player.dropped_platforms.is_empty(),"Down never tunnels through solid ground")
	var fx=load("res://systems/pixel_fx.gd").new();root.add_child(fx)
	var fragments: Array=[]
	enemy.fragments_requested.connect(func(actor: Node2D,direction: float):fragments.append(actor);fx.shatter(actor.rig,actor.position,direction))
	enemy.receive_hit(3000,"kick",1,enemy.position)
	assert(fragments.size()==1 and not enemy.health_display.visible)
	assert(fx.get_child_count()==1 and fx.get_child(0).fragments.size()==6)
	enemy.receive_hit(3000,"kick",1,enemy.position)
	assert(fragments.size()==1,"Death fragments emit once")
	await ticks(55)
	assert(fx.get_child_count()==0,"Fragments clean up")
	root.get_node("Audio").shutdown()
	print("PASS: four distinct taps/clips/contacts, combo reset, slide/cancel, fast fall, safe shelf drop and collision restoration, health updates, one-shot death fragments and cleanup")
	quit()
