extends SceneTree
var failures:=0
func _initialize():call_deferred("run")
func tick():await physics_frame;await process_frame
func run():
 create_timer(600,true,false,true).timeout.connect(func():push_error("AI timing timeout");quit(1))
 var floor=StaticBody2D.new();floor.position=Vector2(600,550);var col=CollisionShape2D.new();var box=RectangleShape2D.new();box.size=Vector2(2200,80);col.shape=box;col.position.y=40;floor.add_child(col);root.add_child(floor)
 var player=load("res://actors/player_2d.gd").new();root.add_child(player);player.set_physics_process(false);player.position=Vector2(650,550);player.invulnerable=999
 for id in range(1,101):
  var spec=preload("res://data/monster_roster.gd").get_monster(id)
  var enemy=load("res://actors/enemy_2d.gd").new();enemy.enemy_kind=spec.kind;enemy.position=Vector2(500,550);enemy.target=player;enemy.is_boss=id%10==0;root.add_child(enemy);enemy.apply_monster_profile(id)
  var contract=enemy.contract;var record=contract.get_choreography()
  var observed={"started":false,"contacts":0,"early":false}
  contract.action_started.connect(func(_id,_move):observed.started=true)
  contract.damage_contact.connect(func(_id,_event,_hit):
   observed.contacts+=1
   if contract.current_action_time<float(record.motion.windup)-.025:observed.early=true)
  for i in range(360):
   await tick()
   if observed.started and not contract.action_active:break
  if not observed.started or observed.contacts==0 or observed.early:
   failures+=1;push_error("AI timing failed %d state%s"%[id,observed])
  assert(is_instance_valid(enemy.motion_visual))
  # A new action interrupted by damage cannot release a delayed stale attack.
  contract.cast();enemy.receive_hit(1,"sword",1,enemy.position)
  assert(not contract.action_active)
  enemy.queue_free();await tick()
 root.get_node("Audio").shutdown();print("AI_TIMING100 failures=",failures," real AI initiation, tell before contact, interrupted strike cancellation");quit(1 if failures else 0)
