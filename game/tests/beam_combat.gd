extends SceneTree
func _initialize():call_deferred("run")
func run():
 var player=load("res://actors/player_2d.gd").new()
 player.position=Vector2(100,300)
 root.add_child(player)
 player.set_physics_process(false)
 var enemies: Array=[]
 for x in [300,420,540]:
  var enemy=load("res://actors/enemy_2d.gd").new()
  enemy.position=Vector2(x,300)
  enemy.target=player
  root.add_child(enemy)
  enemy.set_physics_process(false)
  enemies.append(enemy)
 for tick in range(3):await physics_frame
 var beam=load("res://systems/telegraph_beam.gd").new()
 beam.owner_body=player
 beam.from_player=true
 beam.damage=20
 beam.position=Vector2(120,248)
 root.add_child(beam)
 for tick in range(2):await physics_frame
 assert(enemies[0].health==70,"No damage before warning ends")
 for tick in range(20):await physics_frame
 for enemy in enemies:assert(enemy.health==50,"Player beam pierces three targets once")
 var wall:=StaticBody2D.new()
 wall.collision_layer=1
 wall.position=Vector2(200,248)
 var shape:=CollisionShape2D.new()
 var rect:=RectangleShape2D.new()
 rect.size=Vector2(20,160)
 shape.shape=rect
 wall.add_child(shape)
 root.add_child(wall)
 for tick in range(3):await physics_frame
 var blocked=load("res://systems/telegraph_beam.gd").new()
 blocked.owner_body=player
 blocked.from_player=true
 blocked.damage=20
 blocked.position=Vector2(120,248)
 root.add_child(blocked)
 for tick in range(20):await physics_frame
 for enemy in enemies:assert(enemy.health==50,"Walls stop beam damage")
 wall.queue_free()
 for tick in range(3):await physics_frame
 enemies[0].hurt_left=0
 var hostile=load("res://systems/telegraph_beam.gd").new()
 hostile.owner_body=enemies[0]
 hostile.direction=Vector2.LEFT
 hostile.position=Vector2(300,248)
 root.add_child(hostile)
 for tick in range(10):await physics_frame
 assert(player.health==100,"Enemy warning must not deal damage")
 player.position.y=500
 for tick in range(45):await physics_frame
 assert(player.health==100,"Leaving locked beam aim must evade damage")
 player.position.y=300
 for tick in range(3):await physics_frame
 var aimed=load("res://systems/telegraph_beam.gd").new()
 aimed.owner_body=enemies[0]
 aimed.direction=Vector2.LEFT
 aimed.position=Vector2(300,248)
 root.add_child(aimed)
 for tick in range(55):await physics_frame
 assert(player.health==78,"Enemy beam damages once after telegraph")
 root.get_node("Audio").shutdown()
 print("PASS: beam warning, three-target piercing, single damage event, walls stop damage, enemy telegraph and evasion")
 quit()
