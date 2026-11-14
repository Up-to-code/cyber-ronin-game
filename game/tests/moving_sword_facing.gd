extends SceneTree
var p: CharacterBody2D
func _initialize():call_deferred("run")
func ticks(n: int):
 for i in range(n):await physics_frame;await process_frame
func tap(action: String):
 Input.action_press(action);await ticks(1);Input.action_release(action)
func run():
 create_timer(20,true,false,true).timeout.connect(func():push_error("moving sword timeout");quit(1))
 var floor_body:=StaticBody2D.new()
 floor_body.position=Vector2(1500,650)
 var shape:=RectangleShape2D.new();shape.size=Vector2(6000,40)
 var col:=CollisionShape2D.new();col.shape=shape;col.position.y=20;floor_body.add_child(col);root.add_child(floor_body)
 p=load("res://actors/player_2d.gd").new();p.position=Vector2(1500,650);p.map_width=6000;root.add_child(p)
 await ticks(5)
 Input.action_press("move_right");await tap("attack")
 assert(p.sword_motion=="moving_sword")
 await ticks(3)
 Input.action_release("move_right");Input.action_press("move_left")
 await ticks(1)
 assert(p.attack_time>0 and p.facing==-1 and p.rig.sprite.flip_h,"A must turn visible actor during active J")
 await tap("attack")
 var turn_wait:=0
 while p.combo_step<2 and turn_wait<50:await ticks(1);turn_wait+=1
 assert(p.combo_step==2 and p.sword_motion=="turn_sword","Reversal plus queued J selects the return sweep")
 p._update_rig(0)
 assert(p.rig.current_clip=="turn_sword2")
 await ticks(10)
 assert(p.velocity.x<0,"Attack drive must not push against reverse input")
 Input.action_release("move_left")
 await ticks(45)
 # Hold A, tap J repeatedly: all four phases must resolve distinct profiles.
 Input.action_press("move_left");await ticks(20)
 var clips: Array[String]=[]
 for step in range(1,5):
  await tap("attack")
  var limit:=0
  while p.combo_step!=step and limit<50:await ticks(1);limit+=1
  assert(p.combo_step==step and p.sword_motion=="drive_sword")
  p._update_rig(0)
  clips.append(p.rig.current_clip)
  while not p.attack_hit:await ticks(1)
  assert(p.attack_aim.x<0,"Visible facing and damage aim must agree")
 assert(clips==["drive_sword","drive_sword2","drive_sword3","drive_sword4"])
 Input.action_release("move_left");await ticks(50)
 assert(p.combo_window_left==0)
 await tap("attack")
 assert(p.combo_step==1 and p.sword_motion=="sword")
 await ticks(40)
 # Air attack may reverse too, without resetting animation phase.
 await tap("jump");await tap("attack")
 var before: float=p.attack_time
 Input.action_press("move_right");await ticks(1)
 assert(p.sword_motion=="air_sword" and p.facing==1 and p.attack_time<before)
 Input.action_release("move_right")
 root.get_node("Audio").shutdown()
 print("PASS: active J turning, reverse drive, hold-A four distinct clips, hit aim, reset and air reversal")
 quit()
