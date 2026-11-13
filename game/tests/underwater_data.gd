extends SceneTree
const Campaign=preload("res://data/campaign.gd")
func _initialize():
 var level:Dictionary=Campaign.get_level(8)
 assert(level.traversal=="swim" and level.vertical_route and level.mission=="seals")
 assert(level.water_bounds==Rect2(500,250,2400,1400))
 assert(not level.water_bounds.has_point(level.spawn) and not level.water_bounds.has_point(level.exit))
 var seals:Array=level.pickups.filter(func(p):return p.kind=="seal")
 assert(seals.size()==3)
 for pearl in seals:assert(level.water_bounds.has_point(pearl.position))
 assert(seals[1].position.y-seals[0].position.y>500)
 assert(level.water_currents.size()==3)
 for current in level.water_currents:assert(level.water_bounds.has_point(current.center) and current.radius>=180)
 assert(level.enemies[0].monster_id==8 and level.water_enemies.size()==5)
 for enemy in level.enemies:assert(enemy.swim and level.water_bounds.has_point(enemy.position))
 # Swept 44x84 body along the authored swim itinerary must clear real masonry.
 var points:Array=level.swim_waypoints
 assert(points[-1]==[2850.0,315.0],"Surface exit must support lateral water breach above dry deck")
 for i in range(points.size()-1):
  var a:=Vector2(points[i][0],points[i][1]);var b:=Vector2(points[i+1][0],points[i+1][1])
  for sample in range(101):
   var feet:Vector2=a.lerp(b,float(sample)/100)
   var body:=Rect2(feet-Vector2(22,84),Vector2(44,84))
   for wall in level.platforms:
    var solid:=Rect2(wall.center-Vector2(wall.width/2,0),Vector2(wall.width,wall.depth))
    assert(not body.intersects(solid),"Swim itinerary must clear solid castle walls")
 print("PASS flooded castle: 3 chamber pearls, 3 currents, 5 aquatic actors, dry endpoints and unobstructed swept swim itinerary")
 quit()
