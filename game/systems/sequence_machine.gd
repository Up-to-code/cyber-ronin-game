extends Node2D
# Level-owned encounter: pausing freezes both the timer and the lift.
class EncounterPanel extends Control:
	func _process(_delta: float) -> void:
		visible = not get_tree().paused

signal completed
const SEQUENCE = ["move_up","move_up","move_down","move_down","move_left","move_right","move_left","move_right","jump"]
const NAMES = ["UP","UP","DN","DN","LT","RT","LT","RT","JUMP"]
var player: CharacterBody2D
var phase := "idle"
var clock := 0.0
var remaining := 60.0
var step := 0
var lift := 0.0
var notice := "STAND ON PAD  •  2 SECONDS"
var font = preload("res://art/pixel/PixelifySans.ttf")
var panel: Control

func _ready() -> void:
	z_index = 5
	var layer := CanvasLayer.new()
	layer.layer = 15
	add_child(layer)
	panel = EncounterPanel.new()
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(panel)
	panel.draw.connect(_draw_panel)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player): return
	if phase == "idle":
		if player.health > 0 and absf(player.position.x-position.x)<44 and absf(player.position.y-position.y)<16 and player.is_on_floor():
			clock += delta
			if clock >= 2:
				phase = "rise"
				notice = "COCKPIT SEALED • RISING"
				clock = 0
				player.cancel_pending_input()
				player.set_physics_process(false)
		else: clock = 0
	elif phase == "rise":
		lift = move_toward(lift, 90, delta*60)
		if lift == 90:
			phase = "input"
			notice = "ENTER SEQUENCE • WRONG KEY RESTARTS"
	elif phase == "input":
		remaining = maxf(0, remaining-delta)
		if remaining == 0:
			phase = "failed"
			player.set_physics_process(true)
			player.invulnerable = 0
			player.take_damage(player.max_health)
	elif phase == "fire":
		clock += delta
		if clock >= 1.5:
			phase = "lower"
			notice = "TARGET DESTROYED • RETURNING"
	elif phase == "lower":
		lift = move_toward(lift,0,delta*90)
		if lift == 0:
			phase = "done"
			player.set_physics_process(true)
			player.velocity = Vector2.ZERO
			player.cancel_pending_input()
			completed.emit()
	if phase in ["rise","input","fire","lower"]:
		player.position = position+Vector2(0,-lift)
		player.velocity = Vector2.ZERO
	queue_redraw()
	panel.queue_redraw()

func _input(event: InputEvent) -> void:
	if phase != "input" or event.is_echo() or not event.is_pressed(): return
	for action in ["move_up","move_down","move_left","move_right","jump","attack","kick","dodge","interact","power_attack","ranged_attack"]:
		if event.is_action_pressed(action):
			submit(action)
			get_viewport().set_input_as_handled()
			return

func submit(action: String) -> void:
	if phase != "input": return
	if action != SEQUENCE[step]:
		step = 0
		notice = "ERROR • RESTART FROM UP • TIMER CONTINUES"
		return
	step += 1
	notice = "ACCEPTED • %d / 9" % step
	if step == SEQUENCE.size():
		phase = "fire"
		clock = 0
		notice = "LOCK CONFIRMED • FIRING"

func _draw() -> void:
	var top := -lift
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if lift > 0:
		draw_texture_rect(preload("res://art/crimson-gold/piston.png"),Rect2(-40,top,80,lift+8),false)
	draw_texture_rect(preload("res://art/crimson-gold/cockpit.png"),Rect2(-72,top-146,144,160),false)
	if phase in ["rise","input","fire","lower"]:
		draw_texture_rect(preload("res://art/crimson-gold/glass.png"),Rect2(-55,top-130,110,130),false,Color(1,1,1,0.32))
	if phase not in ["lower","done"]:
		draw_texture_rect(preload("res://art/crimson-gold/sentinel.png"),Rect2(110,-172,154,172),false)
	if phase == "fire":
		var target := Vector2(185,-122)
		draw_line(Vector2(48,top-68),target,Color("b51e35"),18)
		draw_line(Vector2(48,top-68),target,Color("ffcf48"),9)
		draw_line(Vector2(48,top-68),target,Color("fff3c7"),3)
		var frames := [preload("res://art/crimson-gold/impact0.png"),preload("res://art/crimson-gold/impact1.png"),preload("res://art/crimson-gold/impact2.png"),preload("res://art/crimson-gold/impact3.png")]
		draw_texture_rect(frames[mini(3,int(clock/0.3))],Rect2(target-Vector2(110,110),Vector2(220,220)),false)
	if phase == "idle":
		draw_string(font,Vector2(-76,-166),"HOLD PAD: 2s",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("ffe69b"))

func _draw_panel() -> void:
	if phase not in ["rise","input","fire","lower"]: return
	var w := minf(600,panel.size.x-24)
	var origin := Vector2((panel.size.x-w)/2, panel.size.y-116)
	panel.draw_style_box(preload("res://ui/pixel_menu_components.gd").frame(),Rect2(origin-Vector2(8,8),Vector2(w+16,120)))
	panel.draw_string(font,origin+Vector2(12,22),"SENTINEL OVERRIDE   %02d s" % ceili(remaining),HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color.WHITE)
	for i in range(NAMES.size()):
		var x := origin+Vector2(12+i*(w-24)/9,32)
		panel.draw_texture_rect(preload("res://art/crimson-gold/button_selected.png") if i==step else preload("res://art/crimson-gold/button.png"),Rect2(x,Vector2((w-32)/9,28)),false)
		panel.draw_string(font,x+Vector2(5,20),NAMES[i],HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("929298") if i<step else Color.WHITE)
	panel.draw_string(font,origin+Vector2(12,87),notice,HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color.WHITE)
